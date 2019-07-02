生成器对象是一个迭代器。但是它比迭代器对象多了一些方法，它们包括send方法，throw方法和close方法。这些方法，主要是用于外部与生成器对象的交互。

## send

```python
def gen():
    value = 1
    while True:
        value = yield value
g = gen()
# 执行下面一句代码的时候yield value这条语句已经执行完毕了
print(next(g))
print(g.send(2))
print(g.send(3))
```

当执行`next(g)`代码的时候yield value这条语句已经执行完毕了.另外生成器执行完毕会自动抛出StopIterration异常对象。

## throw

throw实现手段是通过向生成器对象<font color="red">在上次被挂起处，抛出一个异常。</font>可以在yield挂起处进行异常捕获，如果不捕获这个异常会向上抛出。

```python
def gen():
    value = 1
    while True:
        yield value
        value += 1
g = gen()
print(next(g))
print(next(g))
print(g.throw(Exception, "Method throw called"))
"""
1
2
Traceback (most recent call last):
  File "/Users/guwanhua/git/castle/tricks/entrance/进程/test.py", line 9, in <module>
    print(g.throw(Exception, "Method throw called"))
  File "/Users/guwanhua/git/castle/tricks/entrance/进程/test.py", line 4, in gen
    yield value
Exception: Method throw called
"""
```

加入异常捕获：

```python
def gen():
    value = 1
    while True:
        try:
            yield value
            value += 1
        except:
            value = 1
g = gen()
print(next(g))
print(next(g))
print(g.throw(Exception, "Method throw called"))
print(next(g))
print(next(g))
"""
1
2
1
2
3
Exception ignored in: <generator object gen at 0x1033ae3b8>
RuntimeError: generator ignored GeneratorExit
"""
```

加入了一个try-except语句块处理异常。当生成器方法收到异常后，会调到except语句块，将value置为1

<font color="red">报RunTimeError错误的原因：</font>

在执行完throw后，生成器对象方法的while循环并没有结束，也即是说生成器方法的执行还没有结束。这个时候如果强制结束主程序，会抛出一个RuntimeError。也就是上面输出的第4行。对于这种出现异常并捕获处理的生成器，要优雅地关闭主程序，需要用到生成器对象的close方法。<font color="red">真实原因是主程序结束前系统产生GeneratorExit异常，被生成器对象方法的except语句捕获，但是此时while语句还没有退出，因此后面还会执行“yield value”这一语句，从而发生RuntimeError。</font>

## GeneratorExit

<font color="red">当一个生成器对象被销毁时，会抛出一个GeneratorExit异常。而GeneratorExit异常产生的时机，是在生成器对象被销毁之前。</font>

```python
def gen():
    try:
        yield 1
        yield 2
    except GeneratorExit:
        print("gen exit")

g = gen()
print(next(g))
del g
print("main exit")
"""
1
gen exit
main exit
"""
```

值得一提的是，GeneratorExit异常只有在生成器对象被激活后，才有可能产生。更确切的说，需要至少调用一次生成器对象的next方法后，系统才会产生GeneratorExit异常。

```python
def gen():
    try:
        yield 1
        yield 2
    except GeneratorExit:
        print("gen exit")

g = gen()
del g
print("main exit")
"""
main exit
"""
```

在平常的很多代码中，我们并不能经常看到捕获GeneratorExit但是生成器对象也不会把该异常向主程序抛出，这是因为GeneratorExit异常定义的初衷，是方便开发者在生成器对象调用结束后定义一些收尾的工作，如释放资源等。

值得注意的是：<font color="red">GeneratorExit异常的产生意味着生成器对象的生命周期已经结束。因此，一旦产生了GeneratorExit异常，生成器方法后续执行的语句中，不能再有yield语句，否则会产生RuntimeError。</font>

## close

<font color="red">生成器对象的close方法会在生成器对象方法的挂起处抛出一个GeneratorExit异常。GeneratorExit异常产生后，系统会继续把生成器对象方法后续的代码执行完毕。</font>

```python
def gen():
    try:
        yield 1
    except GeneratorExit:
        print("close")
    print('gen over')

g = gen()
print(next(g))
g.close()
print('main exit')
"""
1
close
gen over
main exit
"""
```

```python
def gen():
    try:
        yield 1
    except GeneratorExit:
        print("close")
    yield 2

g = gen()
print(next(g))
g.close()
print('main exit')
"""
1
close
Traceback (most recent call last):
  File "/Users/guwanhua/git/castle/tricks/entrance/进程/test.py", line 10, in <module>
    g.close()
RuntimeError: generator ignored GeneratorExit
"""
```

```python
def gen():
    value = 1
    while True:
        try:
            yield value
            value += 1
        except:
            value = 1
g = gen()
print(next(g))
print(next(g))
print(g.throw(Exception, "Method throw called"))
"""
1
2
1
Exception ignored in: <generator object gen at 0x1033ae3b8>
RuntimeError: generator ignored GeneratorExit
"""
```

去除上面的RuntimeError的方法非常简单：

```python
def gen():
    value = 1
    while True:
        try:
            yield value
            value += 1
        except Exception:
            value = 1
g = gen()
print(next(g))
print(next(g))
print(g.throw(Exception, "Method throw called"))

```

except语句声明只捕获Exception异常对象。这样，当系统产生GeneratorExit异常后，不再被except Exception语句捕获，继续向外抛出，从而跳出了生成器对象方法的while语句。这里一般人可能还有一个疑问，<font color="red">为啥GeneratorExit不能被基类Exception进行捕获，原因是GeneratorExit异常继承自BaseException类。BaseException类与Exception类不同。一般情况下，BaseException类是所有内建异常类的基类，而Exception类是所有用户定义的异常类的基类。</font>

## yield和yield from

```python
def subgen():
    for i in range(3):
        yield 'subgen: %s' % i
    return 'subgen returned'

def gen():
    r = yield from subgen()
    print('r = "%s"' % r)
    yield r

def gen_without_yield_from():
    sg = subgen()
    try:
        while 1:
            yield sg.send(None)
    except StopIteration as e:
        yield e.value

print('* [gen] get all values')
for v in gen_without_yield_from():
    print('get value: %s' % v)
print('* [gen_without_yield_from] get all values')
for v in gen():
    print('get value: %s' % v)
```

yield from 子迭代器是把子迭代器的值一个一个传出去。

```python
# 源程序
@asyncio.coroutine
def hello():
    print("Hello world!")
    yield from asyncio.sleep(1)
    print("Hello again!")

# 使用yield
@asyncio.coroutine
def hello():
    print("Hello world!")
    for v in asyncio.sleep(1):
        yield v
    print("Hello again!")
```

迭代器和协程：在知乎看到一句话觉得比较恰当：举个比喻，迭代器和协程就像火药和枪械，利用火药的特性辅助各种其他东西才造出了枪械。为什么看上去都是`generator`，迭代器不会天生成为协程呢？
因为没有一个知道什么时候应该叫你回到这个程序的人。
这个人就是`event_loop`（消息循环）。



