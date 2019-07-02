

```python
%load_ext sql
%sql mysql+pymysql://root@localhost/girls
```

    The sql extension is already loaded. To reload it, use:
      %reload_ext sql





    'Connected: root@girls'



# DML



针对数据的操作语言：
* 插入：insert
* 修改：update
* 删除：delete



## 插入语句
方式一：经典的插入
`insert into 表名(列名,...) values(值1,...);`

方式二：
`insert into 表名 set 列名=值,列名=值,...`

两种方式的比较：
1. 方式一支持插入多行,方式二不支持
2. 方式一支持子查询，方式二不支持

通过比较，还是方式一用的比较多。


```python
%sql DESC beauty;
```

     * mysql+pymysql://root@localhost/girls
       mysql+pymysql://root@localhost/myemployees
    7 rows affected.





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
        <td>NO</td>
        <td>PRI</td>
        <td>None</td>
        <td>auto_increment</td>
    </tr>
    <tr>
        <td>name</td>
        <td>varchar(50)</td>
        <td>NO</td>
        <td></td>
        <td>None</td>
        <td></td>
    </tr>
    <tr>
        <td>sex</td>
        <td>char(1)</td>
        <td>YES</td>
        <td></td>
        <td>女</td>
        <td></td>
    </tr>
    <tr>
        <td>borndate</td>
        <td>datetime</td>
        <td>YES</td>
        <td></td>
        <td>1987-01-01 00:00:00</td>
        <td></td>
    </tr>
    <tr>
        <td>phone</td>
        <td>varchar(11)</td>
        <td>NO</td>
        <td></td>
        <td>None</td>
        <td></td>
    </tr>
    <tr>
        <td>photo</td>
        <td>blob</td>
        <td>YES</td>
        <td></td>
        <td>None</td>
        <td></td>
    </tr>
    <tr>
        <td>boyfriend_id</td>
        <td>int(11)</td>
        <td>YES</td>
        <td></td>
        <td>None</td>
        <td></td>
    </tr>
</table>






```python
# 1. 插入的字段和值一一完全精确匹配，包含允许为null的值
%sql INSERT INTO beauty(id,NAME,sex,borndate,phone,photo,boyfriend_id) \
VALUES(13,'罗宾','女','1990-4-23','1898888888',NULL,2);
```

     * mysql+pymysql://root@localhost/girls
       mysql+pymysql://root@localhost/myemployees
    1 rows affected.





    []




```python
# 2. 允许为null的列可以不插入值
%sql INSERT INTO beauty(id,NAME,sex,phone) \
VALUES(15,'娜美','女','1388888888');
```

     * mysql+pymysql://root@localhost/girls
       mysql+pymysql://root@localhost/myemployees
    1 rows affected.





    []




```python
# 3. 可以省略列名，默认所有列，而且列的顺序和表中列的顺序一致
%sql INSERT INTO beauty \
VALUES(18,'张飞','男',NULL,'119',NULL,NULL);
```

     * mysql+pymysql://root@localhost/girls
       mysql+pymysql://root@localhost/myemployees
    1 rows affected.





    []




```python
%sql INSERT INTO beauty \
SET id=19,NAME='女帝',phone='999';
```

     * mysql+pymysql://root@localhost/girls
       mysql+pymysql://root@localhost/myemployees
    1 rows affected.





    []



## 修改语句

1. 修改单表的记录

  语法：
    ```
    update 表名
    set 列=新值,列=新值,...
    where 筛选条件;
    ```
    
   表名->where筛选条件->set值
   

2. 修改多表的记录

  语法：
  
    ```
    sql92语法：
    update 表1 别名,表2 别名
    set 列=值,...
    where 连接条件
    and 筛选条件;

    sql99语法：
    update 表1 别名
    inner|left|right join 表2 别名
    on 连接条件
    set 列=值,...
    where 筛选条件;
    ```
    



```python
# 1. 单表的更新
%sql UPDATE boys SET boyname='张飞',usercp=10 \
WHERE id=2;
```

     * mysql+pymysql://root@localhost/girls
       mysql+pymysql://root@localhost/myemployees
    1 rows affected.





    []




```python
# 2. 多表的更新
# 修改没有男朋友的女神的男朋友编号都为2号
%sql update beauty be left join boys bo on bo.id=be.boyfriend_id set be.boyfriend_id=2 where be.boyfriend_id is null;

```

     * mysql+pymysql://root@localhost/girls
       mysql+pymysql://root@localhost/myemployees
    3 rows affected.





    []



# 删除

方式一：delete
语法：
    ```
    1、单表的删除
    delete from 表名 where 筛选条件

    2、多表的删除【补充】

    sql92语法：
    delete 表1的别名,表2的别名
    from 表1 别名,表2 别名
    where 连接条件
    and 筛选条件;

    sql99语法：

    delete 表1的别名, [表2的别名]
    from 表1 别名
    inner|left|right join 表2 别名 on 连接条件
    where 筛选条件;
    ```


方式二：truncate
语法：truncate table 表名;

## delete


```python
# 1. 单表删除 删除手机号以9结尾的女神信息
%sql delete from beauty where beauty.phone like "%9";
```

     * mysql+pymysql://root@localhost/girls
       mysql+pymysql://root@localhost/myemployees
    5 rows affected.





    []




```python
# 2. 多表的删除 删除白展堂的女朋友的信息
%sql delete be  from beauty be \
inner join boys bo \
on be.boyfriend_id=bo.id \
where bo.boyName="白展堂";
```

     * mysql+pymysql://root@localhost/girls
       mysql+pymysql://root@localhost/myemployees
    3 rows affected.





    []




```python
# 删除吕秀才的信息以及他女朋友的信息
%sql DELETE be,bo \
FROM beauty be \
INNER JOIN boys bo ON be.boyfriend_id=bo.id \
WHERE bo.boyName='吕秀才';
```

     * mysql+pymysql://root@localhost/girls
       mysql+pymysql://root@localhost/myemployees
    2 rows affected.





    []



## truncate

truncate主要用于快速清空表

delete pk truncate：
1. delete可以加where 条件，truncate不能加
2. truncate删除，效率高一丢丢
3. 假如要删除的表中有自增长列，如果用delete删除后，再插入数据，自增长列的值从断点开始，而truncate删除后，再插入数据，自增长列的值从1开始。
4. truncate删除没有返回值，delete删除有返回值
5. truncate删除不能回滚，delete删除可以回滚.


```python

```
