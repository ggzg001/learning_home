Tornado的auth模块提供了一些常用的认证，可以参考里面的代码编写对接其他服务提供商的业务逻辑，比如说我们自己写的tornado的程序去看qq空间的图片等信息。

# OAuth2

OAuth2 是一个**开放授权标准，**它允许用户让第三方应用访问该用户在某服务的**特定私有资源**（QQ空间中用户的照片，可以不包含用户的小视频哦）但是不提供账号密码信息给第三方应用。

## OAuth2的四个重要角色

1. **Resource Owner**：资源拥有者，上面栗子中的**小明**；
2. **Resource Server**：资源服务器，上面栗子中的**QQ空间**，它是小明想要分享照片给PP的照片的提供方；
3. **Client**：第三方应用客户端，上面栗子中的**PP**，代指任何可以消费资源服务器的第三方应用；
4. **Authorization Server** ：授权服务器，管理**Resource Owner，Client和Resource Server的三角关系的中间层**。

## 作为Resource server

在一般情况下，Resource server提供Authorization server服务，主要提供两类接口：

1. 授权接口：接受Client的授权请求，引导用户到Resource server完成登陆授权的过程。
2. 获取访问令牌接口：使用授权接口提供的许可凭据来颁发Resource owner的访问令牌给Client，或者由Client更新过期的访问令牌。

除此之外，还需要提供一个第三方应用程序注册管理的服务。通常情况下会为注册完成的第三方应用程序分配两个成对出现的重要参数：

1. client_id：第三方应用程序的一个标识id，这个信息通常是公开的信息，用来区分哪一个第三方应用程序。
2. client_secret：第三方应用程序的私钥信息，这个信息是私密的信息，不允许在OAuth2流程中传递的，用于安全方面的检测和加密。

## 作为Client

在Client取得client_id和client_secret之后。使用这些信息来发起授权请求、获取access_token请求和消费受保护的资源。

![img](https://images2015.cnblogs.com/blog/168328/201612/168328-20161228154537320-2101529434.jpg)

## OAuth2的4种授权许可

OAuth2定义了四种许可类型以及用于定义其他类型的可扩展性机制：

1. Authorization Code：授权码；
2. Implicit：隐式许可；
3. Resource Owner Password Credentials：资源所有者密码凭据；
4. Client Credentials ：客户端凭据。

### Authorization Code

- **Client**使用浏览器（用户代理）访问**Authorization server。**也就是用浏览器访问一个URL，这个URL是**Authorization server**提供的，访问的收Client需要提供（客户端标识，请求范围，本地状态和重定向URL）这些参数。
- **Authorization server**验证**Client**在（A）中传递的参数信息，如果无误则提供一个页面供**Resource owner**登陆，登陆成功后选择**Client**可以访问**Resource server**的哪些资源以及读写权限。
- 在（B）无误后返回一个**授权码（Authorization Code）**给Client**。**
- **Client**拿着（C）中获得的**授权码（Authorization Code）**和（客户端标识、重定向URL等信息）作为参数，请求**Authorization server**提供的获取访问令牌的URL**。**
- **Authorization server**返回**访问令牌**和可选的**刷新令牌**以及**令牌有效时间**等信息给**Client**。

#### Authorization Request

对应步骤（A），客户端提供以下参数请求Authorization Server：

1. #### response_type：必选。值固定为“code”。

2. client_id：必选。第三方应用的标识ID。

3. state：**推荐**。Client提供的一个字符串，服务器会原样返回给Client。

4. redirect_uri：必选。授权成功后的重定向地址。

5. scope：可选。表示授权范围。

#### Authorization Response

对应步骤（C），Authorization Server会返回如下信息：

1. code：授权码。
2. state：步骤（A）中客户端提供的state参数原样返回。

比如示例如下：

> ```
> HTTP/1.1 302 Found
> Location: https://client.example.com/oauth2?code=SplxlOBeZQQYbYS6WxSbIA&state=xyz
> ```

Location头部信息指向步骤（A）提供的redirect_uri地址，同时携带code信息和state信息给client，这样浏览器在重定向的时候就会已GET的方式访问Client提供的redirect_uri。同时Client接收到redirect_uri发送的这个请求，那么在client这一端就可以接收到code信息和state信息。下一步就可以请求access_token了。请求access_token对用户来说可以是无感知的。

#### Access Token Request

对应步骤（D），客户端提供以下参数请求Authorization Server：

1. grant_type：必选。固定值“authorization_code”。
2. code : 必选。Authorization Response 中响应的code。
3. redirect_uri：必选。必须和Authorization Request中提供的redirect_uri相同。
4. client_id：必选。必须和Authorization Request中提供的client_id相同。

比如以下示例：

> ```
> POST /token HTTP/1.1
> Host: server.example.com
> Content-Type: application/x-www-form-urlencoded
> 
> grant_type=authorization_code&code=123&client_id=1&redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Foauth2
> ```

#### Access Token Response

对应步骤（E），Authorization Server会返回如下典型的信息：

1. access_token：访问令牌。
2. refresh_token：刷新令牌。
3. expires_in：过期时间。

比如以下示例：

> ```
> HTTP/1.1 200 OK
> Content-Type: application/json;charset=UTF-8
> 
> {
>    "access_token":"2YotnFZFEjr1zCsicMWpAA",
>    "token_type":"example",
>    "expires_in":3600, 
>    "refresh_token":"tGzv3JOkF0XG5Qx2TlKWIA", 
>    "example_parameter":"example_value"
> }
> ```

### Implicit

这个是Authorization Code的简化版本。其中省略掉了颁发授权码（Authorization Code）给客户端的过程，而是直接返回访问令牌和可选的刷新令牌。其适用于没有Server服务器来接受处理Authorization Code的第三方应用。

#### Authorization Request

客户端提供以下参数请求Authorization Server：

1. response_type：必选。值固定为“token”。
2. client_id：必选。第三方应用的标识ID。
3. state：**推荐**。Client提供的一个字符串，服务器会原样返回给Client。
4. redirect_uri：可选。授权成功后的重定向地址。
5. scope：可选。表示授权范围。

重点区别在于**response_type为“token”**，而不再是“code”，redirect_uri也变为了可选参数。

比如以下示例：

> ```
> GET /authorize?response_type=token&client_id=1&state=xyz&redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Foauth2&scope=user,photo HTTP/1.1
> Host: server.example.com
> ```

##### Access Token Response

Authorization Server会返回如下典型的信息：

1. access_token：访问令牌。
2. refresh_token：刷新令牌。
3. expires_in：过期时间。

比如以下示：

> ```
> HTTP/1.1 302 Found
> Location: http://client.example.com/oauth2#access_token=2YotnFZFEjr1zCsicMWpAA&state=xyz&expires_in=3600
> ```

注意其和Authorization Code的最大区别在于它是把token信息放在了url的hash部分（#后面），而不是作为参数(?后面)。这样浏览器在访问重定向的Location指定的url时，就不会把这些数据发送到服务器。而Client可以通过读取Location头信息中获取到access_token信息。

### Resource Owner Password Credentials Grant

这种模式再一步简化，和Authorzation Code类型下重要的区分就是省略了Authorization Request和Authorization Response。而是Client直接使用Resource owner提供的username和password来直接请求access_token（直接发起Access Token Request然后返回Access Token Response信息）。这种模式一般适用于Resource server高度信任第三方Client的情况下。

客户端提供以下参数请求Authorization Server：

1. grant_type：必选。值固定为“password”。
2. username：必选。用户登陆名。
3. passward：必选**。**用户登陆密码。
4. scope：可选。表示授权范围。

比如以下示例：

> ```
> POST /token HTTP/1.1
> Host: server.example.com
> Content-Type: application/x-www-form-urlencoded
> 
> grant_type=password&username=blackheart&password=1234
> ```

### Client Credentials Grant

这种类型就更简化了，Client直接已自己的名义而不是Resource owner的名义去要求访问Resource server的一些受保护资源。

客户端提供以下参数请求Authorization Server：

1. grant_type：必选。值固定为“client_credentials”。
2. scope：可选。表示授权范围。

比如以下示例：

> ```
> POST /token HTTP/1.1
> Host: server.example.com
> Content-Type: application/x-www-form-urlencoded
> 
> grant_type=client_credentials
> ```

Access Token Response和Authorization Code一致，就不列出来了。

公共号开发的经验，它提供由这类的OAuth2许可类型，这个场景下得到的access_token的所属人是公众号的，可以用此access_token来获取所有已关注的用户的信息，而不局限于特定的某一个用户，正是Client Credentials Grant这种类型的许可的用武之地

# OAuth2Mixin

```python
class OAuth2Mixin(object):
    """Abstract implementation of OAuth v 2."""

    def authorize_redirect(self, redirect_uri=None, client_id=None,
                           client_secret=None, extra_params=None ):
        """Redirects the user to obtain OAuth authorization for this service.

        Some providers require that you register a Callback
        URL with your application. You should call this method to log the
        user in, and then call get_authenticated_user() in the handler
        you registered as your Callback URL to complete the authorization
        process.
        """
        # 授权重定向, 往服务提供商的授权url _OAUTH_AUTHORIZE_URL 发起请求
        # 提供的参数是2个, 一个是重定向url, 另一个是client_id(用于标识client的身份)
        args = {
          "redirect_uri": redirect_uri,
          "client_id": client_id
        }
        if extra_params: args.update(extra_params)
        # 重定向到服务提供商的授权url上
        self.redirect(self._OAUTH_AUTHORIZE_URL +
              urllib.urlencode(args))

    def _oauth_request_token_url(self, redirect_uri= None, client_id = None,
                                 client_secret=None, code=None,
                                 extra_params=None):
        # 拼接请求access_token的url, 用 _OAUTH_ACCESS_TOKEN_URL, 参数新增加了code和client_secret
        url = self._OAUTH_ACCESS_TOKEN_URL
        args = dict(
            redirect_uri=redirect_uri,
            code=code,
            client_id=client_id,
            client_secret=client_secret,
            )
        if extra_params: args.update(extra_params)
        # 返回拼接的url
        return url + urllib.urlencode(args)
```

# FacebookGraphMixin

看一个连接facebook的例子，在这之前先了解一下RequestHandle的async_callback函数。

## async_callback

```python
def async_callback(self, callback, *args, **kwargs):
    """Obsolete - catches exceptions from the wrapped function.

    This function is unnecessary since Tornado 1.1.
    """
    if callback is None:
        return None
    if args or kwargs:
        callback = functools.partial(callback, *args, **kwargs)

    def wrapper(*args, **kwargs):
        try:
            return callback(*args, **kwargs)
        except Exception as e:
            if self._headers_written:
                logging.error("Exception after headers written",
                              exc_info=True)
            else:
                self._handle_request_exception(e)
    return wrapper
```

简单来说就是用functools.partial重新封装了一下函数.

```python
class FacebookGraphMixin(OAuth2Mixin):
    _OAUTH_ACCESS_TOKEN_URL = "https://graph.facebook.com/oauth/access_token?"
    _OAUTH_AUTHORIZE_URL = "https://graph.facebook.com/oauth/authorize?"
    _OAUTH_NO_CALLBACKS = False

    def get_authenticated_user(self, redirect_uri, client_id, client_secret,
                              code, callback, extra_fields=None):
      """ Handles the login for the Facebook user, returning a user object.

      Example usage:
      class FacebookGraphLoginHandler(LoginHandler, tornado.auth.FacebookGraphMixin):
        @tornado.web.asynchronous
        def get(self):
            if self.get_argument("code", False):
                self.get_authenticated_user(
                  redirect_uri='/auth/facebookgraph/',
                  client_id=self.settings["facebook_api_key"],
                  client_secret=self.settings["facebook_secret"],
                  code=self.get_argument("code"),
                  callback=self.async_callback(
                    self._on_login))
                return
            self.authorize_redirect(redirect_uri='/auth/facebookgraph/',
                                    client_id=self.settings["facebook_api_key"],
                                    extra_params={"scope": "read_stream,offline_access"})

        def _on_login(self, user):
          logging.error(user)
          self.finish()

      """

      # 这个请求之前一般发送了authorize_redirect请求获取了code了, 一般用于登录并把access_token存储起来
      http = httpclient.AsyncHTTPClient()
      args = {
        "redirect_uri": redirect_uri,
        "code": code,
        "client_id": client_id,
        "client_secret": client_secret,
      }

      fields = set(['id', 'name', 'first_name', 'last_name',
                    'locale', 'picture', 'link'])
      if extra_fields: fields.update(extra_fields)

      # 拿着code去发向_oauth_request_token_url 发送请求
      # 拿到access_token之后执行callback
      http.fetch(self._oauth_request_token_url(**args),
          self.async_callback(self._on_access_token, redirect_uri, client_id,
                              client_secret, callback, fields))

    def _on_access_token(self, redirect_uri, client_id, client_secret,
                        callback, fields, response):
      # 根据fetch的返回是response, 把response作为_on_access_token的最后一个参数
      if response.error:
          logging.warning('Facebook auth error: %s' % str(response))
          callback(None)
          return

      session = {
          "access_token": cgi.parse_qs(response.body)["access_token"][-1],
          "expires": cgi.parse_qs(response.body).get("expires")
      }
      # 拿着access_token 给facebook发送请求, 调用_on_get_user_info获取用户信息, 获取成功之后再调用callback
      self.facebook_request(
          path="/me",
          callback=self.async_callback(
              self._on_get_user_info, callback, session, fields),
          access_token=session["access_token"],
          fields=",".join(fields)
          )


    def _on_get_user_info(self, callback, session, fields, user):
        # user是返回的response
        if user is None:
            callback(None)
            return

        fieldmap = {}
        for field in fields:
            # 从返回的response取希望得到的属性field
            fieldmap[field] = user.get(field)

        fieldmap.update({"access_token": session["access_token"], "session_expires": session.get("expires")})
        # 用户的回调函数
        callback(fieldmap)

    def facebook_request(self, path, callback, access_token=None,
                           post_args=None, **args):
        """Fetches the given relative API path, e.g., "/btaylor/picture"

        If the request is a POST, post_args should be provided. Query
        string arguments should be given as keyword arguments.

        An introduction to the Facebook Graph API can be found at
        http://developers.facebook.com/docs/api

        Many methods require an OAuth access token which you can obtain
        through authorize_redirect() and get_authenticated_user(). The
        user returned through that process includes an 'access_token'
        attribute that can be used to make authenticated requests via
        this method. Example usage:

        class MainHandler(tornado.web.RequestHandler,
                          tornado.auth.FacebookGraphMixin):
            @tornado.web.authenticated
            @tornado.web.asynchronous
            def get(self):
                self.facebook_request(
                    "/me/feed",
                    post_args={"message": "I am posting from my Tornado application!"},
                    access_token=self.current_user["access_token"],
                    callback=self.async_callback(self._on_post))

            def _on_post(self, new_entry):
                if not new_entry:
                    # Call failed; perhaps missing permission?
                    self.authorize_redirect()
                    return
                self.finish("Posted a message!")

        """
        # 用户登录成功facebook之后可以拿着access_token去做想做的事
        url = "https://graph.facebook.com" + path
        all_args = {}
        if access_token:
            all_args["access_token"] = access_token
            all_args.update(args)
            all_args.update(post_args or {})
        if all_args: url += "?" + urllib.urlencode(all_args)
        callback = self.async_callback(self._on_facebook_request, callback)
        http = httpclient.AsyncHTTPClient()
        if post_args is not None:
            http.fetch(url, method="POST", body=urllib.urlencode(post_args),
                       callback=callback)
        else:
            http.fetch(url, callback=callback)

    def _on_facebook_request(self, callback, response):
        if response.error:
            logging.warning("Error response %s fetching %s", response.error,
                            response.request.url)
            callback(None)
            return
        callback(escape.json_decode(response.body))
```