1. ioloop是tornado的核心模块，实现了事件循环的封装包括select, epoll, kquene
   iostream是在ioloop基础上实现的套接字的缓存，读取和写入功能
   httpserver是在iostream上实现的http协议功能的封装，包括监听端口和解析协议等功能
2. Application 构造器有一个wsgi的参数是用来干嘛的？cgi, wsgi, uwsgi 到底是什么玩意？

# Application

```python
application = tornado.web.Application([
    (r"/index", MainHandler),
    (r"/python/(?P<day>[a-zA-Z0-9]+)/(?P<title>[a-zA-Z]+)", tornado.web.RedirectHandler,
        dict(url=r"/index")),
])
```

上述代码从tornado.web 这个py文件实例化一个Application对象，传入的是是一个list, list 的元素是元组，元组的长度是2或3.

应用封装路由关系，`__call__` 调用的时候会匹配路由，然后调用对应的handle的`_execute`方法(具体是调用这个类的get还是post方法根据请求来定，所以`__call__`  理应会有一个request参数)。

## Application 方法

### init

```python
def __init__(self, handlers=None, default_host="", transforms=None,
             wsgi=False, **settings):
    # 传输方式: 默认在self.transforms列表中设置分块传输和压缩传输两种方式
    if transforms is None:
        self.transforms = []
        if settings.get("gzip"):
            self.transforms.append(GZipContentEncoding)
        self.transforms.append(ChunkedTransferEncoding)
    else:
        self.transforms = transforms
    self.handlers = []
    self.named_handlers = {}
    self.default_host = default_host
    # 绑定settings, 以便Application类的其他方法能够使用到
    self.settings = settings
    self.ui_modules = {}
    self.ui_methods = {}
    self._wsgi = wsgi
    self._load_ui_modules(settings.get("ui_modules", {}))
    self._load_ui_methods(settings.get("ui_methods", {}))
    # 如果settings配了静态文件路径：static_path，还有相应的url路径前缀，组装新的handles，其中favicon.ico也去静态文件夹内寻找
    # TODO handles有第三个参数是是怎么调用的，或者说StaticFileHandler是怎么写的？
    # 另外，handles的组装的数据格式是列表套元组，这也是一种可以借鉴的思路
    # TODO 这里为啥直接存放类，而不是存放类实例，那么类的实例在哪完成的还是说根本不需要实例化
    if self.settings.get("static_path"):
        path = self.settings["static_path"]
        handlers = list(handlers or [])
        static_url_prefix = settings.get("static_url_prefix",
                                         "/static/")
        handlers = [
            (re.escape(static_url_prefix) + r"(.*)", StaticFileHandler,
             dict(path=path)),
            (r"/(favicon\.ico)", StaticFileHandler, dict(path=path)),
            (r"/(robots\.txt)", StaticFileHandler, dict(path=path)),
        ] + handlers
    # add_handlers才是真正的绑定handles，前面的self.handlers = []只是init函数正常的初始化
    if handlers:
        self.add_handlers(".*$", handlers)

    # Automatically reload modified modules
    # TODO: debug模式自动重启服务, 自动重启服务可以借鉴阅读使用
    if self.settings.get("debug") and not wsgi:
        import autoreload
        autoreload.start()
```

初始化的时候关注这个对象里封装了哪些属性，有些属性可能是调用初始化方法没有传的实参, 后续对象的方法可能往里面填充值，在这里就设置上默认值。刚开始接触这个实例化方法的时候这些属性应该设置上默认值。重点关注以下几个属性：

* transforms
* handlers
* settings

### add_handlers 

<font color="red">self.handles并不是单纯的接收构造方法传入的列表，数据格式是[(re.compile(host_pattern),  handles)]</font>

```python
    def add_handlers(self, host_pattern, host_handlers):
        # add_handlers 做的事更像是二级路由，先匹配主机名，然后在去匹配路由规则
        # TODO 当请求真实发生的时候，又是怎么去匹配主机名的？
        if not host_pattern.endswith("$"):
            host_pattern += "$"
        handlers = []
				# 保证.*$是列表的最后一个，避免被截胡，这里的and判断是一个点
        if self.handlers and self.handlers[-1][0].pattern == '.*$':
            self.handlers.insert(-1, (re.compile(host_pattern), handlers))
        else:
            self.handlers.append((re.compile(host_pattern), handlers))

        for spec in host_handlers:
            if isinstance(spec, type(())):
                assert len(spec) in (2, 3)
                pattern = spec[0]
                handler = spec[1]
                # kwargs = spec[2] if len(spec) == 3 else {}, 保证可以传kwargs参数
                if len(spec) == 3:
                    kwargs = spec[2]
                else:
                    kwargs = {}
                # TODO URLSpec 这个类存放url 和 处理类 的对应关系，这个对应关系为啥用一个类来组合，不用单纯的元组呢
                spec = URLSpec(pattern, handler, kwargs)
            handlers.append(spec)

            if spec.name:
                if spec.name in self.named_handlers:
                    logging.warning(
                        "Multiple handlers named %s; replacing previous value",
                        spec.name)
                self.named_handlers[spec.name] = spec
```

这里把host_handlers的三个参数，比如下面元组的三个参数：

```
(r"/python/(?P<day>[a-zA-Z0-9]+)/(?P<title>[a-zA-Z]+)", tornado.web.RedirectHandler,
    dict(url=r"/index")
```

pattern： `r"/python/(?P<day>[a-zA-Z0-9]+)/(?P<title>[a-zA-Z]+)"`;

handler:   ` tornado.web.RedirectHandler`

kwargs:    `dict(url=r"/index")`

这里把这三个参数组装成一个URLSpec对象，为啥要组装成这样一个对象？因为在这三个参数上有一些操作可以做，也必须去做。

###_get_host_handlers 

```python
def _get_host_handlers(self, request):
  host = request.host.lower().split(':')[0]
  for pattern, handlers in self.handlers:
    # <_sre.SRE_Pattern object at 0x10af283b0> [<tornado.web.URLSpec object at 0x10b2c2250>]
    if pattern.match(host):
      return handlers
    # Look for default host if not behind load balancer (for debugging)
    if "X-Real-Ip" not in request.headers:
      for pattern, handlers in self.handlers:
        if pattern.match(self.default_host):
          return handlers
        return None
```

### log_request

```python
def log_request(self, handler):
  """Writes a completed HTTP request to the logs.

        By default writes to the python root logger.  To change
        this behavior either subclass Application and override this method,
        or pass a function in the application settings dictionary as
        'log_function'.
        """
  if "log_function" in self.settings:
    self.settings["log_function"](handler)
    return
  if handler.get_status() < 400:
    log_method = logging.info
    elif handler.get_status() < 500:
      log_method = logging.warning
      else:
        log_method = logging.error
        request_time = 1000.0 * handler.request.request_time()
        log_method("%d %s %.2fms", handler.get_status(),
                   handler._request_summary(), request_time)
```



### call



```python
import urllib


def __call__(self, request):
    """Called by HTTPServer to execute the request."""
    # [<tornado.web.ChunkedTransferEncoding object at 0x110009390>]
    transforms = [t(request) for t in self.transforms]
    # 初始化三个参数，后面经过业务逻辑需要赋值的，其中args和kwarg是handle的get、post等方法使用的
    handler = None
    args = []
    kwargs = {}
    # 根据host(也可以说是一级路由)去匹配handles列表
    handlers = self._get_host_handlers(request)
    if not handlers:
        handler = RedirectHandler(
            self, request, url="http://" + self.default_host + "/")
    else:
        # 根据request.path一个个去匹配处理用户逻辑的handle类
        for spec in handlers:
            # request.path 可能经过了urlencode编码
            match = spec.regex.match(request.path)
            if match:
                def unquote(s):
                    if s is None:
                        return s
                    # 反编码
                    return urllib.unquote(s)
                # spec.kwargs: 就是路由配置元组的第三个参数,handle类型在此处实例化
                handler = spec.handler_class(self, request, **spec.kwargs)
                # 用户Handle类的get(self, *args, **kwargs)方法,这里的args和kwargs就是这个方法需要的参数, 也就是从路由中抽取的部分
                kwargs = dict((k, unquote(v))
                              for (k, v) in match.groupdict().iteritems())
                # kwargs 和 args 必须其一
                if kwargs:
                    args = []
                else:
                    args = [unquote(s) for s in match.groups()]
                break
        if not handler:
            # 没有匹配到路由
            handler = ErrorHandler(self, request, status_code=404)

    # In debug mode, re-compile templates and reload static files on every
    # request so you don't need to restart to see changes
    if self.settings.get("debug"):
        if getattr(RequestHandler, "_templates", None):
            for loader in RequestHandler._templates.values():
                loader.reset()
        RequestHandler._static_hashes = {}
    # handle 对象执行_execute
    handler._execute(transforms, *args, **kwargs)
    return handler
```

对于一个函数或方法而言，关注其输入和输出。输入是request，输出是handle对象(此对象非单例,因为不同的请求对应的参数可能不一样，无法做到单例)。

对于 `handler = spec.handler_class(self, request, **spec.kwargs)`, handle类的实例化的描述。

## Application构造用到的别的类

### URLSpec



```python
class URLSpec(object):
    """Specifies mappings between URLs and handlers."""

    def __init__(self, pattern, handler_class, kwargs={}, name=None):
        if not pattern.endswith('$'):
            pattern += '$'
        self.regex = re.compile(pattern)
        self.handler_class = handler_class
        self.kwargs = kwargs
        self.name = name
        # 通过方法新增2个属性
        self._path, self._group_count = self._find_groups()

    def _find_groups(self):
        """Returns a tuple (reverse string, group count) for a url.

        For example: Given the url pattern /([0-9]{4})/([a-z-]+)/, this method
        would return ('/%s/%s/', 2).
        """
        pattern = self.regex.pattern
        if pattern.startswith('^'):
            pattern = pattern[1:]
        if pattern.endswith('$'):
            pattern = pattern[:-1]

        if self.regex.groups != pattern.count('('):
            # The pattern is too complicated for our simplistic matching,
            # so we can't support reversing it.
            return (None, None)

        pieces = []
        for fragment in pattern.split('('):
            if ')' in fragment:
                paren_loc = fragment.index(')')
                if paren_loc >= 0:
                    pieces.append('%s' + fragment[paren_loc + 1:])
            else:
                pieces.append(fragment)

        return (''.join(pieces), self.regex.groups)
		
    def reverse(self, *args):
        # 将传入的参数args以%s的格式化方式格式化成路由字符串
        assert self._path is not None, \
            "Cannot reverse url regex " + self.regex.pattern
        assert len(args) == self._group_count, "required number of arguments "\
            "not found"
        if not len(args):
            return self._path
        return self._path % tuple([str(a) for a in args])
```

```python
In [1]: import re

In [2]: regex = re.compile(r"/python/(?P<day>[a-zA-Z0-9]+)/(?P<title>[a-zA-Z]+)")

In [3]: regex.groups
Out[3]: 2

In [4]: match = regex.match("/python/122/jak")

In [5]: match.group()
Out[5]: '/python/122/jak'

In [6]: match.groups()
Out[6]: ('122', 'jak')

In [7]: match.groupdict()
Out[7]: {'day': '122', 'title': 'jak'}
```

## Application call用到的类

### RequestHandler

RequestHandler类是用于可以继承，并编写业务逻辑的主要地方，所以这个类的方法有很多，用于满足用户各种需求。<font color="red">这个类主要用于响应，至于请求的request框架帮我们封装好了</font>

#### 构造



```python
class RequestHandler(object):
  
    SUPPORTED_METHODS = ("GET", "HEAD", "POST", "DELETE", "PUT", "OPTIONS")
   
    def __init__(self, application, request, **kwargs):
        self.application = application
        self.request = request
        self._headers_written = False
        self._finished = False
        self._auto_finish = True
        # 响应的传输格式, 后续会被设置
        self._transforms = None  # will be set in _execute
        self.ui = _O((n, self._ui_method(m)) for n, m in
                     application.ui_methods.iteritems())
        self.ui["modules"] = _O((n, self._ui_module(n, m)) for n, m in                               application.ui_modules.iteritems())
        # 设置状态码，_headers列表，把_write_buffer置为空列表
        self.clear()
        # Check since connection is not available in WSGI
        if hasattr(self.request, "connection"):
            self.request.connection.stream.set_close_callback(
                self.on_connection_close)
        # 留给子类的hook, 成员赋值
        self.initialize(**kwargs)
```

对象的initialize()被调用，传入的参数来自Application组态。initialize应该只把传入的参数保存在自身的成员变量中，而不应该提供任何的输出或调用如send_error等方法。

_write_buffer不同于iostream的buffer, 这里的buffer是一个列表.

RequestHandler还有一些方法简单说明一下，如set_cookie,  set_header等，这些都是给对象成员赋值, 但是因为赋值前有一些逻辑，比如值的转换或校验等，所以这里用方法封装了，另外也是为了给别人调用提供接口，而不是简单地让对象给成员赋值。

#### clear



```python
def clear(self):
    """Resets all headers and content for this response."""
    self._headers = {
        "Server": "TornadoServer/%s" % tornado.version,
        "Content-Type": "text/html; charset=UTF-8",
    }
    if not self.request.supports_http_1_1():
        if self.request.headers.get("Connection") == "Keep-Alive":
            self.set_header("Connection", "Keep-Alive")
    self._write_buffer = []
    self._status_code = 200
```

#### execute



```python
def _execute(self, transforms, *args, **kwargs):
    # handle 对象初始化之后有一定的成员变量之后进行的执行操作
    # 输入是分三个，一个是传输类型，另外两个是url从路由匹配到的值
    self._transforms = transforms
    with stack_context.ExceptionStackContext(
            self._stack_context_handle_exception):
        if self.request.method not in self.SUPPORTED_METHODS:
            raise HTTPError(405)
        # If XSRF cookies are turned on, reject form submissions without
        # the proper cookie
        if self.request.method not in ("GET", "HEAD") and \
           self.application.settings.get("xsrf_cookies"):
            self.check_xsrf_cookie()
        self.prepare()
        if not self._finished:
            getattr(self, self.request.method.lower())(*args, **kwargs)
            if self._auto_finish and not self._finished:
                self.finish()
```

对象的prepare()被调用，这是你所有handler子类所继承的最有用的函数，因为不管哪一个HTTP方法被使用prepare都会被调用，并且prepare可以提供输出。如果prepare里使用了finish或者redirect方法，那么进程就在此结束。

#### log

```python
def _log(self):
    """Logs the current request.

    Sort of deprecated since this functionality was moved to the
    Application, but left in place for the benefit of existing apps
    that have overridden this method.
    """
    self.application.log_request(self)
```

#### _request_summary

```python
def _request_summary(self):
		return self.request.method + " " + self.request.uri + " (" + \
self.request.remote_ip + ")"
```

#### xsrf

#### write

write做的最主要的事就是把数据json化，并append到_write_buffer这个列表中，既然是列表，肯定可以被append多次，所以也可以write多次.

```python
def write(self, chunk):
    """Writes the given chunk to the output buffer.

    To write the output to the network, use the flush() method below.

    If the given chunk is a dictionary, we write it as JSON and set
    the Content-Type of the response to be text/javascript.

    Note that lists are not converted to JSON because of a potential
    cross-site security vulnerability.  All JSON output should be
    wrapped in a dictionary.  More details at
    http://haacked.com/archive/2008/11/20/anatomy-of-a-subtle-json-vulnerability.aspx
    """
    assert not self._finished
    if isinstance(chunk, dict):
        # chunk: '{"name": "jack"}'
        chunk = escape.json_encode(chunk)
        self.set_header("Content-Type", "text/javascript; charset=UTF-8")
    chunk = _utf8(chunk)
    self._write_buffer.append(chunk)
```

#### finish

一次请求中finish只能调用一次，表示请求结束.

```python
def finish(self, chunk=None):
    """Finishes this response, ending the HTTP request."""
    # 结束请求, 调用finish就会把self._finished置为True,下面的断言就是为了防止在一个请求中多次调用finish方法
    assert not self._finished
    if chunk is not None:
        self.write(chunk)

    # Automatically support ETags and add the Content-Length header if
    # we have not flushed any content yet.
    if not self._headers_written:
        if (self._status_code == 200 and
            self.request.method in ("GET", "HEAD") and
                "Etag" not in self._headers):
            # 响应头里没有etag的话, 那就需要设置一下etag.
            hasher = hashlib.sha1()
            for part in self._write_buffer:
                hasher.update(part)
            etag = '"%s"' % hasher.hexdigest()
            inm = self.request.headers.get("If-None-Match")
            # 
            if inm and inm.find(etag) != -1:
                self._write_buffer = []
                self.set_status(304)
            # 没有If-None-Match或者If-None-Match中的数据和后台的数据不一致
            else:
                self.set_header("Etag", etag)
        if "Content-Length" not in self._headers:
            content_length = sum(len(part) for part in self._write_buffer)
            # 响应报文数据的长度Content-Length，请求体的这个参数表示请求体的数据长度
            self.set_header("Content-Length", content_length)

    if hasattr(self.request, "connection"):
        self.request.connection.stream.set_close_callback(None)

    if not self.application._wsgi:
        self.flush(include_footers=True)
        self.request.finish()
        self._log()
    self._finished = True
```

关于 self._headers_written 的说明：

通过检测 self._headers_written 的值，来判断是否该请求已经被返回给了客户端：                                                                                                                      在 基类 RequestHandler 的初始化中，self._headers_written = False，之后如果当前输出的缓冲区已经flush到了网络的时候，函数 def flush() 中会将 self._headers_written = True。所以此时头信息headers已经别写入了请求且已经返回给了客户端，是无法进行重定向了。

先做了一些etag的判断，然后分别调用了 3个方法：

```python
self.flush(include_footers=True)
self.request.finish()
self._log()
```

> ETag是HTTP1.1中才加入的一个属性，用来帮助服务器控制Web端的缓存验证。它的原理是这样的，当浏览器请求服务器的某项资源(A)时, 服务器根据A算出一个哈希值(3f80f-1b6-3e1cb03b)并通过 ETag 返回给浏览器，浏览器把"3f80f-1b6-3e1cb03b" 和 A 同时缓存在本地，当下次再次向服务器请求A时，会通过类似 `If-None-Match: "3f80f-1b6-3e1cb03b"` 的请求头把ETag发送给服务器，服务器再次计算A的哈希值并和浏览器返回的值做比较，如果发现A发生了变化就把A返回给浏览器(200)，如果发现A没有变化就给浏览器返回一个304未修改。这样通过控制浏览器端的缓存，可以节省服务器的带宽，因为服务器不需要每次都把全量数据返回给客户端。

##### self.request.finish()

断开连接。

#### _generate_headers

用于生成响应头

```python
def _generate_headers(self):
    lines = [self.request.version + " " + str(self._status_code) + " " +
             httplib.responses[self._status_code]]
    lines.extend(["%s: %s" % (n, v) for n, v in self._headers.iteritems()])
    for cookie_dict in getattr(self, "_new_cookies", []):
        for cookie in cookie_dict.values():
            lines.append("Set-Cookie: " + cookie.OutputString(None))
    return "\r\n".join(lines) + "\r\n\r\n"
```

## self.flush(include_footers=True)

flush表示把数据真正刷到网络中. 在finish中，这个方法仅仅被调用了一次。用户可以调用这个方法调用多次。

```python
    def flush(self, include_footers=False):
        """Flushes the current output buffer to the network."""
        if self.application._wsgi:
            raise Exception("WSGI applications do not support flush()")
        # 把handle里的_write_buffer组装成一个大字符串
        chunk = "".join(self._write_buffer)
        self._write_buffer = []
        # 这个判断表示可以多次flush数据
        if not self._headers_written:
            self._headers_written = True
            for transform in self._transforms:
                self._headers, chunk = transform.transform_first_chunk(
                    self._headers, chunk, include_footers)
            headers = self._generate_headers()
        else:
            # 第二次flush数据，那么就不是第一次transform了，之前header也有过了
            for transform in self._transforms:
                chunk = transform.transform_chunk(chunk, include_footers)
            headers = ""
        # Ignore the chunk and only write the headers for HEAD requests
        if self.request.method == "HEAD":
            if headers:
                self.request.write(headers)
            return

        if headers or chunk:
            # 真正发送数据
            self.request.write(headers + chunk)
```

request的finish

```python
def finish(self):
    """Finishes this HTTP request on the open connection."""
    self.connection.finish()
    self._finish_time = time.time()
```

<font color="red">request的finish干了些什么事；两个transform做了些什么事</font>



encoding 几次取决于调用了flush几次



<font color="red">数据和响应头分别是通过怎样的形式返回给客户端的；hasattr(self.request, "connection") 这个是什么意思？检查连接是否可用，应该是长短连接有关？self.request.write(headers + chunk)是什么原理？</font>

RequestHandle也有一个_write_buffer， 这个buffer是一个列表. 为啥需要这个buffer呢？和stream的buffer有什么区别呢？

HEAD请求是什么鬼？

```
if self.request.method == "HEAD":
    if headers:
        self.request.write(headers)
```



# transfer-encoding

transfer-encoding的可选值有：chunked,identity，从字面意义可以理解，前者指把要发送传输的数据切割成一系列的块数据传输，后者指传输时不做任何处理，自身的本质数据形式传输。举个例子，如果我们要传输一本“红楼梦”小说到服务器，chunked方式就会先把这本小说分成一章一章的，然后逐个章节上传，而identity方式则是从小说的第一个字按顺序传输到最后一个字结束。

Content-Encoding ： content-encoding和transfer-encoding所作用的对象不同，行为目标也不同，前者是对数据内容采用什么样的编码方式，后者是对数据传输采用什么样的编码。前者通常是对数据内容进行一些**压缩编码**操作，后者通常是对传传输采用**分块策略**之类的。

Content-length : content-length头的作用是指定待传输的内容的字节长度。比如上面举的例子中，我们要上传一本红楼梦小说，则可以指定其长度大小，如：content-length:731017。细心的读者可能会有疑惑，它和transfer-encoding又有什么关系呢？如果想知道它们的关系，只要反过来问下自己，为什么transfer-encoding会有identity和chunked两种，各在什么上下文情景中要用到。比如chunked方式，把数据分块传输在很多地方就非常有用，如服务端在处理一个复杂的问题时，其返回结果是阶段性的产出，不能一次性知道最终的返回的总长度(content-lenght值)，所以这时候返回头中就不能有content-lenght头信息，有也要忽略处理。所以你可以这样理解，transfer-encoding在不能一次性确定消息实体(entity)内容时自定义一些传输协议，如果能确定的话，则可以在消息头中加入content-length头信息指示其长度，可以把transfer-encoding和content-length看成互斥性的两种头。

![2012101912451656](https://ws1.sinaimg.cn/large/006tNc79ly1g35t7zk8g9j30sk0grt99.jpg)

分块编码主要应用于如下场景，即要传输大量的数据，但是在请求在没有被处理完之前响应的长度是无法获得的。例如，当需要用从数据库中查询获得的数据生成一个大的HTML表格的时候，或者需要传输大量的图片的时候。一个分块响应形式如下：

```html
HTTP/1.1 200 OK 
Content-Type: text/plain 
Transfer-Encoding: chunked

7\r\n
Mozilla\r\n 
9\r\n
Developer\r\n
7\r\n
Network\r\n
0\r\n 
\r\n
```

#HttpServer 

















将sleep.py的代码如上述一样改造，即在get()方法前面增加了装饰器@tornado.web.asynchronous，它的作用在于将tornado服务器本身默认的设置_auto_fininsh值修改为false。如果不用这个装饰器，客户端访问服务器的get()方法并得到返回值之后，两只之间的连接就断开了，但是用了@tornado.web.asynchronous之后，这个连接就不关闭，直到执行了self.finish()才关闭这个连接。

tornado.ioloop.IOLoop.instance().add_timeout()也是一个实现异步的函数，time.time()+17是给前面函数提供一个参数，这样实现了相当于time.sleep(17)的功能，不过，还没有完成，当这个操作完成之后，就执行回调函数on_response()中的self.render(“sleep.html”)，并关闭连接self.finish()。 



一旦其中一个子进程成功的建立了连接, 当其他子进程再尝试建立这个连接的时候就会触发 `EWOULDBLOCK` (或 EAGAIN) 错误. 这时候回调函数判断是这个错误则返回函数不做处理.

当成功建立连接的子进程还在处理这个连接的时候又过来一个连接, 这时候就会有另外一个 子进程接手这个连接.

Tornado 就是通过这样一种机制, 利用多进程提升效率, 由于连接只能由一个子进程成功创建, 同一个请求也就不会被多个子进程处理.