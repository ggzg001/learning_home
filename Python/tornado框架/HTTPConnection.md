```python
try:
    if self.ssl_options is not None:
        stream = iostream.SSLIOStream(connection, io_loop=self.io_loop)
    else:
        stream = iostream.IOStream(connection, io_loop=self.io_loop)
    HTTPConnection(stream, address, self.request_callback,
                   self.no_keep_alive, self.xheaders)
```

HTTPConnection 类的作用： 是用来处理客户端对等的socket连接的, 用来处理真实的HTTP请求的。解析http请求头和请求体，执行http请求的回调的。

## 构造方法

```python
class HTTPConnection(object):
    """Handles a connection to an HTTP client, executing HTTP requests.

    We parse HTTP headers and bodies, and execute the request callback
    until the HTTP conection is closed.
    """
    # 处理http请求的整个功能逻辑
    def __init__(self, stream, address, request_callback, no_keep_alive=False,
                 xheaders=False):
        # 创建封装了客户端socket对象和IOLoop对象的IOStream实例, stream之后可以用来获取或输出数据
        self.stream = stream
        # ('127.0.0.1', 61163), client的地址信息
        self.address = address
        # <tornado.web.Application object at 0x1064c7090>, 请求对应的回调对象, 可以加括号直接运行的
        self.request_callback = request_callback
        # TODO 这里的长连接是怎么实现的
        self.no_keep_alive = no_keep_alive
        self.xheaders = xheaders
        # 每一个HTTPConnection对象都有一个HTTPRequest对象
        self._request = None
        self._request_finished = False
        # Save stack context here, outside of any request.  This keeps
        # contexts from one request from leaking into the next.

        # 获取请求信息(请求头和内容), 然后执行 HTTPConnection的_on_headers方法继续处理请求
        self._header_callback = stack_context.wrap(self._on_headers)
        # 这句代码是一个异步操作，等啥时有请求数据并读取到\r\n\r\n 就自动调用 _header_callback 方法了
        self.stream.read_until("\r\n\r\n", self._header_callback)
```

## _on_headers

解析请求头数据，并把请求头的数据放到self._request中.

```python
def _on_headers(self, data):
    # 这里的data是带着分隔符"\r\n\r\n"
    try:
        eol = data.find("\r\n")
        start_line = data[:eol]
        try:
            method, uri, version = start_line.split(" ")
        except ValueError:
            raise _BadRequestException("Malformed HTTP request line")
        if not version.startswith("HTTP/"):
            raise _BadRequestException("Malformed HTTP version in HTTP Request-Line")
        # headers 是一个类字典对象, 用来封装请求头信息, 内部调用splitlines进行分割
        # 当然，这里还有一个 _request, 用来封装所有的请求信息
        headers = httputil.HTTPHeaders.parse(data[eol:])

        # HTTPRequest 封装的connection 就是HTTPConnection, 这里的url包括查询字符串在内
        self._request = HTTPRequest(
            connection=self, method=method, uri=uri, version=version,
            headers=headers, remote_ip=self.address[0])

        # 根据请求头的Content-Length来判断请求体的数据长度
        # 一般 post请求 请求头有content-length
        content_length = headers.get("Content-Length")
        if content_length:
            content_length = int(content_length)
            # 请求体的数据长度如果大于stream可以接收的buffer大小表示buffer存不下请求体的数据报错, 这里默认的最大请求体最大长度是100M,做过试验传超过100M的数据, content_length=142889555 > 104857600
            if content_length > self.stream.max_buffer_size:
                raise _BadRequestException("Content-Length too long")
            # 能走到这个条件就说明content-length的长度服务端还可以处理
            if headers.get("Expect") == "100-continue":
                self.stream.write("HTTP/1.1 100 (Continue)\r\n\r\n")
            # 去处理请求体的数据了
            self.stream.read_bytes(content_length, self._on_request_body)
            return
        # 解析完毕之后立即去执行Application对象的 __call__ 方法，也就是路由系统的入口, 这里把request作为参数, 这样在开发者写的handle里就能使用self.request拿到请求相关的信息做相应的处理了
        self.request_callback(self._request)
    except _BadRequestException, e:
        logging.info("Malformed HTTP request from %s: %s",
                     self.address[0], e)
        self.stream.close()
        return
```

self.stream.read_bytes(content_length, self._on_request_body): 如果请求头中有`Content-Length`，那么需要进一步去提取请求体数据，请求体长度就是`Content-Length`.

#### Expect

**Expect** 是一个请求消息头，包含一个期望条件，表示服务器只有在满足此期望条件的情况下才能妥善地处理请求。

规范中只规定了一个期望条件，即 `Expect: 100-continue`, 对此服务器可以做出如下回应：

- [`100`](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Status/100) 如果消息头中的期望条件可以得到满足，使得请求可以顺利进行的话，
- [`417`](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Status/417) (Expectation Failed) 如果服务器不能满足期望条件的话；也可以是其他任意表示客户端错误的状态码（4xx）。

100-continue: 通知接收方客户端要发送一个体积可能很大的消息体，期望收到状态码为[`100`](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Status/100) (Continue)  的临时回复。

客户端发送带有Expect消息头的请求，等服务器回复后再发送消息体。

```html
PUT /somewhere/fun HTTP/1.1
Host: origin.example.com
Content-Type: video/h264
Content-Length: 1234567890987
Expect: 100-continue
```

服务器开始检查请求消息头，可能会返回一个状态码为 [`100`](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Status/100) (Continue) 的回复来告知客户端继续发送消息体，也可能会返回一个状态码为[`417`](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Status/417) (Expectation Failed) 的回复来告知对方要求不能得到满足。

### headers对象

httputil.HTTPHeaders对象继承字典，可以先简单地理解headers就是一个字典

### HTTPRequest

```python
def __init__(self, method, uri, version="HTTP/1.0", headers=None,
             body=None, remote_ip=None, protocol=None, host=None,
             files=None, connection=None):
    self.method = method
    # /index?name=jack
    self.uri = uri
    self.version = version
    self.headers = headers or httputil.HTTPHeaders()
    self.body = body or ""
    if connection and connection.xheaders:
        # Squid uses X-Forwarded-For, others use X-Real-Ip
        self.remote_ip = self.headers.get(
            "X-Real-Ip", self.headers.get("X-Forwarded-For", remote_ip))
        # AWS uses X-Forwarded-Proto
        self.protocol = self.headers.get(
            "X-Scheme", self.headers.get("X-Forwarded-Proto", protocol))
        if self.protocol not in ("http", "https"):
            self.protocol = "http"
    else:
        self.remote_ip = remote_ip
        if protocol:
            self.protocol = protocol
        elif connection and isinstance(connection.stream, 
                                       iostream.SSLIOStream):
            self.protocol = "https"
        else:
            self.protocol = "http"
    self.host = host or self.headers.get("Host") or "127.0.0.1"
    # {"filed1": [{"filename": "", "value": "", "content_type": ""}, {}]}
    self.files = files or {}
    self.connection = connection
    # 生成 HTTPRequest 对象的时间, 也可以理解为请求开始的时机
    self._start_time = time.time()
    # 请求结束时间
    self._finish_time = None
    # urlparse.urlsplit("http://www.google.com/search?hl=en&q=urlparse&btnG=Google+Search")
    # SplitResult(scheme='http', netloc='www.google.com',
    # path='/search', query='hl=en&q=urlparse&btnG=Google+Search', fragment='')
    scheme, netloc, path, query, fragment = urlparse.urlsplit(uri)
    self.path = path
    self.query = query
    arguments = cgi.parse_qs(query)
    # GET 的查询参数本体在query里, 这里只是再做一层解析
    self.arguments = {}
    for name, values in arguments.iteritems():
        values = [v for v in values if v]
        if values: self.arguments[name] = values
```

HTTPRequest 对象封装和请求相关的一切，包括请求方法、url、http版本、headers、body、remote_ip、protocol、host、files以及HTTPConnection对象。

其中下面的代码是做path和get请求的query参数提取的

```python
scheme, netloc, path, query, fragment = urlparse.urlsplit(uri)
self.path = path
self.query = query
arguments = cgi.parse_qs(query)
```

#### write

```python
def write(self, chunk):
    """Writes the given chunk to the response stream."""
    assert isinstance(chunk, str)
    self.connection.write(chunk)
```

write方法self._request 给用户暴露的写数据接口。

这里的connection.write又调用了stream的write方法

```python
def write(self, chunk):
    assert self._request, "Request closed"
    if not self.stream.closed():
        self.stream.write(chunk, self._on_write_complete)
```

#### finish

```python
def finish(self):
    """Finishes this HTTP request on the open connection."""
    self.connection.finish()
    self._finish_time = time.time()
```

设置请求结束时间，调用self.connection.finish, 结束整个业务连接。

##_on_write_complete

```python
def _on_write_complete(self):
    if self._request_finished:
        self._finish_request()
```

## _finish_request 

```python
def _finish_request(self):
    if self.no_keep_alive:
        disconnect = True
    else:
        connection_header = self._request.headers.get("Connection")
        if self._request.supports_http_1_1():
            disconnect = connection_header == "close"
        elif ("Content-Length" in self._request.headers
                or self._request.method in ("HEAD", "GET")):
            disconnect = connection_header != "Keep-Alive"
        else:
            disconnect = True
    self._request = None
    self._request_finished = False
    if disconnect:
        self.stream.close()
        return
    self.stream.read_until("\r\n\r\n", self._header_callback)
```

## _on_request_body

处理请求体的数据,  这里根据内容类型Content-Type又不同的处理方式, 对应form表单不同的上传方式。

```python
def _on_request_body(self, data):
    # 请求体的数据: 如post的数据data = "name=jack&age=14"。 requests.post(url,data={"name":"jack", "age": 23})
    # 给请求request的body属性赋值
    self._request.body = data
    content_type = self._request.headers.get("Content-Type", "")
    if self._request.method in ("POST", "PUT"):
        # 默认的 Content-Type 就是 "application/x-www-form-urlencoded"
        if content_type.startswith("application/x-www-form-urlencoded"):
            # {'age': ['14'], 'name': ['jack']}
            arguments = cgi.parse_qs(self._request.body)
            for name, values in arguments.iteritems():
                # 存放的value是一个列表,因为post的data数据可能是"name=jack&name=alex&age=14"
                values = [v for v in values if v]
                if values:
                    # 字典的值是 list 情况, 先 setdefault 然后 extend. 如果是post application/x-www-form-urlencoded 的数据存放在request.arguments 这个字典里面
                    self._request.arguments.setdefault(name, []).extend(
                        values)
        elif content_type.startswith("multipart/form-data"):
            # multipart/form-data; boundary=f0e2685dce938c73ffa917ba6e3a8cde
            fields = content_type.split(";")
            for field in fields:
                k, sep, v = field.strip().partition("=")
                # 根据boundary去分割文件, 并把解析后的内容存入request对象里
                if k == "boundary" and v:
                    self._parse_mime_body(v, data)
                    break
            else:
                logging.warning("Invalid multipart/form-data")
    # post或者put请求解析完请求之后再去调用app.__call__
    self.request_callback(self._request)
```

_on_request_body 用来填充self.__request 对象。这里对请求体的处理分为普通请求体和上传文件两种形式。这种方式最后也调用self.request_callback(self._request)来处理用户自定义handle的业务逻辑。

## _parse_mime_body

用于处理上传文件,  从parse的含义"解析"可以看出这个函数就是解析请求体的数据并防在request.files 属性中或者 request.arguments属性里。

```python
def _parse_mime_body(self, boundary, data):
    # The standard allows for the boundary to be quoted in the header,
    # although it's rare (it happens at least for google app engine
    # xmpp).  I think we're also supposed to handle backslash-escapes
    # here but I'll save that until we see a client that uses them
    # in the wild.

    # boundary: '056407c647fd75e8e370c1a765bcd005'
    if boundary.startswith('"') and boundary.endswith('"'):
        boundary = boundary[1:-1]
    """
    data: '--056407c647fd75e8e370c1a765bcd005\r\n
           Content-Disposition: form-data; name="filed1"; filename="a.py"
           \r\n\r\n\r\n--056407c647fd75e8e370c1a765bcd005--\r\n'
    """
    if data.endswith("\r\n"):
        footer_length = len(boundary) + 6
    else:
        footer_length = len(boundary) + 4
    # data[:-footer_length]: '--11268220cbb1efb54fcc7c05d7b3dfea\r\n
    #                         Content-Disposition: form-data; name="filed1"; filename="a.py"\r\n\r\n
    #                         def bar():\n    print(\'bar\')\n\r\n'
    parts = data[:-footer_length].split("--" + boundary + "\r\n")
    for part in parts:
        # part: 'Content-Disposition: form-data; name="filed1"; filename="a.py"\r\n\r\ndef bar():\n    print(\'bar\')\n\r\n'
        if not part: continue
        eoh = part.find("\r\n\r\n")
        if eoh == -1:
            logging.warning("multipart/form-data missing headers")
            continue
        # {'Content-Disposition': ['form-data; name="filed1"; filename="a.py"']} 里面的parse是以 : 进行的分割
        headers = httputil.HTTPHeaders.parse(part[:eoh])
        # name_header: form-data; name="f1"; filename="a.txt"
        name_header = headers.get("Content-Disposition", "")
        if not name_header.startswith("form-data;") or \
           not part.endswith("\r\n"):
            logging.warning("Invalid multipart/form-data")
            continue
        # value: "def bar():\n    print('bar')\n"
        value = part[eoh + 4:-2]
        
        # 取出name 和 filename 的值
        name_values = {}
        for name_part in name_header[10:].split(";"):
            name, name_value = name_part.strip().split("=", 1)
            name_values[name] = name_value.strip('"').decode("utf-8")
        if not name_values.get("name"):
            logging.warning("multipart/form-data value missing name")
            continue
        name = name_values["name"]
        if name_values.get("filename"):
            ctype = headers.get("Content-Type", "application/unknown")
            # 往request的files里面填充值,files 是一个字典 {'name': [{'filename': filename, 'body': value, 'content_type':content_type}]}
            self._request.files.setdefault(name, []).append(dict(
                filename=name_values["filename"], body=value,
                content_type=ctype))
        else:
            # 没有文件名则把文件内容直接塞到arguments参数里面
            self._request.arguments.setdefault(name, []).append(value)
```

## finish

```python
def finish(self):
    assert self._request, "Request closed"
    self._request_finished = True
    if not self.stream.writing():
        self._finish_request()
```

## _finish_request

```python
    def _finish_request(self):
        if self.no_keep_alive:
            disconnect = True
        else:
            # keep-alive
            connection_header = self._request.headers.get("Connection")
            if self._request.supports_http_1_1():
                # False
                disconnect = connection_header == "close"
            elif ("Content-Length" in self._request.headers
                    or self._request.method in ("HEAD", "GET")):
                disconnect = connection_header != "Keep-Alive"
            else:
                disconnect = True
        self._request = None
        self._request_finished = False
        if disconnect:
            self.stream.close()
            return
        # 连接没有关闭，继续接受请求
        self.stream.read_until("\r\n\r\n", self._header_callback)
```

## write

```python
def write(self, chunk):
    assert self._request, "Request closed"
    if not self.stream.closed():
        self.stream.write(chunk, self._on_write_complete)
```