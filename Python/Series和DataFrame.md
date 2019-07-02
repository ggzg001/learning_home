# Series

series是一种类似于<font color="red">一维数组</font>的对象，由下面2部分组成

* values: 一组数据(ndarray类型)
* index: 相关的数据索引标签

## 创建

### 由列表或numpy数组创建

默认索引是0到N-1的整数型索引.

```python
In [77]: Series([1,2,3])
Out[77]:
0    1
1    2
2    3
dtype: int64

In [78]: import numpy as np

In [79]: Series(np.random.randint(1,20,size=(2,3)))
---------------------------------------------------------------------------
Exception                                 Traceback (most recent call last)
<ipython-input-79-7912422ee6f1> in <module>()
----> 1 Series(np.random.randint(1,20,size=(2,3)))
```

指定显式索引

```python
In [85]: Series(data=np.random.randint(1,40,size=(5,)), index=['a', 'b', 'c', 'd',
    ...:  'f'],name='boo')
Out[85]:
a    27
b     9
c    13
d    11
f    35
Name: boo, dtype: int64
```

由字典创建(数据源必须是一维数据)，但不能使用index参数，但是默认索引仍然存在。

```python
In [86]: Series(data={'a':1, 'b':2})
Out[86]:
a    1
b    2
dtype: int64

In [88]: Series(data={'a':1, 'b':2},index=['d','f'])
Out[88]:
d   NaN
f   NaN
dtype: float64
```

## series的索引和切片

可以使用中括号取单个索引(此时返回的是元素的类型), 或者中括号里一个列表套多个索引(此时返回的是Series类型)。

显式索引： s.loc[]：loc中位置放的一定是显式索引。

隐式索引：s.iloc[]   iloc中位置放的一定是隐式索引。

## 切片：隐式索引切片和显式索引切片

loc是闭区间，iloc是半开半闭区间。

```python
In [91]: s.loc['a':'b']
Out[91]:
a    1
b    2
dtype: int64

In [92]: s.iloc[0:1]
Out[92]:
a    1
dtype: int64
```

## series的操作

可以把series看做是一个不定长的有序字典，给series增加一行，相当于给字典增加一个键值对。

可以通过shape、size、index和values得到series的属性。

```python
In [94]: s.shape
Out[94]: (2,)

In [95]: s.size
Out[95]: 2

In [96]: s.values
Out[96]: array([1, 2])

In [97]: s.index
Out[97]: Index(['a', 'b'], dtype='object')
```

使用s.head，s.tail分别查看前n个和后n个值.

```
In [99]: s.head(1)
Out[99]:
a    1
dtype: int64
```

去重

```python
In [100]: s = Series(data=[1,2,1,1,2,3])

In [101]: s.unique()
Out[101]: array([1, 2, 3])
```

```python
In [102]: s1 = Series([1,2,3,4,5],index=['a','b','c','d','f'])

In [103]: s2 = Series([6,7,8,9,10],index=['a','b','d','g','h'])

In [104]: s1 + s2
Out[104]:
a     7.0
b     9.0
c     NaN
d    12.0
f     NaN
g     NaN
h     NaN
dtype: float64
```

s[[True, False, True]] 

```
In [108]: s[s.notnull()]
Out[108]:
a     7.0
b     9.0
d    12.0
dtype: float64
```

Series 之间的运算：

* 在运算中自动对齐不同索引的数据
* 如果索引不对齐，则补NaN

# DataFrame

DataFrame是一个表格型的数据结构，设计初衷是把Series的使用场景从一维拓展到多维。DataFrame既有行索引，也有列索引。

* 行索引： index
* 列索引： columns
* 值：values

## 创建

最常用的方法是传递一个字典来创建。DataFrame以字典的键作为每一列的名称，以字典的值(一个数组)作为每一列。此外，DataFrame会自动加上<font color="red">每一行</font>的索引，使用字典则columns参数不能被使用。同Series一样，如果传入的列与字典的键不匹配，则相应的值为NaN.

```python
In [117]: dic = {'a':1, 'b':2}

In [118]: DataFrame(dic,index=['c', 'd'])
Out[118]:
   a  b
c  1  2
d  1  2
```

使用ndarray创建DataFrame.

```python
In [109]: DataFrame(data=np.random.randint(1,200,(2,2)))
Out[109]:
    0    1
0  61  138
1  71   87
```

## 属性

```python
In [111]: df.shape
Out[111]: (2, 2)

In [112]: df.index
Out[112]: RangeIndex(start=0, stop=2, step=1)

In [113]: df.columns
Out[113]: RangeIndex(start=0, stop=2, step=1)

In [114]: df.values
Out[114]:
array([[199,  20],
       [ 57, 130]])

In [115]: df.size
Out[115]: 4

In [116]: df.dtypes
Out[116]:
0    int64
1    int64
dtype: object
```

## 索引

### 对列进行索引

- 通过类似字典的方式 df['a']
- 通过属性的方式 df.q

可以将DataFrame的列获取为一个Series, 返回的Series拥有原DataFrame相同的索引，且name属性也已经设置好就是相应的列名。

```python
In [124]: d['a']
Out[124]:
c    1
d    1
Name: a, dtype: int64
```

批量取数据索引

```python
In [125]: d[['a', 'b']]
Out[125]:
   a  b
c  1  2
d  1  2
```

修改列索引

```python
In [126]: d.columns = ['e', 'f']

In [127]: d
Out[127]:
   e  f
c  1  2
d  1  2
```

### 对行进行索引

- 使用loc[]   加显式index进行索引
- 使用iloc[]  加隐式来进行索引

```python
In [131]: d
Out[131]:
   e  f
c  1  2
d  1  2

In [132]: d.loc['c']
Out[132]:
e    1
f    2
Name: c, dtype: int64

In [133]: d.iloc[0]
Out[133]:
e    1
f    2
Name: c, dtype: int64

In [134]: d.iloc[[0,1]]
Out[134]:
   e  f
c  1  2
d  1  2
```

### 对元素进行索引

```python
In [136]: d.loc['c', 'e']
Out[136]: 1
```

## 切片

<font color="red">注意: 索引表示的是列索引， 切片表示的是行切片</font>

切行

```python
In [138]: d[0:1]
Out[138]:
   e  f
c  1  2

In [139]: d['c':'d']
Out[139]:
   e  f
c  1  2
d  1  2
```

切列

```python
In [142]: d.iloc[:,0:1]
Out[142]:
   e
c  1
d  1
```

```python
import pandas as pd

df = pd.read_csv('/Users/guwanhua/maotai.csv', index_col="date", parse_dates=['date'])
price_last = df['open'][-1]
df_month = df.resample("M").first()
df_year = df.resample("Y").last()[:-1]
cost = 0
hold = 0
for year in range(2016, 2019):
    cost -= df_month.loc[str(year)]["open"].sum() * 100
    hold += len(df_month.loc[str(year)]["open"]) * 100
    if year != 2019:
        cost += df_year.loc[str(year)]["open"][0] * hold
        hold = 0
cost += price_last * hold
print(cost)
```

## 对行的选拔的两种方式

```python
In [144]: df
Out[144]:
               a   b
1999-01-02   9.0   7
1999-01-03  14.0   8
1999-01-04   4.0   9
1999-01-05   5.0  10

In [145]: df['a'] - df['b'] > 2
Out[145]:
1999-01-02    False
1999-01-03     True
1999-01-04    False
1999-01-05    False
Freq: D, dtype: bool

In [146]: df[df['a'] - df['b'] > 2]
Out[146]:
               a  b
1999-01-03  14.0  8
```

```python
In [147]: df.loc[[False, True, False, False]]
Out[147]:
               a  b
1999-01-03  14.0  8
```

## resample抽样

```python
rng = pd.date_range('20180101', periods=12)
ts = pd.Series(np.arange(1,13), index=rng)

print(ts)

#### Outputs ####
2018-01-01     1
2018-01-02     2
2018-01-03     3
2018-01-04     4
2018-01-05     5
2018-01-06     6
2018-01-07     7
2018-01-08     8
2018-01-09     9
2018-01-10    10
2018-01-11    11
2018-01-12    12
Freq: D, dtype: int32
```

```python
ts_5d = ts.resample('5D').sum()
print(ts_5d)

#### Outputs ####
2018-01-01    15
2018-01-06    40
2018-01-11    23
Freq: 5D, dtype: int32
```

```python
ts_5d_rightclosed = ts.resample('5D', closed='right').sum()
print(ts_5d_rightclosed)

#### Outputs ####
2017-12-27     1
2018-01-01    20
2018-01-06    45
2018-01-11    12
Freq: 5D, dtype: int32
```

真实情况：

原始的时间序列是从18年1月1号到1月12号，一共12天。以5天为单位降采样处理后，变成了三个5天，分别是：

- 第一个5天：1-2-3-4-5-6
- 第二个5天：6-7-8-9-10-11
- 第三个5天：12-13-14-15-16

closed = 'right' 左开右闭

由于第一个5天是从1号到6号，但由于是左开区间，1号就落不到1到6号的那个区间，所以要往前补足：

- 区间1：(27, 1]
- 区间2：(1, 6]
- 区间3:   (6, 11]
- 区间4：(11, 16]

现在，在这四个区间上做数据聚合也是一样的道理了：对于区间1，是对28，29，30，31，1这五天的值求和（这里只有1号是有值的），其余的区间也是同理，但需要注意是左开右闭。

-  **closed**：划分区间的依据，left会划成**左闭右开**区间；right会划分成**左开右闭**的区间。一般来说，closed为right的时候，区间会比为left的时候多一个。区间划分完毕，聚合运算就在这个区间内执行。
-  **label**：划分区间完毕，根据label的不同，区间的索引就不同。如果label为left，则区间左边的日期作为索引；如果label为right，则区间右边的日期作为索引。

## 对缺失值的处理

### 直接丢弃

drop系列中

`df.dropna(axis=0, how='any', thresh=None, subset=None, inplace=False)`

### 前后填充

为什么是前后填充？因为前后属于同一列的属性。

`df.fillna(value=None, method=None, axis=None, inplace=False, limit=None, downcast=None, **kwargs)`

一般不会去指定value进行填充,  method : {‘backfill’, ‘bfill’, ‘pad’, ‘ffill’, None}, pad/ffill：用前一个非缺失值去填充该缺失值，backfill/bfill：用下一个非缺失值填充该缺失值。所谓的ffill(向前填充)就是用前一个值进行填充。

## 空值的处理



```python
In [110]: df
Out[110]:
               0   1   2   3
1999-01-01   NaN  11   1  12
1999-01-02   4.0   2  14  19
1999-01-03   8.0   7  12   6
1999-01-04  20.0   5   4  20
1999-01-05  17.0  14   3  12
1999-01-06   3.0  10   4   3
1999-01-07   1.0   1  20  21
1999-01-08  10.0   9   3   6
1999-01-09   8.0   6  18  19
1999-01-10   3.0   6  16   9
1999-01-11  21.0  15  20   8
1999-01-12   8.0   5  18  14
```

isnull() 一般和 any() 合用，notnull() 一般和 all() 在一起合用。

```python
In [111]: df.isnull()
Out[111]:
                0      1      2      3
1999-01-01   True  False  False  False
1999-01-02  False  False  False  False
1999-01-03  False  False  False  False
1999-01-04  False  False  False  False
1999-01-05  False  False  False  False
1999-01-06  False  False  False  False
1999-01-07  False  False  False  False
1999-01-08  False  False  False  False
1999-01-09  False  False  False  False
1999-01-10  False  False  False  False
1999-01-11  False  False  False  False
1999-01-12  False  False  False  False
```

```python
In [113]: df.isnull().any(axis=1)
Out[113]:
1999-01-01     True
1999-01-02    False
1999-01-03    False
1999-01-04    False
1999-01-05    False
1999-01-06    False
1999-01-07    False
1999-01-08    False
1999-01-09    False
1999-01-10    False
1999-01-11    False
1999-01-12    False
Freq: D, dtype: bool

In [114]: df[df.isnull().any(axis=1)]
Out[114]:
             0   1  2   3
1999-01-01 NaN  11  1  12
```

## 多级索引

```python
In [115]: col = pd.MultiIndex.from_product([['qizhong', 'qimo'], ['chinese', 'math']])

In [116]: df = DataFrame(data=np.random.randint(60, 100, size=(2,4)), index=['tom', 'jack'])

In [118]: df = DataFrame(data=np.random.randint(60, 100, size=(2,4)), index=['tom', 'jack'],columns=col)

In [119]: df
Out[119]:
     qizhong         qimo
     chinese math chinese math
tom       64   70      97   84
jack      76   77      81   97

In [120]: df.loc['tom', 'qizhong']
Out[120]:
chinese    64
math       70
Name: tom, dtype: int64

In [121]: df.loc['tom', 'qizhong']['math']
Out[121]: 70
```

## 拼接

pandas的拼接操作分为2种：

* 级联
* 合并

### 级联

`pd.concat(objs, axis=0, join='outer', join_axes=None, ignore_index=False, keys=None, levels=None, names=None, verify_integrity=False, sort=None, copy=True)`

关注的参数有如下几种：objs, axis,  join,  ignore_index

join: outer 和 inner。 outer 会将所有的选项进行级联，inner 只会将匹配的项级联到一起，不匹配的不级联。

#### 匹配级联

```python
In [124]: df1 = DataFrame(np.random.randint(0, 100, size=(3,3)), index=['a', 'b', 'c'], columns=['A', "B", "C"])

In [125]: df2 = DataFrame(np.random.randint(0, 100, size=(3,3)), index=['a', 'd', 'c'], columns=['A', "D", "C"])

In [126]: pd.concat((df1, df1))
Out[126]:
    A   B  C
a  83  95  2
b  71  91  6
c  56  39  0
a  83  95  2
b  71  91  6
c  56  39  0

In [127]: pd.concat((df1, df1), ignore_index=True)
Out[127]:
    A   B  C
0  83  95  2
1  71  91  6
2  56  39  0
3  83  95  2
4  71  91  6
5  56  39  0
```

#### 不匹配级联

不匹配级联指的是数据的维度的索引不一致，例如纵向级联时列索引不一致，横向级联时行索引不一致。

有2种连接方式：

* 外连接(outer)
* 内连接

```python
In [134]: pd.concat((df1, df2), axis=0)
Out[134]:
    A     B   C     D
a  83  95.0   2   NaN
b  71  91.0   6   NaN
c  56  39.0   0   NaN
a  77   NaN  70  90.0
d   2   NaN  78  54.0
c  65   NaN  89  32.0

In [135]: pd.concat((df1, df2), axis=0, join='inner')
Out[135]:
    A   C
a  83   2
b  71   6
c  56   0
a  77  70
d   2  78
c  65  89
```

append是竖直方向的拼接

```python
In [136]: df1.append(df2)
Out[136]:
    A     B   C     D
a  83  95.0   2   NaN
b  71  91.0   6   NaN
c  56  39.0   0   NaN
a  77   NaN  70  90.0
d   2   NaN  78  54.0
c  65   NaN  89  32.0
```

### 合并

merge和concat的区别在于，merge需要依据某一个共同的数据列进行合并。

注意每一列元素的顺序不要求一致。

`pd.merge(left, right, how='inner', on=None, left_on=None, right_on=None, left_index=False, right_index=False, sort=False, suffixes=('_x', '_y'), copy=True, indicator=False, validate=None)`

主要关注以下几个参数：left, right, how, on, left_on, right_on。

#### 一对一合并

```python
In [143]: df1 = DataFrame({'employee': ["Bob", "Jack", "Lisa"], "group": ["Accounting", "Engineering", "Engineering"]})

In [144]: df2 = DataFrame({'employee': ["Matin", "Jack", "Lisa"], 'hire_date': [2004, 2008, 2014]})

In [145]: df1
Out[145]:
  employee        group
0      Bob   Accounting
1     Jack  Engineering
2     Lisa  Engineering

In [146]: df2
Out[146]:
  employee  hire_date
0    Matin       2004
1     Jack       2008
2     Lisa       2014

In [147]: pd.merge(df1, df2)
Out[147]:
  employee        group  hire_date
0     Jack  Engineering       2008
1     Lisa  Engineering       2014

In [148]: pd.merge(df1, df2, how='outer')
Out[148]:
  employee        group  hire_date
0      Bob   Accounting        NaN
1     Jack  Engineering     2008.0
2     Lisa  Engineering     2014.0
3    Matin          NaN     2004.0
```

#### 多对一合并

```python
In [149]: df3 = DataFrame({"employee": ['Lisa', 'Jack'], 'group': ['Accounting', 'Engineering'], 'hire_date': [2004, 2016]})

In [150]: df4 = DataFrame({'group':["Accounting", "Engineering", "Engineering"], 'supervisor': ["Carly", 'Guido', "Steve"]})

In [151]: df3
Out[151]:
  employee        group  hire_date
0     Lisa   Accounting       2004
1     Jack  Engineering       2016

In [152]: df4
Out[152]:
         group supervisor
0   Accounting      Carly
1  Engineering      Guido
2  Engineering      Steve

In [153]: pd.merge(df3, df4)
Out[153]:
  employee        group  hire_date supervisor
0     Lisa   Accounting       2004      Carly
1     Jack  Engineering       2016      Guido
2     Jack  Engineering       2016      Steve

In [154]: pd.merge(df4, df3)
Out[154]:
         group supervisor employee  hire_date
0   Accounting      Carly     Lisa       2004
1  Engineering      Guido     Jack       2016
2  Engineering      Steve     Jack       2016

In [155]: pd.merge(df3, df4, on='group')
Out[155]:
  employee        group  hire_date supervisor
0     Lisa   Accounting       2004      Carly
1     Jack  Engineering       2016      Guido
2     Jack  Engineering       2016      Steve

In [156]: pd.merge(df4, df3, on='group')
Out[156]:
         group supervisor employee  hire_date
0   Accounting      Carly     Lisa       2004
1  Engineering      Guido     Jack       2016
2  Engineering      Steve     Jack       2016
```

#### 多对多合并

```python
In [157]: df1 = DataFrame({"employee": ["Bob", "Jack", "Lisa"], "group": ["Accounting", 'Engineering', "Engineering"]})

In [158]: df2 = DataFrame({'group': ['Engineering', "Engineering", "HR"], "supervisor": ["Carly", 'Guido', "Steve"]})

In [159]: df1
Out[159]:
  employee        group
0      Bob   Accounting
1     Jack  Engineering
2     Lisa  Engineering

In [160]: df2
Out[160]:
         group supervisor
0  Engineering      Carly
1  Engineering      Guido
2           HR      Steve

In [161]: pd.merge(df1, df2, on='group')
Out[161]:
  employee        group supervisor
0     Jack  Engineering      Carly
1     Jack  Engineering      Guido
2     Lisa  Engineering      Carly
3     Lisa  Engineering      Guido
```

以上分这三种合并，也是视数据的不同而分的，本质就是想同的值的列进行merge.

`pd.read_excel("excel_path", sheetname=0)`: sheetname表示一个excel有多个sheet, 取其中一个sheetname.





