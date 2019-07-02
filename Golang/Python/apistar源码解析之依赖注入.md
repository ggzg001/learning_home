# 开始

`self.injector.run(funcs, state)`
`self.injector = Injector(components, initial_components)`
self就是实例化的app，通过调用app某个属性对象injector的run方法，其中run传进去的参数是实际的参数，funcs(列表)和state(字典)。

# 静态类型检查

```
from typing import NewType

UserId = NewType('UserId', int)

def name_by_id(user_id: UserId) -> str:
    ...

UserId('user')          # Fails type check

name_by_id(42)          # Fails type check
name_by_id(UserId(42))  # OK

num = UserId(5) + 1     # type: int
```
Python是一门动态语言。在给python传参数的时候并没 有严格的类型限制。写python程序的时候，发现错误经常只能在执行的时候发现。有一些 错误由于隐藏的比较深，只有特定逻辑才会触发，往往导致需要花很多时间才能将语法错误慢慢排查出来。其实有一些错误是很明显的，假如能在写程序的时候发现这些错误，就能提高工作效率。
习惯了C/C++等编译语言，使用像Python这种动态语言，总有点不放心，特别是搭建比较大的系统的时候。Python静态语法检查工具就出现了。
注意：虽然上面的代码无法通过静态类型检查，但并不代表运行会报错。但是怎么说呢？一个好的python程序员都应该写出高质量的代码，这体现一个工程师的素养。

# inspect

```
import inspect

def test(a: int) -> dict:
    pass

args = inspect.signature(test).parameters

for k, v in args.items():
    # a <class 'str'> a:int <class 'inspect.Parameter'>
    print(k, type(k), v, type(v))

ret = inspect.signature(test).return_annotation
# <class 'dict'> <class 'type'>
print(ret, type(ret))
```

# 泛型

```
import inspect
from typing import Sequence, TypeVar

T = TypeVar("T")

def repeat(x: T, n: int) -> Sequence[T]:
    """Return a list containing n references to x."""
    return [x]*n

args = inspect.signature(repeat).parameters

for k, v in args.items():
    """
    x:~T <class 'inspect.Parameter'>
    n:int <class 'inspect.Parameter'>
    """
    print(v, type(v))
```
泛型 就是泛指任何类型

# component

什么是component？这是一个类还是一个实例对象？

```
class Component():
    def identity(self, parameter: inspect.Parameter):
        """
        Each component needs a unique identifier string that we use for lookups
        from the `state` dictionary when we run the dependency injection.
        """
        parameter_name = parameter.name.lower()
        annotation_name = parameter.annotation.__name__.lower()

        # If `resolve_parameter` includes `Parameter` then we use an identifier
        # that is additionally parameterized by the parameter name.
        args = inspect.signature(self.resolve).parameters.values()
        if inspect.Parameter in [arg.annotation for arg in args]:
            return annotation_name + ':' + parameter_name

        # Standard case is to use the class name, lowercased.
        return annotation_name

    def can_handle_parameter(self, parameter: inspect.Parameter):
        # Return `True` if this component can handle the given parameter.
        #
        # The default behavior is for components to handle whatever class
        # is used as the return annotation by the `resolve` method.
        #
        # You can override this for more customized styles, for example if you
        # wanted name-based parameter resolution, or if you want to provide
        # a value for a range of different types.
        #
        # Eg. Include the `Request` instance for any parameter named `request`.
        return_annotation = inspect.signature(self.resolve).return_annotation
        if return_annotation is inspect.Signature.empty:
            msg = (
                'Component "%s" must include a return annotation on the '
                '`resolve()` method, or override `can_handle_parameter`'
            )
            raise exceptions.ConfigurationError(msg % self.__class__.__name__)
        return parameter.annotation is return_annotation

    def resolve(self):
        raise NotImplementedError()
```

## 处理整数的PrimitiveParamComponent

```
class PrimitiveParamComponent(Component):
    def can_handle_parameter(self, parameter: inspect.Parameter):
        return parameter.annotation in (str, int, float, bool, parameter.empty)

    def resolve(self,
                parameter: inspect.Parameter,
                path_params: ValidatedPathParams,
                query_params: ValidatedQueryParams):
        params = path_params if (parameter.name in path_params) else query_params
        has_default = parameter.default is not parameter.empty
        allow_null = parameter.default is None

        param_validator = {
            parameter.empty: validators.Any(),
            str: validators.String(allow_null=allow_null),
            int: validators.Integer(allow_null=allow_null),
            float: validators.Number(allow_null=allow_null),
            bool: validators.Boolean(allow_null=allow_null)
        }[parameter.annotation]

        validator = validators.Object(
            properties=[(parameter.name, param_validator)],
            required=[] if has_default else [parameter.name]
        )

        try:
            params = validator.validate(params, allow_coerce=True)
        except validators.ValidationError as exc:
            raise exceptions.NotFound(exc.detail)
        return params.get(parameter.name, parameter.default)
```

# 流程图

怎样才能寻找到结果？找到一个可以处理的component，有且只有一个component，而且是第一个component可以处理即可，这样就执行到break,从而执行到step
`ValidatedPathParams = typing.NewType('ValidatedPathParams', dict)`得到的一个结果是NewType对象, 在路由里面的参数类型使用这种新的方式


## 第一次的resolve_function
参数：
func = get_user, 
output_name = None, 
seen_state = {'start_response', 'path_params', 'exc', 'environ', 'route', 'app', 'response'},
parent_parameter=None, 
set_return=True

运行过程产生的变量值：
steps = [], 
consts = {}, 
output_name = 'return_value', 
kwargs = {'app': 'app', 'user_id': 'int:user_id'},
seen_state = {'response', 'int:user_id', 'app', 'path_params', 'environ', 'route', 'exc', 'start_response'}

## 第二次的resolve_function

第二次的resolve_function 是为了处理get_user的user_id: int 这个参数，从而进入到这个递归当中。使用的component是PrimitiveParamComponent。

参数：
func = PrimitiveParamComponent().resolve, 
output_name = "int:user_id", 
seen_state = seen_state = {'response', 'int:user_id', 'app', 'path_params', 'environ', 'route', 'exc', 'start_response'},
parent_parameter = user_id:int,(inspect.Parameter类型) 
set_return = False

运行过程产生的变量值：
steps = [], 
const = {'parameter': <Parameter "user_id:int">}
output_name = "int:user_id"
seen_state = {'start_response', 'response', 'route', 'app', 'path_params', 'exc', 'int:user_id', 'validatedpathparams', 'environ'}
kwargs = {'path_params': 'validatedpathparams'}


## 第三次的resolve_function

第三次的resolve_function是为了处理PrimitiveParamComponent().resolve的第二个参数path_params:ValidatedPathParams这个参数, 使用的component是ValidatePathParamsComponent。

参数：
func = ValidatePathParamsComponent.resolve, 
output_name = "validatedpathparams", 
seen_state = {'start_response', 'response', 'route', 'app', 'path_params', 'exc', 'int:user_id', 'validatedpathparams', 'environ'},
parent_parameter = path_params:<function NewType.<locals>.new_type at 0x10e173b70>,(inspect.Parameter类型) 
set_return = False

运行过程产生的变量值：
steps = [],
const = {},
kwargs = {'route': 'route', 'path_params': 'path_params'}

## 第四次

为了处理PrimitiveParamComponent().resolve的最后一个参数query_params
parent_parameter = user_id:int 
kwargs = {'path_params': 'validatedpathparams'}
output_name = 'int:user_id'
seen_state = {'start_response', 'response', 'route', 'app', 'path_params', 'exc', 'int:user_id', 'validatedpathparams', 'environ'}
steps = <class 'list'>: [(<bound method ValidatePathParamsComponent.resolve of <apistar.server.validation.ValidatePathParamsComponent object at 0x10e160fd0>>, False, {'route': 'route', 'path_params': 'path_params'}, {}, 'validatedpathparams', False)]
identity = 'validatedqueryparams'

## 第五次

<bound method ValidateQueryParamsComponent.resolve of <apistar.server.validation.ValidateQueryParamsComponent object at 0x10e184048>>


kwargs = {'route': 'route', 'query_params': 'queryparams'}
seen_state = {'start_response', 'exc', 'environ', 'route', 'int:user_id', 'validatedpathparams', 'validatedqueryparams', 'response', 'queryparams', 'app', 'path_params'}

## 第六次

<bound method QueryParamsComponent.resolve of <apistar.server.wsgi.QueryParamsComponent object at 0x10e104518>>


scope 怎么变成environ了



render_response:
<class 'list'>: [(<bound method App.render_response of <apistar.server.app.App object at 0x10da20668>>, False, {'return_value': 'return_value'}, {}, 'response', True)]

finalize_wsgi:
[(<bound method App.finalize_wsgi of <apistar.server.app.App object at 0x10da20668>>, False, {'response': 'response', 'start_response': 'start_response'}, {}, 'return_value', True)]


格式是这样的：
func, is_async, kwargs, consts, output_name, set_return

(ValidatePathParamsComponent().resolve(self,
                route: Route,
                path_params: http.PathParams) -> ValidatedPathParams, 
  	False, 
  	{'route': 'route', 'path_params': 'path_params'}, 
  	{}, 
  	'validatedpathparams', 
  	False)
  	
  	validatedpathparams {'user_id': 2}
  	{'validatedpathparams': {'user_id': 2}}
----
(QueryParamsComponent().resolve(self,
                environ: WSGIEnviron) -> http.QueryParams, 
     False, 
     {'environ': 'environ'}, 
     {}, 'queryparams', 
     False)
     
     queryparams QueryParams([])
     {'queryparams': QueryParams([])}
----
(ValidateQueryParamsComponent().resolve(self,
                route: Route,
                query_params: http.QueryParams) -> ValidatedQueryParams, 
       False, 
       {'route': 'route', 'query_params': 'queryparams'}, 
       {}, 
       'validatedqueryparams', 
       False)
       
       validatedqueryparams {}
       {'validatedqueryparams': {}}
----
(PrimitiveParamComponent().resolve(self,
                parameter: inspect.Parameter,
                path_params: ValidatedPathParams,
                query_params: ValidatedQueryParams), 
        False, 
        {'path_params': 'validatedpathparams', 'query_params': 'validatedqueryparams'}, 
        {'parameter': <Parameter "user_id:int">}, 
        'int:user_id', 
        False)
        
        int:user_id 2
        {'int:user_id': 2}
----
(get_user(app: App, user_id: int) -> dict, 
	False, 
	{'app': 'app', 'user_id': 'int:user_id'}, 
	{}, 
	'return_value', 
	True)
	
	return_value {'username': 'james', 'url': '/users/2'}
	{'return_value': {'username': 'james', 'url': '/users/2'}}
----
(def render_response(self, return_value: ReturnValue) -> Response, 
	False, 
	{'return_value': 'return_value'}, 
	{}, 
	'response', 
	True)
	
	response <apistar.http.JSONResponse object at 0x104eb4828>
	{'response': <apistar.http.JSONResponse object at 0x104eb4828>}
----
(def finalize_wsgi(self, response: Response, start_response: WSGIStartResponse), 
	False, 
	{'response': 'response', 'start_response': 'start_response'}, 
	{}, 
	'return_value', 
	True)
	
	return_value [b'{"username":"james","url":"/users/2"}']
	{'return_value': [b'{"username":"james","url":"/users/2"}']}
----
{
	'environ': {'wsgi.version': (1, 0), 'wsgi.url_scheme': 'http', 'wsgi.input': <_io.BufferedReader name=6>, 'wsgi.errors': <_io.TextIOWrapper name='<stderr>' mode='w' encoding='UTF-8'>, 'wsgi.multithread': False, 'wsgi.multiprocess': False, 'wsgi.run_once': False, 'werkzeug.server.shutdown': <function WSGIRequestHandler.make_environ.<locals>.shutdown_server at 0x103eaf620>, 'SERVER_SOFTWARE': 'Werkzeug/0.14.1', 'REQUEST_METHOD': 'GET', 'SCRIPT_NAME': '', 'PATH_INFO': '/users/2', 'QUERY_STRING': '', 'REMOTE_ADDR': '127.0.0.1', 'REMOTE_PORT': 50847, 'SERVER_NAME': '0.0.0.0', 'SERVER_PORT': '8000', 'SERVER_PROTOCOL': 'HTTP/1.1', 'HTTP_HOST': '127.0.0.1:8000', 'HTTP_CONNECTION': 'keep-alive', 'HTTP_CACHE_CONTROL': 'max-age=0', 'HTTP_UPGRADE_INSECURE_REQUESTS': '1', 'HTTP_USER_AGENT': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36', 'HTTP_ACCEPT': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8', 'HTTP_ACCEPT_ENCODING': 'gzip, deflate, br', 'HTTP_ACCEPT_LANGUAGE': 'zh-CN,zh;q=0.9', 'werkzeug.request': <BaseRequest 'http://127.0.0.1:8000/users/2' [GET]>}, 
	'start_response': <function WSGIRequestHandler.run_wsgi.<locals>.start_response at 0x103eaf7b8>, 
	'exc': None, 
	'app': <apistar.server.app.App object at 0x103dd7e10>, 
	'path_params': {'user_id': 2}, 
	'route': <apistar.server.core.Route object at 0x10d071748>, 
	'response': None}


flake8 . | awk -F ':' '{print $1}' | uniq | xargs autopep8 --in-place --aggressive --max-line-length 79








