# 几个概念

协程代码块:   一个入口点和下一个入口点(或者退出点)中的代码。
协程模块:  由n个入口点代码，和n个协程代码块组成。第一个入口点通常是一个函 数入口点。其组织形式如：函数入口点->协程代码块->入口点->协程代码块…，入口点和代码块相间。
线性模块：一个同步函数的函数体是线性执行的。也就是说一个模块中的每一行代码，相继执行，一个模块在执行中，如果还没有执行完毕，不会去执行其他模块的代码。称这样的代码模块为线性模块。

一个协程模块,如果只含有单一入口点和单一协程代码块(假设这个协程代码块全是同步代码),当然这个协程模块是一个线性执行模块，但是如果含有多个入口点和多个协程代码块，那么就不是一个线性模块。那么执行一个协程模块过程实际是分散的(不同的时间段，执行不同的协程代码块，协程代码块的执行时间段，彼此不相交)，但也是顺序的(后一个协程代码块在前一个协程代码块执行结束后才执行)。两个属于同一协程模块的相继协程代码块执行的中间时间间隙，可能有很多其他协程模块的协程代码片段在执行。

# 生成器和yield语义

在pep255中提到了”simple generator”和”yield语句”(此时还不是”yield表达式”)的实现。一个basic idea，**提供一种函数，能够返回中间结果给调用者，然后维护函数的局部状态，以便函数当离开后，也能恢复执行**。

Generator已经具备协程的一些能力。如：能够暂停执行，保存状态；能够恢复执行；能够异步执行。

但是此时Generator还不是一个协程。**一个真正的协程能够控制代码什么时候继续执行。而一个Generator执行遇到一个yield表达式 或者语句，会将执行控制权转移给调用者**。

在维基百科中提到，可以实现一个顶级的调度子例程，将执行控制权转移回Generator，从而让它继续执行。在tornado中，ioLoop就是这样的顶级调度子例程，每个协程模块通过，函数装饰器coroutine和ioLoop进行通信，从而ioLoop可以在协程模块执行暂停后，在合适的时机重新调度协程模块执行。

# Future类

Future类位于tornado源码的concurrent模块中。

```python
class Future(object):
    def done(self):
        return self._done

    def result(self, timeout=None):
        # 获取结果
        self._clear_tb_log()
        if self._result is not None:
            return self._result
        if self._exc_info is not None:
            raise_exc_info(self._exc_info)
        self._check_done()
        return self._result

    def add_done_callback(self, fn):
        # 可以先简单地理解为往_callbacks列表添加东西
        if self._done:
            fn(self)
        else:
            self._callbacks.append(fn)

    def set_result(self, result):
        # 比较重要的方法, 设置上值并依次调用_callbacks列表里的函数
        self._result = result
        self._set_done()

    def _set_done(self):
        # 把 self._done 设置成 True。
        self._done = True
        for cb in self._callbacks:
            try:
                cb(self)
            except Exception:
                app_log.exception('exception calling callback %r for %r',
                                  cb, self)
        self._callbacks = None
```

Future封装了异步操作的结果, 最终希望它被set_result,并且调用一些回调函数(用来驱动协程继续执行)。Future对象实际是coroutine函数装饰器和IOLoop的沟通使者，有着非常重要的作用。

# IOLoop类

tornado框架的底层核心类，位于tornado的ioloop模块。IOLoop主要调度处理的是IO事件(如读，写，错误)。除此之外，还能调度callback和timeout事件。

# 实例分析

```python
import tornado.ioloop
from tornado.gen import coroutine
from tornado.concurrent import Future

@coroutine
def asyn_sum(a, b):
    print("begin calculate:sum %d+%d"%(a,b))
    future = Future()

    def callback(a, b):
        print("calculating the sum of %d+%d:"%(a,b))
        future.set_result(a+b)
    tornado.ioloop.IOLoop.instance().add_callback(callback, a, b)

    result = yield future

    print("after yielded")
    print("the %d+%d=%d"%(a, b, result))

def main():
    asyn_sum(2, 3)
    tornado.ioloop.IOLoop.instance().start()

main()
```

```python
def coroutine(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        # TODO 这里的 future 是什么作用? 和 yielded 的future 是什么区别？
        future = _create_future()
        try:
            # result 就是得到的协程 gen
            result = func(*args, **kwargs)
        ...
        else:
            if isinstance(result, Generator):
                try:
                    # 在上面的实例中 yielded 就是在 asyn_sum 创建的future
                    yielded = next(result)
                ...
                else:
                    runner = Runner(result, future, yielded)
                    future.add_done_callback(lambda _: runner)
                yielded = None
                try:
                    return future
                finally:
                    future = None  # type: ignore
        future_set_result_unless_cancelled(future, result)
        return future
    wrapper.__wrapped__ = func  # type: ignore
    wrapper.__tornado_coroutine__ = True  # type: ignore
    return wrapper
```



```python
class Runner(object):
    def __init__(
        self,
        gen,
        result_future,
        first_yielded
    ):
        # 包裹了生成器 asyn_sum, 第一次next的返回以及在coroutine创建的future(result_future结果future)
        self.gen = gen
        self.result_future = result_future
        self.future = _null_future  # type: Union[None, Future]
        self.running = False
        self.finished = False
        self.io_loop = IOLoop.current()
        if self.handle_yield(first_yielded):
            gen = result_future = first_yielded = None  # type: ignore
            self.run()
```



```python
def handle_yield(self, yielded: _Yieldable) -> bool:
    try:
        # 在这里分清 self.future(asyn_sum返回的future对象) 和 self.result_future (是在coroutine里创建的future对象)。
        self.future = convert_yielded(yielded)
    ...
    if self.future is moment:
        self.io_loop.add_callback(self.run)
        return False
    elif self.future is None:
        raise Exception("no pending future")
    # 检查self.future的状态，因为ioloop还没有进行调度
    elif not self.future.done():
        def inner(f: Any) -> None:
            # Break a reference cycle to speed GC.
            f = None  # noqa: F841
            self.run()
        self.io_loop.add_future(self.future, inner)
        return False
    return True
```

```python
def add_future(
        self,
        future,
        callback
) -> None:
    if isinstance(future, Future):
        # 给asyn_sum的future添加回调函数
        future.add_done_callback(lambda f: self._run_callback(functools.partial(callback, future)))
    else:
        assert is_future(future)
        future_add_done_callback(
            future, lambda f: self.add_callback(callback, future))
```

一旦 `tornado.ioloop.IOLoop.instance().start()` 启动事件循环, 那么ioloop添加的回调函数(tornado.ioloop.IOLoop.instance().add_callback(callback, a, b))都会被执行. 此时future.set_result(a+b)之后就会调用future里设置的callback回调函数，也就是里面设置的inner。

```python
def run(self) -> None:
    if self.running or self.finished:
        return
    try:
        self.running = True
        while True:
            # 这里的 future 就是 aync_sum 里返回的future
            future = self.future
            if future is None:
                raise Exception("No pending future")
            if not future.done():
                return
            self.future = None
            try:
                exc_info = None

                try:
                    value = future.result()
                ...
                else:
                    # 继续执行 asyn_sum 生成器
                    yielded = self.gen.send(value)
            ...
            # 下一次寻找yield的过程
            if not self.handle_yield(yielded):
                return
            yielded = None
    finally:
        self.running = False
```

这里的Runner可以看做是asynico中驱动gen运行的task。

上面的例子说明了ioloop进行callback的调度，在调度过程中某一个future被设置上result，就会进行这个future的callback调度，在future的这些callback中会有一个内置的类似于step的函数，用于驱动生成器gen的运行。





 

