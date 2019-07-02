# 基础代码

users.py
```
from apistar import App, Route, exceptions
USERS = {1: 'hazel', 2: 'james', 3: 'ana'}
def list_users(app: App) -> list:
    return [
        {
            'username': username,
            'url': app.reverse_url('users:get_user', user_id=user_id)
        } for user_id, username in USERS.items()
    ]
def get_user(app: App, user_id: int) -> dict:
    if user_id not in USERS:
        raise exceptions.NotFound()
    return {
        'username': USERS[user_id],
        'url': app.reverse_url('users:get_user', user_id=user_id)
    }
routes = [
    Route('/', method='GET', handler=list_users),
    Route('/{user_id}', method='GET', handler=get_user),
]
```

app.py
```
from apistar import App, Include
from myproject import users
from uvicorn import run
routes = [
    Include('/users', name='users', routes=users.routes)
]
app = App(routes=routes)
if __name__ == '__main__':
    # run(app)
    app.__call__
    app.serve(host='0.0.0.0', port=8000, debug=True)
```

## app.__call__

```
    def __call__(self, environ, start_response):
        state = {
            'environ': environ,
            'start_response': start_response,
            'exc': None,
            'app': self,
            'path_params': None,
            'route': None,
            'response': None,
        }
        method = environ['REQUEST_METHOD'].upper()
        path = environ['PATH_INFO']
        if self.event_hooks is None:
            on_request, on_response, on_error = [], [], []
        else:
            on_request, on_response, on_error = self.get_event_hooks()

        try:
            route, path_params = self.router.lookup(path, method)
            state['route'] = route
            # path_params: {'user_id': 1}
            state['path_params'] = path_params
            if route.standalone:
                funcs = [route.handler]
            else:
                funcs = (
                    on_request +
                    [route.handler, self.render_response] +
                    on_response +
                    [self.finalize_wsgi]
                )

            return self.injector.run(funcs, state)
        except Exception as exc:
            try:
                state['exc'] = exc
                funcs = (
                    [self.exception_handler] +
                    on_response +
                    [self.finalize_wsgi]
                )
                return self.injector.run(funcs, state)
            except Exception as inner_exc:
                try:
                    state['exc'] = inner_exc
                    self.injector.run(on_error, state)
                finally:
                    funcs = [self.error_handler, self.finalize_wsgi]
                    return self.injector.run(funcs, state)
```
代码大致流程：

1. 获取请求方法和请求路径


2. 根据请求方法和请求路径去app.router对象去匹配出route和path_params


3. 查看是否有event_hooks,也就是中间件


4. 把所有的参数信息等都放在state这个大字典里


5. 有请求参数，有请求对应的函数，执行即可，只不过这里并不是函数的简单执行，而是self.injector.run(funcs, state),因为涉及到依赖注入的问题

下面对代码做几点说明：

1. route.standalone： 类似于开关，可以控制是否开启中间件


2. 获取中间件把请求和响应或异常做了区分：on_request, on_response, on_error = self.get_event_hooks()

3. environment 是一个存放了请求信息的大字典

4. state 这个字典含有请求和响应，最终会把响应从这里发出去

# self.router 

代码里有一句self.router.lookup(path, method)，其中self.router是Router对象，Router对象究竟是个啥玩意？
而且把router对象作为app对象的一个属性，这种方式是写源码一个比较好的参考方式。

```
    def walk_routes(self, routes, url_prefix='', name_prefix=''):
        # 先申明数据变量，里面存放的是一个元组形式，即数据结构是[(), (), ()]
        walked = []
        for item in routes:
            if isinstance(item, Route):
                # item.url  item.name 等方式把route对象的某些属性抽离出来，因为这些属性对于路由匹配是有用的信息
                result = (url_prefix + item.url, name_prefix + item.name, item)
                walked.append(result)
            elif isinstance(item, Include):
                # 递归
                result = self.walk_routes(
                    item.routes,
                    url_prefix + item.url,
                    name_prefix + item.name + ':'
                )
                walked.extend(result)
        # [('/users/', 'users:list_users', <apistar.server.core.Route object at 0x10d16bb00>),
        # ('/users/{user_id}', 'users:get_user', <apistar.server.core.Route object at 0x10d16bcf8>)]
        # 有递归的result = self.walk_routes() ，所以必须得有返回
        return walked
```

```
    def __init__(self, routes):
        rules = []
        name_lookups = {}

        for path, name, route in self.walk_routes(routes):
            # path_params 是请求路径参数
            path_params = [
                item.strip('{}') for item in re.findall('{[^}]*}', path)
            ]
            # args 是一个 OrderedDict 类型
            args = inspect.signature(route.handler).parameters
            # 对path如/users/{user_id} 含有 {user_id} 这种，把path进行修改
            for path_param in path_params:
                if path_param.startswith('+'):
                    path = path.replace(
                        '{%s}' % path_param,
                        "<path:%s>" % path_param.lstrip('+')
                    )
                elif path_param in args and args[path_param].annotation is int:
                    path = path.replace(
                        '{%s}' % path_param,
                        "<int:%s>" % path_param
                    )
                elif path_param in args and args[path_param].annotation is float:
                    path = path.replace(
                        '{%s}' % path_param,
                        "<float:%s>" % path_param
                    )
                else:
                    path = path.replace(
                        '{%s}' % path_param,
                        "<string:%s>" % path_param
                    )
            # 把path修改成flask的path，下面的两行代码加上self.adapter = Map(rules).bind('')可以参照flask源码，几乎一样
            # 里面封装了path， method 和 name
            rule = Rule(path, methods=[route.method], endpoint=name)
            rules.append(rule)
            # 因为这里的name和flask的name还不太一样，所以单独使用这个字典
            name_lookups[name] = route
        # self.adapter的rule里面封装了path， method 和 name
        self.adapter = Map(rules).bind('')
        self.name_lookups = name_lookups

        # Use an MRU cache for router lookups.
        self._lookup_cache = dict_type()
        self._lookup_cache_size = 10000
```

```
    def lookup(self, path: str, method: str):
        # _lookup_cache 是这样的一种数据结构 {lookup_key:(route, path_params)}
        lookup_key = method + ' ' + path
        try:
            return self._lookup_cache[lookup_key]
        except KeyError:
            pass

        try:
            name, path_params = self.adapter.match(path, method)
        except werkzeug.exceptions.NotFound:
            raise exceptions.NotFound() from None
        except werkzeug.exceptions.MethodNotAllowed:
            raise exceptions.MethodNotAllowed() from None
        except werkzeug.routing.RequestRedirect as exc:
            path = urlparse(exc.new_url).path
            raise exceptions.Found(path) from None

        route = self.name_lookups[name]

        self._lookup_cache[lookup_key] = (route, path_params)
        if len(self._lookup_cache) > self._lookup_cache_size:
            self._lookup_cache.pop(next(iter(self._lookup_cache)))

        return (route, path_params)
```
lookup的触发是来自真实的请求的参数，并非是内部消化。其中的name, path_params = self.adapter.match(path, method)得到的path_params是一个字典，通过path和method得到path_params的过程与apistar框架无关。这个方法体现了一个编程的点：先从缓存里拿，没有去手动获取，获取之后再往缓存里放。

补充一个用于兼容性的知识点：
```
import collections
import sys
if sys.version_info < (3, 6):
    dict_type = collections.OrderedDict
else:
    dict_type = dict
```

```
sys.version
Out[27]: '3.6.3 (v3.6.3:2c5fed86e0, Oct  3 2017, 00:32:08) \n[GCC 4.2.1 (Apple Inc. build 5666) (dot 3)]'
sys.version_info
Out[28]: sys.version_info(major=3, minor=6, micro=3, releaselevel='final', serial=0)
```
由此可见，version_info是一个类tuple对象，version是一个字符串

## werkzeug.routing

```
from werkzeug.routing import Map, Rule

rules = []
path = "/users"
rule = Rule(path, methods=["GET"], endpoint="users")
rules.append(rule)
path = "/users/<int:uid>"
rule = Rule(path, methods=["GET"], endpoint="users:detail")
rules.append(rule)

# <werkzeug.routing.MapAdapter object at 0x10c6464a8>
adapter = Map(rules).bind('')

name, path_params = adapter.match("/users/2", "GET")
# users:detail {'uid': 2}
print(name, path_params)
# /users/12
print(adapter.build(name, {"uid": 12}))
```









