python2和python3的垃圾回收机制有差别，python弱引用在python2可以明显地看出结果。

弱引用，与强引用相对，是指不能确保其引用的对象不会被垃圾回收器回收的引用。一个对象若只被弱引用所引用，则可能在任何时刻被回收。弱引用的主要作用就是减少循环引用，减少内存中不必要的对象存在的数量。

使用weakref模块，你可以创建到对象的弱引用，Python在对象的引用计数为0或只存在对象的弱引用时将回收这个对象。

## 获取对象的引用计数

```python
In [5]: m  = Man()
In [6]: sys.getrefcount(m)
Out[6]: 2
In [7]: sys.getrefcount(m)
Out[7]: 2
```

调用sys.getrefcount会自动给引用计数加1

## 循环引用的例子

```python
class Node(object):

    def __init__(self, data):
        self.data = data
        self.parent = None
        self.children = []

    def add_child(self, child):
        self.children.append(child)
        child.parent = self

    def __del__(self):
        print '__del__'

# __del__
n1 = Node(1)
n2 = Node(2)
n1.add_child(n2)
del n1
```

`del n1`之后发现并没有预料的`__del__`输出。

我们可以手动使用 gc 模块来进行垃圾回收

```python
import gc
gc.collect()
```

糟糕的是，我们这里循环引用的对象都实现了 `__del__` 方法，gc 模块不会销毁这些对象，因为 gc 模块不知道应该先调用哪个对象的 `__del__` 方法。gc模块会把这样的对象放到 gc.garbage 中，并不会销毁对象。

```python
class Node(object):

    def __init__(self, data):
        self.data = data
        self.parent = None
        self.children = []

    def add_child(self, child):
        self.children.append(child)
        child.parent = self

    def __del__(self):
        print '__del__'

# __del__
n1 = Node(1)
n2 = Node(2)
n1.add_child(n2)
del n1
del n2
import gc
gc.collect()
# [<__main__.Node object at 0x100c00090>, <__main__.Node object at 0x100c00110>]
print gc.garbage
```

## 弱引用

如果一个对象只剩下一个弱引用，那么它是可以被垃圾回收的。

你可以通过调用weakref模块的ref(obj[,callback])来创建一个弱引用，obj是你想弱引用的对象，callback是一个可选的函数，当因没有引用导致Python要销毁这个对象时调用。回调函数callback要求单个参数（弱引用的对象）

```python
>>>>　import　sys
>>>　import　weakref
>>>　class　Man:
　　def　__init__(self,name):
　　　　print　self.name = name
　　　　
>>>　o　=　Man('Jim')
>>>　sys.getrefcount(o)   
2
>>>　r　=　weakref.ref(o)　#　创建一个弱引用
>>>　sys.getrefcount(o)　#　引用计数并没有改变
2
>>>　r
<weakref　at　00D3B3F0;　to　'instance'　at　00D37A30>　#　弱引用所指向的对象信息
>>>　o2　=　r()　#　获取弱引用所指向的对象
>>>　o　is　o2
True
>>>　sys.getrefcount(o)
3
>>>　o　=　None
>>>　o2　=　None
>>>　r　#　当对象引用计数为零时，弱引用失效。
<weakref　at　00D3B3F0;　dead>de>
```

```python
import weakref

class Node(object):

    def __init__(self, data):
        self.data = data
        self._parent = None
        self.children = []

    @property
    def parent(self):
        return None if self._parent is None else self._parent()

    @parent.setter
    def parent(self, node):
        self._parent = weakref.ref(node, callback)

    def add_child(self, child):
        self.children.append(child)
        child.parent = self

def callback(ref):
    print '__del__', ref

n1 = Node(0)
n2 = Node(2)
print n1,n2
# <__main__.Node object at 0x7fb0c2750c10> <__main__.Node object at 0x7fb0c2750d10>
n1.add_child(n2)
del n1
# __del__ <weakref at 0x7fb0c26e75d0; dead>
```

我们使用 weakref.ref() 创建弱引用，每次使用时都需要形如这样 xx() 来获取，有一点别扭。 可以通过 weakref.proxy() 这种来避免 () 操作

```python
In [7]: class Man:
   ...:     def __init__(self, name):
   ...:         self.name = name
   ...:

In [8]: m = Man('jack')

In [9]: p = weakref.proxy(m)

In [10]: p.name
Out[10]: 'jack'
```

## 缓存对象

`ref`和`proxy`都只可用与维护单个对象的弱引用，如果想同时创建多个对象的弱引用咋办？这时可以使用`WeakKeyDictionary`和`WeakValueDictionary`来实现。

`WeakValueDictionary`类，顾名思义，本质上还是个字典类型，只是它的值类型是弱引用。当这些值引用的对象不再被其他非弱引用对象引用时，那么这些引用的对象就可以通过垃圾回收器进行回收。

```python
import weakref
import gc
from pprint import pprint
 
gc.set_debug(gc.DEBUG_LEAK)
  
class Man(object):
    def __init__(self, name):
        self.name = name
 
    def __repr__(self):
        return '<Man name=%s>' % self.name
 
    def __del__(self):
        print "deleting %s" % self
 
 
def demo(cache_factory):
    all_refs = {}
    print("cache type:", cache_factory)
    cache = cache_factory()
    for name in ["Jim", 'Tom', 'Green']:
        man = Man(name)
        cache[name] = man
        all_refs[name] = man
        del man
    print("all_refs=")
    pprint(all_refs)
    print
    print "before, cache contains:", cache.keys()
    for name, value in cache.items():
        print "%s = %s" % (name, value)
    print("\ncleanup")
    del all_refs
    gc.collect()
 
    print
    print("after, cache contains:", cache.keys())
    for name, value in cache.items():
        print("%s = %s" % (name, value))
    print("demo returning")
    return
 
demo(dict)
print
 
demo(weakref.WeakValueDictionary)
```

理解这边缓存的含义，真实数据all_ref消失了，那么缓存的数据也应该失效(在这里被回收)