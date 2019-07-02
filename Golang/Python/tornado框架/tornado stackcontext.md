## 问题引出

异步函数执行的时候，抛出的异常已经和主函数的上下文不一致，为了解决这个问题，可以使用Python的上下文管理器进行wrapper。下面的代码，就存在异步异常在主函数中无法捕获的问题：

```python
import tornado.ioloop
import tornado.stack_context

ioloop = tornado.ioloop.IOLoop.instance()

times = 0

def callback():
    print 'run callback'
    raise ValueError('except in callback')

def async_task():
    global times
    times += 1
    print 'run async task {}'.format(times)
    ioloop.add_callback(callback=callback)


def main():
    try:
        async_task()
    except Exception as e:
        print 'main exception {}'.format(e)
    print 'end'
```

运行上述代码将会返回：

```python
run async task 1
end
run callback
ERROR:root:Exception in callback <tornado.stack_context._StackContextWrapper object at 0x10306f890>
Traceback (most recent call last):
  ...
    raise ValueError('except in callback')
ValueError: except in callback
```

async_task函数执行的时候，在注册了一个异步回调函数callback。可是在async_task的异常try逻辑中，callback抛出的异常无法正确的catch。也就是终端并没有输出`main exception except in callback`，而是仅仅输出了`except in callback`的异常。

## 初次解决

因为主函数无法捕获回调的异常，同时为了防止回调的异常蔓延到主函数，一个简单的思路就是在callback中进行try捕获。

```python
def callback():
    print 'run callback'
    try:
        raise ValueError('except in callback')
    except Exception as e:
        print 'main exception {}'.format(e)
```

看起来不错，在callback中写入了main函数的捕获逻辑。问题算是解决了。可是，这样的做法相当丑陋。如果主函数里针对callback异常还有别的业务逻辑，那么这样的写法就很死，甚至无法完成接下来的逻辑。

## 稍微进化

针对主函数无法catch，初次尝试把catch移步到callback中。这样的问题是涉及主函数逻辑会写死。如果异步的try作为一个包裹，而不是语法修改，会不会更好呢？写个 callback代码如下：

```python
def callback():
    print 'run callback'
    raise ValueError('except in callback')

def wrapper(func):
    try:
        func()
    except Exception as e:
        print 'main exception {}'.format(e)

def async_task():
    global times
    times += 1
    print 'run async task {}'.format(times)
    ioloop.add_callback(callback=functools.partial(wrapper, callback))

def main():
    wrapper(async_task)
```

运行之后，发现主函数可以catch callback中的异常了。这样做的思路其实很简单，因为callback会产生异常，并且这个异常需要蔓延传播到主函数，那么我们就挖一个坑，这个坑分别包裹callback和主函数，因为坑都是一样的，所有raise的异常可以定义在坑中。

注意：这里使用了functools.partial 避免了使用装饰器的方式，如果使用装饰器应该是这样的：

```python
def callback():
    print 'run callback'
    raise ValueError('except in callback')

def wrapper(func):
    def inner(*args, **kwargs):
        try:
            func()
        except Exception as e:
            print 'main exception {}'.format(e)
    return inner

def async_task():
    global times
    times += 1
    print 'run async task {}'.format(times)
    ioloop.add_callback(callback=wrapper(callback))

def main():
    wrapper(async_task)()
```

灵活性变大了，当然，这样做还是有限制，比如主函数需要另外一种坑，如果定义多个坑，那么还得修改 async_task中的wrapper，比较好的方式是在主函数可以动态的传递wrapper函数。这就涉及到全局变量。可以使用全局的字段存储多个不同的wrapper函数坑。

```python
times = 0

GLOBAL_WRAPPERS = {}

def callback():
    print 'run callback'
    raise ValueError('except in callback')

def wrapper(func):
    try:
        func()
    except Exception as e:
        print 'wrapper exception {}'.format(e)

def other_wrapper(func):
    try:
        func()
    except Exception as e:
        print 'other_wrapper exception {}'.format(e)

def async_task():
    global times
    times += 1
    print 'run async task {}'.format(times)
    ioloop.add_callback(callback=functools.partial(GLOBAL_WRAPPERS['context'], callback))

def main():
    GLOBAL_WRAPPERS['context'] = wrapper
    wrapper(async_task)

    GLOBAL_WRAPPERS['context'] = other_wrapper
    other_wrapper(async_task)
```

定义了一个全局变量，用于保存不同的函数坑，其实这个坑可以理解为函数执行的上下文。变换不同的上下文，异步callback也会跟着进入对应的上下文。这种技巧，tornado的stack_context用到了极致，相当巧妙。

## tornado stack_context 源码

对于stack_context的分析，主要采用tornado2.0的代码例子。tornado的源码附带的测试样例非常棒，不过我们还是写一个简单的使用stack_context的代码，然后再一步步看程序的执行。

```
times = 0

def callback():
    print 'Run callback'
    raise ValueError('except in callback')

def async_task():
    global times
    times += 1
    print 'run async task {}'.format(times)
    ioloop.add_callback(callback=callback)

@contextlib.contextmanager
def contextor():
    print 'Enter contextor'
    try:
        yield
    except Exception as e:
        print 'Handler except'
        print 'exception {}'.format(e)
    finally:
        print 'Release'

def main():
    with tornado.stack_context.StackContext(contextor):
        async_task()
    print 'End'
```

运行结果如下：

```
Enter contextor
run async task 1
Release
End
Enter contextor
Run callback
Handler except
exception except in callback
Release
```

从输出来看：

1. 首先进入contextor上下文管理器上下文
2. 执行 async 函数
3. 退出contextor上下文管理器上下文
4. 再次进入contextor上下文管理器上下文
5. 执行异步的callback
6. callback产生异常，执行 contextor上下文管理器的异常处理代码
7. 再次退出contextor上下文管理器上下文

所有上述的步骤，正如前面的分析，无论是主函数还是异步回调函数，都经过了stack_context的包裹（挖的坑），实现了上下文切换执行代码。具体而言，在我们的代码的with语句进行了一次包裹，ioloop.add_callback则进行了对回调的包裹。

### 创建Stack_context 上下文管理器

在main函数中，首先创建了Stack_context上下文管理器，然后通过with语句进入contextor上下文

```python
def main():
     stack_context = tornado.stack_context.StackContext(contextor)
    with stack_context:
        async_task()
    print 'End'
```

在 stack_context.py 文件中，实例StackContext的时候，将上下文管理contextor注入其中，然后调用 with语句的时候，执行StackContext的 `__enter__`方法：

```python
class StackContext(object):
    
    def __init__(self, context_factory):
            # 将上下文管理函数传到StackContext
        self.context_factory = context_factory
        
    def __enter__(self):
            # 存储旧的状态上下文
        self.old_contexts = _state.contexts
        # _state.contexts 是一个元组的结果，为StackContext和上下文管理函数 (class, arg) 这样的结构，下面就是更新 _state.contexts, 注意元组是不可修改的，所以它的赋值不是引用类型的现象
        _state.contexts = (self.old_contexts + 
                           ((StackContext, self.context_factory),))
        
        try:
                 # self.context_factory 是传递进来的上下文管理函数（contextor），通过调用self.context_factory创建上下文管理器。
            self.context = self.context_factory()
            # 调用上下文管理器的__enter__ 方法，进入contextor上下文环境
            self.context.__enter__()
        except Exception:
            _state.contexts = self.old_contexts
            raise
```

上述代码注释解释了大部分逻辑，需要额外注意是这个 `_state.context`。它是一个python线程的全局变量（theading.local），其职能类似GLOBAL_WRAPPER用于保存不同的上下文。他的特点就是每个线程都能把自己的私有数据写入，同时对于别的线程又是隔离不可见。一旦执行了`self.context.__enter__()`代码，函数控制上下文将会转移到上下文管理器(contextor)的`__enter__`方法中：

```python
def contextor():
     # StackContext 中执行 self.context = self.context_factory()将会转移到此
    print 'Enter contextor'
    try:
        yield
    except Exception as e:
        print 'Handler except'
        print 'exception {}'.format(e)
    finally:
        print 'Release'
```

此时可以看到控制台输出 'Enter contextor'的输出，同时被yield，函数控制权回到StackContext中的**enter**。

### 注册回调函数

接下来，进入到with语句后，`__enter__`方法返回后，执行async_task函数，而async_task调用了`ioloop.add_callback(callback=callback)`。下面来看里面的代码：

```python
    def add_callback(self, callback):
        if not self._callbacks:
            self._wake()
        # 将callback传递给stack_context，返回一个_StackContextWrapper对象，该其中保存了callback和aysnc_task的上下文对象元组(StackContext, contextor)
        self._callbacks.append(stack_context.wrap(callback))
```



首先判断包裹的函数（callback）是否为None，并且他是否已经被`_StackContextWrapper`包裹了，如果满足上面的条件，就直接返回。否则则进行_StackContextWrapper包裹。_StackContextWrapper其实就是一个偏函数functools.partial。这里需要注意的是 wreapped函数（稍后会用到），fn（被包裹的callback），状态上下文 _state.contexts。 _state.contexts就是之前 Stack_context.**enter**方法中创建的那个 （class，args） 元组。这样的做法，就是为了后面包裹回调函数的上下文环境保存起来。此时的_state.contexts是一个 StackContext和contextor的元组对，将会在wrapper函数中进行再一次包裹：即StackContext(contextor)。

### 执行callback

出现异常的逻辑在callback，到目前为止，还没有执行callback函数。从上面的经验可以看出，想要执行callback，首先需要上下文管理器包裹一下callback，然后进入callback上下文，执行callback，触发异常，进入callback的**exit**上下文。当然，无论是之前的对contextor的wrapper还是接下来对callback的wrapper，都是用的同一个上下文管理器 contextor。

继续代码的执行，将会运行到 ioloop.start方法

```
callbacks = self._callbacks
self._callbacks = []
for callback in callbacks:         
    self._run_callback(callback)
```

然后是在_run_callback中执行 callback()函数。

```
    def _run_callback(self, callback):
        try:
            callback()   # 此时成callback是一个被StackContext.wrap包裹的_StackContextWrappe对象。即可以通过contextor创建上下文环境，该上下文环境与async_task的一致
        except (KeyboardInterrupt, SystemExit):
            raise
        except:
            self.handle_callback_exception(callback)
```

注意此时的callback，并不是定义的callback，而是经过StackContext包裹的callback，具体在StackContext.wrap(callback)调用的时候，返回了偏函数的_StackContextWrapper 对象。因此调用_StackContextWrappe(),进入下面的StackContext.wrap函数的逻辑.

```python
def wrap(fn):
    
    '''
    if fn is None or fn.__class__ is _StackContextWrapper:
        return fn
   
    def wrapped(callback, contexts, *args, **kwargs):
            # 判断当前上下文（cls， args（contextor））是否在全局中保存。对于没有嵌套的StackContext.wrap，此时的条件不成立。如果是嵌套包裹，此时就直接调用callback。
        if contexts is _state.contexts or not contexts:
            callback(*args, **kwargs)
            return
        # 将 StackContext和contextor进行包裹
        if not _state.contexts:
            new_contexts = [cls(arg) for (cls, arg) in contexts]
        elif (len(_state.contexts) > len(contexts) or
            any(a[1] is not b[1]
                for a, b in itertools.izip(_state.contexts, contexts))):
            # contexts have been removed or changed, so start over
            new_contexts = ([NullContext()] +
                            [cls(arg) for (cls,arg) in contexts])
        else:
            new_contexts = [cls(arg)
                            for (cls, arg) in contexts[len(_state.contexts):]]
                            
        if len(new_contexts) > 1:
            with _nested(*new_contexts):
                callback(*args, **kwargs)
        elif new_contexts:
                # 再一次使用 StackContext包裹一个上下文处理器 contextor
            with new_contexts[0]:
                # 将callback在被StackContext包裹contextor执行callback
                callback(*args, **kwargs)
        else:
            callback(*args, **kwargs)
    return _StackContextWrapper(wrapped, fn, _state.contexts)
```

cls(arg)的做法，与main函数中的stack_context = tornado.stack_context.StackContext(contextor)。 一模一样。创建一个创建Stack_context 上下文管理器。至于with new_contexts则与StackContext.wrapper(connextor)的效果一致。进入contextor上下文环境，然后执行callback，此时进入上下文管理器的时候，也会打印 `Enter contextor`。然后就是真正的执行callback回调函数。因为发生异常，就触发了contextor的`__exit__`方法，然后执行了`print 'exception {}'.format(e)`代码，最后退出contextor上下文环境。完成callback的调用。

### 大体流程

1. StackContext(contextor)实例化创建上下文管理器，然后通过with语句调用，进入了contextor的 `__enter__`方法所打印输出
2.  进入with上下文环境，调用 async_task输出，同时ioloop注册回调函数。通过stack_context.wrap(callback)注册并保存与async_task上下文一样的管理器，并使用_StackContext偏函数返回_
3. _退出with代码块，执行contextor.**exit**方法输出
4. 主函数main继续执行打印
5. ioloop继续执行，调用callback回调，此时的callback是_StackContextWrapper对象，_StackContextWrapper调用 wrapper函数内逻辑，通过cls(args)创建一个新的上下文管理器，并通过with new_contexts[0]进入上下文管理器。
6. 进入 callback函数执行
7. 产生异常，触发新创建的上下文管理器的**exit**中的异常处理
8. 输出异常
9. 执行上下文管理器的finnaly分支，退出上下文管理器。

其中 2 步骤是处理上下文管理器的基础，5则是aync_task和callback上下文管理器包裹同步的关键。

![img](https://upload-images.jianshu.io/upload_images/11043-25c2f93ea9ed0688.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)

总而言之，async_task和callback的执行上下文本来不一样。为了解决问题，定义一个上下文管理器contextor。无论再调用async_task还是callback之前，先用StackContext管理contextor。初始执行async_task和callback函数逻辑的时候，都在contextor上下文环境中，并且异常抛出也一样。简化为一下步骤为：

1 使用StackContext(contextor) 创建一个上下文管理器，并将上下文管理函数推入_state.contexts 栈中
 2 执行 async_task函数，注册callback回调：将_state.contexts栈中的上下文管理函数出栈，创建一个_StackContextWrapper 对象，该对象存储了出栈的async_task上下文函数。此时ioloop注册的callback为_StackContextWrapper对象。
 3 ioloop调用callback，_StackContextWrapper中，将存储的上下文函数创建一个与syanc_task 一样的上下文管理器。在这个上下文环境中执行callback函数
 4 3步骤中也涉及了创建上下文管理器的_state.contexts入栈出栈操作，多嵌套的with则会操作对应的上下文函数。执行完callback（或产生异常），执行上下文管理器的**exit**方法。

4个步骤的关键在于通过_state.contexts栈的处理，将主函数上下文管理函数绑定给了callback。因此无论callback还是async_task的上下文，通过contextor管理器都变得一样了。

contextor就像一个桥梁，连接着async_task和callback。而StackContext就像一个工程师，如何把函数和异步回调之间架设桥梁。

### 总结

本篇使用了大量的文字描述stack_contextor 的原理，其实还比不过打断点执行一遍。当然，对于多个嵌套的with，stack_context模块同样使用，其关键就在于_state.context是一个上下文管理器的栈，通过他的入栈和出栈可以轻松应对嵌套环境下的上下文环境。

下面是一段多嵌套的代码和输出结果，具体原理就不再分析了：

```python
ioloop = tornado.ioloop.IOLoop.instance()

times = 0

def callback():
    print 'Run callback'
    raise ValueError('except in callback')

def async_task():
    global times
    times += 1
    print 'run async task {}'.format(times)
    ioloop.add_callback(callback=callback)

@contextlib.contextmanager
def A():
    print("Enter A context")
    try:
        yield
    except Exception as e:
        print("A catch the exception: %s" % e)
    finally:
        print("Exit A context")


@contextlib.contextmanager
def B():
    print("Enter B context")
    try:
        yield
    except Exception as e:
        print("B catch the exception: %s" % e)
    finally:
        print("Exit B context")


def main():
    with tornado.stack_context.StackContext(A):
        with tornado.stack_context.StackContext(B):
            async_task()

main()
ioloop.start()
```

输入结果很明了：

```
Enter A context
Enter B context
run async task 1
Exit B context
Exit A context
Enter A context
Enter B context
Run callback
B catch the exception: except in callback
Exit B context
Exit A context
```

先进入A的上下文，再进入B中，然后运行函数注册异步回调，退出B，再退出A。ioloop执行异步函数，再进入A，再进入B，运行回调，B发生异常，catch 捕获，退出B，再退出A 。

