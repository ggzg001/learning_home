## 利用状态模式优化代码

### 什么是状态模式

当一个对象的内在状态改变时允许改变其行为，这个对象看起来像是改变了类本身。

### 应用场景

当控制一个对象的状态转换的条件表达式过于复杂时,把状态的判断逻辑转移到表示不同状态的一系列类当中,可以把复杂的判断逻辑简化。(当一个对象的行为取决于它的状态,并且它必须在运行时刻根据状态改变他的行为)。

```python
from termcolor import colored
from state import curr, switch, stateful, State, behavior

@stateful
class User(object):
    def __init__(self, name):
        self.name = name

    class NeedSignin(State):
        default = True
        @behavior
        def signin(self):
            print(colored("{} login success...".format(self.name), "green"))
            switch(self, self.__class__.Signin)

    class Signin(State):
        @behavior
        def logout(self):
            print(colored("{} logout success...".format(self.name), "blue"))

        @behavior
        def payment(self):
            print(colored("{} payment success...".format(self.name), "red"))

user = User("jack")
print curr(user)
user.signin()
user.logout()
user.payment()
print curr(user)
```

使用状态模式的好处：

* 可以减少if-else，也可以减少在一个方法上多个装饰器的帽子
* 把一个巨类变得更清晰
* 当调用当前状态不存在的行为时，出错信息是AttributeError错误，可以更精确地定位错误。

对state模块的几点说明：

1. `@stateful`重载了被修饰类的`__getattr__`使得能调用当前状态类的方法
2. 状态类继承`State`, 可以重写`__begin__`和`__end__`, 状态类可以自定义进入和离开当前状态对宿主的初始化和清理操作。
3. 默认状态通过`default = True`来设置。

## 观察者模式



每个设计模式都是围绕如下三个问题：

1. 为什么？即为什么要使用这个设计模式，在使用这个模式之前存在什么样的问题？
2. 是什么？通过Python语言来去实现这个设计模式，用于解决为什么中提到的问题。
3. 怎么用？理解了为什么我们也就基本了解了什么情况下使用这个模式，不过在这里还是会细化使用场景，阐述模式的局限和优缺点。

### 耦合和解耦

我们常常说模块之间要“解耦合”，软件设计要“松耦合”。那么什么是“耦合”呢？

实际上耦合是指两个模块之间（模块可以理解为两坨代码，所以可以是函数，可以是类，或者更大范围的系统）发生了关系，比如一个模块调用了另一个模块的函数，或者一个模块需要获取另一个模块的数据，总之有了联系就有了耦合。所谓“解耦合”或者“松耦合”是说让两个模块之间的联系没有那么紧密，这样一个模块的变化不会影响另一个模块的代码。那么我们如何来使我们的系统是一个“松耦合”的系统呢？

实现“松耦合”最重要的就是**抽象**和**一致性**，白话就是要通过抽象的接口（Python中没有接口的概念，可以理解为抽象的类）来联系调用方和被调方。

```python
class A(object):
    def __init__(self):
        self.obj = B(param1, param2)

    def method_of_a(self):
        self.obj.method_of_b(param3)


class B(object):
    def __init__(self, param1, param2):
        ...

    def method_of_b(self, param3):
         # do something
```

但是这种情况下，如果B发生改变，或者想换成另一个类C，这时就需要更改A的代码，那么如果我们把A和B之间的联系抽象出来，通过接口（或者类似接口的东西）来连接A和B我们就可以某种程度上屏蔽这种变化.

```python
class A(object):
    def __init__(self, some_obj):
        self.obj = some_obj

    def method_of_a(self):
        self.obj.consistent_method(param3)

class B(object):
    def __init__(self, param1, param2):
        ...
    def consistent_method(self, param3):
        ...

class C(object):
    def __init__(self, param1, param2):
        ...
    def consistent_method(self, param3):
        ...
```

在这个例子中，我们的参数some_obj可以想象成一个抽象类或者Java中的接口，我们传递参数时可以传递具体实现类的对象（比如B或者C的对象），但在这里只是一个**抽象**。

另外，我们的B和C都实现了consistent_method，这就是**一致性**的体现.

### 为什么

假设我们设计了某种功能，当用户点击页面上的按钮时，我们需要为用户做两件事，一是做页面变换显示出预期的效果，二是响起特定的音乐。那么我们的代码可能是这样的：

```
def onClick():
    changePage()
    playMusic()
```

后来你的需求有变动，还需要记录用户点击时间，需要弹出提示信息，需要......
 于是你需要不断的修改上述的代码，可能是这样的

```
def onClick():
    changePage()
    playMusic()
    recordTime()
    popupHint()
    ...
```

我们认为onClick()和这些功能函数耦合的过于紧密了，每次的改动都会影响onClick函数。<font color="red">这类问题抽象出来就是当一个事件发生时需要调用很多功能模块，而解决这类问题最好的方式就是观察者模式，也叫发布-订阅模式。</font>

### 是什么

观察者模式是说你有一个观察者列表，这个列表中的函数或者某种功能都在观察某个事件的发生，一旦发生，这些函数或者功能就会自动执行，这个其实很好理解。

```python
class Button(object):
    """publisher or subject"""
    def __init__(self):
        self.observer_list = []

    def register(self, func):
        self.observer_list.append(func)

    def unregister(self, func):
        self.observer_list.remove(func)

    def onClick():
        for func in self.observer_list:
            func()
    ...

def playMusic():
     """subscriber or observer"""
    ...

def changePage():
    """subscriber or observer"""
    ...
...

def main():
    button = Button()
    button.register(playMusic)
    button.register(changePage)
```

通过这种方式，我们实现了发布者和订阅者之间的松耦合，它们之间并不直接联系，而是通过<font color="red">统一的register/unregister(类似于统一的抽象接口)</font>来绑定和解绑定。

### 怎么用

似乎代码也没少啊，而且注册的时候不还是要修改代码去注册新的功能吗？这里基于以下几种好处我们要使用这个模式：

- 使用这个模式的最大好处之一就是**灵活**
  我们可以动态的修改监听的事件，比如用户不想在点击该按钮的时候响起音乐，那么当ta不选择这一项时，我们的程序可以灵活的通过unregister来解绑定，试想如果你不使用观察者模式，是很难解绑定的，你就需要去修改原来的一堆代码，显然这不现实。有了unregister可以在那堆代码外面进行影响那堆代码运行的操作。所以，使用这个模式的理由之一就是你需要动态的绑定和解绑相应的功能时，你就需要观察者模式。
- 第二个好处是代码复用
  比如你有很多个按钮，都需要统一的注册某些功能，这个时候你就可以实现一个父类，在初始化的时候将所有的需要注册的功能都注册好，子类直接继承就好了，子类当然还可以注册自己特殊功能。

## 利用发布订阅模式进行解耦

最简单的发布订阅：

```python
# Broker.py
from collections import defaultdict
route_table = defaultdict(list)
def sub(topic, callback):
    if callback in route_table[topic]:
        return
    route_table[topic].append(callback)

def pub(topic, *args, **kw):
    for func in route_table[topic]:
        func(*args, **kw)
```

```python
import Broker
def greeting(name):
    print('Hello, {}'.format(name))
Broker.sub('greet', greeting)
Broker.pub('greet', 'LaiYonghao')
```

python的blinker 和 message 两个模块可以实现发布订阅模式。

发布订阅模式中发布者和订阅者对系统拓扑没有感知，关注的是订阅和发布的主题。

### 利用message解决的一个问题

假设你写了一个库,  里面有一个重要的函数bar

```python
def bar():
    print "this is bar"
    do_some_thing()
```

别人在使用你这个库的时候，使用的logging模块记录日志，对于脚本的调用`python test.py > /dev/null`, 因为这样标准输出print的结果就石沉大海了。那怎么办，我这边的print要改成logging吗？关键是有的人在使用你的库的时候不用logging模块，就用print.那怎么修改？需要库和应用方联合使用一起来修改。

使用message来修改bar函数，应用方要使用logging模块还有就用标准输出也好，完全由应用方来定。

```python
# client.py
import message

LOG_MSG = ("log", "foo")

def bar():
    # 这边的使用元组作为topic，保证可hash
    message.pub(LOG_MSG, "haha, Calling bar")
    do_some_thing()
```

不同的调用方：

标准输出

```python
import message
import client

def handle_foo_log_msg(txt):
    print txt

message.sub(client.LOG_MSG, handle_foo_log_msg)

client.bar()
```

logging日志

```python
import message
import client

def handle_foo_log_msg(txt):
    import logging
    logging.critical(txt)

message.sub(client.LOG_MSG, handle_foo_log_msg)

client.bar()
```

## 掌握字符串的基本用法

### 多行的字符串常量

```python
In [4]: s = ('select * '
   ...: 'from stu')

In [5]: s
Out[5]: 'select * from stu'
```

利用 `()` 和 单引号做字符串拼接和 用三引号的不同：

```python
In [6]: s = """select * from
   ...: stu"""

In [7]: s
Out[7]: 'select * from\nstu'
```

### py2判断是不是字符串

`isinstance(s, basestring)`

py3中basestring被废弃了。

### 判断字符串是否包含子串

使用`in` 和 `not in`， 不使用find和index(index找不到会报错，find找不到返回-1)

### split和partition

#### split

```python
In [14]: "hello    world  ".split()
Out[14]: ['hello', 'world']

In [15]: "hello    world  ".split("")
---------------------------------------------------------------------------
ValueError                                Traceback (most recent call last)
<ipython-input-15-7998eb369a7f> in <module>()
----> 1 "hello    world  ".split("")

ValueError: empty separator

In [16]: "hello    world  ".split(" ")
Out[16]: ['hello', '', '', '', 'world', '', '']
```

split参数为空的情况：会先去除字符串左右两边的空行，然后以任意长度的空白串进行分割。

split() 不能参数不能是空字符串，当时一个字符串的时候，会认为连续两个sep之间有一个空串。

## 按需选择sort和sorted

`sorted(iterable, /, *, key=None, reverse=False)`

```
Help on method_descriptor:

sort(...)
    L.sort(key=None, reverse=False) -> None -- stable sort *IN PLACE*
```

key是一个带参数的函数，用来为每个元素提取比较值，默认为None(即直接比较每个元素)。

sorted可以作用于任意可迭代对象，sort一般只用于列表，针对元组使用sort会抛出异常。sorted的功能强大，可以支持多种排序：

对字典进行排序

```python
In [26]: sorted(dic.items(), key=itemgetter(1))
Out[26]: [('egon', 34), ('alex', 130), ('jack', 230)]

In [27]: dict(sorted(dic.items(), key=itemgetter(1)))
Out[27]: {'egon': 34, 'alex': 130, 'jack': 230}
```

多维list排序

先根据等级再根据分数进行排序。

```python
In [28]: gameresult = [["Bob", 97, "A"], ["Jack", 97, "B"], ["Alex", 67, "C"]]

In [29]: sorted(gameresult, key=itemgetter(2,1))
Out[29]: [['Bob', 97, 'A'], ['Jack', 97, 'B'], ['Alex', 67, 'C']]
```

字典中混合list排序

```python
In [43]: mydict
Out[43]:
{'Li': ['M', 7],
 'Zhang': ['E', 2],
 'Wang': ['P', 3],
 'Du': ['C', 2],
 'Ma': ['C', 9],
 'Zhe': ['H', 7]}

In [44]: sorted(mydict.items(), key=lambda x: itemgetter(1)(x[1]))
Out[44]:
[('Zhang', ['E', 2]),
 ('Du', ['C', 2]),
 ('Wang', ['P', 3]),
 ('Li', ['M', 7]),
 ('Zhe', ['H', 7]),
 ('Ma', ['C', 9])]s
```

list混合字典

```python
In [45]: gameresult = [{"name": "Bob", "wins": 5, "losses": 2}, {"name": "Alex", "wins": 10, "losses":1}]

In [46]: sorted(gameresult, key=itemgetter('wins', 'losses'))
Out[46]:
[{'name': 'Bob', 'wins': 5, 'losses': 2},
 {'name': 'Alex', 'wins': 10, 'losses': 1}]
```

普通函数可能只比较一个，用了itemgetter可以比较两个。

## 使用counter进行计数统计

```
In [49]: c = Counter('abcdeabcdabcaba')

In [50]: c
Out[50]: Counter({'a': 5, 'b': 4, 'c': 3, 'd': 2, 'e': 1})

In [51]: c.keys()
Out[51]: dict_keys(['a', 'b', 'c', 'd', 'e'])

In [52]: c.values()
Out[52]: dict_values([5, 4, 3, 2, 1])

In [53]: c.most_common(3)
Out[53]: [('a', 5), ('b', 4), ('c', 3)]
```

<font color="red">Counter继承自字典, 所以得到的是字典类型。除了update，也有substract(), 值允许为0或负数。</font>

## 配置文件使用ConfigParser

configparser支持conf的下面写法：

```
# format.conf
[DEFAULT]
conn_str = %(dbn)%s://%(user)s:%(pw)s@%(host)s:%(port)s/%(db)s
dbn = mysql
user = root
host = localhost
port = 3306
[db1]
user = aaa
pw = ppp
db = example
```

```
import ConfigParser
conf = ConfigParser.ConfigParser()
conf.read("format.conf")
conf.get("db1", "conn_str")
```

## 使用argparse处理命令行

## 序列化的不错选择JSON

json比pickle所占用的空间更小。

json具有较强的拓展性，提供编码(JSONEncoder)和解码(JSONDecoder)类.

## 使用traceback获取栈信息



## 使用logging记录日志



logging和traceback配合使用。























