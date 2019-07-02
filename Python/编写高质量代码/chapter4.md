# 有节制地使用 `from ... import` 语句

Python 提供了 3 种方式来引入外部模块：`import` 语句、`from ... import ...` 及 `__import__` 函数。其中较为常见的为前面两种，而 `__import__` 函数与 `import` 语句类似，不同点在于前者显式地将模块的名称作为字符串传递并赋值给命名空间的变量。

在使用 `import` 的时候注意以下几点：

- 一般情况下尽量优先使用 `import a` 形式
- 有节制地使用 `from a import B` 形式
- 尽量避免使用 `from a import *`，因为这会污染命名空间

## sys.modules 与sys.path

python在import包的时候会从列表sys.path依次去寻找，寻找到就会把包名和包对象放在字典sys.modules里，有了sys.modules这样我们就能在程序使用导入的包的代码了(从字典sys.modules去寻找包对象)。

## python -m

区分运行python脚本的两种方式：

1. python xx.py
2. python -m xx

`python -m xx` 表示把xx当做模块来启动，__但是__`__name__`的值为'**main**' .不同的加载py文件的方式，主要是影响sys.path 这个属性。sys.path 就相当于liunx中的PATH。

1. 直接启动是把xx.py文件所在的目录放到了sys.path属性中。
2. 模块启动是把输入命令的目录（也就是当前路径），放到了sys.path属性中

考虑下面的目录结构：

```python
package/
    __init__.py
    mod1.py
package2/
    __init__.py
    run.py  
```

```python
# run.py 内容如下
import sys
from package import mod1
print(sys.path)
```

```python
➜  test_import_project git:(master) ✗ python package2/run.py
Traceback (most recent call last):
  File "package2/run.py", line 2, in <module>
    from package import mod1
ImportError: No module named package

# 以模块方式启动（成功）
➜  test_import_project git:(master) ✗ python -m package2.run
['',
'/usr/local/Cellar/python/2.7.11/Frameworks/Python.framework/Versions/2.7/lib/python27.zip',
...]
```

当需要启动的py文件引用了一个模块。你需要注意：在启动的时候需要考虑sys.path中有没有你import的模块的路径！
这个时候，到底是使用直接启动，还是以模块的启动？目的就是把import的那个模块的路径放到sys.path中。

## 考虑使用from … import

- 当只需要导入部分属性或方法时
- 模块中的这些属性和方法访问频率较高导致使用 "模块名.名称" 的形式进行访问过于繁琐时
- 模块的文档明确说明需要使用 `from ... import` 形式，导入的是一个包下面的子模块，且使用 `from ... import` 形式能够更为简单和便利时。如使用from io.drivers import zip 比 import io.drivers.zip 更好。

除了上述情况建议使用import,因为解决循环嵌套导入的一个方式就是使用import

# 优先使用 `absolute import` 来导入模块

在 Python2.4 以前默认为隐式的 `relative import`，局部范围的模块将覆盖同名的全局范围的模块。如果要使用标准库中同名的模块，需要深入考察 `sys.modules`。Python2.5 中后虽然默认的仍然是 `relative import`，但它为 `absolute import` 提供了一种新的机制，在模块中使用 `from __future__ import absolute_import` 语句进行说明后再进行导入。同时它还通过点号提供了一种显式进行 `relative import` 的方法，"." 表示当前目录， ".." 表示当前目录的上一层目录。

## Python import 的步骤

python 所有加载的模块信息都存放在 `sys.modules` 结构中，当 import 一个模块时，会按如下步骤来进行

- 如果是 `import A`，检查 sys.modules 中是否已经有 A，如果有则不加载，如果没有则为 A 创建 module 对象，并加载 A
- 如果是 `from A import B`，先为 A 创建 module 对象，再解析A，从中寻找B并填充到 A 的 `__dict__`中

## 相对导入与绝对导入

Python 相对导入与绝对导入，这两个概念是相对于包内导入而言的。包内导入即是包内的模块导入包内部的模块。(如一个包含__init__.py的包里有string.py, mod.py,在mod.py里import string, 这种情况如果不使用absolute导入那么最终导入的是我们写的string文件，而不是系统的包string).

绝对导入的格式为 `import A.B` 或 `from A import B`，相对导入格式为 `from . import B`或 `from ..A import B`，`.`代表当前模块，`..`代表上层模块，`...`代表上上层模块，依次类推。

相对导入可以避免硬编码带来的维护问题，例如我们改了某一顶层包的名，那么其子包所有的导入就都不能用了。但是 **存在相对导入语句的模块，不能直接运行**，否则会有异常

```python
ValueError: Attempted relative import in non-package
```

要运行包中包含绝对导入和相对导入的模块，可以用 `python -m A.B.C` 告诉解释器模块的层次结构。解释器会根据A.B.C和..B来推断出py文件所在的目录层次位置

### 导入模块时的一些规则：

在没有明确指定包结构的情况下，Python 是根据 `__name__` 来决定一个模块在包中的结构的，如果是 `__main__` 则它本身是顶层模块，没有包结构，如果是`A.B.C` 结构，那么顶层模块是 A。基本上遵循这样的原则：

- 如果是绝对导入，一个模块只能导入自身的子模块或和它的顶层模块同级别的模块及其子模块
- 如果是相对导入，一个模块必须有包结构且只能导入它的顶层模块内部的模块

如果一个模块被直接运行，则它自己为顶层模块，不存在层次结构，所以找不到其他的相对路径。

### py2和py3的区别

Python2.x 缺省为相对路径导入，Python3.x 缺省为绝对路径导入。绝对导入可以避免导入子包覆盖掉标准库模块（由于名字相同，发生冲突）。如果在 Python2.x 中要默认使用绝对导入，可以在文件开头加入如下语句:

```python
from __future__ import absolute_import
```

这句 import 并不是指将所有的导入视为绝对导入，而是指禁用 `implicit relative import`（隐式相对导入）, 但并不会禁掉 `explicit relative import`（显示相对导入）.

```
thing
├── books
│   ├── adventure.py
│   ├── history.py
│   ├── horror.py
│   ├── __init__.py
│   └── lovestory.py
├── furniture
│   ├── armchair.py
│   ├── bench.py
│   ├── __init__.py
│   ├── screen.py
│   └── stool.py
└── __init__.py
```

```
import bench                 # 此为 implicit relative import
from . import bench          # 此为 explicit relative import
from furniture import bench  # 此为 absolute import
```

隐式相对就是没有告诉解释器相对于谁，但默认相对与当前模块；而显示相对则明确告诉解释器相对于谁来导入。以上导入方式的第三种，才是官方推荐的，第一种是官方强烈不推荐的，**Python3 中已经被废弃**。

另外：**from __future__ import absolute_import: 在 3.0 以前的旧版本中启用相对导入等特性所必须的 future 语句**

## 实际开发

如果是写的应用程序，在加入了from __future__ import absolute_import 之后，那么在程序的编写过程中使用类似from package.submodule import b 只能导入系统环境路径里面的包，导入不了你写的应用程序的子包，如果导入你写的应用程序的子包必须使用from ..submodule import b。

如下面的例子，自己程序有urllib这个和第三方重名的包，我们发现导入的是系统的urllib包而不是我们自己写的目录

![image-20190313151553901](/Users/guwanhua/Library/Application Support/typora-user-images/image-20190313151553901.png)

写的是工具类程序，比如说写的是三方包，发布给别人安装。那么在加入了from __future__ import absolute_import 之后还是可以在相对导入的时候使用from package.submodule import b 。那么这么做不是from __future__ import absolute_import 所说的特性没有了么。其实不然。因为我们编写的程序是需要安装在系统环境路径里面的，所以这种绝对导入的方式是可以相对导入的，这个时候搜索包名的时候是在系统环境路径里面搜索，但是因为你的包就在这些路径的某一个路径里面，所以可以搜得到from package.submodule import b 里面的b(模块,函数，变量，类)。这种编写工具包以绝对导入进行相对导入的方法还避免了from ..submodule import b 最好导入不超过两层的这一建议. 特别适合在开发大型工具的时候。



# 建议：i+=1 不等于 ++i

python中++i被解读成+(+i)

# 建议：使用with自动关闭资源

`with` 语句支持嵌套，支持多个 `with` 子句，它们两者可以相互转换。`with expr1 as e1, expr2 as e2` 与下面的嵌套形式等价：

```python
with expr1 as e1:
    with expr2 as e2:
```

## contextlib

自定义上下文管理器确实很方便，但是Python标准库还提供了更加易用的上下文管理器工具模块contextlib，它是通过生成器实现的，不需要再创建类以及__enter__和__exit__这两个特俗的方法.

```python
from contextlib import contextmanager

@contextmanager
def make_open_context(filename, mode):
    fp = open(filename, mode)
    try:
        yield fp
    finally:
        fp.close()

with make_open_context('/tmp/a.txt', 'a') as file_obj:
    file_obj.write("hello world")
```

yield关键词把<font color="red">上下文分割成两部分：yield之前就是__init__中的代码块；yield之后其实就是__exit__中的代码块</font>，yield生成的值会绑定到with语句as子句中的变量，例如在上面的例子中，yield生成的值是文件句柄对象fp，在下面的with语句中，会将fp和file_obj绑定到一起，也就是说file_obj此时就是一个文件句柄对象，那么它就可以操作文件了，因此就可以调用file_obj.write("hello world")

## 实际开发

将一个不是上下问管理器的类变成了一个上下文管理器，这样做的好处在于，我们就可以在执行真正的核心代码之前可以执行一部分代码，然后在执行完毕后，又可以执行一部分代码，这种场景在实际需求中还是很常见的。

```python
from contextlib import contextmanager

class DB:
    def query(self):
        print("query data")

@contextmanager
def make_myresource():
    print("connect to resource")
    yield MyResource()
    print("connect to resource")

with DB() as r:
    r.query()
```

下面的示例充分体现上下文的含义：

```python
from flask_sqlalchemy import SQLAlchemy as _SQLAlchemy
from contextlib import contextmanager

class SQLAlchemy(_SQLAlchemy):
    @contextmanager
    def auto_commit(self):
        try:
            yield
            self.session.commit()
        except Exception as e:
            self.session.rollback()
            print(e)
```

# 建议：使用else字句简化循环

在循环中，`else` 子句提供了隐含的对循环是否由 break 语句引发循环结束的判断(不需要借助标志位)。

当循环“自然”终结（循环条件为假）时 `else` 从句会被执行一次，而当循环是由 `break` 语句中断时，`else` 子句就不被执行。与 `for` 语句相似，`while` 语句中的 `else` 子句的语意是一样的：`else` 块在循环正常结束和循环条件不成立时被执行。

在 Python 的异常处理中，也提供了 `else` 子句语法，`try` 块没有抛出任何异常时，执行 `else` 块。Python 的异常处理中有一种 `try-except-else-finally` 形式。



# 建议 ：遵循异常处理的几点基本原则

- 注意异常的粒度，不推荐在 `try` 中放入过多的代码。在处理异常的时候最好保持异常粒度的一致性和合理性。在 try 中放入过多的代码带来的问题是如果程序中抛出异常，将会较难定位，给 debug 和修复带来不便，因此应尽量只在可能抛出异常的语句块前面放入 try 语句。
- 谨慎使用单独的 except 语句处理所有异常，最好能定位具体的异常。同样也不推荐使用 `except Exception` 或者 `except StandardError` 来捕获异常。如果必须使用，最好能够使用 raise 语句将异常抛出向上层传递。
- 注意异常捕获的顺序，在合适的层次处理异常。Python 中内建异常以类的形式出现，Python 2.5 后异常被迁移到新式类上，启用了一个新的所有异常之母的 
- 使用更为友好的异常信息，遵守异常参数的规范。软件最终是位用户服务的，当异常发生的时候，异常信息清晰友好与否直接关系到用户体验。通常来说有两类异常阅读者：使用软件的人和开发软件的人。

# 建议：避免 finally 中可能发生的陷阱

无论 `try` 语句中是否有异常抛出，`finally` 语句总会被执行。由于这个特性，`finally` 语句经常被用来做一些清理工作。

但使用 finally 时，也要特别小心一些陷阱。

- 当 `try` 块中发生异常的时候，如果在 `except` 语句中找不到对应的异常处理，异常将会被临时保存起来，当 `finally` 执行完毕的时候，临时保存的异常将会再次被抛出，但如果 `finally` 语句中产生了新的异常或者执行了 `return` 或者 `break` 语句，那么临时保存的异常将会被丢失，从而导致异常屏蔽。
- 在实际应用程序开发过程中，并不推荐在 `finally` 中使用 `return` 语句进行返回，这种处理方式不仅会带来误解而且可能会引起非常严重的错误。

finally的另外一个陷阱(在return a之前会先执行finnally)：

```python
def return_test(a):
    try:
        if a < 0:
            raise ValueError("值必须大于0")
        else:
            print("else")
            return a
    except ValueError as e:
        print(e)
    finally:
        print("The end")
        return -1

res = return_test(2)
# res = -1
print(res)
```

# 建议：连接字符串优先还有join而不是+

```python
import timeit
# 生成测试所需要的字符数组
strlist = ["it is a long value string will not keep in memory" for n in range(100000)]
def join_test():
    return "".join(strlist) # 使用 join 方法连接 strlist 中的元素并返回字符串
def plus_test():
    result = ""
    for i, v in enumerate(strlist):
        return += v
	return result

if __name__ == "__main__":
    join_timer = timeit.Timer("join_test()", "from __main__ import join_test")
    print(join_timer.timeit(number=100))
    plus_timer = timeit.Timer("plus_test()", "from __main__ import plus_test")
    print(plus_timer.timeit(number=100))
```

# 建议 ：`[]`、`()` 和 `{}`：一致的容器初始化形式

推荐在需要生成列表的时候使用列表解析：

* 使用列表解析更为直观清晰，代码更为简洁

- 列表解析的效率更高（对于大数据处理，列表解析并不是一个最佳选择，过多的内存消耗可能会导致 `MemoryError`）

# 建议: 记住函数传参既不是传值也不是传引用

对于 Python 函数参数是传值还是传引用这个问题的答案是：都不是。正确的叫法应该是传对象（call by object）或者说传对象的引用（call-by-object-reference）。函数参数在传递的过程中将整个对象传入，对可变对象的修改在函数外部以及内部都可见，调用者和被调用者之间共享这个对象，而对于不可变对象，由于并不能真正被修改，因此，修改往往是通过生成一个新对象然后赋值来实现的。

```python
def change(org_list):
    print(id(org_list))
    new_list = org_list
    print(id(new_list))
    if len(new_list) > 5:
        # 此时new_list 重新指向了一块内存空间
        new_list = ['a', 'b', 'c']
    for i, e in enumerate(new_list):
        if isinstance(e, list):
            new_list[i] = '***'
    print(new_list)
    print(id(new_list))

test_list = [1,2,3,4,5,6, [1]]
change(test_list)
print(test_list)s
```

# 建议：警惕默认参数潜在的问题

def 在 Python 中是一个可执行的语句，当解释器执行 def 的时候，默认参数也会被计算，并存在函数的 `.func_defaults` 属性中。由于 Python 中函数参数传递的是对象，可变对象在调用者和被调用者之间共享，而再次调用的时候默认参数不会重新计算。

如果不想让默认参数所指向的对象在所有的函数调用中被共享，而是在函数调用的过程中动态生成，可以在定义的时候用 None 对象作为占位符。

```python
def appendtest(newitem, lista=[]):  # 默认参数是空列表
    print(id(lista))
    lista.append(newitem)
    print(id(lista))
    return lista
```

# 建议：慎用变长参数

慎用可变长度参数，原因如下：

- 使用过于灵活，在混合普通参数或者默认参数的情况下，变长参数意味着这个函数的签名不够清晰，存在多种调用方式。另外变长参数可能会破坏程序的健壮性。
- 如果一个函数的参数列表很长，虽然可以通过使用 `*args` 和 `**kwargs` 来简化函数的定义，但这通常意味着这个函数可以有更好的实现方式，应该被重构。
- 可变长参数适合在下列情况下使用：
  - 为函数添加一个装饰器
  - 如果参数的数目不确定，可以考虑使用变长参数。
  - 用来实现函数的多态或者在继承情况下子类需要调用父类的某些方法的时候

# 建议：深入理解 `str()` 和 `repr()` 的区别

- 两者之间的目标不同：`str()` 主要面向用户，其目的是可读性，返回形式为用户友好性和可读性都较强的字符串类型；而 `repr()` 面向的是 Python 解释器，或者说开发人员，其目的是准确性，其返回值表示 Python 解释器内部的含义，常作为编程人员 debug 用途
- 在解释器中直接输入时默认调用 `repr()` 函数，而 print 则调用 `str()` 函数
- `repr()` 的返回值一般可以用 `eval()` 函数来还原对象，通常来说有如下等式：`obj == eval(repr(obj))`，这个等式不是所有情况下都成立
- 一般来说在类中都应该定义 `__repr__()` 方法，而 `__str__()` 方法则为可选，当可读性比准确性更为重要的时候应该考虑定义 `__str__()` 方法。如果类中没有定义 `__str__()` 方法，则默认会使用 `__repr__()` 方法的结果来返回对象的字符串表示形式。用户实现 `__repr__()` 方法的时候最好保证其返回值可以用 `eval()` 方法使对象重新还原。

# 分清 staticmethod 和 classmethod 的适用场景

classmethod 适用于类的继承的某些情况，如对类属性的修改，继承的类对各自类属性的修改，这时的某些set方法可以用classmethod.如初始化成不同对象，也可以使用classmethod.

方法既不跟特定的实例相关也不跟特定的类相关，因此将其定义为静态方法是个不错的选择，这样代码能够一目了然。静态方法定义在类中，较之外部函数，能够更加有效地将代码组织起来，从而使相关代码的垂直距离更近，提高代码的可维护性。