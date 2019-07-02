# 创建

## 基本创建

```python
In [4]: import numpy as np

In [5]: np.array([1,2,3])
Out[5]: array([1, 2, 3])

In [6]: help(np.array)


In [7]: np.array([[1,2,3],['a','b']])
Out[7]: array([list([1, 2, 3]), list(['a', 'b'])], dtype=object)

In [8]: np.array([[1,2,3],['a','b', 'c']])
Out[8]:
array([['1', '2', '3'],
       ['a', 'b', 'c']], dtype='<U21')
```

numpy 默认所有的ndarray的所有元素的类型是相同的，如果传进来的列表中包含不同的类似，则统一为同一类型，str > float > int

## 利用np的routines函数创建

等差一维

```
In [10]: np.linspace(0, 100, 3)
Out[10]: array([  0.,  50., 100.])
```

```
In [11]: np.arange(1,10,2)
Out[11]: array([1, 3, 5, 7, 9])

In [12]: np.arange(1,10,1)
Out[12]: array([1, 2, 3, 4, 5, 6, 7, 8, 9])
```

随机array(一维和多维)

```python
In [14]: np.random.randint(1,10,size=(2,3))
Out[14]:
array([[6, 9, 2],
       [3, 2, 4]])
In [24]: np.random.random(size=(3,3))
Out[24]:
array([[0.29701836, 0.28786882, 0.11619332],
       [0.18172704, 0.49428977, 0.56576513],
       [0.22183517, 0.76749117, 0.57730807]])
```

size 和 shape 是类似的.

# array属性

size、shape、dtype、ndim

```
In [19]: d = np.random.randint(1,10,size=(2,3))

In [20]: d.size
Out[20]: 6

In [21]: d.shape
Out[21]: (2, 3)

In [22]: d.dtype
Out[22]: dtype('int64')

In [23]: d.ndim
Out[23]: 2
```

# ndarray的基本操作

## 索引

```python
In [30]: arr = np.random.randint(1,13,size=(3,3))

In [31]: arr
Out[31]:
array([[ 9,  3, 11],
       [10,  9,  8],
       [ 2,  7,  9]])

In [32]: arr[0]
Out[32]: array([ 9,  3, 11])
# 批量选择行索引
In [33]: arr[[0,1]]
Out[33]:
array([[ 9,  3, 11],
       [10,  9,  8]])
```

根据索引修改数据

```
In [34]: arr[0][0]
Out[34]: 9

In [35]: arr[0][0] = 3

In [36]: arr
Out[36]:
array([[ 3,  3, 11],
       [10,  9,  8],
       [ 2,  7,  9]])
```

## 切片

获取前两行

```
In [37]: arr[0:2]
Out[37]:
array([[ 3,  3, 11],
       [10,  9,  8]])
```

获取前两列

```
In [39]: arr[:,0:2]
Out[39]:
array([[ 3,  3],
       [10,  9],
       [ 2,  7]])
```

获取前两行和前两列

```
In [40]: arr[0:2,0:2]
Out[40]:
array([[ 3,  3],
       [10,  9]])
```

行倒序

```
In [42]: arr[::-1]
Out[42]:
array([[ 2,  7,  9],
       [10,  9,  8],
       [ 3,  3, 11]])
```

列倒序

```
In [43]: arr[:,::-1]
Out[43]:
array([[11,  3,  3],
       [ 8,  9, 10],
       [ 9,  7,  2]])
```

全倒序

```
In [44]: arr[::-1,::-1]
Out[44]:
array([[ 9,  7,  2],
       [ 8,  9, 10],
       [11,  3,  3]])
```

# 数组维度转换

```
In [45]: arr
Out[45]:
array([[ 3,  3, 11],
       [10,  9,  8],
       [ 2,  7,  9]])

In [46]: arr.reshape((9,))
Out[46]: array([ 3,  3, 11, 10,  9,  8,  2,  7,  9])
```

# 级联

np.concatenate

```
concatenate(...)
    concatenate((a1, a2, ...), axis=0, out=None)
```

axis = 0 表示列维度，axis = 1表示行维度

按列级联

```python
In [52]: np.concatenate((arr,arr))
Out[52]:
array([[ 3,  3, 11],
       [10,  9,  8],
       [ 2,  7,  9],
       [ 3,  3, 11],
       [10,  9,  8],
       [ 2,  7,  9]])
```

按行级联

```python
In [53]: np.concatenate((arr,arr),axis=1)
Out[53]:
array([[ 3,  3, 11,  3,  3, 11],
       [10,  9,  8, 10,  9,  8],
       [ 2,  7,  9,  2,  7,  9]])
```

级联的参数是列表；维度必须相同；形状相符；通过axis改变级联方向。

# 切割

np.split

```python
split(ary, indices_or_sections, axis=0)
    Split an array into multiple sub-arrays.
```

大小要么按照数字来划分（int），要么是一个list来划分：但是如果你仅是输入一个int类型的数字的话，你的数组必须是均等的分割，否则就会报错，不像array_split()是可以进行不均等的划分的！

```python
In [66]: np.split(arr,[1])
Out[66]:
[array([[ 3,  3, 11]]), array([[10,  9,  8],
        [ 2,  7,  9]])]

In [67]: np.split(arr,[1],axis=1)
Out[67]:
[array([[ 3],
        [10],
        [ 2]]), array([[ 3, 11],
        [ 9,  8],
        [ 7,  9]])]
```

这里的axis表示的是切刀的落点

# 排序

np.sort() 和 ndarray.sort() 都可以，其中np.sort 不改变输入，ndarray.sort()本地处理不占用空间，但是改变输入。

```python
sort(a, axis=-1, kind='quicksort', order=None)
```

按列排序

```python
In [73]: np.sort(arr,axis=0)
Out[73]:
array([[ 2,  3,  9],
       [ 3,  7, 10],
       [ 8,  9, 11]])
```



