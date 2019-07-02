# 删除重复元素

```python
In [164]: df1 = DataFrame(np.random.randint(1, 20, size=(6, 6)))
  
In [169]: df1.iloc[0] = 666

In [170]: df1
Out[170]:
     0    1    2    3    4    5
0  666  666  666  666  666  666
1   19   18   12    1   17   13
2   11    9   16   17   15    6
3   15   15    8   19   12    9
4    6   14    1    1   18    6
5    9    3    9   18    8    4

In [171]: df1.loc[2] = 666

In [172]: df1
Out[172]:
     0    1    2    3    4    5
0  666  666  666  666  666  666
1   19   18   12    1   17   13
2  666  666  666  666  666  666
3   15   15    8   19   12    9
4    6   14    1    1   18    6
5    9    3    9   18    8    4
```

## 查看重复元素的行

查看重复的行,  参数keep有三种不同类型的值: first 表示保留重复的第一行。

```python
In [187]: df1
Out[187]:
     a    b    c    d    e    f
0  666  666  666  666  666  666
1   19   18   12    1   17   13
2  666  666  666  666  666  666
3   15   15    8   19   12    9
4    6   14    1    1   18    6
5    9    3    9   18    8    4

In [188]: df1.duplicated(keep='first')
Out[188]:
0    False
1    False
2     True
3    False
4    False
5    False
dtype: bool

In [189]: df1.duplicated(keep='last')
Out[189]:
0     True
1    False
2    False
3    False
4    False
5    False
dtype: bool

In [190]: df1.duplicated(keep=False)
Out[190]:
0     True
1    False
2     True
3    False
4    False
5    False
dtype: bool
```

## 删除重复元素的行

```python
In [195]: index = df1.loc[df1.duplicated(keep='first')].index

In [196]: df1.drop(labels=index, axis=0)
Out[196]:
     a    b    c    d    e    f
0  666  666  666  666  666  666
1   19   18   12    1   17   13
3   15   15    8   19   12    9
4    6   14    1    1   18    6
5    9    3    9   18    8    4
```

也可以直接使用封装好的一个函数drop_duplicates

```python
In [197]: df1.drop_duplicates(keep='first')
Out[197]:
     a    b    c    d    e    f
0  666  666  666  666  666  666
1   19   18   12    1   17   13
3   15   15    8   19   12    9
4    6   14    1    1   18    6
5    9    3    9   18    8    4
```

# 映射

## replace

`df1.replace(to_replace=None, value=None, inplace=False, limit=None, regex=False, method='pad')`

单值替换

```python
In [201]: df1
Out[201]:
     a    b    c    d    e    f
0  666  666  666  666  666  666
1   19   18   12    1   17   13
2  666  666  666  666  666  666
3   15   15    8   19   12    9
4    6   14    1    1   18    6
5    9    3    9   18    8    4

In [202]: df1.replace(to_replace=666, value=10)
Out[202]:
    a   b   c   d   e   f
0  10  10  10  10  10  10
1  19  18  12   1  17  13
2  10  10  10  10  10  10
3  15  15   8  19  12   9
4   6  14   1   1  18   6
5   9   3   9  18   8   4
```

多个值分别进行替换

```python
In [203]: df1
Out[203]:
     a    b    c    d    e    f
0  666  666  666  666  666  666
1   19   18   12    1   17   13
2  666  666  666  666  666  666
3   15   15    8   19   12    9
4    6   14    1    1   18    6
5    9    3    9   18    8    4

In [204]: df1.replace(to_replace=[1, 666], value=[22, 10])
Out[204]:
    a   b   c   d   e   f
0  10  10  10  10  10  10
1  19  18  12  22  17  13
2  10  10  10  10  10  10
3  15  15   8  19  12   9
4   6  14  22  22  18   6
5   9   3   9  18   8   4
```

```python
In [205]: df1
Out[205]:
     a    b    c    d    e    f
0  666  666  666  666  666  666
1   19   18   12    1   17   13
2  666  666  666  666  666  666
3   15   15    8   19   12    9
4    6   14    1    1   18    6
5    9    3    9   18    8    4

In [206]: df1.replace(to_replace={666: 0})
Out[206]:
    a   b   c   d   e   f
0   0   0   0   0   0   0
1  19  18  12   1  17  13
2   0   0   0   0   0   0
3  15  15   8  19  12   9
4   6  14   1   1  18   6
5   9   3   9  18   8   4
```

## map

map是新建一列，map函数不是df的方法，而是series的方法。

* map可以映射新一列数据
* map可以使用lambda表达式
* map可以使用自定义的方法

```python
In [211]: df = DataFrame({"name": ["jack", 'tom', 'jay'], 'salary': [10000, 15000, 20000]})

In [212]: df
Out[212]:
   name  salary
0  jack   10000
1   tom   15000
2   jay   20000

In [213]: dic = {"jack": "谷", "tom": "王", "jay": "张"}

In [214]: df['name'].map(dic)
Out[214]:
0    谷
1    王
2    张
Name: name, dtype: object

In [215]: df['c_name'] = df['name'].map(dic)

In [216]: df
Out[216]:
   name  salary c_name
0  jack   10000      谷
1   tom   15000      王
2   jay   20000      张
```



map可以当做一种运算工具，至于执行何种运算，是由map函数的参数决定的(参数：lambda 函数)。

```python
In [217]: def after_sal(s):
     ...:     if s < 10000:
     ...:         return s
     ...:     else:
     ...:         return s - 10000
     ...:

In [218]: df['salary'].map(after_sal)
Out[218]:
0        0
1     5000
2    10000
Name: salary, dtype: int64
```

并不是任何形式的函数都可以作为map的参数，只有当一个函数具有一个参数且有返回值才能作为map的参数。

# 使用聚合操作对数据异常值进行检查和过滤

```python
df = DataFrame(data=np.random.random(size=(100,3)), columns=['A', "B", "C"])
```

去除C列数据大于C列标准差

```python
df.loc[df['C'] < df['C'].std() * 2]
```

# 排序

task() 接收一个索引列表，用数字表示，使得df根据列表中索引的顺序进行排序。

```python
In [227]: df.take([2,1,0], axis=0)
Out[227]:
          A         B         C
2  0.618262  0.791531  0.083423
1  0.497472  0.544447  0.463508
0  0.434423  0.139949  0.887366
```

发现take的axis的轴向比较特殊，和drop是一类的，并且第一个参数列表必须是隐式索引。

np.random.permutation(x) 可以生成x个从0到x-1的随机数列。

```python
In [228]: np.random.permutation(10)
Out[228]: array([0, 6, 7, 9, 4, 2, 1, 8, 3, 5])
```

当DataFrame足够大的时候，可以使用np.random.permutation以及take做随机抽样。

# 数据分类

`df.groupby(by=None, axis=0, level=None, as_index=True, sort=True, group_keys=True, squeeze=False, observed=False, **kwargs)`

```python
In [234]: df
Out[234]:
   Animal  Max Speed
0  Falcon      380.0
1  Falcon      370.0
2  Parrot       24.0
3  Parrot       26.0

In [235]: df.groupby(by='Animal', axis=0)
Out[235]: <pandas.core.groupby.groupby.DataFrameGroupBy object at 0x1178322e8>

In [236]: df.groupby(by='Animal', axis=0).groups
Out[236]:
{'Falcon': Int64Index([0, 1], dtype='int64'),
 'Parrot': Int64Index([2, 3], dtype='int64')}
```

分组后的聚合操作：分组后的成员可以被进行运算的值会被进行运算，不能被运算的值不进行运算。

```python
In [30]: df
Out[30]:
   A  B  C
0  1  1  2
1  1  2  3
2  2  3  4

In [31]: df.groupby('A')['B']
Out[31]: <pandas.core.groupby.groupby.SeriesGroupBy object at 0x117602978>

In [32]: df.groupby('A')['B'].sum()
Out[32]:
A
1    3
2    3
Name: B, dtype: int64
In [33]: df.groupby('A')['B'].sum().to_dict()
Out[33]: {1: 3, 2: 3}
```

```python
In [37]: df['A_mean'] = df['A'].map(df.groupby('A')['B'].mean().to_dict())

In [38]: df
Out[38]:
   A  B  C  A_mean
0  1  1  2     1.5
1  1  2  3     1.5
2  2  3  4     3.0
```

分组by参数也可以是一个列表，如`table.groupby(['contb_receipt_dt','party']).groups`

## 高级数据聚合

使用groupby分组之后，也可以使用transform和apply提供自定义函数实现更多的运算。

* df.groupby("item")["price"].sum() <==> df.groupby("item")["price"].apply(sum)
* transform和apply都可以进行运算，在transform或者apply中传入函数即可。
* transform和apply也可以传入一个lambda表达式。

比如说求出水果的平均价格：

```
def func(s):
    summary = 0
    for i in s:
        summary += i
    return summary / s.size

df.group_by(by="item")["price"].apply(func)
```

apply的效率比map高。

# 替换DataFrame中的某些元素

```python
In [43]: df
Out[43]:
     A  B  C  A_mean
0  NaN  1  2     1.5
1  1.0  2  3     1.5
2  2.0  3  4     3.0

In [44]: df.loc[[0, 1], 'A'] = [3,4]

In [45]: df
Out[45]:
     A  B  C  A_mean
0  3.0  1  2     1.5
1  4.0  2  3     1.5
2  2.0  3  4     3.0

In [46]: df.loc[[0, 1], 'A'] = 5

In [47]: df
Out[47]:
     A  B  C  A_mean
0  5.0  1  2     1.5
1  5.0  2  3     1.5
2  2.0  3  4     3.0
```

# 小tips

1.某一列有缺失数据，找出是哪些行？

```python
In [53]: df['A'].isnull()
Out[53]:
0     True
1    False
2    False
Name: A, dtype: bool

In [54]: df.loc[df['A'].isnull()]
Out[54]:
    A  B  C  A_mean
0 NaN  1  2     1.5
```

2.去除所有含义缺失数据的行? 先找到有缺失数据的行，然后通过索引去除或者通过drop去除。

```python
In [60]: df.isnull().any(axis=1)
Out[60]:
0     True
1     True
2    False
dtype: bool

In [61]: df.loc[~df.isnull().any(axis=1)]
Out[61]:
     A    B  C  A_mean
2  2.0  3.0  4     3.0
```

3.找出C列大于2且A列小于5的数据行？

```python
In [62]: df
Out[62]:
     A    B  C  A_mean
0  NaN  1.0  2     1.5
1  5.0  NaN  3     1.5
2  2.0  3.0  4     3.0

In [63]: df.query("C > 2 & A < 5")
Out[63]:
     A    B  C  A_mean
2  2.0  3.0  4     3.0
```

4.计算各州的人口密度

```python
In [77]: df['D'] = df["A"] / df["B"]

In [78]: df
Out[78]:
     A    B  C         D
0  5.0  1.0  2  5.000000
1  5.0  3.0  3  1.666667
2  2.0  3.0  4  0.666667
```

5.找出人口密度最高的5个州？

```
In [85]: df.sort_values(by='A', axis=0)[0:5]
Out[85]:
     A    B  C         D
2  2.0  3.0  4  0.666667
```

6.使用value_counts()函数，统计party列中各个元素出现次数，value_counts()是Series中的，无参，返回一个带有每个元素出现次数的Series

```python
In [61]: df['party'].value_counts()
Out[61]:
Democrat       292400
Republican     237575
Reform           5364
Libertarian       702
Name: party, dtype: int64
```

7.查看具体每天各个党派收到的政治献金总数contb_receipt_amt

```python
r1 = df.groupby(['contb_receipt_dt','party'])['contb_receipt_amt'].sum()

In [69]: r1.head(4)
Out[69]:
contb_receipt_dt  party
01-APR-11         Reform             50.0
                  Republican      12635.0
01-AUG-11         Democrat       175281.0
                  Libertarian      1000.0
Name: contb_receipt_amt, dtype: float64
# unstack()将所得数据中的party行索引变成列索引
In [71]: r1.unstack(level=1).fillna(value=0).head(4)
Out[71]:
party              Democrat  Libertarian  Reform  Republican
contb_receipt_dt
01-APR-11              0.00          0.0    50.0    12635.00
01-AUG-11         175281.00       1000.0  1847.0   234598.46
01-DEC-11         651532.82        725.0   875.0   486405.96
01-FEB-11              0.00          0.0     0.0      250.00
```

8.查看老兵(捐献者职业)DISABLED VETERAN主要支持谁 ：查看老兵们捐赠给谁的钱最多 考察Series索引

```python
In [79]: r3 = df.loc[df['contbr_occupation'] == 'DISABLED VETERAN'].groupby('cand_nm')['contb_receipt_amt'].sum()

In [80]: r3
Out[80]:
cand_nm
Cain, Herman       300.00
Obama, Barack     4205.00
Paul, Ron         2425.49
Santorum, Rick     250.00
Name: contb_receipt_amt, dtype: float64

In [82]: r3.reset_index()
Out[82]:
          cand_nm  contb_receipt_amt
0    Cain, Herman             300.00
1   Obama, Barack            4205.00
2       Paul, Ron            2425.49
3  Santorum, Rick             250.00

In [84]: s1 = Series([1,2,4], index=['a', 'b', 'v'], name='xxx')

In [85]: s1
Out[85]:
a    1
b    2
v    4
Name: xxx, dtype: int64

In [86]: s1.reset_index()
Out[86]:
  index  xxx
0     a    1
1     b    2
2     v    4
```

9.找出各个候选人的捐赠者中，捐赠金额最大的人的职业以及捐献额

```python
table['contb_receipt_amt'].max() # 1944042.43
table.query("contb_receipt_amt == 1944042.43")
```

其中contb_receipt_amt是列

# 双曲线策略

![éååæ­"åçå"ä¹.jpg](http://ww4.sinaimg.cn/large/006tNc79ly1g3q9fajdzqj30j60fcab1.jpg)

金叉：多方占据有利低位的表现，一旦个股出现黄金交叉，后市上涨空间非常可观，黄金交叉点形成之际就是最佳的入场时机。

死叉： 此形态常出现在个股下跌区域，表现形式为短线均线从上往下突破中长期均线，从而产生的交叉现象称为死亡交叉。如MA10下行穿越MA30，形成MA30在上，MA10在下的形态，其交叉点位就是死亡交叉。

金叉适宜买入，死叉适宜卖出止损，一般情况下死叉的值比金叉要高。

```
s1 = m5 < m30  T-F 金叉  F-T 死叉
s2 = m5 >= m30 
s1 T T F F T T F F
s2   F F T T F F T T
     T F T T T F T    按位或  出现的两个F是金叉
```

```python
df = pd.read_csv("600519.csv",index_col='date', parse_dates=['date'])[['open','close','low','high']]
df['ma5']=df['open'].rolling(5).mean()
df['ma30']=df['open'].rolling(30).mean()
sr1 = df['ma5'] < df['ma30']
sr2 = df['ma5'] >= df['ma30']
death_cross = df[sr1 & sr2.shift(1)].index
golden_cross = df[~(sr1 | sr2.shift(1))].index
first_money = 100000
money = first_money
hold = 0#持有多少股
sr1 = pd.Series(1, index=golden_cross)
sr2 = pd.Series(0, index=death_cross)
# 把两者拼接在一起并按照时间排序，这样每一个金叉正好对应相应的死叉
sr = sr1.append(sr2).sort_index()

for i in range(0, len(sr)):
    p = df['open'][sr.index[i]]
    if sr.iloc[i] == 1:
        # 金叉, 尽量买入, 1手等于100股
        buy = (money // (100 * p))
        # 持有多少股股票
        hold += buy*100
        money -= buy*100*p
    else:
        money += hold * p
        hold = 0
# 如果此时还有hold, 说明没有碰到交易出去的死叉, 如果hold=0,那么now_money=money       
price = df['open'][-1]
now_money = hold * price + money

print(now_money - first_money)
```







单独拿出来再聚合

apply的效率比map高

机器学习帮我们去解方程









