IOStream类其实就是为了处理conn这个socket的读写的，重要的是这个读写是异步的。先看构造方法：

```python
class IOStream(object):
    """A utility class to write to and read from a non-blocking socket.

    We support three methods: write(), read_until(), and read_bytes().
    All of the methods take callbacks (since writing and reading are
    non-blocking and asynchronous). read_until() reads the socket until
    a given delimiter, and read_bytes() reads until a specified number
    of bytes have been read from the socket.

    The socket parameter may either be connected or unconnected.  For
    server operations the socket is the result of calling socket.accept().
    For client operations the socket is created with socket.socket(),
    and may either be connected before passing it to the IOStream or
    connected with IOStream.connect.

    A very simple (and broken) HTTP client using this class:

        from tornado import ioloop
        from tornado import iostream
        import socket

        def send_request():
            stream.write("GET / HTTP/1.0\r\nHost: friendfeed.com\r\n\r\n")
            stream.read_until("\r\n\r\n", on_headers)

        def on_headers(data):
            headers = {}
            for line in data.split("\r\n"):
               parts = line.split(":")
               if len(parts) == 2:
                   headers[parts[0].strip()] = parts[1].strip()
            stream.read_bytes(int(headers["Content-Length"]), on_body)

        def on_body(data):
            print data
            stream.close()
            ioloop.IOLoop.instance().stop()

        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0)
        stream = iostream.IOStream(s)
        stream.connect(("friendfeed.com", 80), send_request)
        ioloop.IOLoop.instance().start()

    """
    def __init__(self, socket, io_loop=None, max_buffer_size=104857600,
                 read_chunk_size=4096):
        # iostream 包装了一个非阻塞的socket
        self.socket = socket
        self.socket.setblocking(False)
        self.io_loop = io_loop or ioloop.IOLoop.instance()
        # 缓冲区的大小, 包括发送缓冲和读缓冲
        self.max_buffer_size = max_buffer_size
        # 每一次recv的size
        self.read_chunk_size = read_chunk_size
        # 分配读和写两个缓冲区
        # 写: 有发送的需求时，先把数据写到_write_buffer,有合适的时机再把_write_buffer数据发送出去
        self._read_buffer = collections.deque()
        self._write_buffer = collections.deque()
        self._write_buffer_frozen = False
        # 读取数据截止符
        self._read_delimiter = None
        # 已读数据长度
        self._read_bytes = None
        # 对应socket四个不同状态的回调
        self._read_callback = None
        self._write_callback = None
        self._close_callback = None
        self._connect_callback = None
        # 发起连接
        self._connecting = False
        # 初始监听的事件是error
        self._state = self.io_loop.ERROR
        # TODO 这里为什么使用NullContext(), self._handle_events 不需要上下文？
        with stack_context.NullContext():
            self.io_loop.add_handler(
                self.socket.fileno(), self._handle_events, self._state)
```

构造方法接收两个参数，sokcet和ioloop。IOStream既可以给服务端使用也可以给客户端使用，根据socket的不同就可以扮演不同的角色。

IOstream有两个缓冲区，比如说需要write的时候，先把数据发到缓冲区，然后再进行调度。

在构造方法里就注册ioloop监听事件。

# 服务端角色

## reading and writing

```python
def reading(self):
    """Returns true if we are currently reading from the stream."""
    return self._read_callback is not None

def writing(self):
    """Returns true if we are currently writing to the stream."""
    return bool(self._write_buffer)
```

## _read_from_socket

```python
def _read_from_socket(self):
    """Attempts to read from the socket.

    Returns the data read or None if there is nothing to read.
    May be overridden in subclasses.
    """
    try:
        chunk = self.socket.recv(self.read_chunk_size)
    except socket.error, e:
        # 数据没有准备好，那么就会满足这个条件返回None
        if e.args[0] in (errno.EWOULDBLOCK, errno.EAGAIN):
            # 在这里就return了，不需要使用chunk = None 最后再return chunk的方式
            return None
        else:
            raise
    # 对端close socket, 这时也应该关闭该端的socket
    if not chunk:
        self.close()
        return None
    return chunk
```

负责从socket里面对数据,  至于数据准备好没有是上层调用控制的,  返回None或读取到的数据chunk.

## _read_to_buffer

```python
def _read_to_buffer(self):
    """Reads from the socket and appends the result to the read buffer.

    Returns the number of bytes read.  Returns 0 if there is nothing
    to read (i.e. the read returns EWOULDBLOCK or equivalent).  On
    error closes the socket and raises an exception.
    """
    try:
        chunk = self._read_from_socket()
    except socket.error, e:
        # ssl.SSLError is a subclass of socket.error
        # socket 读取数据报错，其实是_read_from_socket中raise的错误
        logging.warning("Read error on %d: %s",
                        self.socket.fileno(), e)
        self.close()
        raise
    # socket 没有准备好，往buffer里面添加的数据长度为0
    if chunk is None:
        return 0
    self._read_buffer.append(chunk)
    if self._read_buffer_size() >= self.max_buffer_size:
        logging.error("Reached maximum read buffer size")
        self.close()
        raise IOError("Reached maximum read buffer size")
    return len(chunk)
```

本质就是往_read_buffer 放值, 返回len(value).  方法每调用一次就只放一个chunk。

## _read_from_buffer

```python
def _read_from_buffer(self):
    """Attempts to complete the currently-pending read from the buffer.

    Returns True if the read was completed.
    """

    # _read_from_buffer 是根据两个判断标准来确定需要读取多少数据
    # 一 是根据结尾符号比如说 "\r\n\r\n" 作为结尾
    # 二 是根据需要读取的字符数为依据

    if self._read_bytes:
        # 缓冲区有你需要的长度的数据才开始读取，长度不够就从读数据到缓冲区内再次循环进来
        if self._read_buffer_size() >= self._read_bytes:
            num_bytes = self._read_bytes
            callback = self._read_callback
            self._read_callback = None
            self._read_bytes = None
            self._run_callback(callback, self._consume(num_bytes))
            return True
    elif self._read_delimiter:
        _merge_prefix(self._read_buffer, sys.maxint)
        loc = self._read_buffer[0].find(self._read_delimiter)
        # 在缓冲区找到了分隔符
        if loc != -1:
            callback = self._read_callback
            delimiter_len = len(self._read_delimiter)
            self._read_callback = None
            self._read_delimiter = None
            self._run_callback(callback,
                               self._consume(loc + delimiter_len))
            return True
    # 默认返回False,只有进行了回调函数的的调用就返回True
    return False
```

从已有的buffer中读取数据，并根据两种不同的条件调用相应的回调函数.如果满足条件调用回调函数后返回True, 否则返回False. 

 ## read_until

```python
def read_until(self, delimiter, callback):
    """Call callback when we read the given delimiter."""
    assert not self._read_callback, "Already reading"
    self._read_delimiter = delimiter
    self._read_callback = stack_context.wrap(callback)
    while True:
        # See if we've already got the data from a previous read
        # 要多少我写多少，一点也不多余
        # 第一次buffer里没数据, 什么也读不到, 返回False
        if self._read_from_buffer():
            return
        # 在每一次和socket的读写相关的操作时进行一次check
        self._check_closed()
        # 调用一次就会往buffer里append chunk 大小的数据, 返回从socket读到的数据大小
        if self._read_to_buffer() == 0:
            break
    self._add_io_state(self.io_loop.READ)
```

## read_bytes

```python
def read_bytes(self, num_bytes, callback):
    """Call callback when we read the given number of bytes."""
    assert not self._read_callback, "Already reading"
    if num_bytes == 0:
        callback("")
        return
    self._read_bytes = num_bytes
    self._read_callback = stack_context.wrap(callback)
    while True:
        if self._read_from_buffer():
            return
        self._check_closed()
        if self._read_to_buffer() == 0:
            break
    self._add_io_state(self.io_loop.READ)
```

## write

```python
def write(self, data, callback=None):
    """Write the given data to this stream.

    If callback is given, we call it when all of the buffered write
    data has been successfully written to the stream. If there was
    previously buffered write data and an old write callback, that
    callback is simply overwritten with this new callback.
    """
    self._check_closed()
    # 先往缓冲区里放，等连接建立成功也就是可以发送的时候再发送数据
    # 此时从另一个角度来说可以把socket的读状态或写状态释放出来，切换到另外一个状态进行监听
    # 设置状态为监听可写的事件的时候将数据发出去
    self._write_buffer.append(data)
    self._add_io_state(self.io_loop.WRITE)
    self._write_callback = stack_context.wrap(callback)
```

把数据刷到缓冲区，等待ioloop调度。

## _consume

```python
def _consume(self, loc):
    # 消费掉数据
    _merge_prefix(self._read_buffer, loc)
    return self._read_buffer.popleft()
```

## handle_events

```python
def _handle_events(self, fd, events):
    # _handle_events 作为上层IOLoop的add_handle()的参数，传递到IOLoop中检测事件发生
    # 后回调此函数，READ , WRIET , ERROR 事件都采用这个统一的回调
    if not self.socket:
        logging.warning("Got events for closed stream %d", fd)
        return
    try:
        # 可读事件
        if events & self.io_loop.READ:
            self._handle_read()
        if not self.socket:
            return
        # 可写事件
        if events & self.io_loop.WRITE:
            # 注意这里的 connecting 标志位
            # 在服务端的话是不需要此标志位的
            if self._connecting:
                # 连接已经建立，可以发送连接请求了
                self._handle_connect()
            self._handle_write()
        if not self.socket:
            return
        if events & self.io_loop.ERROR:
            self.close()
            return
        state = self.io_loop.ERROR
        if self.reading():
            state |= self.io_loop.READ
        if self.writing():
            state |= self.io_loop.WRITE
        if state != self._state:
            self._state = state
            self.io_loop.update_handler(self.socket.fileno(), self._state)
    except:
        logging.error("Uncaught exception, closing connection.",
                      exc_info=True)
        self.close()
        raise
```

读写分发函数，可以理解为入口。

### handle_read

```python
def _handle_read(self):
    while True:
        try:
            # Read from the socket until we get EWOULDBLOCK or equivalent.
            # SSL sockets do some internal buffering, and if the data is
            # sitting in the SSL object's buffer select() and friends
            # can't see it; the only way to find out if it's there is to
            # try to read it.

            # 从socket读取数据到本地buffer
            # 此同步调用其实是因为在这里的上层函数 _handle_read是异步被回调的
            # 所以这里能够确定此时的 socket 是可读的
            result = self._read_to_buffer()
        except Exception:
            self.close()
            return
        if result == 0:
            break
        else:
            # 在处理完数据并将数据通过一系列处理后，调用_read_from_buffer()将数据从buffer
            # 中取出，然后回调 read_bytes()或者是 read_until() 中的回调函数
            if self._read_from_buffer():
                return
```

用于从socket读取对端发送过来的数据。

如果read_until没有读到数据，那么等分发成read时候回调用read_until的回调。

### handle_write

```python
def _handle_write(self):
    while self._write_buffer:
        # 在异步的写的过程中，遵循的原则就是能写多少就写多少
        try:
            if not self._write_buffer_frozen:
                # On windows, socket.send blows up if given a
                # write buffer that's too large, instead of just
                # returning the number of bytes it was able to
                # process.  Therefore we must not call socket.send
                # with more than 128KB at a time.
                _merge_prefix(self._write_buffer, 128 * 1024)
            num_bytes = self.socket.send(self._write_buffer[0])
            self._write_buffer_frozen = False
            _merge_prefix(self._write_buffer, num_bytes)
            self._write_buffer.popleft()
        except socket.error, e:
            if e.args[0] in (errno.EWOULDBLOCK, errno.EAGAIN):
                # With OpenSSL, after send returns EWOULDBLOCK,
                # the very same string object must be used on the
                # next call to send.  Therefore we suppress
                # merging the write buffer after an EWOULDBLOCK.
                # A cleaner solution would be to set
                # SSL_MODE_ACCEPT_MOVING_WRITE_BUFFER, but this is
                # not yet accessible from python
                # (http://bugs.python.org/issue8240)

                # 这里的套接口写过程当中如果遇到了不可写的情况，会先停止
                # 但是此时未发送的buffer 的数据任然在，所以不会导致数据丢失
                # 因为在发送的时候是有多少发送多少，因为在负载不大的情况下，套接口
                # 是一直可写的，所以 epoll返回的都是可写状态
                # frozen 的字面意思是冻结可见一斑
                self._write_buffer_frozen = True
                break
            else:
                logging.warning("Write error on %d: %s",
                                self.socket.fileno(), e)
                self.close()
                return
    # 数据全部发送完毕且有回调函数则进行回调
    if not self._write_buffer and self._write_callback:
        callback = self._write_callback
        self._write_callback = None
        self._run_callback(callback)
```

用于从socket发送数据到对端。

# 客户端角色

## connect

```python
def connect(self, address, callback=None):
    """Connects the socket to a remote address without blocking.

    May only be called if the socket passed to the constructor was
    not previously connected.  The address parameter is in the
    same format as for socket.connect, i.e. a (host, port) tuple.
    If callback is specified, it will be called when the
    connection is completed.

    Note that it is safe to call IOStream.write while the
    connection is pending, in which case the data will be written
    as soon as the connection is ready.  Calling IOStream read
    methods before the socket is connected works on some platforms
    but is non-portable.
    """
    # 正在建立连接，连接是否建立成功目前未知
    self._connecting = True
    try:
        self.socket.connect(address)
    except socket.error, e:
        # In non-blocking mode connect() always raises an exception
        if e.args[0] not in (errno.EINPROGRESS, errno.EWOULDBLOCK):
            raise
    # 连接建立成功之后调用的回调函数
    self._connect_callback = stack_context.wrap(callback)
    # 增加 io_loop 的可写状态，也就是三次握手建立成功之后
    self._add_io_state(self.io_loop.WRITE)
```

发送请求之后设定回调函数，等待handle_events的写事件触发。