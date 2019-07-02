## 函数

### 普通函数

```python
def function():
    return 1
```

### 异步函数(协程)

```python
async def async_function():
    return 1
```

###普通生成器

```python
def generator():
    yield 1
```

###异步生成器 

```python
async def async_generator():
    yield 1
```

### 判断函数类型

```python
import types
print(type(function) is types.FunctionType)
print(type(generator()) is types.GeneratorType)
print(type(async_function()) is types.CoroutineType)
print(type(async_generator()) is types.AsyncGeneratorType)
```

### 驱动协程的运行

```python
def run(coroutine):
    try:
        coroutine.send(None)
    except StopIteration as e:
        return e.value
```

或者使用asyncio的loop进行调度

```python
async def async_function():
    return 1

async def await_coroutine():
    result = await async_function()
    print(result)
    
run(await_coroutine())
```

```python
from _collections_abc import Awaitable

class Awaitable(metaclass=ABCMeta):
    __slots__ = ()

    @abstractmethod
    def __await__(self):
        yield

    @classmethod
    def __subclasshook__(cls, C):
        if cls is Awaitable:
            return _check_methods(C, "__await__")
        return NotImplemented
```

## 异步迭代async for

能被async for迭代的是异步可迭代对象，必须实现`__aiter__`。`__aiter__`方法必须返回一个异步迭代器(必须实现`__anext__`方法)，和普通迭代器一样为了停止迭代，`__anext__`必须抛出一个`StopAsyncIteration`异常。其中，比较特殊的`__anext__`是方法返回一个awaitable类型的值。 

同步迭代：

```python
import time
from termcolor import colored


class Potato:

    @classmethod
    def make(cls, num, *args, **kwargs):
        potatos = []
        for i in range(num):
            potatos.append(cls.__new__(cls, *args, **kwargs))
        return potatos


def task_potatos(num):
    count = 0
    while count < num:
        if len(all_potatos) == 0:
            time.sleep(1)
        else:
            count += 1
            potato = all_potatos.pop()
            yield potato


def buy_potatos(num):
    for i in task_potatos(num):
        print(colored(str(i), "blue"))


if __name__ == '__main__':
    all_potatos = Potato.make(5)
    buy_potatos(10)
```

可以使用多线程或多进程去往篮子里放东西，也可以考虑协程去做这件事，而且协程编程的好处是更贴近我们的从上到下的同步编程逻辑。

```python
import time
from termcolor import colored


class Potato:

    @classmethod
    def make(cls, num, *args, **kwargs):
        potatos = []
        for i in range(num):
            potatos.append(cls.__new__(cls, *args, **kwargs))
        return potatos


async def ask_for_potatos():
    time.sleep(1)
    all_potatos.extend(Potato.make(1))


async def task_potatos(num):
    count = 0
    while count < num:
        if len(all_potatos) == 0:
            await ask_for_potatos()
        else:
            count += 1
            potato = all_potatos.pop()
            yield potato


async def buy_potatos(num):
    async for i in task_potatos(num):
        print(colored(str(i), "blue"))


def run(coroutine):
    try:
        coroutine.send(None)
    except StopIteration as e:
        return e.value


if __name__ == '__main__':
    all_potatos = Potato.make(5)
    run(buy_potatos(10))
```

## 异步类

定义了`async def`的方法都能被`await`, 比如类实例的普通方法也能用async语法修饰。同理还有类方法等。

```python
import asyncio
import inspect

class OneTwoThree:
    async def begin(self):
        print(1)
        await asyncio.sleep(0.5)
        print(2)
        await asyncio.sleep(0.5)
        print(3)
        await asyncio.sleep(0.5)
        return

async def game():
    o = OneTwoThree()
    print(inspect.iscoroutine(o.begin()))
    await o.begin()
    print("satrt")
```

## async with

```python
import asyncio

class GameContext:
    async def __aenter__(self):
        print('game loading')
        await asyncio.sleep(1)

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        print('game exit')
        await asyncio.sleep(1)

async def game():
    async with GameContext():
        print('game start')
        await asyncio.sleep(1)

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(game())
```

`__aenter__和__aexit__`只要是通过`async def`定义的方法就行，至于返回什么东西不重要。<font color="red">异步上下文管理器指的是在`__aenter__`和`__aexit__`方法处能够暂停执行的上下文管理器。</font>

在3.7版本，contextlib中会新增一个asynccontextmanager装饰器来包装一个实现异步协议的上下文管理器：

```python
from contextlib import asynccontextmanager

@asynccontextmanager
async def get_connection():
    conn = await acquire_db_connection()
    try:
        yield
    finally:
        await release_db_connection(conn)
```

async修饰符也能用在`__call__`方法上.

```python
class GameContext:
    async def __aenter__(self):
        self._started = time()
        print('game loading...')
        await asyncio.sleep(1)
        return self

    async def __aexit__(self, exc_type, exc, tb):
        print('game exit...')
        await asyncio.sleep(1)

    async def __call__(self, *args, **kws):
        if args[0] == 'time':
            return time() - self._started

async def game():
    async with GameContext() as ctx:
        print('game start...')
        await asyncio.sleep(2)
        print('game time: ', await ctx('time'))
```

asyncio是使用async/await语法开发的协程库，而不是有asyncio才能用async/await，除了asyncio之外，curio和trio是更加轻量级的替代物，而且也更容易使用。

```python
class AsyncIterator:
    def __init__(self, obj):
        self._it = iter(obj)

    async def __aiter__(self):
        return self

    async def __anext__(self):
        try:
            value = next(self._it)
        except StopIteration:
            raise StopAsyncIteration
        return value


def run(coroutine):
    try:
        coroutine.send(None)
    except StopIteration as e:
        return e.value


async def my_iter():
    async for letter in AsyncIterator("hello"):
        print(letter)

if __name__ == '__main__':
    run(my_iter())
```

