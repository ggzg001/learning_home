argparse是python的一个命令行解析包，非常编写可读性非常好的程序。使用好argparse其实主要分清2种参数：位置参数(必要参数)和可选参数(非必要参数)。

简单的使用分3步：

1. 创建解析器对象
2. 添加需要解析的参数
3. 解析

## 创建解析器对象

`argparse.ArgumentParser`

常用的参数有description， add_help, conflict_handler, prog.

```python
import argparse

parser = argparse.ArgumentParser(description="这是我的第一个命令行解析工具")
parser.add_argument("-x", nargs=3)
args = parser.parse_args()
print(args)
```

## ![image-20190419172912851](https://ws4.sinaimg.cn/large/006tNc79ly1g282n5q2rzj30de04m74g.jpg)

`add_help = False` 的情况下，`python test.py -h` 不会显示帮助信息

conflict_handler: 默认是'error',  解决冲突的策略，默认情况下冲突会发生错误

```
import argparse

parser = argparse.ArgumentParser(description="这是我的第一个命令行解析工具")
parser.add_argument("-x", "--xmind", dest="y")
parser.add_argument("-x")
args = parser.parse_args()
```

```
import argparse
parser = argparse.ArgumentParser(description="The Help Of Python",epilog="End Of Help",conflict_handler="resolve")
parser.add_argument("-t","--thread",help="Thread Run",action="store_true")
parser.add_argument("-t","--thread",help="Thread Run(2)",action="store_true")
args = parser.parse_args()
if args.thread:
    print(args)
else:
    print("Error")
```

![img](https://images2017.cnblogs.com/blog/1242616/201801/1242616-20180121220821787-2100890918.png)

prog**：程序的名字，默认为sys.argv[0]，用来在help信息中描述程序的名称

```
import argparse

parser = argparse.ArgumentParser(description="这是我的第一个命令行解析工具", usage="车手")
parser.add_argument("-x", "--xmind", dest="y")
args = parser.parse_args()
```

![image-20190419173621458](https://ws2.sinaimg.cn/large/006tNc79gy1g282ukgfstj30go05a0t1.jpg)

**usage**：描述程序用途的字符串

```
import argparse

parser = argparse.ArgumentParser(description="这是我的第一个命令行解析工具", usage="马龙")
parser.add_argument("-x", "--xmind", dest="y")
args = parser.parse_args()
print(args)
```

![image-20190419173714723](https://ws1.sinaimg.cn/large/006tNc79gy1g282vhs655j30gi055aac.jpg)

## 添加解析参数

`add_argument(name or flags...[, action][, nargs][, const][, default][, type][, choices][, required][, help][, metavar][, dest])`

**name or flags**：参数有两种，可选参数和位置参数。

添加可选参数：`parser.add_argument('-f', '--foo')`

添加位置参数：`parser.add_argument('bar')`

parse_args()运行时，会用'-'来认证可选参数，剩下的即为位置参数。位置参数position arguments:  必须提供，无法使用default来设置默认值, 也无法使用dest来指定新变量的指向。传值得时候直接放值就行，不是使用bar 20的形式，是直接使用20的形式。位置参数的传递位置其实也有讲究，如果定义了两个位置参数，那么被可选参数挑选剩下的值就会按照定义位置参数的顺序分配给位置参数。

### **action**

#### store_const

store常常结合const来使用，使用这个表示定义一个不需要也不允许用户传的常量,<font color="red">用于position argument</font>

```python
import argparse

parser = argparse.ArgumentParser(description="这是我的第一个命令行解析工具", usage="车手")
parser.add_argument("-x", "--xmind", dest="y")
parser.add_argument('bar', action="store_const", const=23)
parser.add_argument("foo")
# Namespace(bar=23, foo='30', y=None)
args = parser.parse_args(['30'])
```

用于optional argument 时，只有出现可选参数，才会触发store_const的操作。

#### store_true和store_false

<font color="red">分情况，用于position argument的时候可以理解成store_const成true或flase的效果，用于optional argument时，如果出现可选参数把可选参数置为store的值，否则取反</font>

```python
import argparse

parser = argparse.ArgumentParser(description="这是我的第一个命令行解析工具", usage="车手")
parser.add_argument("-x", "--xmind", action="store_false")
parser.add_argument("foo")
# Namespace(foo='30', xmind=True)
args = parser.parse_args(['30'])
```

#### append

分两种情况，其中position argument的效果不如optional argument

```python
import argparse

parser = argparse.ArgumentParser(description="这是我的第一个命令行解析工具", usage="车手")
parser.add_argument("-x", "--xmind", action="append")
parser.add_argument("foo")
args = parser.parse_args()
```

![image-20190420134443450](https://ws1.sinaimg.cn/large/006tNc79ly1g291rwxhpej30dl0190sp.jpg)

```
import argparse

parser = argparse.ArgumentParser(description="这是我的第一个命令行解析工具", usage="车手")
# parser.add_argument("-x", "--xmind", action="append")
parser.add_argument("foo", action="append")
args = parser.parse_args()
```

![image-20190420134638944](https://ws2.sinaimg.cn/large/006tNc79ly1g291tvjfakj30dt03b74h.jpg)

#### append_const

```
import argparse

parser = argparse.ArgumentParser(description="这是我的第一个命令行解析工具", usage="车手")
# parser.add_argument("-x", "--xmind", action="append")
parser.add_argument("--foo", action="append_const", const=1, dest="const")
parser.add_argument("--bar", action="append_const", const=1, dest="const")
args = parser.parse_args()
```

![image-20190420140005361](https://ws4.sinaimg.cn/large/006tNc79ly1g2927yo97zj30dm02owel.jpg)

#### count

统计参数出现的次数, 一般用于optional argument

```
import argparse

parser = argparse.ArgumentParser(description="这是我的第一个命令行解析工具", usage="车手")
# parser.add_argument("-x", "--xmind", action="append")
parser.add_argument("--foo", action="count", default=0)
args = parser.parse_args()
```

![image-20190420140644755](https://ws3.sinaimg.cn/large/006tNc79ly1g292evsvmpj30ek03zq37.jpg)

### nargs

用于捕获多少个参数填充变量，值的类型可以是正数，可以是字符串："+"， "*"以及"?".

```
import argparse

parser = argparse.ArgumentParser(description="这是我的第一个命令行解析工具", usage="车手")
parser.add_argument("-foo", nargs=3)
args = parser.parse_args()
```

![image-20190420141154925](https://ws1.sinaimg.cn/large/006tNc79ly1g292k9jrv3j30f905f0t8.jpg)

```python
import argparse

parser = argparse.ArgumentParser(description="这是我的第一个命令行解析工具", usage="车手")
parser.add_argument("foo", nargs=3)
args = parser.parse_args()
```

![image-20190420141945214](https://ws3.sinaimg.cn/large/006tNc79ly1g292sfe6wnj30ci01rweh.jpg)

### default

### type

对传入的值做类型转换

### dest

对参数重命名，不能用于position argument，只能用于optional argument.

```python
import argparse

parser = argparse.ArgumentParser(description="这是我的第一个命令行解析工具", usage="车手")
parser.add_argument("-foo", dest="y")
parser.add_argument("-bar", dest="y")
args = parser.parse_args()
```

![image-20190420142330941](https://ws2.sinaimg.cn/large/006tNc79ly1g292w8ecbgj30dh01dwef.jpg)

```python
import argparse

parser = argparse.ArgumentParser(description="这是我的第一个命令行解析工具", usage="车手")
parser.add_argument("-foo", dest="y", action="append")
parser.add_argument("-bar", dest="y", action="append")
args = parser.parse_args()
```

![image-20190420142622464](https://ws1.sinaimg.cn/large/006tNc79ly1g292zay935j30ek01kq2w.jpg)

### **choices**

可供选择的值，是一种约束。

## 互斥参数

必须使用optional argument

```python
import argparse

parser = argparse.ArgumentParser(description="这是我的第一个命令行解析工具", usage="车手")
group = parser.add_mutually_exclusive_group()
group.add_argument('-bar')
group.add_argument("-foo")
args = parser.parse_args()
```

要么都不出现，要么只出现一个，两个同时出现就会报错。

## 解析参数

参数有几种写法：

1. 空格
2. =

```python
>>> parser = argparse.ArgumentParser(prog='PROG')
>>> parser.add_argument('-x')
>>> parser.add_argument('--foo')
>>> parser.parse_args('-x X'.split())
Namespace(foo=None, x='X')
>>> parser.parse_args('--foo FOO'.split())
Namespace(foo='FOO', x=None)
```

```python
>>> parser.parse_args('--foo=FOO'.split())
Namespace(foo='FOO', x=None)
```

parse_args()方法的返回值为namespace，可以用vars()内建函数化为字典.



## 子解析器

```python
>>> # sub-command functions
>>> def foo(args):
... print args.x * args.y
...
>>> def bar(args):
... print '((%s))' % args.z
...
>>> # create the top-level parser
>>> parser = argparse.ArgumentParser()
>>> subparsers = parser.add_subparsers()
>>>
>>> # create the parser for the "foo" command
>>> parser_foo = subparsers.add_parser('foo')
>>> parser_foo.add_argument('-x', type=int, default=1)
>>> parser_foo.add_argument('y', type=float)
>>> parser_foo.set_defaults(func=foo)
>>>
>>> # create the parser for the "bar" command
>>> parser_bar = subparsers.add_parser('bar')
>>> parser_bar.add_argument('z')
>>> parser_bar.set_defaults(func=bar)
>>>
>>> # parse the args and call whatever function was selected
>>> args = parser.parse_args('foo 1 -x 2'.split())
>>> args.func(args)
2.0
>>>
>>> # parse the args and call whatever function was selected
>>> args = parser.parse_args('bar XYZYX'.split())
>>> args.func(args)
((XYZYX))
```

 通过这种方式，你可以在解析完参数之后，调用指定的函数，但是必须检查子命令的名字。

```python
>>> parser = argparse.ArgumentParser()
>>> subparsers = parser.add_subparsers(dest='subparser_name')
>>> subparser1 = subparsers.add_parser('1')
>>> subparser1.add_argument('-x')
>>> subparser2 = subparsers.add_parser('2')
>>> subparser2.add_argument('y')
>>> parser.parse_args(['2', 'frobble'])
Namespace(subparser_name='2', y='frobble')
```

```python
>>> from string import Template
>>> template_string = '$who likes $what'
>>> s = Template(template_string)
>>> d = {'who': 'Tim', 'what': 'kung pao'}
>>> s.substitute(d)
'Tim likes kung pao'
```

