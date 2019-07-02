# RequestHandler

<font color="red">每一次请求都会生成一个RequestHandler对象，执行`_execute`方法</font>

## redirect

```python
def redirect(self, url, permanent=False):
    """Sends a redirect to the given (optionally relative) URL."""
    if self._headers_written:
        raise Exception("Cannot redirect after headers have been written")
    self.set_status(301 if permanent else 302)
    # Remove whitespace 去除空白
    url = re.sub(r"[\x00-\x20]+", "", _utf8(url))
    self.set_header("Location", urlparse.urljoin(self.request.uri, url))
    # 结束请求
    self.finish()
```

```python
re.sub(r"[\x00-\x20]+", "", 'dsadasd     adasd\r\n dadas\ndsas')
Out[6]: 'dsadasdadasddadasdsas'
```

## set_header

set_header 就是给`self._headers`赋值，`self._headers` 是一个字典。把很少的代码逻辑也封装成函数，一是为了减少代码量，而是为了语义更清晰。日后的开发中应该多注意这种抽象的函数或方法的剥离。

```python
def set_header(self, name, value):
    """Sets the given response header name and value.

    If a datetime is given, we automatically format it according to the
    HTTP specification. If the value is not a string, we convert it to
    a string. All header values are then encoded as UTF-8.
    """
    if isinstance(value, datetime.datetime):
        t = calendar.timegm(value.utctimetuple())
        # 'Fri, 17 May 2019 15:39:28 GMT'
        value = email.utils.formatdate(t, localtime=False, usegmt=True)
    elif isinstance(value, int) or isinstance(value, long):
        value = str(value)
    else:
        value = _utf8(value)
        # If \n is allowed into the header, it is possible to inject
        # additional headers or split the request. Also cap length to
        # prevent obviously erroneous values.
        safe_value = re.sub(r"[\x00-\x1f]", " ", value)[:4000]
        if safe_value != value:
            raise ValueError("Unsafe header value %r", value)
    self._headers[name] = value
```

## 普通cookies

请求携带的cookie。

```python
@property
def cookies(self):
    """A dictionary of Cookie.Morsel objects."""
    # 在同一次请求中 load 一遍之后就不需要再load了
    if not hasattr(self, "_cookies"):
        self._cookies = Cookie.BaseCookie()
        # 只有请求头携带Cookie才进行load操作
        if "Cookie" in self.request.headers:
            try:
                self._cookies.load(self.request.headers["Cookie"])
            except BaseException:
                self.clear_all_cookies()
    return self._cookies
```

采用property的方式，返回`self._cookies`(BaseCookie对象)。

### get_cookie

```python
def get_cookie(self, name, default=None):
    """Gets the value of the cookie with the given name, else default."""
    if name in self.cookies:
        return self.cookies[name].value
    return default
```

从请求头中获取cookie。

### set_cookie

```python
def set_cookie(self, name, value, domain=None, expires=None, path="/",
               expires_days=None, **kwargs):
    name = _utf8(name)
    value = _utf8(value)
    if re.search(r"[\x00-\x20]", name + value):
        # Don't let us accidentally inject bad stuff
        raise ValueError("Invalid cookie %r: %r" % (name, value))
    if not hasattr(self, "_new_cookies"):
        self._new_cookies = []
    new_cookie = Cookie.BaseCookie()
    # 这里使用列表self._new_cookies说明在一个请求中set_cookie可以调用多次, 生成多个BaseCookie对象放入列表
    self._new_cookies.append(new_cookie)
    new_cookie[name] = value
    if domain:
        new_cookie[name]["domain"] = domain
    if expires_days is not None and not expires:
        expires = datetime.datetime.utcnow() + datetime.timedelta(
            days=expires_days)
    # 如果同时提供expires和expires_days那么以expires优先
    if expires:
        timestamp = calendar.timegm(expires.utctimetuple())
        new_cookie[name]["expires"] = email.utils.formatdate(
            timestamp, localtime=False, usegmt=True)
    if path:
        new_cookie[name]["path"] = path
    for k, v in kwargs.iteritems():
        new_cookie[name][k] = v
```

服务端需要设置给客户端的cookie，和get_cookie扮演的角色不同。

## 加密cookies

### set_secure_cookie

```python
def set_secure_cookie(self, name, value, expires_days=30, **kwargs):
    """Signs and timestamps a cookie so it cannot be forged.

    You must specify the 'cookie_secret' setting in your Application
    to use this method. It should be a long, random sequence of bytes
    to be used as the HMAC secret for the signature.

    To read a cookie set with this method, use get_secure_cookie().
    """
    self.set_cookie(name, self.create_signed_value(name, value),
                    expires_days=expires_days, **kwargs)
```

#### create_signed_value

```python
def create_signed_value(self, name, value):
    """Signs and timestamps a string so it cannot be forged.

    Normally used via set_secure_cookie, but provided as a separate
    method for non-cookie uses.  To decode a value not stored
    as a cookie use the optional value argument to get_secure_cookie.
    """
    timestamp = str(int(time.time()))
    value = base64.b64encode(value)
    signature = self._cookie_signature(name, value, timestamp)
    # 把经过base64加密的value, 当前时间戳timestamp 和对 name、value 以及timestamp进行加密的三者拼接起来
    value = "|".join([value, timestamp, signature])
    return value
```

#### _cookie_signature

```python
def _cookie_signature(self, *parts):
    """
    hamc 进行加密处理
    :param parts:
    :return:
    """
    # settings必须提供关键字cookie_secret, 像这种必须提供属性也封装成一个方法
    self.require_setting("cookie_secret", "secure cookies")
    hash = hmac.new(self.application.settings["cookie_secret"],
                    digestmod=hashlib.sha1)
    for part in parts:
        hash.update(part)
    return hash.hexdigest()
```

### get_secure_cookie

```python
    def get_secure_cookie(self, name, include_name=True, value=None):
        """Returns the given signed cookie if it validates, or None.

        In older versions of Tornado (0.1 and 0.2), we did not include the
        name of the cookie in the cookie signature. To read these old-style
        cookies, pass include_name=False to this method. Otherwise, all
        attempts to read old-style cookies will fail (and you may log all
        your users out whose cookies were written with a previous Tornado
        version).
        """
        if value is None:
            # 从请求头的cookie中提取cookie
            value = self.get_cookie(name)
        if not value:
            return None
        # 分割解密
        parts = value.split("|")
        if len(parts) != 3:
            return None
        if include_name:
            signature = self._cookie_signature(name, parts[0], parts[1])
        else:
            signature = self._cookie_signature(parts[0], parts[1])
        # 判断签名是否相等
        if not _time_independent_equals(parts[2], signature):
            logging.warning("Invalid cookie signature %r", value)
            return None
        timestamp = int(parts[1])
        # cookie过期
        if timestamp < time.time() - 31 * 86400:
            logging.warning("Expired cookie %r", value)
            return None
        # cookie被篡改了, 日期竟然那么比未来的time.time()还大
        if timestamp > time.time() + 31 * 86400:
            # _cookie_signature does not hash a delimiter between the
            # parts of the cookie, so an attacker could transfer trailing
            # digits from the payload to the timestamp without altering the
            # signature.  For backwards compatibility, sanity-check timestamp
            # here instead of modifying _cookie_signature.
            logging.warning(
                "Cookie timestamp in future; possible tampering %r", value)
            return None
        # 时间戳不可能以0开头
        if parts[1].startswith("0"):
            logging.warning("Tampered cookie %r", value)
        try:
            # 解密数据
            return base64.b64decode(parts[0])
        except BaseException:
            return None
```

# 用户认证

tornado和flask一样，在requestHandler中current_user保存当前请求用户名，但默认值时空，需要用requestHandler.get_current_user属性设置该属性。

```python
import tornado.web
import tornado.ioloop
import uuid  # uuid生成库

dict_sessions = {}  # 保存所有登陆的session

class BaseHandler(tornado.web.RequestHandler):
    def get_current_user(self):  # 写入current_user函数
        session_id = self.get_secure_cookie('session')
        return dict_sessions.get(session_id)

class MainHandler(BaseHandler):
    @tornado.web.authenticated  # 需要身份认证才能访问的处理器
    def get(self):
        self.write('hello world')

class LoginHandler(BaseHandler):
    def get(self):
        self.write(
            '<html><body><form action="/login" method = "post">Name:<input type = "text" name = "name">:<input type = "submit" value = "sign in"></form></body></html>')

    def post(self):
        if len(self.get_argument('name')) < 3:
            self.redirect('/login')
        session_id = str(uuid.uuid1())
        dict_sessions[session_id] = self.get_argument('name')
        self.set_secure_cookie('session_id', session_id)
        self.redirect('/')

application = tornado.web.Application([(r'/', MainHandler), (r'/login', LoginHandler), ], cookie_secret='mimi',
                                      login_url='/login')

def main():
    application.listen(8888)
    tornado.ioloop.IOLoop.current().start()

if __name__ == '__main__':
    main()
```

## current_user

```python
@property
def current_user(self):
    """The authenticated user for this request.

    Determined by either get_current_user, which you can override to
    set the user based on, e.g., a cookie. If that method is not
    overridden, this method always returns None.

    We lazy-load the current user the first time this method is called
    and cache the result after that.
    """
    # lazy-load, 第一次计算之后下次就不用计算了
    if not hasattr(self, "_current_user"):
        self._current_user = self.get_current_user()
    return self._current_user
```

get_current_user 默认返回None, 需要被用户重写。

## get_login_url

```python
def get_login_url(self):
    """Override to customize the login URL based on the request.

    By default, we use the 'login_url' application setting.
    """
    self.require_setting("login_url", "@tornado.web.authenticated")
    return self.application.settings["login_url"]
```

## authenticated

```python
def authenticated(method):
    """Decorate methods with this to require that the user be logged in."""
    @functools.wraps(method)
    def wrapper(self, *args, **kwargs):
        # self.current_user 为 None 理解为用户未登陆(从cookie中没取到值)
        if not self.current_user:
            if self.request.method in ("GET", "HEAD"):
                url = self.get_login_url()
                if "?" not in url:
                    if urlparse.urlsplit(url).scheme:
                        # url 是绝对路径的url, 那么next_url也设置成绝对路径, 否则就设置为本次请求的相对url
                        # if login url is absolute, make next absolute too
                        next_url = self.request.full_url()
                    else:
                        next_url = self.request.uri
                    # url 后面带着从哪个请求来的
                    url += "?" + urllib.urlencode(dict(next=next_url))
                self.redirect(url)
                return
            raise HTTPError(403)
        # 方法的装饰器method是函数，需要主动传self
        return method(self, *args, **kwargs)
    return wrapper
```



# CSRF Token

目的是防御CSRF攻击。

Token就是令牌，最大的特点就是**随机性，不可预测**。

CSRF 攻击之所以能够成功，是因为黑客可以完全伪造用户的请求，该请求中所有的用户验证信息都是存在于 cookie 中，因此黑客可以在不知道这些验证信息的情况下直接利用用户自己的 cookie 来通过安全验证。要抵御 CSRF，关键在于在请求中放入黑客所不能伪造的信息，并且该信息不存在于 cookie 之中。**可以在 HTTP 请求中以参数的形式加入一个随机产生的 token，并在服务器端建立一个拦截器来验证这个 token，如果请求中没有 token 或者 token 内容不正确，则认为可能是 CSRF 攻击而拒绝该请求**。

这种方法要比检查 Referer 要安全一些，token 可以在用户登陆后产生并放于 session 之中，**然后在每次请求时把 token 从 session 中拿出**，与请求中的 token 进行比对，但这种方法的难点在于如何把 token 以参数的形式加入请求。对于 GET 请求，token 将附在请求地址之后，这样 URL 就变成 http://url?**csrftoken=tokenvalue**。 而对于 POST 请求来说，要在 form 的最后加上 <input type=”hidden” name=”csrftoken” value=”tokenvalue”/>，这样就把 token 以参数的形式加入请求了。

 

如果说这个Token是指的用户登录的凭据，并用以维持登录状态的话，**也就是说一个用户必须要输入用户名密码并验证通过后，服务器才会分配一个Token**，传回并储存在客户端作为凭证（同时储存在服务器上）。因此并不是每个人都可以获得这个Token，只有能提供正确用户密码的客户端才可以。

之后每一次操作，**都需要客户端向服务器提供这个Token**，以验证登录状态，如果考虑安全性的话，还可以增加对User-Agent、IP等信息的验证。

说明：理解token的作用，他是一个**随机的值**，**是服务器端前一个请求给的，是一次性的**，可以防止csrf这种恶意的携带自己站点的信息发请求或者提交数据（这个动作一般需要获取你的**前一个请求**的响应返回的token值，加大了难度，并不能完全杜绝）。
注意当然不能**写到cookie中**，因为浏览器在发出恶意csrf请求时，是自动带着你的cookie的。

## CSRF防范方法：

1. 验证码
2. refer头
3. Token

## RequestHandle的_execute的check_xsrf_cookie

```python
if self.request.method not in ("GET", "HEAD") and \
   self.application.settings.get("xsrf_cookies"):
    self.check_xsrf_cookie()
```

self.application.settings.get("xsrf_cookies") 为True表示开启xsrf验证功能。

## check_xsrf_cookie

```python
def check_xsrf_cookie(self):
    """Verifies that the '_xsrf' cookie matches the '_xsrf' argument.

    To prevent cross-site request forgery, we set an '_xsrf'
    cookie and include the same value as a non-cookie
    field with all POST requests. If the two do not match, we
    reject the form submission as a potential forgery.

    The _xsrf value may be set as either a form field named _xsrf
    or in a custom HTTP header named X-XSRFToken or X-CSRFToken
    (the latter is accepted for compatibility with Django).
    """
    token = (self.get_argument("_xsrf", None) or
             self.request.headers.get("X-Xsrftoken") or
             self.request.headers.get("X-Csrftoken"))
    if not token:
        raise HTTPError(403, "'_xsrf' argument missing from POST")
    if self.xsrf_token != token:
        raise HTTPError(403, "XSRF cookie does not match POST argument")
```

HTTP 403 ： 认证未通过。

## self.xsrf_token

```python
@property
def xsrf_token(self):
    """The XSRF-prevention token for the current user/session.

    To prevent cross-site request forgery, we set an '_xsrf' cookie
    and include the same '_xsrf' value as an argument with all POST
    requests. If the two do not match, we reject the form submission
    as a potential forgery.

    See http://en.wikipedia.org/wiki/Cross-site_request_forgery
    """
    # 手动设置上token,下次请求发送的时候就拿着这个token放在请求中带过来(无论是放在get参数还是header中)
    if not hasattr(self, "_xsrf_token"):
        token = self.get_cookie("_xsrf")
        if not token:
            token = binascii.b2a_hex(uuid.uuid4().bytes)
            expires_days = 30 if self.current_user else None
            self.set_cookie("_xsrf", token, expires_days=expires_days)
        self._xsrf_token = token
    return self._xsrf_token
```

```python
binascii.b2a_hex(uuid.uuid4().bytes)
Out[25]: '2bc49a2b23fe432786f95b352d1d159b'
binascii.b2a_hex('a')
Out[26]: '61'
```

binascii模块包含很多在二进制和ASCII编码的二进制表示转换的方法。通常情况不会直接使用这些功能，而是使用像UU，base64编码，或BinHex封装模块。 binascii模块包含更高级别的模块使用的，用C语言编写的低级高效功能。

这里有意思的一点是调用self.xsrf_token这个属性会自定在cookie里设置上_xsrf的token, 而不是像我们习惯性地理解self.xsrf_token = 'xxx'。而且这里的xsrf token不是放在session里的，是放在RequestHandle对象里的。



