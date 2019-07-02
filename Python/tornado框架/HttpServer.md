```python
class HTTPServer(object):
    """A non-blocking, single-threaded HTTP server.

    A server is defined by a request callback that takes an HTTPRequest
    instance as an argument and writes a valid HTTP response with
    request.write(). request.finish() finishes the request (but does not
    necessarily close the connection in the case of HTTP/1.1 keep-alive
    requests). A simple example server that echoes back the URI you
    requested:

        import httpserver
        import ioloop

        def handle_request(request):
           message = "You requested %s\n" % request.uri
           request.write("HTTP/1.1 200 OK\r\nContent-Length: %d\r\n\r\n%s" % (
                         len(message), message))
           request.finish()

        http_server = httpserver.HTTPServer(handle_request)
        http_server.listen(8888)
        ioloop.IOLoop.instance().start()

    HTTPServer is a very basic connection handler. Beyond parsing the
    HTTP request body and headers, the only HTTP semantics implemented
    in HTTPServer is HTTP/1.1 keep-alive connections. We do not, however,
    implement chunked encoding, so the request callback must provide a
    Content-Length header or implement chunked encoding for HTTP/1.1
    requests for the server to run correctly for HTTP/1.1 clients. If
    the request handler is unable to do this, you can provide the
    no_keep_alive argument to the HTTPServer constructor, which will
    ensure the connection is closed on every request no matter what HTTP
    version the client is using.

    If xheaders is True, we support the X-Real-Ip and X-Scheme headers,
    which override the remote IP and HTTP scheme for all requests. These
    headers are useful when running Tornado behind a reverse proxy or
    load balancer.

    HTTPServer can serve HTTPS (SSL) traffic with Python 2.6+ and OpenSSL.
    To make this server serve SSL traffic, send the ssl_options dictionary
    argument with the arguments required for the ssl.wrap_socket() method,
    including "certfile" and "keyfile":

       HTTPServer(applicaton, ssl_options={
           "certfile": os.path.join(data_dir, "mydomain.crt"),
           "keyfile": os.path.join(data_dir, "mydomain.key"),
       })

    By default, listen() runs in a single thread in a single process. You
    can utilize all available CPUs on this machine by calling bind() and
    start() instead of listen():

        http_server = httpserver.HTTPServer(handle_request)
        http_server.bind(8888)
        http_server.start(0) # Forks multiple sub-processes
        ioloop.IOLoop.instance().start()

    start(0) detects the number of CPUs on this machine and "pre-forks" that
    number of child processes so that we have one Tornado process per CPU,
    all with their own IOLoop. You can also pass in the specific number of
    child processes you want to run with if you want to override this
    auto-detection.
    """
    def __init__(self, request_callback, no_keep_alive=False, io_loop=None,
                 xheaders=False, ssl_options=None):
        """Initializes the server with the given request callback.

        If you use pre-forking/start() instead of the listen() method to
        start your server, you should not pass an IOLoop instance to this
        constructor. Each pre-forked child process will create its own
        IOLoop instance after the forking process.
        """
        # 这里的request_callback 就是application对象
        self.request_callback = request_callback
        # 是否需要保持长连接
        self.no_keep_alive = no_keep_alive
        self.io_loop = io_loop
        self.xheaders = xheaders
        self.ssl_options = ssl_options
        self._socket = None
        self._started = False

    def listen(self, port, address=""):
        """Binds to the given port and starts the server in a single process.

        This method is a shortcut for:

            server.bind(port, address)
            server.start(1)

        """
        # 绑定端口和注册事件, 此时并未开启事件循环。
        # 如果想把这个server跑在单线程上，可以调用listen方法，listen是bind和start方法的单进程模式的“快捷键”。
        self.bind(port, address)
        self.start(1)

    def bind(self, port, address=""):
        """Binds this server to the given port on the given IP address.

        To start the server, call start(). If you want to run this server
        in a single process, you can call listen() as a shortcut to the
        sequence of bind() and start() calls.
        """
        assert not self._socket
        self._socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0)
        # 下面的一段代码是为了应对子进程情况，在子进程exec之前就关闭子进程的fd(不影响主进程的fd)
        flags = fcntl.fcntl(self._socket.fileno(), fcntl.F_GETFD)
        flags |= fcntl.FD_CLOEXEC
        fcntl.fcntl(self._socket.fileno(), fcntl.F_SETFD, flags)
        self._socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self._socket.setblocking(0)
        self._socket.bind((address, port))
        self._socket.listen(128)

    def start(self, num_processes=1):
        """Starts this server in the IOLoop.

        By default, we run the server in this process and do not fork any
        additional child process.

        If num_processes is None or <= 0, we detect the number of cores
        available on this machine and fork that number of child
        processes. If num_processes is given and > 1, we fork that
        specific number of sub-processes.

        Since we use processes and not threads, there is no shared memory
        between any server code.

        Note that multiple processes are not compatible with the autoreload
        module (or the debug=True option to tornado.web.Application).
        When using multiple processes, no IOLoops can be created or
        referenced until after the call to HTTPServer.start(n).
        """
        """
        默认情况下，但进程运行server，不会fork任何额外的子进程。
        如果num_processes为None或 <= 0 ，会根据机器的cpu核数fork子进程。若num_processes >= 1，就fork这个数目的子进程。
        因为我们使用的是进程而不是线程, 所以不会在server
        code之间共享内存。
        特别注意，多进程与自动装载模型不兼容。在调用start(n)前，任何IOLoop都不能创建和引用
        """
        # 不可以start多次
        assert not self._started
        self._started = True
        if num_processes is None or num_processes <= 0:
            num_processes = _cpu_count()
        # 必须在创建ioloop实例之前创建完进程
        if num_processes > 1 and ioloop.IOLoop.initialized():
            logging.error("Cannot run in multiple processes: IOLoop instance "
                          "has already been initialized. You cannot call "
                          "IOLoop.instance() before calling start()")
            num_processes = 1
        if num_processes > 1:
            logging.info("Pre-forking %d server processes", num_processes)
            for i in range(num_processes):
                if os.fork() == 0:
                    import random
                    from binascii import hexlify
                    try:
                        # If available, use the same method as
                        # random.py
                        seed = long(hexlify(os.urandom(16)), 16)
                    except NotImplementedError:
                        # Include the pid to avoid initializing two
                        # processes to the same value
                        seed(int(time.time() * 1000) ^ os.getpid())
                    random.seed(seed)
                    self.io_loop = ioloop.IOLoop.instance()
                    # socket event 可读时，执行_handle_events
                    self.io_loop.add_handler(
                        self._socket.fileno(), self._handle_events,
                        ioloop.IOLoop.READ)
                    return
            os.waitpid(-1, 0)
        else:
            if not self.io_loop:
                self.io_loop = ioloop.IOLoop.instance()
            self.io_loop.add_handler(self._socket.fileno(),
                                     self._handle_events,
                                     ioloop.IOLoop.READ)

    def stop(self):
        self.io_loop.remove_handler(self._socket.fileno())
        self._socket.close()

    def _handle_events(self, fd, events):
        # 站在服务端的角度来说，进入这个函数表示有请求进服务器了
        # 这里使用的是死循环，为啥这里使用while循环，因为可能一下有多个连接进来，这里针对这多个连接分别使用一个HTTPConnection进行处理。
        while True:
            try:
                connection, address = self._socket.accept()
            except socket.error, e:
                if e.args[0] in (errno.EWOULDBLOCK, errno.EAGAIN):
                    return
                raise
            if self.ssl_options is not None:
                assert ssl, "Python 2.6+ and OpenSSL required for SSL"
                try:
                    connection = ssl.wrap_socket(connection,
                                                 server_side=True,
                                                 do_handshake_on_connect=False,
                                                 **self.ssl_options)
                except ssl.SSLError, err:
                    if err.args[0] == ssl.SSL_ERROR_EOF:
                        return connection.close()
                    else:
                        raise
                except socket.error, err:
                    if err.args[0] == errno.ECONNABORTED:
                        return connection.close()
                    else:
                        raise
            try:
                if self.ssl_options is not None:
                    stream = iostream.SSLIOStream(connection, io_loop=self.io_loop)
                else:
                    stream = iostream.IOStream(connection, io_loop=self.io_loop)
                HTTPConnection(stream, address, self.request_callback,
                               self.no_keep_alive, self.xheaders)
            except:
                logging.error("Error in connection callback", exc_info=True)
```

httpserver 从本身意义上来理解就是http服务器端，主要做的事就是创建socket，监听端口. 可以fork出多进程共同监听一个socket对象。Application的启动就是和httpserver对象打交道。httpserver又和HTTPConnection、IOStream对象之间相关。

## linux进程间的close-on-exec机制

大部分这种问题都能够解决，在文章的最后，提到了一种特殊情况，就是父子进程中的端口占用情况。父进程监听一个端口后，fork出一个子进程，然后kill掉父进程，再重启父进程，这个时候提示端口占用，用netstat查看，子进程占用了父进程监听的端口。

原理其实很简单，子进程在fork出来的时候，使用了写时复制（COW，Copy-On-Write）方式获得父进程的数据空间、 堆和栈副本，这其中也包括文件描述符。刚刚fork成功时，父子进程中相同的文件描述符指向系统文件表中的同一项（这也意味着他们共享同一文件偏移量）。这其中当然也包含父进程创建的socket。

接着，一般我们会调用exec执行另一个程序，此时会用全新的程序替换子进程的正文，数据，堆和栈等。此时保存文件描述符的变量当然也不存在了，我们就无法关闭无用的文件描述符了。所以通常我们会fork子进程后在子进程中直接执行close关掉无用的文件描述符，然后再执行exec。

但是在复杂系统中，有时我们fork子进程时已经不知道打开了多少个文件描述符（包括socket句柄等），这此时进行逐一清理确实有很大难度。我们期望的是能在fork子进程前打开某个文件句柄时就指定好：“这个句柄我在fork子进程后执行exec时就关闭”。其实时有这样的方法的：即所谓 的 close-on-exec。

同时，也为了安全着想。不做限制的话，子进程就可以会拿着文件描述符为所欲为.

<font color="red">PS:如果将fcntl设置为开启，即设置为1，那么，此文件描述符依然是可以被主进程操作的。可以理解为文件句柄可以多个进程占用的，多个进程对应文件句柄的多个点，被多个点占用文件句柄就不会被释放。</font>



## [子进程复制了父进程的什么](https://www.cnblogs.com/zhangchaoyang/articles/2317420.html)

使用fork会出现一个奇怪的现象，有时会出现父子进程变量的地址一样，但值不一样。

里就涉及到物理地址和逻辑地址（或称虚拟地址）的概念。

从逻辑地址到物理地址的映射称为地址重定向。分为：

静态重定向--在程序装入主存时已经完成了逻辑地址到物理地址和变换，在程序执行期间不会再发生改变。

动态重定向--程序执行期间完成，其实现依赖于硬件地址变换机构，如基址寄存器。

逻辑地址：CPU所生成的地址。CPU产生的逻辑地址被分为 :p （页号） 它包含每个页在物理内存中的基址，用来作为页表的索引；d （页偏移），同基址相结合，用来确定送入内存设备的物理内存地址。

物理地址：内存单元所看到的地址。

用户程序看不见真正的物理地址。用户只生成逻辑地址，且认为进程的地址空间为0到max。物理地址范围从R+0到R+max，R为基地址,地址映射－将程序地址空间中使用的逻辑地址变换成内存中的物理地址的过程。由内存管理单元（MMU）来完成。

  fork（）会产生一个和父进程完全相同的子进程，但子进程在此后多会exec系统调用，出于效率考虑，linux中引入了“写时复制“技术，也就是只有进程空间的各段的内容要发生变化时，才会将父进程的内容复制一份给子进程。在fork之后exec之前两个进程用的是相同的物理空间（内存区），子进程的代码段、数据段、堆栈都是指向父进程的物理空间，也就是说，两者的虚拟空间不同，但其对应的物理空间是同一个。当父子进程中有更改相应段的行为发生时，再为子进程相应的段分配物理空间，如果不是因为exec，内核会给子进程的数据段、堆栈段分配相应的物理空间（至此两者有各自的进程空间，互不影响），而代码段继续共享父进程的物理空间（两者的代码完全相同）。而如果是因为exec，由于两者执行的代码不同，子进程的代码段也会分配单独的物理空间。
       fork之后内核会通过将子进程放在队列的前面，以让子进程先执行，以免父进程执行导致写时复制，而后子进程执行exec系统调用，因无意义的复制而造成效率的下降。

fork时子进程获得父进程数据空间、堆和栈的复制，所以变量的地址（当然是虚拟地址）也是一样的。

每个进程都有自己的虚拟地址空间，不同进程的相同的虚拟地址显然可以对应不同的物理地址。因此地址相同（虚拟地址）而值不同没什么奇怪。
具体过程是这样的：
fork子进程完全复制父进程的栈空间，也复制了页表，但没有复制物理页面，所以这时虚拟地址相同，物理地址也相同，但是会把父子共享的页面标记为“只读”（类似mmap的private的方式），如果父子进程一直对这个页面是同一个页面，知道其中任何一个进程要对共享的页面“写操作”，这时内核会复制一个物理页面给这个进程使用，同时修改页表。而把原来的只读页面标记为“可写”，留给另外一个进程使用。

这就是所谓的“写时复制”。正因为fork采用了这种写时复制的机制，所以fork出来子进程之后，父子进程哪个先调度呢？内核一般会先调度子进程，因为很多情况下子进程是要马上执行exec，会清空栈、堆。。这些和父进程共享的空间，加载新的代码段。。。，这就避免了“写时复制”拷贝共享页面的机会。如果父进程先调度很可能写共享页面，会产生“写时复制”的无用功。所以，一般是子进程先调度滴。

python中通过id()方法查看到的是虚拟地址。

## 阻塞IO

阻塞IO的connect, recv 都是阻塞的，listen(4) 表示队列最多可以支持5个connect连接，多余的connect连接就只能等待了(不报错)。



