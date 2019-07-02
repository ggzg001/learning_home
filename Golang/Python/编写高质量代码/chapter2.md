# 建议7：利用 assert 语句来发现问题

断言是用来捕获用户所定义的约束的，而不是用来捕获程序本身的错误的。

不用断言：

1. 如果 Python 本身的异常能够处理就不要再使用断言。如对于类似于数组越界、类型不匹配、除数为 0 之类的错误，不建议使用断言来进行处理
2. 不要使用断言来检查用户的输入。如对于一个数字类型，如果根据用户的设计该值的范围应该是 2~10，较好的做法是使用条件判断，并在不符合条件的时候输出错误提示信息

使用断言：

1. 在函数调用后，当需要确认返回值是否合理时可以使用断言
2. 当条件是业务逻辑继续下去的先决条件时可以使用断言

python -O test.py: -O参数可以不检查断言，因为断言会有性能的损耗

# 建议8：数据交换的时候不推荐使用中间变量

```python
from timeit import Timer
# 0.038436460999946576
print(Timer("temp = x; x = y; y = temp", "x=2;y=3").timeit())
# 0.02844161000029999
print(Timer("x,y=y,x", "x=2;y=3").timeit())
```

`x,y = y,x`=>`x,y = (y,x)`  利用元组的解包

# 建议9：充分利用 Lazy evaluation 的特性

Lazy evaluation 常被译为“延迟计算”或“惰性计算”，指的是仅仅在真正需要执行的时候才计算表达式的值。充分利用 Lazy evaluation 的特性带来的好处主要体现在以下两个方面：

1. 避免不必要的计算，带来性能上的提升。对于 Python 中的条件表达式 `if x and y`，在 x 为 false 的情况下 y 表达式的值将不再计算。而对于 `if x or y`，当 x 的值为 true 的时候将直接返回，不再计算 y 的值。因此编程中应该充分利用该特性。对于 or 条件表达式应该将值为真可能性较高的变量写在 or 的前面，而 and 则应该推后。
2. 节省空间，使得无限循环的数据结构成为可能。Python 中最典型的使用延迟计算的例子就是生成器表达式了

# 建议10：不推荐使用 type 来进行类型检查

内建函数 `type(object)` 用于返回当前对象的类型，因此可以通过与 Python 自带模块 types 中所定义的名称进行比较，根据其返回值确定变量类型是否符合要求。python2的type和python3的type不太一样，python2和python3的types模块也不太一样。在python2中：

```python
class A:
    pass

class B:
    pass

a = A()
b = B()
```

`type(a) == type(b)` 但是在python3中就不成立，为了一致性，推荐使用isinstance

# 建议11：警惕 `eval()` 的安全漏洞

eval(expression, globals=None, locals=None)  --- 官方文档中的解释是，将字符串str当成有效的表达式来求值并返回计算结果。globals和locals参数是可选的，如果提供了globals参数，那么它必须是dictionary类型；如果提供了locals参数，那么它可以是任意的map对象。

 

python是用命名空间来记录变量的轨迹的，命名空间是一个dictionary，键是变量名，值是变量值。

当一行代码要使用变量 `x` 的值时，Python 会到所有可用的名字空间去查找变量，按照如下顺序:

1）局部名字空间 - 特指当前函数或类的方法。如果函数定义了一个局部变量 `x`, 或一个参数 `x`，Python 将使用它，然后停止搜索。

2）全局名字空间 - 特指当前的模块。如果模块定义了一个名为 `x` 的变量，函数或类，Python 将使用它然后停止搜索。

3）内置名字空间 - 对每个模块都是全局的。作为最后的尝试，Python 将假设 `x` 是内置函数或变量。

python的全局名字空间存储在一个叫globals()的dict对象中；局部名字空间存储在一个叫locals()的dict对象中。我们可以用print (locals())来查看该函数体内的所有变量名和变量值。

locals()对象的值不能修改，globals()对象的值可以修改.

eval有安全性问题,比如用户恶意输入就会获得当前目录文件:`eval("__import__('os').system('dir')")`

推荐使用ast.literal_eval()替换内置的eval,.计算操作，及危险操作，如果换成了ast.literal_eval()，都会拒绝执行

# 建议12：使用 `enumerate()` 获取序列迭代的索引和值

函数 `enumerate()`，主要是为了解决在循环中获取索引以及对应值的问题。它具有一定的惰性（lazy），每次仅在需要的时候才会产生一个（index, item）对

# 建议13：考虑兼容性，尽可能使用 Unicode

考虑兼容性一般在python文件开头加上这么一句：`from __future__ import unicode_literals` 用于处理python2的字符串和python3的不统一

# python中的枚举

```python
from enum import Enum, unique

@unique
class Color(Enum):
    red = 1
    orange = 2
    yellow = 3
    green = 4
    blue = 5
    indigo = 6
    purple = 7
```

* 颜色枚举有7个成员，分别是Color.red、Color.orange、Color.yellow等。
* 每一个成员都有它们各自名称和值，Color.red成员的名称是：red，值是：1

细节：

1. 成员名称不能重复
2. 默认情况下, 不同的成员的值可以相同，只不过后面的当做前面的别名(要想不同可以加unique装饰器)。通过值枚举时只能取到第一个枚举变量
3. `for color in Color` : 只获取重复成员的第一个成员，要想获得所有成员：`for color in Color.__members__.items()`
4. 枚举成员有name和value两种属性，Color["red"] 或 Color(1)
5. 枚举成员可以进行等值比较，不能进行大小比较