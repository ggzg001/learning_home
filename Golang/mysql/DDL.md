

```python
%load_ext sql
%sql mysql+pymysql://root@localhost
```




    'Connected: root@None'



# 库和表的管理

一、库的管理

创建、修改、删除

二、表的管理

创建、修改、删除

创建： create
修改： alter
删除： drop

## 库的管理

### 创建
语法： create database [if not exists]库名;


```python
%sql create database ttt;
```

     * mysql+pymysql://root@localhost
    1 rows affected.





    []




```python
%sql create database ttt;
```

     * mysql+pymysql://root@localhost
    (pymysql.err.ProgrammingError) (1007, "Can't create database 'ttt'; database exists")
    [SQL: create database ttt;]
    (Background on this error at: http://sqlalche.me/e/f405)



```python
%sql create database if not exists ttt;
```

     * mysql+pymysql://root@localhost
    1 rows affected.


    /Users/guwanhua/venv36/lib/python3.6/site-packages/pymysql/cursors.py:170: Warning: (1007, "Can't create database 'ttt'; database exists")
      result = self._query(query)





    []



### 库的删除

语法：drop database [if exists]库名;


```python
%sql drop database if exists ttt;
```

     * mysql+pymysql://root@localhost
    0 rows affected.





    []



### 库的修改

库的修改一般不会用到，就算用到大部分也是改一下库的字符集。


```python
%sql alter database test character set utf8;
```

     * mysql+pymysql://root@localhost
    1 rows affected.


    /Users/guwanhua/venv36/lib/python3.6/site-packages/pymysql/cursors.py:170: Warning: (3719, "'utf8' is currently an alias for the character set UTF8MB3, but will be an alias for UTF8MB4 in a future release. Please consider using UTF8MB4 in order to be unambiguous.")
      result = self._query(query)





    []



## 表的管理

### 表的创建

语法：
```
create table 表名(
	列名 列的类型[(长度) 约束],
	列名 列的类型[(长度) 约束],
	列名 列的类型[(长度) 约束],
	...
	列名 列的类型[(长度) 约束]
)
```


```python
%sql use test;
%sql create table book(id int, name varchar(10), price DOUBLE, create_time datetime, update_time timestamp);
```

     * mysql+pymysql://root@localhost
    0 rows affected.
     * mysql+pymysql://root@localhost
    0 rows affected.





    []



### 表的修改

语法: alter table 表名 add|drop|modify|change column 列名 [列类型 约束];


```python
# 更换列名
%sql alter table book change column price Price float;
```

     * mysql+pymysql://root@localhost
    1 rows affected.





    []




```python
# 修改列的类型
%sql alter table book modify column Price double;
```

     * mysql+pymysql://root@localhost
    1 rows affected.





    []




```python
# 增加新列
%sql alter table book add column authorId int;
```

     * mysql+pymysql://root@localhost
    0 rows affected.





    []




```python
# 删除列
%sql alter table book drop column Price;
```

     * mysql+pymysql://root@localhost
    0 rows affected.





    []




```python
# 修改表的名称
%sql alter table book rename to books;
```

     * mysql+pymysql://root@localhost
    0 rows affected.





    []



### 表的删除

语法：drop table if exists 表名

### 表的复制

1. 仅仅复制表的结构
2. 复制表的结构+数据
3. 只复制部分数据
4. 仅仅复制某些字段


```python
# 仅仅复制表的结构
%sql create table books_copy like books;
%sql show tables;
```

     * mysql+pymysql://root@localhost
    0 rows affected.
     * mysql+pymysql://root@localhost
    2 rows affected.





<table>
    <tr>
        <th>Tables_in_test</th>
    </tr>
    <tr>
        <td>books</td>
    </tr>
    <tr>
        <td>books_copy</td>
    </tr>
</table>




```python
# 复制表的结构+数据
%sql create table b2 select * from books;
```

     * mysql+pymysql://root@localhost
    1 rows affected.





    []




```python
# 只复制部分数据
%sql create table b3 select * from books where id=1;
```

     * mysql+pymysql://root@localhost
    1 rows affected.





    []




```python
# 仅仅复制某些字段
%sql create table b4 select id,name from books where 1=2;
%sql desc b4;
```

     * mysql+pymysql://root@localhost
    0 rows affected.
     * mysql+pymysql://root@localhost
    2 rows affected.





<table>
    <tr>
        <th>Field</th>
        <th>Type</th>
        <th>Null</th>
        <th>Key</th>
        <th>Default</th>
        <th>Extra</th>
    </tr>
    <tr>
        <td>id</td>
        <td>int(11)</td>
        <td>YES</td>
        <td></td>
        <td>None</td>
        <td></td>
    </tr>
    <tr>
        <td>name</td>
        <td>varchar(10)</td>
        <td>YES</td>
        <td></td>
        <td>None</td>
        <td></td>
    </tr>
</table>



# 常见的数据类型

数值型：
	整型
	小数：
		定点数
		浮点数
字符型：
	较短的文本：char、varchar
	较长的文本：text、blob（较长的二进制数据）

日期型：
	

## 整型

分类：
```
tinyint、smallint、mediumint、int/integer、bigint
1	      2		   3	          4		    8
```

特点：
1. 如果不设置无符号还是有符号，默认是有符号，如果想设置无符号，需要添加unsigned关键字
2. 如果插入的数值超出了整型的范围,会报out of range异常，并且插入临界值
3. 如果不设置长度，会有默认的长度
4. 长度代表了显示的最大宽度，如果不够会用0在左边填充，但必须搭配zerofill使用, 使用了zerofill默认就是unsigned！

## 小数

1. 浮点型: float(M, D), double(M, D)
2. 定点型: dec(M, D), decimal(M, D)

特点：
```
M：整数部位+小数部位
D：小数部位
会严格按照M位来显示，小数位不足用0来补充


M和D都可以省略
如果是decimal，则M默认为10，D默认为0
如果是float和double，则会根据插入的数值的精度来决定精度

定点型的精确度较高，如果要求插入数值的精度较高如货币运算等则考虑使用
```

## 字符型

* 较短的文本：char, varchar
* 较长的文本：text, blob(较大的二进制)
* 其他：binary和varbinary用于保存较短的二进制
* enum用于保存枚举
* set用于保存集合

4.0版本以下，varchar(20)，指的是20字节，如果存放UTF8汉字时，只能存6个（每个汉字3字节） 
5.0版本以上，varchar(20)，指的是20字符，无论存放的是数字、字母还是UTF8汉字（每个汉字3字节），都可以存放20个，最大大小是65532字节 

char, varchar的区别：
* char(M)类型的数据列里，每个值都占用M个字节，如果某个长度小于M，MySQL就会在它的右边用空格字符补足．（在检索操作中那些填补出来的空格字符将被去掉）在varchar(M)类型的数据列里，每个值只占用刚好够用的字节再加上一个用来记录其长度的字节（即总长度为L+1字节）
* char因为是固定长度，所以从效率上来说可能要高一点。

什么时候使用char？ 

1. 存储很短的信息，比如门牌号码101，201……这样很短的信息应该用char，因为varchar还要占个byte用于存储信息长度，本来打算节约存储的现在得不偿失。 
2. 固定长度的。比如使用uuid作为主键，那用char应该更合适。因为他固定长度，varchar动态根据长度的特性就消失了，而且还要占个长度信息。 


关于varchar的问题是，varchar既然可以自动适应存储空间，那varchar(8)和varchar(255)存储应该都是一样的，那每次表设计的时候往大的方向去好了，免得以后不够用麻烦。这个思路对吗？答案是否定的。mysql会把表信息放到内存中，这时内存的申请是按照固定长度来的，如果varchar很大就会有问题。所以还是应该按需索取。

## 日期型

分类：
1. date 只保存日期
2. time 只保存时间
3. year 只保存年
4. datetime 保存日期+时间： 1000—9999 占8字节
5. timestamp 保存日期+时间： 1970—2038	占4字节


datetime与timestamp：
1. timestamp和实际时区有关，更能反映实际的日期，而datetime则只能反映出插入时的当地时区，对于跨时区的业务，TIMESTAMP更为合适
2. timestamp的属性受Mysql版本和SQLMode的影响很大





```python
%sql CREATE TABLE tab_date( \
    t1 DATETIME, \
    t2 TIMESTAMP \
);
```

     * mysql+pymysql://root@localhost
    0 rows affected.





    []




```python
%sql INSERT INTO tab_date VALUES(NOW(),NOW());
%sql SELECT * FROM tab_date;
```

     * mysql+pymysql://root@localhost
    1 rows affected.
     * mysql+pymysql://root@localhost
    1 rows affected.





<table>
    <tr>
        <th>t1</th>
        <th>t2</th>
    </tr>
    <tr>
        <td>2019-06-28 11:26:57</td>
        <td>2019-06-28 11:26:57</td>
    </tr>
</table>




```python
%sql SHOW VARIABLES LIKE 'time_zone';
# 设置时区
%sql SET time_zone='+9:00';
# 发现timestamp的字段时间会自动改变，因为mysql会在内部做这样的计算，把之前的时区和现在时区的区别做相应调整
%sql SELECT * FROM tab_date;
```

     * mysql+pymysql://root@localhost
    1 rows affected.
     * mysql+pymysql://root@localhost
    0 rows affected.
     * mysql+pymysql://root@localhost
    1 rows affected.





<table>
    <tr>
        <th>t1</th>
        <th>t2</th>
    </tr>
    <tr>
        <td>2019-06-28 11:26:57</td>
        <td>2019-06-28 12:26:57</td>
    </tr>
</table>



# 常见约束

含义：一种限制，用于限制表中的数据，为了保证表中的数据的准确和可靠性


分类：5大约束
1. NOT NULL：非空，用于保证该字段的值不能为空。比如姓名、学号等
2. DEFAULT:默认，用于保证该字段有默认值。比如性别
3. PRIMARY KEY:主键，用于保证该字段的值具有唯一性，并且非空。比如学号、员工编号等
4. UNIQUE:唯一，用于保证该字段的值具有唯一性。可以为空，比如座位号
5. FOREIGN KEY:外键，用于限制两个表的关系，用于保证该字段的值必须来自于主表的关联列的值，在从表添加外键约束，用于引用主表中某列的值。比如学生表的专业编号，员工表的部门编号，员工表的工种编号
	

添加约束的时机：
1. 创建表时
2. 修改表时
	

约束的添加分类：
1. 列级约束：5大约束语法上都支持，<font color="red">但外键约束没有效果</font>
2. 表级约束：<font color="red">除了非空、默认，其他的都支持</font>
		
		
主键和唯一的大对比：

	|保证唯一性 | 是否允许为空   | 一个表中可以有多少个   |是否允许组合|
	|主键	 |√		 |×	  |	至多有1个      |     √，但不推荐|
	|唯一	 |√		 |√	   |	可以有多个    |      √，但不推荐|
    
外键：
1. 要求在从表设置外键关系
2. 从表的外键列的类型和主表的关联列的类型要求一致或兼容，名称无要求
3. 主表的关联列必须是一个key（一般是主键或唯一）
4. 插入数据时，先插入主表，再插入从表; 删除数据时，先删除从表，再删除主表

语法：
```
CREATE TABLE 表名(
	字段名 字段类型 列级约束,
	字段名 字段类型,
	表级约束
)
```

## 创建表时添加约束

### 添加列级约束

语法：直接在字段名和类型后面追加 约束类型即可。

只支持：默认、非空、主键、唯一, 不支持外键


```python
%sql create table stuinfo (id int primary key, \
name varchar(10) not null unique, \
age int default 18, \
insert_time datetime default CURRENT_TIMESTAMP)                         

```

     * mysql+pymysql://root@localhost
    0 rows affected.





    []



### 添加表级约束

不支持：default、非空，其他都支持




```python
%sql drop table if exists stuinfo; 
%sql create table stuinfo ( \
id int, \
name varchar(12) not null, \
majorid int, \
constraint pk primary key(id), \
constraint uq unique(name), \
constraint fk foreign key(majorid) references major(id) 
)
```


```python
# 一般通用的写法, 把外键的设置用表级约束进行添加
%sql CREATE TABLE IF NOT EXISTS stuinfo( \
    id INT PRIMARY KEY, \
    stuname VARCHAR(20), \
    sex CHAR(1), \
    age INT DEFAULT 18, \
    seat INT UNIQUE, \
    majorid INT, \
    CONSTRAINT fk_stuinfo_major FOREIGN KEY(majorid) REFERENCES major(id)
);
```

## 修改表时添加约束

1. 添加列级约束
alter table 表名 modify column 字段名 字段类型 新约束;

2. 添加表级约束
alter table 表名 add 【constraint 约束名】 约束类型(字段名) 【外键的引用】;


```python
%sql DROP TABLE IF EXISTS stuinfo;
%sql CREATE TABLE stuinfo (id int, stuname char(20),gender CHAR(1),seat INT, age INT, majorid int)
```

     * mysql+pymysql://root@localhost
    0 rows affected.
     * mysql+pymysql://root@localhost
    0 rows affected.





    []




```python
%sql desc stuinfo;
```

     * mysql+pymysql://root@localhost
    6 rows affected.





<table>
    <tr>
        <th>Field</th>
        <th>Type</th>
        <th>Null</th>
        <th>Key</th>
        <th>Default</th>
        <th>Extra</th>
    </tr>
    <tr>
        <td>id</td>
        <td>int(11)</td>
        <td>YES</td>
        <td></td>
        <td>None</td>
        <td></td>
    </tr>
    <tr>
        <td>stuname</td>
        <td>char(20)</td>
        <td>YES</td>
        <td></td>
        <td>None</td>
        <td></td>
    </tr>
    <tr>
        <td>gender</td>
        <td>char(1)</td>
        <td>YES</td>
        <td></td>
        <td>None</td>
        <td></td>
    </tr>
    <tr>
        <td>seat</td>
        <td>int(11)</td>
        <td>YES</td>
        <td></td>
        <td>None</td>
        <td></td>
    </tr>
    <tr>
        <td>age</td>
        <td>int(11)</td>
        <td>YES</td>
        <td></td>
        <td>None</td>
        <td></td>
    </tr>
    <tr>
        <td>majorid</td>
        <td>int(11)</td>
        <td>YES</td>
        <td></td>
        <td>None</td>
        <td></td>
    </tr>
</table>




```python
# 1.添加非空约束
%sql alter table stuinfo modify column stuname varchar(20) not null;
```

     * mysql+pymysql://root@localhost
    0 rows affected.





    []




```python
# 2.添加默认约束
%sql alter table stuinfo modify column age int default 18;
```

     * mysql+pymysql://root@localhost
    0 rows affected.





    []




```python
# 3.添加主键
%sql alter table stuinfo modify column id int primary key;
```

     * mysql+pymysql://root@localhost
    0 rows affected.





    []




```python
# 4.添加外键
%sql CREATE TABLE if not exists major(id INT PRIMARY KEY, majorName VARCHAR(20));
%sql alter table stuinfo add constraint fk foreign key(majorid) references major(id);
```

     * mysql+pymysql://root@localhost
    0 rows affected.
     * mysql+pymysql://root@localhost
    0 rows affected.


    /Users/guwanhua/venv36/lib/python3.6/site-packages/pymysql/cursors.py:170: Warning: (1050, "Table 'major' already exists")
      result = self._query(query)





    []



## 修改表时删除约束



```python
# 1.删除非空约束
%sql ALTER TABLE stuinfo MODIFY COLUMN stuname VARCHAR(20) NULL;
```

     * mysql+pymysql://root@localhost
    0 rows affected.





    []




```python
# 2.删除默认约束
%sql ALTER TABLE stuinfo MODIFY COLUMN age INT ;
```

     * mysql+pymysql://root@localhost
    0 rows affected.





    []




```python
# 3.删除主键
%sql alter table stuinfo drop primary key;
```

     * mysql+pymysql://root@localhost
    0 rows affected.





    []




```python
# 4.删除外键
%sql alter table stuinfo drop foreign key fk;
```

     * mysql+pymysql://root@localhost
    0 rows affected.





    []



# 自增长列

含义：可以不用手动的插入值，系统提供默认的序列值


特点：
1. 标识列必须和主键搭配吗？不一定，但要求是一个key
2. 一个表可以有几个标识列？至多一个！
3. 标识列的类型只能是数值型(int float等)
4. 标识列可以通过 SET auto_increment_increment=3;设置步长

如果对float类型设置自增, 上一次的值是4， 某一次手动插入的值是7.2，那么下一次自动插入的值就是8.

下图的NAME设置成FLOAT UNIQUE AUTO_INCREMENT.
```
+------+------+------+
| id   | NAME | seat |
+------+------+------+
|    1 |    1 |    2 |
|    1 |    2 |    2 |
|    1 |  3.2 |    2 |
|    1 |    4 |    2 |
|    1 |  7.2 |    2 |
|    1 |    8 |    2 |
+------+------+------+
```

SHOW VARIABLES LIKE '%auto_increment%';

SET auto_increment_increment=3;


```python

```
