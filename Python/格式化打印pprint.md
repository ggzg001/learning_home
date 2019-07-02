## 打印

```python
data = [(1,{'a':'A','b':'B','c':'C','d':'D'}),
 
    (2,{'e':'E','f':'F','g':'G','h':'H',
 
      'i':'I','j':'J','k':'K','l':'L'
 
      }),
     ]
```

```python
from pprint import pprint

data = [(1, {'a': 'A', 'b': 'B', 'c': 'C', 'd': 'D'}),
        (2, {'e': 'E', 'f': 'F', 'g': 'G', 'h': 'H',    'i': 'I', 'j': 'J', 'k': 'K', 'l': 'L'
   }), ]
"""
[(1, {'a': 'A', 'b': 'B', 'c': 'C', 'd': 'D'}),
 (2,
  {'e': 'E',
   'f': 'F',
   'g': 'G',
   'h': 'H',
   'i': 'I',
   'j': 'J',
   'k': 'K',
   'l': 'L'})]
"""
pprint(data)
```

pprint()格式化一个对象，并把它写至一个数据流，这个数据流作为参数传入（或者是默认的sys.stdout）

注意为什么第二个字典中会显示一竖列，因为pprint打印支持8个对象以上的竖列打印

## 格式化

格式化一个数据结构而不把它直接写至一个流（例如用于日志记录），可以使用pformat()来构造一个字符串表示。 

```python
data = [(1, {'a': 'A', 'b': 'B', 'c': 'C', 'd': 'D'}),

        (2, {'e': 'E', 'f': 'F', 'g': 'G', 'h': 'H',

             'i': 'I', 'j': 'J', 'k': 'K', 'l': 'L'

             }),

        ]
import logging
from pprint import pformat
logging.basicConfig(level = logging.DEBUG,
          format = '%(levelname)-8s %(message)s',
          )
logging.debug('Logging pformatted data')
# 格式化的字符串
formatted = pformat(data)
for line in formatted.splitlines():
  logging.debug(line.rstrip())
"""
DEBUG    Logging pformatted data
DEBUG    [(1, {'a': 'A', 'b': 'B', 'c': 'C', 'd': 'D'}),
DEBUG     (2,
DEBUG      {'e': 'E',
DEBUG       'f': 'F',
DEBUG       'g': 'G',
DEBUG       'h': 'H',
DEBUG       'i': 'I',
DEBUG       'j': 'J',
DEBUG       'k': 'K',
DEBUG       'l': 'L'})]
"""
```

## **任意类**

如果定制类定义了一个__repr__()方法，pprint()使用的PrettyPrinter类还可以处理这些定制类。

```python
from pprint import pprint 
class node(object):
  def __init__(self,name,contents =[]):
    self.name = name
    self.contents = contents[:]
  def __repr__(self):
    return ('node(' + repr(self.name) + ',' +
        repr(self.contents) + ')'
        )
trees = [node('node-1'),
     node('node-2',[node('node-2-1')]),
     node('node-3',[node('node-3-1')]),     
     ]
"""
[node('node-1',[]),
 node('node-2',[node('node-2-1',[])]),
 node('node-3',[node('node-3-1',[])])]
"""
# print输出结果是一行
pprint(trees)
```

## **递归**

递归数据结构有指向原数据源的引用来表示，形式为`<Recursion on typename with id=number>`。

```python
from pprint import pprint
local_data = ['a','b',1,2]
local_data.append(local_data)
print('id(local_data) =>',id(local_data))
pprint(local_data)
print(local_data)
"""
id(local_data) => 4349459144
['a', 'b', 1, 2, <Recursion on list with id=4349459144>]
['a', 'b', 1, 2, [...]]
"""
```

## **限制嵌套输出**

对于非常深的数据结构，可能不要求输出包含所有细节。有可能数据没有是当地格式化，也可能格式化文本过大而无法管理，或者默写数据时多余的。

 

```python
from pprint import pprint

data = [(1, {'a': 'A', 'b': 'B', 'c': 'C', 'd': 'D'}),

        (2, {'e': 'E', 'f': 'F', 'g': 'G', 'h': 'H',

             'i': 'I', 'j': 'J', 'k': 'K', 'l': 'L'

             }),

        ]
print('depth 1 :')
# depth 最小是一层
pprint(data, depth=1)

print('depth 2 :')
pprint(data, depth=2)

print('depth 3 :')
pprint(data, depth=3)
"""
depth 1 :
[(...), (...)]
depth 2 :
[(1, {...}), (2, {...})]
depth 3 :
[(1, {'a': 'A', 'b': 'B', 'c': 'C', 'd': 'D'}),
 (2,
  {'e': 'E',
   'f': 'F',
   'g': 'G',
   'h': 'H',
   'i': 'I',
   'j': 'J',
   'k': 'K',
   'l': 'L'})]
"""
```

使用depth参数可以控制美观打印机递归处理嵌套数据结构的深度。输出中未包含的层次由一个省略号表示 

## **控制输出宽度**

格式化文本的默认输出宽度为80列。要调整这个宽度，可以再pprint()中使用参数width。 

```python
from pprint import pprint

data = [(1, {'a': 'A', 'b': 'B', 'c': 'C', 'd': 'D'}),

        (2, {'e': 'E', 'f': 'F', 'g': 'G', 'h': 'H',

             'i': 'I', 'j': 'J', 'k': 'K', 'l': 'L'

             }),

        ]
pprint(data, width=5)
"""
[(1,
  {'a': 'A',
   'b': 'B',
   'c': 'C',
   'd': 'D'}),
 (2,
  {'e': 'E',
   'f': 'F',
   'g': 'G',
   'h': 'H',
   'i': 'I',
   'j': 'J',
   'k': 'K',
   'l': 'L'})]
"""
```

## FunctionType, MethodType

```
class _C:
    def _m(self): pass
MethodType = type(_C()._m)
```

```
def _f(): pass
FunctionType = type(_f)
```

```python
from types import FunctionType, MethodType

class People:
    def speak(self):
        pass

def speak():
    pass

print(isinstance(People().speak, FunctionType), isinstance(People().speak, MethodType))
print(isinstance(People.speak, FunctionType), isinstance(People.speak, MethodType))
print(isinstance(speak, FunctionType), isinstance(speak, MethodType))
```

# 异常相关

## 自定义异常

python中一切皆对象，抛出的异常也是一个对象。在程序中我们自定义异常的场景是区分不同的异常类型，比如做网络编程中的程序时有协议错误，连接超时等不同的异常。

```
class NetworkError(Exception):
    pass

class HostnameError(NetworkError):
    pass

class TimeoutError(NetworkError):
    pass

class ProtocolError(NetworkError):
    pass
```

```
try:
    msg = s.recv()
except TimeoutError as e:
    ...
except ProtocolError as e:
    ...
```

Exception的默认行为是接受所有传递的参数并将它们以元组形式存储在 `.args` 属性中. 很多其他函数库和部分Python库默认所有异常都必须有 `.args` 属性， 因此如果你忽略了这一步，你会发现有些时候你定义的新异常不会按照期望运行。

```
class CustomError(Exception):
    def __init__(self, message, status, *args, **kwargs):
        print(message, status, args, kwargs)
        super().__init__(message, status, *args, **kwargs)
        self.message = message
        self.status = status
    def __str__(self):
        return self.message
"""
hello 1 ('world',) {}
hello ('hello', 1, 'world')
"""
try:
    raise CustomError("hello", 1, "world")
except CustomError as e:
    print(e.message, e.args)
```

## traceback捕获并打印异常

异常处理是日常操作了，但是有时候不能只能打印我们处理的结果，还需要将我们的异常打印出来，如异常出现在哪个文件哪一行，这样更直观的显示错误。

```
try:
    1 / 0
except Exception as e:
    print(e)
```

输出结果是integer division or modulo by zero，只知道是报了这个错，但是却不知道在哪个文件哪个函数哪一行报的错。

```
import traceback
try:
    1 / 0
except Exception as e:
    # traceback.print_exc(file=open('tb.txt',  'w+'))
    s = traceback.format_exc()
    print(s)

print(1)
print(1)
```

traceback.print_exc()跟traceback.format_exc()的区别：

* format_exc()返回字符串
* print_exc()则直接给打印出来。

print_exc()还可以接受file参数直接写入到一个文件。比如traceback.print_exc(file=open('tb.txt','w+'))写入到tb.txt文件去。

# collections模块

## Counter

计数器是一个非常常用的功能需求

```
In [2]: c = Counter('abcdeabcdabcaba')

In [3]: c
Out[3]: Counter({'a': 5, 'b': 4, 'c': 3, 'd': 2, 'e': 1})

In [4]: c.elements
Out[4]: <bound method Counter.elements of Counter({'a': 5, 'b': 4, 'c': 3, 'd': 2, 'e': 1})>

In [5]: c.elements()
Out[5]: <itertools.chain at 0x105d7eb38>

In [6]: c.most_common(4)
Out[6]: [('a', 5), ('b', 4), ('c', 3), ('d', 2)]

In [7]: list(c.elements())
Out[7]: ['a', 'a', 'a', 'a', 'a', 'b', 'b', 'b', 'b', 'c', 'c', 'c', 'd', 'd', 'e']

In [8]: c.values()
Out[8]: dict_values([5, 4, 3, 2, 1])

In [9]: c.keys()
Out[9]: dict_keys(['a', 'b', 'c', 'd', 'e'])

In [10]: type(c.most_common(2))
Out[10]: list
```

most_common(2)  表示最多的2个元素

```
>>> c = Counter(a=4, b=2, c=0, d=-2)
>>> list(c.elements())
['a', 'a', 'a', 'a', 'b', 'b']
```

## defaultdict

```python
>>> from collections import defaultdict
>>> s = [('yellow', 1), ('blue', 2), ('yellow', 3), ('blue', 4), ('red', 1)]
>>> d = defaultdict(list)
>>> for k, v in s:
...     d[k].append(v)
...
>>> d.items()
dict_items([('blue', [2, 4]), ('red', [1]), ('yellow', [1, 3])])
```

`defaultdict` 对象不存在某个*键*，它会自动创建一个空列表。当然，可以进行覆盖，如d['a'] = 1

## namedtuple

命名元组有助于对元组每个位置赋予意义.namedtuple使用和类相似，定义一个类，然后实例化。

```
In [23]: Point = namedtuple('Point', ['x', 'y'])

In [24]: p = Point(1,3)

In [25]: p.x
Out[25]: 1

In [26]: p[0]
Out[26]: 1

In [27]: Point(1,3,4)
---------------------------------------------------------------------------
TypeError                                 Traceback (most recent call last)
<ipython-input-27-9e9e53e89e7d> in <module>()
----> 1 Point(1,3,4)

TypeError: __new__() takes 3 positional arguments but 4 were given

In [28]: x, y = p

In [29]: x
Out[29]: 1

In [30]: y
Out[30]: 3
```

## **deque**

deque其实是 double-ended queue 的缩写，翻译过来就是双端队列，它最大的好处就是实现了从队列 头部快速增加和取出对象。

原生的list也可以从头部添加和取出对象。但是值得注意的是，list对象的这两种用法的时间复杂度是 O(n) ，也就是说随着元素数量的增加耗时呈 线性上升。而使用deque对象则是 O(1) 的复杂度，所以当你的代码有这样的需求的时候， 一定要记得使用deque.

```python
import sys
import time
from collections import deque
fancy_loading = deque('>--------------------')
while True:
    print('\r%s' % ''.join(fancy_loading))
    fancy_loading.rotate(1)
    sys.stdout.flush()
    time.sleep(0.08)
```



