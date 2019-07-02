**进程/线程：操作系统提供的一种并发处理任务的能力。**

**协程：程序员通过高超的代码能力，在代码执行流程中人为的实现多任务并发，是单个线程内的任务调度技巧。**

几个概念：

1. event_loop 事件循环：程序开启一个无限的循环，程序员会把一些函数注册到事件循环上。当满足事件发生的时候，调用相应的协程函数。

2. coroutine 协程：协程对象，指一个使用async关键字定义的函数，它的调用不会立即执行函数，而是会返回一个协程对象。协程对象需要注册到事件循环，由事件循环调用。

3. task  任务：一个协程对象就是一个原生可以挂起的函数，任务则是对协程进一步封装，其中包含任务的各种状态。

## task

```python
import asyncio

async def do_some_thing(x):
    await asyncio.sleep(.2)
    print("wait... ", x)
    return x

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    coroutine = do_some_thing(10)
    # task = asyncio.ensure_future(coroutine)
    task = loop.create_task(coroutine)
    loop.run_until_complete(task)
```

task对象是Future的子类，可以看到coroutine的状态。

## 给task绑定回调

绑定回调，在task执行完毕的时候可以获取执行的结果，回调的最后一个参数是future对象，通过该对象可以获取协程返回值。如果回调需要多个参数，可以通过偏函数导入。

```python
import asyncio
from functools import partial

async def do_some_thing(x):
    await asyncio.sleep(.2)
    print("wait... ", x)
    return x

def callback(x, future):
    print(x, future.result())

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    coroutine = do_some_thing(10)
    # task = asyncio.ensure_future(coroutine)
    task = loop.create_task(coroutine)
    task.add_done_callback(partial(callback, 10))
    loop.run_until_complete(task)
```

coroutine执行结束时候会调用回调函数。并通过参数future获取协程执行的结果。我们创建的task和回调里的future对象，实际上是同一个对象。

## 并发

```python
import asyncio

async def do_some_thing(x):
    await asyncio.sleep(.2)
    print("wait... ", x)
    return x

async def main():
    tasks = []
    for i in range(3):
        tasks.append(asyncio.ensure_future(do_some_thing(i)))
    # return await asyncio.gather(*tasks)
    done, pending = await asyncio.wait(tasks)
    for f in done:
        print(f.result())

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    coroutine = main()
    task = loop.create_task(coroutine)
    loop.run_until_complete(task)
```

如果使用的是 asyncio.gather创建协程对象，那么await的返回值就是协程运行的结果。

不在main协程函数里处理结果，直接返回await的内容，那么最外层的run_until_complete将会返回main协程的结果。

## 协程停止

协程状态：

- Pending
- Running
- Done
- Cancelled

```python
import asyncio

async def do_some_thing(x):
    await asyncio.sleep(x)
    print("wait... ", x)
    return x

async def main():
    tasks = []
    for i in range(1, 4):
        tasks.append(asyncio.ensure_future(do_some_thing(i)))
    done, pending = await asyncio.wait(tasks)
    for f in done:
        print(f.result())

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    coroutine = main()
    task = loop.create_task(coroutine)
    try:
        loop.run_until_complete(task)
    except KeyboardInterrupt:
        # print(asyncio.Task.all_tasks())
        for task in asyncio.Task.all_tasks():
            print(task.cancel())
        # print(asyncio.gather(*asyncio.Task.all_tasks()).cancel())
        loop.stop()
        loop.run_forever()
    finally:
        loop.close()
```

## 多线程下的协程

### 不同线程的事件循环

很多时候，我们的事件循环用于注册协程，而有的协程需要动态的添加到事件循环中。一个简单的方式就是使用多线程。当前线程创建一个事件循环，然后在新建一个线程，在新线程中启动事件循环。当前线程不会被block。

```python
import asyncio
import time
from threading import Thread

# async def do_some_thing(x):
#     await asyncio.sleep(x)
#     print("wait... ", x)
#     return x
def do_some_thing(x):
    time.sleep(x)
    print("wait... ", x)
    return x

def start_loop(loop):
    asyncio.set_event_loop(loop)
    loop.run_forever()

loop = asyncio.new_event_loop()
Thread(target=start_loop, args=(loop, )).start()
# 在主线程中注册事件
loop.call_soon_threadsafe(do_some_thing, 3)
loop.call_soon_threadsafe(do_some_thing, 5)
```

启动上述代码之后，当前线程不会被block，新线程中会<font color="red">按照顺序执行call_soon_threadsafe方法注册的do_some_thing方法</font>，后者因为time.sleep操作是同步阻塞的，因此运行完毕more_work需要大致5 + 3.

### 主线程注册协程 

```python
import asyncio
import time
from threading import Thread

async def do_some_thing(x):
    await asyncio.sleep(x)
    print("wait... ", x)
    return x


def start_loop(loop):
    asyncio.set_event_loop(loop)
    loop.run_forever()

loop = asyncio.new_event_loop()
t = Thread(target=start_loop, args=(loop, ))
t.start()
# 在主线程中注册事件
asyncio.run_coroutine_threadsafe(do_some_thing(3), loop)
asyncio.run_coroutine_threadsafe(do_some_thing(5), loop)
```

上述的例子，主线程中创建一个new_loop，然后在另外的子线程中开启一个无限事件循环。主线程通过run_coroutine_threadsafe新注册协程对象。这样就能在子线程中进行事件循环的并发操作，同时主线程又不会被block。一共执行的时间大概在5s左右。

### aiohttp基本使用

```python
import aiohttp

async def gen_message():
    async with aiohttp.ClientSession() as session:
        async with session.get("http://www.baidu.com") as response:
            res = response.read()
            return res
```



