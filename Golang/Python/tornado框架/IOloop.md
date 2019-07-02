# 构造方法

```python
class IOLoop(object):
    # Constants from the epoll module
    _EPOLLIN = 0x001
    _EPOLLPRI = 0x002
    _EPOLLOUT = 0x004
    _EPOLLERR = 0x008
    _EPOLLHUP = 0x010
    _EPOLLRDHUP = 0x2000
    _EPOLLONESHOT = (1 << 30)
    _EPOLLET = (1 << 31)

    # Our events map exactly to the epoll events
    NONE = 0
    READ = _EPOLLIN
    WRITE = _EPOLLOUT
    # socket 是否关闭: 正常关闭或异常关闭
    ERROR = _EPOLLERR | _EPOLLHUP | _EPOLLRDHUP

    def __init__(self, impl=None):
        # self._impl 是 ioloop 对象
        # or 这里避免了使用三元表达式的语法
        self._impl = impl or _poll()
        if hasattr(self._impl, 'fileno'):
            self._set_close_exec(self._impl.fileno())
        # 存放fd 和 对应 事件处理函数 func 的对应关系
        self._handlers = {}
        self._events = {}
        # ioloop 的回调，里面存放wrap后的回调函数
        self._callbacks = []
        # ioloop 的和时间相关的任务，里面存放特定的对象
        self._timeouts = []
        # 标识 ioloop 正在运行与否
        self._running = False
        # 标识ioloop 停止
        self._stopped = False
        self._blocking_signal_threshold = None

        # Create a pipe that we send bogus data to when we want to wake
        # the I/O loop when it is idle

        # windows 系统
        if os.name != 'nt':
            r, w = os.pipe()
            self._set_nonblocking(r)
            self._set_nonblocking(w)
            self._set_close_exec(r)
            self._set_close_exec(w)
            self._waker_reader = os.fdopen(r, "rb", 0)
            self._waker_writer = os.fdopen(w, "wb", 0)
        else:
            self._waker_reader = self._waker_writer = win32_support.Pipe()
            # reader_fd 其实就是 fileno()
            r = self._waker_writer.reader_fd
        self.add_handler(r, self._read_waker, self.READ)
```

# _read_waker

```python
def _read_waker(self, fd, events):
    try:
        while True:
            self._waker_reader.read()
    except IOError:
        pass
```

# instance

```python
@classmethod
def instance(cls):
    if not hasattr(cls, "_instance"):
        cls._instance = cls()
    return cls._instance
```

# add_handler

```python
def add_handler(self, fd, handler, events):
    """Registers the given handler to receive the given events for fd."""
    self._handlers[fd] = stack_context.wrap(handler)
    self._impl.register(fd, events | self.ERROR)
```

# remove_handler

```python
def remove_handler(self, fd):
    """Stop listening for events on fd."""
    self._handlers.pop(fd, None)
    self._events.pop(fd, None)
    try:
        self._impl.unregister(fd)
    except (OSError, IOError):
        logging.debug("Error deleting fd from IOLoop", exc_info=True)
```

# start

```python
def start(self):
    """Starts the I/O loop.

    The loop will run until one of the I/O handlers calls stop(), which
    will make the loop stop after the current event iteration completes.
    """
    if self._stopped:
        self._stopped = False
        return
    # self._running: False 也把ioloop给停止
    self._running = True
    while True:
        # Never use an infinite timeout here - it can stall epoll
        poll_timeout = 0.2

        # Prevent IO event starvation by delaying new callbacks
        # to the next iteration of the event loop.
        callbacks = self._callbacks
        self._callbacks = []
        for callback in callbacks:
            self._run_callback(callback)

        if self._callbacks:
            poll_timeout = 0.0

        if self._timeouts:
            now = time.time()
            # 这个循环是一个小技巧，过期任务
            while self._timeouts and self._timeouts[0].deadline <= now:
                timeout = self._timeouts.pop(0)
                self._run_callback(timeout.callback)
            if self._timeouts:
                milliseconds = self._timeouts[0].deadline - now
                # 取最小的时间间隔
                poll_timeout = min(milliseconds, poll_timeout)
        # 把self._callback 和 self._timeouts 运行一部分再停止
        if not self._running:
            break

        if self._blocking_signal_threshold is not None:
            # clear alarm so it doesn't fire while poll is waiting for
            # events.
            signal.setitimer(signal.ITIMER_REAL, 0, 0)

        try:
            event_pairs = self._impl.poll(poll_timeout)
        except Exception, e:
            # Depending on python version and IOLoop implementation,
            # different exception types may be thrown and there are
            # two ways EINTR might be signaled:
            # * e.errno == errno.EINTR
            # * e.args is like (errno.EINTR, 'Interrupted system call')
            if (getattr(e, 'errno', None) == errno.EINTR or
                (isinstance(getattr(e, 'args', None), tuple) and
                 len(e.args) == 2 and e.args[0] == errno.EINTR)):
                continue
            else:
                raise

        if self._blocking_signal_threshold is not None:
            signal.setitimer(signal.ITIMER_REAL,
                             self._blocking_signal_threshold, 0)

        # Pop one fd at a time from the set of pending fds and run
        # its handler. Since that handler may perform actions on
        # other file descriptors, there may be reentrant calls to
        # this IOLoop that update self._events
        self._events.update(event_pairs)
        # 使用while + popitem 替代循环: 防止remove_handle等方法对self._events的影响
        while self._events:
            fd, events = self._events.popitem()
            try:
                self._handlers[fd](fd, events)
            except (KeyboardInterrupt, SystemExit):
                raise
            except (OSError, IOError), e:
                if e.args[0] == errno.EPIPE:
                    # Happens when the client closes the connection
                    pass
                else:
                    logging.error("Exception in I/O handler for fd %d",
                                  fd, exc_info=True)
            except:
                logging.error("Exception in I/O handler for fd %d",
                              fd, exc_info=True)
    # reset the stopped flag so another start/stop pair can be issued
    self._stopped = False
    if self._blocking_signal_threshold is not None:
        signal.setitimer(signal.ITIMER_REAL, 0, 0)
```

# stop

```python
def stop(self):
    self._running = False
    self._stopped = True
    # 唤醒ioloop，让设置的self._running 和 self._stopped 起作用
    self._wake()
```

# add_timeout

```python
def add_timeout(self, deadline, callback):
    # 对 self._timeouts 列表操作
    timeout = _Timeout(deadline, stack_context.wrap(callback))
    bisect.insort(self._timeouts, timeout)
    return timeout
```

# add_callback

```python
def add_callback(self, callback):
    # 添加回调函数
    self._callbacks.append(stack_context.wrap(callback))
    # 让阻塞的ioloop立即去执行我们添加的回调函数
    self._wake()
```

# _wake

```python
def _wake(self):
    # 唤醒阻塞的事件循环
    try:
        self._waker_writer.write("x")
    except IOError:
        pass
```

# _run_callback

```python
def _run_callback(self, callback):
    # 运行callback函数，并做异常处理
    try:
        callback()
    except (KeyboardInterrupt, SystemExit):
        raise
    except:
        # TODO 就一个logging打印都封装成一个函数？可能是为了调用少写一点代码，另外语义更加明确把
        self.handle_callback_exception(callback)
```

# handle_callback_exception

```python
def handle_callback_exception(self, callback):
    logging.error("Exception in callback %r", callback, exc_info=True)
```