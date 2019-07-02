
# jupyter使用sql语句

在jupyter上使用R语言,同样可以使用SQL语句,详细见github项目：https://github.com/catherinedevlin/ipython-sql.

## 安装ipython-sql
pip install ipython-sql

## 载入
%load_ext sql

## 连接数据库 、
* postgresql://will:longliveliz@localhost/shakes
* mysql+pymysql://scott:tiger@localhost/foo
* oracle://scott:tiger@127.0.0.1:1521/sidname
* sqlite:///foo.db

我是使用的是mysql,本地链接, 用户名root，密码为空，myemployees数据库：%sql mysql+pymysql://root@localhost/myemployees









```python
%load_ext sql
%sql mysql+pymysql://root@localhost/myemployees
```




    'Connected: root@myemployees'



# 查看版本

1. 查看mysql版本
2. 查看当前使用的db

sql语句中的注释：单行使用#, 多行使用/*  */.



```python
%sql select version();
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>version()</th>
    </tr>
    <tr>
        <td>8.0.15</td>
    </tr>
</table>




```python
%sql select DATABASE();
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>DATABASE()</th>
    </tr>
    <tr>
        <td>myemployees</td>
    </tr>
</table>



# 基础查询

语法：
select 查询列表 from 表名;


类似于：System.out.println(打印东西);

特点：

1. 查询列表可以是：表中的字段、常量值、表达式、函数
2. 查询的结果是一个虚拟的表格




```python
# 查询表中的单个字段
%sql SELECT last_name FROM employees;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    107 rows affected.





<table>
    <tr>
        <th>last_name</th>
    </tr>
    <tr>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>Kochhar</td>
    </tr>
    <tr>
        <td>De Haan</td>
    </tr>
    <tr>
        <td>Hunold</td>
    </tr>
    <tr>
        <td>Ernst</td>
    </tr>
    <tr>
        <td>Austin</td>
    </tr>
    <tr>
        <td>Pataballa</td>
    </tr>
    <tr>
        <td>Lorentz</td>
    </tr>
    <tr>
        <td>Greenberg</td>
    </tr>
    <tr>
        <td>Faviet</td>
    </tr>
    <tr>
        <td>Chen</td>
    </tr>
    <tr>
        <td>Sciarra</td>
    </tr>
    <tr>
        <td>Urman</td>
    </tr>
    <tr>
        <td>Popp</td>
    </tr>
    <tr>
        <td>Raphaely</td>
    </tr>
    <tr>
        <td>Khoo</td>
    </tr>
    <tr>
        <td>Baida</td>
    </tr>
    <tr>
        <td>Tobias</td>
    </tr>
    <tr>
        <td>Himuro</td>
    </tr>
    <tr>
        <td>Colmenares</td>
    </tr>
    <tr>
        <td>Weiss</td>
    </tr>
    <tr>
        <td>Fripp</td>
    </tr>
    <tr>
        <td>Kaufling</td>
    </tr>
    <tr>
        <td>Vollman</td>
    </tr>
    <tr>
        <td>Mourgos</td>
    </tr>
    <tr>
        <td>Nayer</td>
    </tr>
    <tr>
        <td>Mikkilineni</td>
    </tr>
    <tr>
        <td>Landry</td>
    </tr>
    <tr>
        <td>Markle</td>
    </tr>
    <tr>
        <td>Bissot</td>
    </tr>
    <tr>
        <td>Atkinson</td>
    </tr>
    <tr>
        <td>Marlow</td>
    </tr>
    <tr>
        <td>Olson</td>
    </tr>
    <tr>
        <td>Mallin</td>
    </tr>
    <tr>
        <td>Rogers</td>
    </tr>
    <tr>
        <td>Gee</td>
    </tr>
    <tr>
        <td>Philtanker</td>
    </tr>
    <tr>
        <td>Ladwig</td>
    </tr>
    <tr>
        <td>Stiles</td>
    </tr>
    <tr>
        <td>Seo</td>
    </tr>
    <tr>
        <td>Patel</td>
    </tr>
    <tr>
        <td>Rajs</td>
    </tr>
    <tr>
        <td>Davies</td>
    </tr>
    <tr>
        <td>Matos</td>
    </tr>
    <tr>
        <td>Vargas</td>
    </tr>
    <tr>
        <td>Russell</td>
    </tr>
    <tr>
        <td>Partners</td>
    </tr>
    <tr>
        <td>Errazuriz</td>
    </tr>
    <tr>
        <td>Cambrault</td>
    </tr>
    <tr>
        <td>Zlotkey</td>
    </tr>
    <tr>
        <td>Tucker</td>
    </tr>
    <tr>
        <td>Bernstein</td>
    </tr>
    <tr>
        <td>Hall</td>
    </tr>
    <tr>
        <td>Olsen</td>
    </tr>
    <tr>
        <td>Cambrault</td>
    </tr>
    <tr>
        <td>Tuvault</td>
    </tr>
    <tr>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>Sully</td>
    </tr>
    <tr>
        <td>McEwen</td>
    </tr>
    <tr>
        <td>Smith</td>
    </tr>
    <tr>
        <td>Doran</td>
    </tr>
    <tr>
        <td>Sewall</td>
    </tr>
    <tr>
        <td>Vishney</td>
    </tr>
    <tr>
        <td>Greene</td>
    </tr>
    <tr>
        <td>Marvins</td>
    </tr>
    <tr>
        <td>Lee</td>
    </tr>
    <tr>
        <td>Ande</td>
    </tr>
    <tr>
        <td>Banda</td>
    </tr>
    <tr>
        <td>Ozer</td>
    </tr>
    <tr>
        <td>Bloom</td>
    </tr>
    <tr>
        <td>Fox</td>
    </tr>
    <tr>
        <td>Smith</td>
    </tr>
    <tr>
        <td>Bates</td>
    </tr>
    <tr>
        <td>Kumar</td>
    </tr>
    <tr>
        <td>Abel</td>
    </tr>
    <tr>
        <td>Hutton</td>
    </tr>
    <tr>
        <td>Taylor</td>
    </tr>
    <tr>
        <td>Livingston</td>
    </tr>
    <tr>
        <td>Grant</td>
    </tr>
    <tr>
        <td>Johnson</td>
    </tr>
    <tr>
        <td>Taylor</td>
    </tr>
    <tr>
        <td>Fleaur</td>
    </tr>
    <tr>
        <td>Sullivan</td>
    </tr>
    <tr>
        <td>Geoni</td>
    </tr>
    <tr>
        <td>Sarchand</td>
    </tr>
    <tr>
        <td>Bull</td>
    </tr>
    <tr>
        <td>Dellinger</td>
    </tr>
    <tr>
        <td>Cabrio</td>
    </tr>
    <tr>
        <td>Chung</td>
    </tr>
    <tr>
        <td>Dilly</td>
    </tr>
    <tr>
        <td>Gates</td>
    </tr>
    <tr>
        <td>Perkins</td>
    </tr>
    <tr>
        <td>Bell</td>
    </tr>
    <tr>
        <td>Everett</td>
    </tr>
    <tr>
        <td>McCain</td>
    </tr>
    <tr>
        <td>Jones</td>
    </tr>
    <tr>
        <td>Walsh</td>
    </tr>
    <tr>
        <td>Feeney</td>
    </tr>
    <tr>
        <td>OConnell</td>
    </tr>
    <tr>
        <td>Grant</td>
    </tr>
    <tr>
        <td>Whalen</td>
    </tr>
    <tr>
        <td>Hartstein</td>
    </tr>
    <tr>
        <td>Fay</td>
    </tr>
    <tr>
        <td>Mavris</td>
    </tr>
    <tr>
        <td>Baer</td>
    </tr>
    <tr>
        <td>Higgins</td>
    </tr>
    <tr>
        <td>Gietz</td>
    </tr>
</table>




```python
# 查询表中的多个字段
%sql SELECT last_name,salary,email FROM employees;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    107 rows affected.





<table>
    <tr>
        <th>last_name</th>
        <th>salary</th>
        <th>email</th>
    </tr>
    <tr>
        <td>K_ing</td>
        <td>24000.0</td>
        <td>SKING</td>
    </tr>
    <tr>
        <td>Kochhar</td>
        <td>17000.0</td>
        <td>NKOCHHAR</td>
    </tr>
    <tr>
        <td>De Haan</td>
        <td>17000.0</td>
        <td>LDEHAAN</td>
    </tr>
    <tr>
        <td>Hunold</td>
        <td>9000.0</td>
        <td>AHUNOLD</td>
    </tr>
    <tr>
        <td>Ernst</td>
        <td>6000.0</td>
        <td>BERNST</td>
    </tr>
    <tr>
        <td>Austin</td>
        <td>4800.0</td>
        <td>DAUSTIN</td>
    </tr>
    <tr>
        <td>Pataballa</td>
        <td>4800.0</td>
        <td>VPATABAL</td>
    </tr>
    <tr>
        <td>Lorentz</td>
        <td>4200.0</td>
        <td>DLORENTZ</td>
    </tr>
    <tr>
        <td>Greenberg</td>
        <td>12000.0</td>
        <td>NGREENBE</td>
    </tr>
    <tr>
        <td>Faviet</td>
        <td>9000.0</td>
        <td>DFAVIET</td>
    </tr>
    <tr>
        <td>Chen</td>
        <td>8200.0</td>
        <td>JCHEN</td>
    </tr>
    <tr>
        <td>Sciarra</td>
        <td>7700.0</td>
        <td>ISCIARRA</td>
    </tr>
    <tr>
        <td>Urman</td>
        <td>7800.0</td>
        <td>JMURMAN</td>
    </tr>
    <tr>
        <td>Popp</td>
        <td>6900.0</td>
        <td>LPOPP</td>
    </tr>
    <tr>
        <td>Raphaely</td>
        <td>11000.0</td>
        <td>DRAPHEAL</td>
    </tr>
    <tr>
        <td>Khoo</td>
        <td>3100.0</td>
        <td>AKHOO</td>
    </tr>
    <tr>
        <td>Baida</td>
        <td>2900.0</td>
        <td>SBAIDA</td>
    </tr>
    <tr>
        <td>Tobias</td>
        <td>2800.0</td>
        <td>STOBIAS</td>
    </tr>
    <tr>
        <td>Himuro</td>
        <td>2600.0</td>
        <td>GHIMURO</td>
    </tr>
    <tr>
        <td>Colmenares</td>
        <td>2500.0</td>
        <td>KCOLMENA</td>
    </tr>
    <tr>
        <td>Weiss</td>
        <td>8000.0</td>
        <td>MWEISS</td>
    </tr>
    <tr>
        <td>Fripp</td>
        <td>8200.0</td>
        <td>AFRIPP</td>
    </tr>
    <tr>
        <td>Kaufling</td>
        <td>7900.0</td>
        <td>PKAUFLIN</td>
    </tr>
    <tr>
        <td>Vollman</td>
        <td>6500.0</td>
        <td>SVOLLMAN</td>
    </tr>
    <tr>
        <td>Mourgos</td>
        <td>5800.0</td>
        <td>KMOURGOS</td>
    </tr>
    <tr>
        <td>Nayer</td>
        <td>3200.0</td>
        <td>JNAYER</td>
    </tr>
    <tr>
        <td>Mikkilineni</td>
        <td>2700.0</td>
        <td>IMIKKILI</td>
    </tr>
    <tr>
        <td>Landry</td>
        <td>2400.0</td>
        <td>JLANDRY</td>
    </tr>
    <tr>
        <td>Markle</td>
        <td>2200.0</td>
        <td>SMARKLE</td>
    </tr>
    <tr>
        <td>Bissot</td>
        <td>3300.0</td>
        <td>LBISSOT</td>
    </tr>
    <tr>
        <td>Atkinson</td>
        <td>2800.0</td>
        <td>MATKINSO</td>
    </tr>
    <tr>
        <td>Marlow</td>
        <td>2500.0</td>
        <td>JAMRLOW</td>
    </tr>
    <tr>
        <td>Olson</td>
        <td>2100.0</td>
        <td>TJOLSON</td>
    </tr>
    <tr>
        <td>Mallin</td>
        <td>3300.0</td>
        <td>JMALLIN</td>
    </tr>
    <tr>
        <td>Rogers</td>
        <td>2900.0</td>
        <td>MROGERS</td>
    </tr>
    <tr>
        <td>Gee</td>
        <td>2400.0</td>
        <td>KGEE</td>
    </tr>
    <tr>
        <td>Philtanker</td>
        <td>2200.0</td>
        <td>HPHILTAN</td>
    </tr>
    <tr>
        <td>Ladwig</td>
        <td>3600.0</td>
        <td>RLADWIG</td>
    </tr>
    <tr>
        <td>Stiles</td>
        <td>3200.0</td>
        <td>SSTILES</td>
    </tr>
    <tr>
        <td>Seo</td>
        <td>2700.0</td>
        <td>JSEO</td>
    </tr>
    <tr>
        <td>Patel</td>
        <td>2500.0</td>
        <td>JPATEL</td>
    </tr>
    <tr>
        <td>Rajs</td>
        <td>3500.0</td>
        <td>TRAJS</td>
    </tr>
    <tr>
        <td>Davies</td>
        <td>3100.0</td>
        <td>CDAVIES</td>
    </tr>
    <tr>
        <td>Matos</td>
        <td>2600.0</td>
        <td>RMATOS</td>
    </tr>
    <tr>
        <td>Vargas</td>
        <td>2500.0</td>
        <td>PVARGAS</td>
    </tr>
    <tr>
        <td>Russell</td>
        <td>14000.0</td>
        <td>JRUSSEL</td>
    </tr>
    <tr>
        <td>Partners</td>
        <td>13500.0</td>
        <td>KPARTNER</td>
    </tr>
    <tr>
        <td>Errazuriz</td>
        <td>12000.0</td>
        <td>AERRAZUR</td>
    </tr>
    <tr>
        <td>Cambrault</td>
        <td>11000.0</td>
        <td>GCAMBRAU</td>
    </tr>
    <tr>
        <td>Zlotkey</td>
        <td>10500.0</td>
        <td>EZLOTKEY</td>
    </tr>
    <tr>
        <td>Tucker</td>
        <td>10000.0</td>
        <td>PTUCKER</td>
    </tr>
    <tr>
        <td>Bernstein</td>
        <td>9500.0</td>
        <td>DBERNSTE</td>
    </tr>
    <tr>
        <td>Hall</td>
        <td>9000.0</td>
        <td>PHALL</td>
    </tr>
    <tr>
        <td>Olsen</td>
        <td>8000.0</td>
        <td>COLSEN</td>
    </tr>
    <tr>
        <td>Cambrault</td>
        <td>7500.0</td>
        <td>NCAMBRAU</td>
    </tr>
    <tr>
        <td>Tuvault</td>
        <td>7000.0</td>
        <td>OTUVAULT</td>
    </tr>
    <tr>
        <td>K_ing</td>
        <td>10000.0</td>
        <td>JKING</td>
    </tr>
    <tr>
        <td>Sully</td>
        <td>9500.0</td>
        <td>PSULLY</td>
    </tr>
    <tr>
        <td>McEwen</td>
        <td>9000.0</td>
        <td>AMCEWEN</td>
    </tr>
    <tr>
        <td>Smith</td>
        <td>8000.0</td>
        <td>LSMITH</td>
    </tr>
    <tr>
        <td>Doran</td>
        <td>7500.0</td>
        <td>LDORAN</td>
    </tr>
    <tr>
        <td>Sewall</td>
        <td>7000.0</td>
        <td>SSEWALL</td>
    </tr>
    <tr>
        <td>Vishney</td>
        <td>10500.0</td>
        <td>CVISHNEY</td>
    </tr>
    <tr>
        <td>Greene</td>
        <td>9500.0</td>
        <td>DGREENE</td>
    </tr>
    <tr>
        <td>Marvins</td>
        <td>7200.0</td>
        <td>MMARVINS</td>
    </tr>
    <tr>
        <td>Lee</td>
        <td>6800.0</td>
        <td>DLEE</td>
    </tr>
    <tr>
        <td>Ande</td>
        <td>6400.0</td>
        <td>SANDE</td>
    </tr>
    <tr>
        <td>Banda</td>
        <td>6200.0</td>
        <td>ABANDA</td>
    </tr>
    <tr>
        <td>Ozer</td>
        <td>11500.0</td>
        <td>LOZER</td>
    </tr>
    <tr>
        <td>Bloom</td>
        <td>10000.0</td>
        <td>HBLOOM</td>
    </tr>
    <tr>
        <td>Fox</td>
        <td>9600.0</td>
        <td>TFOX</td>
    </tr>
    <tr>
        <td>Smith</td>
        <td>7400.0</td>
        <td>WSMITH</td>
    </tr>
    <tr>
        <td>Bates</td>
        <td>7300.0</td>
        <td>EBATES</td>
    </tr>
    <tr>
        <td>Kumar</td>
        <td>6100.0</td>
        <td>SKUMAR</td>
    </tr>
    <tr>
        <td>Abel</td>
        <td>11000.0</td>
        <td>EABEL</td>
    </tr>
    <tr>
        <td>Hutton</td>
        <td>8800.0</td>
        <td>AHUTTON</td>
    </tr>
    <tr>
        <td>Taylor</td>
        <td>8600.0</td>
        <td>JTAYLOR</td>
    </tr>
    <tr>
        <td>Livingston</td>
        <td>8400.0</td>
        <td>JLIVINGS</td>
    </tr>
    <tr>
        <td>Grant</td>
        <td>7000.0</td>
        <td>KGRANT</td>
    </tr>
    <tr>
        <td>Johnson</td>
        <td>6200.0</td>
        <td>CJOHNSON</td>
    </tr>
    <tr>
        <td>Taylor</td>
        <td>3200.0</td>
        <td>WTAYLOR</td>
    </tr>
    <tr>
        <td>Fleaur</td>
        <td>3100.0</td>
        <td>JFLEAUR</td>
    </tr>
    <tr>
        <td>Sullivan</td>
        <td>2500.0</td>
        <td>MSULLIVA</td>
    </tr>
    <tr>
        <td>Geoni</td>
        <td>2800.0</td>
        <td>GGEONI</td>
    </tr>
    <tr>
        <td>Sarchand</td>
        <td>4200.0</td>
        <td>NSARCHAN</td>
    </tr>
    <tr>
        <td>Bull</td>
        <td>4100.0</td>
        <td>ABULL</td>
    </tr>
    <tr>
        <td>Dellinger</td>
        <td>3400.0</td>
        <td>JDELLING</td>
    </tr>
    <tr>
        <td>Cabrio</td>
        <td>3000.0</td>
        <td>ACABRIO</td>
    </tr>
    <tr>
        <td>Chung</td>
        <td>3800.0</td>
        <td>KCHUNG</td>
    </tr>
    <tr>
        <td>Dilly</td>
        <td>3600.0</td>
        <td>JDILLY</td>
    </tr>
    <tr>
        <td>Gates</td>
        <td>2900.0</td>
        <td>TGATES</td>
    </tr>
    <tr>
        <td>Perkins</td>
        <td>2500.0</td>
        <td>RPERKINS</td>
    </tr>
    <tr>
        <td>Bell</td>
        <td>4000.0</td>
        <td>SBELL</td>
    </tr>
    <tr>
        <td>Everett</td>
        <td>3900.0</td>
        <td>BEVERETT</td>
    </tr>
    <tr>
        <td>McCain</td>
        <td>3200.0</td>
        <td>SMCCAIN</td>
    </tr>
    <tr>
        <td>Jones</td>
        <td>2800.0</td>
        <td>VJONES</td>
    </tr>
    <tr>
        <td>Walsh</td>
        <td>3100.0</td>
        <td>AWALSH</td>
    </tr>
    <tr>
        <td>Feeney</td>
        <td>3000.0</td>
        <td>KFEENEY</td>
    </tr>
    <tr>
        <td>OConnell</td>
        <td>2600.0</td>
        <td>DOCONNEL</td>
    </tr>
    <tr>
        <td>Grant</td>
        <td>2600.0</td>
        <td>DGRANT</td>
    </tr>
    <tr>
        <td>Whalen</td>
        <td>4400.0</td>
        <td>JWHALEN</td>
    </tr>
    <tr>
        <td>Hartstein</td>
        <td>13000.0</td>
        <td>MHARTSTE</td>
    </tr>
    <tr>
        <td>Fay</td>
        <td>6000.0</td>
        <td>PFAY</td>
    </tr>
    <tr>
        <td>Mavris</td>
        <td>6500.0</td>
        <td>SMAVRIS</td>
    </tr>
    <tr>
        <td>Baer</td>
        <td>10000.0</td>
        <td>HBAER</td>
    </tr>
    <tr>
        <td>Higgins</td>
        <td>12000.0</td>
        <td>SHIGGINS</td>
    </tr>
    <tr>
        <td>Gietz</td>
        <td>8300.0</td>
        <td>WGIETZ</td>
    </tr>
</table>




```python
# 查询常量值
%sql select 100 from locations;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    23 rows affected.





<table>
    <tr>
        <th>100</th>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
    <tr>
        <td>100</td>
    </tr>
</table>




```python
# 查询表达式
%sql select salary/10,salary from employees;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    107 rows affected.





<table>
    <tr>
        <th>salary/10</th>
        <th>salary</th>
    </tr>
    <tr>
        <td>2400.0</td>
        <td>24000.0</td>
    </tr>
    <tr>
        <td>1700.0</td>
        <td>17000.0</td>
    </tr>
    <tr>
        <td>1700.0</td>
        <td>17000.0</td>
    </tr>
    <tr>
        <td>900.0</td>
        <td>9000.0</td>
    </tr>
    <tr>
        <td>600.0</td>
        <td>6000.0</td>
    </tr>
    <tr>
        <td>480.0</td>
        <td>4800.0</td>
    </tr>
    <tr>
        <td>480.0</td>
        <td>4800.0</td>
    </tr>
    <tr>
        <td>420.0</td>
        <td>4200.0</td>
    </tr>
    <tr>
        <td>1200.0</td>
        <td>12000.0</td>
    </tr>
    <tr>
        <td>900.0</td>
        <td>9000.0</td>
    </tr>
    <tr>
        <td>820.0</td>
        <td>8200.0</td>
    </tr>
    <tr>
        <td>770.0</td>
        <td>7700.0</td>
    </tr>
    <tr>
        <td>780.0</td>
        <td>7800.0</td>
    </tr>
    <tr>
        <td>690.0</td>
        <td>6900.0</td>
    </tr>
    <tr>
        <td>1100.0</td>
        <td>11000.0</td>
    </tr>
    <tr>
        <td>310.0</td>
        <td>3100.0</td>
    </tr>
    <tr>
        <td>290.0</td>
        <td>2900.0</td>
    </tr>
    <tr>
        <td>280.0</td>
        <td>2800.0</td>
    </tr>
    <tr>
        <td>260.0</td>
        <td>2600.0</td>
    </tr>
    <tr>
        <td>250.0</td>
        <td>2500.0</td>
    </tr>
    <tr>
        <td>800.0</td>
        <td>8000.0</td>
    </tr>
    <tr>
        <td>820.0</td>
        <td>8200.0</td>
    </tr>
    <tr>
        <td>790.0</td>
        <td>7900.0</td>
    </tr>
    <tr>
        <td>650.0</td>
        <td>6500.0</td>
    </tr>
    <tr>
        <td>580.0</td>
        <td>5800.0</td>
    </tr>
    <tr>
        <td>320.0</td>
        <td>3200.0</td>
    </tr>
    <tr>
        <td>270.0</td>
        <td>2700.0</td>
    </tr>
    <tr>
        <td>240.0</td>
        <td>2400.0</td>
    </tr>
    <tr>
        <td>220.0</td>
        <td>2200.0</td>
    </tr>
    <tr>
        <td>330.0</td>
        <td>3300.0</td>
    </tr>
    <tr>
        <td>280.0</td>
        <td>2800.0</td>
    </tr>
    <tr>
        <td>250.0</td>
        <td>2500.0</td>
    </tr>
    <tr>
        <td>210.0</td>
        <td>2100.0</td>
    </tr>
    <tr>
        <td>330.0</td>
        <td>3300.0</td>
    </tr>
    <tr>
        <td>290.0</td>
        <td>2900.0</td>
    </tr>
    <tr>
        <td>240.0</td>
        <td>2400.0</td>
    </tr>
    <tr>
        <td>220.0</td>
        <td>2200.0</td>
    </tr>
    <tr>
        <td>360.0</td>
        <td>3600.0</td>
    </tr>
    <tr>
        <td>320.0</td>
        <td>3200.0</td>
    </tr>
    <tr>
        <td>270.0</td>
        <td>2700.0</td>
    </tr>
    <tr>
        <td>250.0</td>
        <td>2500.0</td>
    </tr>
    <tr>
        <td>350.0</td>
        <td>3500.0</td>
    </tr>
    <tr>
        <td>310.0</td>
        <td>3100.0</td>
    </tr>
    <tr>
        <td>260.0</td>
        <td>2600.0</td>
    </tr>
    <tr>
        <td>250.0</td>
        <td>2500.0</td>
    </tr>
    <tr>
        <td>1400.0</td>
        <td>14000.0</td>
    </tr>
    <tr>
        <td>1350.0</td>
        <td>13500.0</td>
    </tr>
    <tr>
        <td>1200.0</td>
        <td>12000.0</td>
    </tr>
    <tr>
        <td>1100.0</td>
        <td>11000.0</td>
    </tr>
    <tr>
        <td>1050.0</td>
        <td>10500.0</td>
    </tr>
    <tr>
        <td>1000.0</td>
        <td>10000.0</td>
    </tr>
    <tr>
        <td>950.0</td>
        <td>9500.0</td>
    </tr>
    <tr>
        <td>900.0</td>
        <td>9000.0</td>
    </tr>
    <tr>
        <td>800.0</td>
        <td>8000.0</td>
    </tr>
    <tr>
        <td>750.0</td>
        <td>7500.0</td>
    </tr>
    <tr>
        <td>700.0</td>
        <td>7000.0</td>
    </tr>
    <tr>
        <td>1000.0</td>
        <td>10000.0</td>
    </tr>
    <tr>
        <td>950.0</td>
        <td>9500.0</td>
    </tr>
    <tr>
        <td>900.0</td>
        <td>9000.0</td>
    </tr>
    <tr>
        <td>800.0</td>
        <td>8000.0</td>
    </tr>
    <tr>
        <td>750.0</td>
        <td>7500.0</td>
    </tr>
    <tr>
        <td>700.0</td>
        <td>7000.0</td>
    </tr>
    <tr>
        <td>1050.0</td>
        <td>10500.0</td>
    </tr>
    <tr>
        <td>950.0</td>
        <td>9500.0</td>
    </tr>
    <tr>
        <td>720.0</td>
        <td>7200.0</td>
    </tr>
    <tr>
        <td>680.0</td>
        <td>6800.0</td>
    </tr>
    <tr>
        <td>640.0</td>
        <td>6400.0</td>
    </tr>
    <tr>
        <td>620.0</td>
        <td>6200.0</td>
    </tr>
    <tr>
        <td>1150.0</td>
        <td>11500.0</td>
    </tr>
    <tr>
        <td>1000.0</td>
        <td>10000.0</td>
    </tr>
    <tr>
        <td>960.0</td>
        <td>9600.0</td>
    </tr>
    <tr>
        <td>740.0</td>
        <td>7400.0</td>
    </tr>
    <tr>
        <td>730.0</td>
        <td>7300.0</td>
    </tr>
    <tr>
        <td>610.0</td>
        <td>6100.0</td>
    </tr>
    <tr>
        <td>1100.0</td>
        <td>11000.0</td>
    </tr>
    <tr>
        <td>880.0</td>
        <td>8800.0</td>
    </tr>
    <tr>
        <td>860.0</td>
        <td>8600.0</td>
    </tr>
    <tr>
        <td>840.0</td>
        <td>8400.0</td>
    </tr>
    <tr>
        <td>700.0</td>
        <td>7000.0</td>
    </tr>
    <tr>
        <td>620.0</td>
        <td>6200.0</td>
    </tr>
    <tr>
        <td>320.0</td>
        <td>3200.0</td>
    </tr>
    <tr>
        <td>310.0</td>
        <td>3100.0</td>
    </tr>
    <tr>
        <td>250.0</td>
        <td>2500.0</td>
    </tr>
    <tr>
        <td>280.0</td>
        <td>2800.0</td>
    </tr>
    <tr>
        <td>420.0</td>
        <td>4200.0</td>
    </tr>
    <tr>
        <td>410.0</td>
        <td>4100.0</td>
    </tr>
    <tr>
        <td>340.0</td>
        <td>3400.0</td>
    </tr>
    <tr>
        <td>300.0</td>
        <td>3000.0</td>
    </tr>
    <tr>
        <td>380.0</td>
        <td>3800.0</td>
    </tr>
    <tr>
        <td>360.0</td>
        <td>3600.0</td>
    </tr>
    <tr>
        <td>290.0</td>
        <td>2900.0</td>
    </tr>
    <tr>
        <td>250.0</td>
        <td>2500.0</td>
    </tr>
    <tr>
        <td>400.0</td>
        <td>4000.0</td>
    </tr>
    <tr>
        <td>390.0</td>
        <td>3900.0</td>
    </tr>
    <tr>
        <td>320.0</td>
        <td>3200.0</td>
    </tr>
    <tr>
        <td>280.0</td>
        <td>2800.0</td>
    </tr>
    <tr>
        <td>310.0</td>
        <td>3100.0</td>
    </tr>
    <tr>
        <td>300.0</td>
        <td>3000.0</td>
    </tr>
    <tr>
        <td>260.0</td>
        <td>2600.0</td>
    </tr>
    <tr>
        <td>260.0</td>
        <td>2600.0</td>
    </tr>
    <tr>
        <td>440.0</td>
        <td>4400.0</td>
    </tr>
    <tr>
        <td>1300.0</td>
        <td>13000.0</td>
    </tr>
    <tr>
        <td>600.0</td>
        <td>6000.0</td>
    </tr>
    <tr>
        <td>650.0</td>
        <td>6500.0</td>
    </tr>
    <tr>
        <td>1000.0</td>
        <td>10000.0</td>
    </tr>
    <tr>
        <td>1200.0</td>
        <td>12000.0</td>
    </tr>
    <tr>
        <td>830.0</td>
        <td>8300.0</td>
    </tr>
</table>




```python
# 查询函数
%sql select now();
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>now()</th>
    </tr>
    <tr>
        <td>2019-06-26 10:37:06</td>
    </tr>
</table>



起别名:
1. 便于理解
2. 如果要查询的字段有重名的情况，使用别名可以区分开来

方式一：使用as

方式二：使用空格


```python
%sql SELECT 100%98 AS 结果;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>结果</th>
    </tr>
    <tr>
        <td>2</td>
    </tr>
</table>




```python
%sql SELECT 100%98 结果;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>结果</th>
    </tr>
    <tr>
        <td>2</td>
    </tr>
</table>



mysql中的+号：仅仅只有一个功能：运算符

* select 100+90; 两个操作数都为数值型，则做加法运算
* select '123'+90;  只要其中一方为字符型，试图将字符型数值转换成数值型，如果转换成功，则继续做加法运算
* select 'john'+90;	如果转换失败，则将字符型数值转换成0
* select null+10; 只要其中一方为null，则结果肯定为null

所以在mysql中要做到拼接字符串，需要借助函数，例如cancat.


```python
%sql SELECT CONCAT(last_name,"_",first_name) AS 姓名 FROM employees;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    107 rows affected.





<table>
    <tr>
        <th>姓名</th>
    </tr>
    <tr>
        <td>K_ing_Steven</td>
    </tr>
    <tr>
        <td>Kochhar_Neena</td>
    </tr>
    <tr>
        <td>De Haan_Lex</td>
    </tr>
    <tr>
        <td>Hunold_Alexander</td>
    </tr>
    <tr>
        <td>Ernst_Bruce</td>
    </tr>
    <tr>
        <td>Austin_David</td>
    </tr>
    <tr>
        <td>Pataballa_Valli</td>
    </tr>
    <tr>
        <td>Lorentz_Diana</td>
    </tr>
    <tr>
        <td>Greenberg_Nancy</td>
    </tr>
    <tr>
        <td>Faviet_Daniel</td>
    </tr>
    <tr>
        <td>Chen_John</td>
    </tr>
    <tr>
        <td>Sciarra_Ismael</td>
    </tr>
    <tr>
        <td>Urman_Jose Manuel</td>
    </tr>
    <tr>
        <td>Popp_Luis</td>
    </tr>
    <tr>
        <td>Raphaely_Den</td>
    </tr>
    <tr>
        <td>Khoo_Alexander</td>
    </tr>
    <tr>
        <td>Baida_Shelli</td>
    </tr>
    <tr>
        <td>Tobias_Sigal</td>
    </tr>
    <tr>
        <td>Himuro_Guy</td>
    </tr>
    <tr>
        <td>Colmenares_Karen</td>
    </tr>
    <tr>
        <td>Weiss_Matthew</td>
    </tr>
    <tr>
        <td>Fripp_Adam</td>
    </tr>
    <tr>
        <td>Kaufling_Payam</td>
    </tr>
    <tr>
        <td>Vollman_Shanta</td>
    </tr>
    <tr>
        <td>Mourgos_Kevin</td>
    </tr>
    <tr>
        <td>Nayer_Julia</td>
    </tr>
    <tr>
        <td>Mikkilineni_Irene</td>
    </tr>
    <tr>
        <td>Landry_James</td>
    </tr>
    <tr>
        <td>Markle_Steven</td>
    </tr>
    <tr>
        <td>Bissot_Laura</td>
    </tr>
    <tr>
        <td>Atkinson_Mozhe</td>
    </tr>
    <tr>
        <td>Marlow_James</td>
    </tr>
    <tr>
        <td>Olson_TJ</td>
    </tr>
    <tr>
        <td>Mallin_Jason</td>
    </tr>
    <tr>
        <td>Rogers_Michael</td>
    </tr>
    <tr>
        <td>Gee_Ki</td>
    </tr>
    <tr>
        <td>Philtanker_Hazel</td>
    </tr>
    <tr>
        <td>Ladwig_Renske</td>
    </tr>
    <tr>
        <td>Stiles_Stephen</td>
    </tr>
    <tr>
        <td>Seo_John</td>
    </tr>
    <tr>
        <td>Patel_Joshua</td>
    </tr>
    <tr>
        <td>Rajs_Trenna</td>
    </tr>
    <tr>
        <td>Davies_Curtis</td>
    </tr>
    <tr>
        <td>Matos_Randall</td>
    </tr>
    <tr>
        <td>Vargas_Peter</td>
    </tr>
    <tr>
        <td>Russell_John</td>
    </tr>
    <tr>
        <td>Partners_Karen</td>
    </tr>
    <tr>
        <td>Errazuriz_Alberto</td>
    </tr>
    <tr>
        <td>Cambrault_Gerald</td>
    </tr>
    <tr>
        <td>Zlotkey_Eleni</td>
    </tr>
    <tr>
        <td>Tucker_Peter</td>
    </tr>
    <tr>
        <td>Bernstein_David</td>
    </tr>
    <tr>
        <td>Hall_Peter</td>
    </tr>
    <tr>
        <td>Olsen_Christopher</td>
    </tr>
    <tr>
        <td>Cambrault_Nanette</td>
    </tr>
    <tr>
        <td>Tuvault_Oliver</td>
    </tr>
    <tr>
        <td>K_ing_Janette</td>
    </tr>
    <tr>
        <td>Sully_Patrick</td>
    </tr>
    <tr>
        <td>McEwen_Allan</td>
    </tr>
    <tr>
        <td>Smith_Lindsey</td>
    </tr>
    <tr>
        <td>Doran_Louise</td>
    </tr>
    <tr>
        <td>Sewall_Sarath</td>
    </tr>
    <tr>
        <td>Vishney_Clara</td>
    </tr>
    <tr>
        <td>Greene_Danielle</td>
    </tr>
    <tr>
        <td>Marvins_Mattea</td>
    </tr>
    <tr>
        <td>Lee_David</td>
    </tr>
    <tr>
        <td>Ande_Sundar</td>
    </tr>
    <tr>
        <td>Banda_Amit</td>
    </tr>
    <tr>
        <td>Ozer_Lisa</td>
    </tr>
    <tr>
        <td>Bloom_Harrison</td>
    </tr>
    <tr>
        <td>Fox_Tayler</td>
    </tr>
    <tr>
        <td>Smith_William</td>
    </tr>
    <tr>
        <td>Bates_Elizabeth</td>
    </tr>
    <tr>
        <td>Kumar_Sundita</td>
    </tr>
    <tr>
        <td>Abel_Ellen</td>
    </tr>
    <tr>
        <td>Hutton_Alyssa</td>
    </tr>
    <tr>
        <td>Taylor_Jonathon</td>
    </tr>
    <tr>
        <td>Livingston_Jack</td>
    </tr>
    <tr>
        <td>Grant_Kimberely</td>
    </tr>
    <tr>
        <td>Johnson_Charles</td>
    </tr>
    <tr>
        <td>Taylor_Winston</td>
    </tr>
    <tr>
        <td>Fleaur_Jean</td>
    </tr>
    <tr>
        <td>Sullivan_Martha</td>
    </tr>
    <tr>
        <td>Geoni_Girard</td>
    </tr>
    <tr>
        <td>Sarchand_Nandita</td>
    </tr>
    <tr>
        <td>Bull_Alexis</td>
    </tr>
    <tr>
        <td>Dellinger_Julia</td>
    </tr>
    <tr>
        <td>Cabrio_Anthony</td>
    </tr>
    <tr>
        <td>Chung_Kelly</td>
    </tr>
    <tr>
        <td>Dilly_Jennifer</td>
    </tr>
    <tr>
        <td>Gates_Timothy</td>
    </tr>
    <tr>
        <td>Perkins_Randall</td>
    </tr>
    <tr>
        <td>Bell_Sarah</td>
    </tr>
    <tr>
        <td>Everett_Britney</td>
    </tr>
    <tr>
        <td>McCain_Samuel</td>
    </tr>
    <tr>
        <td>Jones_Vance</td>
    </tr>
    <tr>
        <td>Walsh_Alana</td>
    </tr>
    <tr>
        <td>Feeney_Kevin</td>
    </tr>
    <tr>
        <td>OConnell_Donald</td>
    </tr>
    <tr>
        <td>Grant_Douglas</td>
    </tr>
    <tr>
        <td>Whalen_Jennifer</td>
    </tr>
    <tr>
        <td>Hartstein_Michael</td>
    </tr>
    <tr>
        <td>Fay_Pat</td>
    </tr>
    <tr>
        <td>Mavris_Susan</td>
    </tr>
    <tr>
        <td>Baer_Hermann</td>
    </tr>
    <tr>
        <td>Higgins_Shelley</td>
    </tr>
    <tr>
        <td>Gietz_William</td>
    </tr>
</table>



# 条件查询

语法：
	select 
		查询列表
	from
		表名
	where
		筛选条件;

分类：

	一、按条件表达式筛选
	
	简单条件运算符：> < = != <> >= <=
	
	二、按逻辑表达式筛选
	逻辑运算符：
	作用：用于连接条件表达式
		and or not
		
	and：两个条件都为true，结果为true，反之为false
	or： 只要有一个条件为true，结果为true，反之为false
	not： 如果连接的条件本身为false，结果为true，反之为false
	
	三、模糊查询
		like
		between and
		in
		is null
## 按条件表达式筛选


```python
# 查询工资>12000的员工信息
%sql select * from employees where salary>12000;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    6 rows affected.





<table>
    <tr>
        <th>employee_id</th>
        <th>first_name</th>
        <th>last_name</th>
        <th>email</th>
        <th>phone_number</th>
        <th>job_id</th>
        <th>salary</th>
        <th>commission_pct</th>
        <th>manager_id</th>
        <th>department_id</th>
        <th>hiredate</th>
    </tr>
    <tr>
        <td>100</td>
        <td>Steven</td>
        <td>K_ing</td>
        <td>SKING</td>
        <td>515.123.4567</td>
        <td>AD_PRES</td>
        <td>24000.0</td>
        <td>None</td>
        <td>None</td>
        <td>90</td>
        <td>1992-04-03 00:00:00</td>
    </tr>
    <tr>
        <td>101</td>
        <td>Neena</td>
        <td>Kochhar</td>
        <td>NKOCHHAR</td>
        <td>515.123.4568</td>
        <td>AD_VP</td>
        <td>17000.0</td>
        <td>None</td>
        <td>100</td>
        <td>90</td>
        <td>1992-04-03 00:00:00</td>
    </tr>
    <tr>
        <td>102</td>
        <td>Lex</td>
        <td>De Haan</td>
        <td>LDEHAAN</td>
        <td>515.123.4569</td>
        <td>AD_VP</td>
        <td>17000.0</td>
        <td>None</td>
        <td>100</td>
        <td>90</td>
        <td>1992-04-03 00:00:00</td>
    </tr>
    <tr>
        <td>145</td>
        <td>John</td>
        <td>Russell</td>
        <td>JRUSSEL</td>
        <td>011.44.1344.429268</td>
        <td>SA_MAN</td>
        <td>14000.0</td>
        <td>0.4</td>
        <td>100</td>
        <td>80</td>
        <td>2002-12-23 00:00:00</td>
    </tr>
    <tr>
        <td>146</td>
        <td>Karen</td>
        <td>Partners</td>
        <td>KPARTNER</td>
        <td>011.44.1344.467268</td>
        <td>SA_MAN</td>
        <td>13500.0</td>
        <td>0.3</td>
        <td>100</td>
        <td>80</td>
        <td>2002-12-23 00:00:00</td>
    </tr>
    <tr>
        <td>201</td>
        <td>Michael</td>
        <td>Hartstein</td>
        <td>MHARTSTE</td>
        <td>515.123.5555</td>
        <td>MK_MAN</td>
        <td>13000.0</td>
        <td>None</td>
        <td>100</td>
        <td>20</td>
        <td>2016-03-03 00:00:00</td>
    </tr>
</table>




```python
# 查询部门编号不等于90号的员工名和部门编号
%sql select last_name, department_id from employees where department_id != 90;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    103 rows affected.





<table>
    <tr>
        <th>last_name</th>
        <th>department_id</th>
    </tr>
    <tr>
        <td>Hunold</td>
        <td>60</td>
    </tr>
    <tr>
        <td>Ernst</td>
        <td>60</td>
    </tr>
    <tr>
        <td>Austin</td>
        <td>60</td>
    </tr>
    <tr>
        <td>Pataballa</td>
        <td>60</td>
    </tr>
    <tr>
        <td>Lorentz</td>
        <td>60</td>
    </tr>
    <tr>
        <td>Greenberg</td>
        <td>100</td>
    </tr>
    <tr>
        <td>Faviet</td>
        <td>100</td>
    </tr>
    <tr>
        <td>Chen</td>
        <td>100</td>
    </tr>
    <tr>
        <td>Sciarra</td>
        <td>100</td>
    </tr>
    <tr>
        <td>Urman</td>
        <td>100</td>
    </tr>
    <tr>
        <td>Popp</td>
        <td>100</td>
    </tr>
    <tr>
        <td>Raphaely</td>
        <td>30</td>
    </tr>
    <tr>
        <td>Khoo</td>
        <td>30</td>
    </tr>
    <tr>
        <td>Baida</td>
        <td>30</td>
    </tr>
    <tr>
        <td>Tobias</td>
        <td>30</td>
    </tr>
    <tr>
        <td>Himuro</td>
        <td>30</td>
    </tr>
    <tr>
        <td>Colmenares</td>
        <td>30</td>
    </tr>
    <tr>
        <td>Weiss</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Fripp</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Kaufling</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Vollman</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Mourgos</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Nayer</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Mikkilineni</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Landry</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Markle</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Bissot</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Atkinson</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Marlow</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Olson</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Mallin</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Rogers</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Gee</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Philtanker</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Ladwig</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Stiles</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Seo</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Patel</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Rajs</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Davies</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Matos</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Vargas</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Russell</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Partners</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Errazuriz</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Cambrault</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Zlotkey</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Tucker</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Bernstein</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Hall</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Olsen</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Cambrault</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Tuvault</td>
        <td>80</td>
    </tr>
    <tr>
        <td>K_ing</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Sully</td>
        <td>80</td>
    </tr>
    <tr>
        <td>McEwen</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Smith</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Doran</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Sewall</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Vishney</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Greene</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Marvins</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Lee</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Ande</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Banda</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Ozer</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Bloom</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Fox</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Smith</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Bates</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Kumar</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Abel</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Hutton</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Taylor</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Livingston</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Johnson</td>
        <td>80</td>
    </tr>
    <tr>
        <td>Taylor</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Fleaur</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Sullivan</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Geoni</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Sarchand</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Bull</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Dellinger</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Cabrio</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Chung</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Dilly</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Gates</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Perkins</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Bell</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Everett</td>
        <td>50</td>
    </tr>
    <tr>
        <td>McCain</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Jones</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Walsh</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Feeney</td>
        <td>50</td>
    </tr>
    <tr>
        <td>OConnell</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Grant</td>
        <td>50</td>
    </tr>
    <tr>
        <td>Whalen</td>
        <td>10</td>
    </tr>
    <tr>
        <td>Hartstein</td>
        <td>20</td>
    </tr>
    <tr>
        <td>Fay</td>
        <td>20</td>
    </tr>
    <tr>
        <td>Mavris</td>
        <td>40</td>
    </tr>
    <tr>
        <td>Baer</td>
        <td>70</td>
    </tr>
    <tr>
        <td>Higgins</td>
        <td>110</td>
    </tr>
    <tr>
        <td>Gietz</td>
        <td>110</td>
    </tr>
</table>



# 按逻辑表达式筛选

按逻辑表达式筛选意味着存在多个条件的查询


```python
# 查询工资在10000到20000之间的员工名、工资以及奖金
%sql select last_name, salary, commission_pct from employees where salary >= 10000 and salary <= 20000;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    18 rows affected.





<table>
    <tr>
        <th>last_name</th>
        <th>salary</th>
        <th>commission_pct</th>
    </tr>
    <tr>
        <td>Kochhar</td>
        <td>17000.0</td>
        <td>None</td>
    </tr>
    <tr>
        <td>De Haan</td>
        <td>17000.0</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Greenberg</td>
        <td>12000.0</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Raphaely</td>
        <td>11000.0</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Russell</td>
        <td>14000.0</td>
        <td>0.4</td>
    </tr>
    <tr>
        <td>Partners</td>
        <td>13500.0</td>
        <td>0.3</td>
    </tr>
    <tr>
        <td>Errazuriz</td>
        <td>12000.0</td>
        <td>0.3</td>
    </tr>
    <tr>
        <td>Cambrault</td>
        <td>11000.0</td>
        <td>0.3</td>
    </tr>
    <tr>
        <td>Zlotkey</td>
        <td>10500.0</td>
        <td>0.2</td>
    </tr>
    <tr>
        <td>Tucker</td>
        <td>10000.0</td>
        <td>0.3</td>
    </tr>
    <tr>
        <td>K_ing</td>
        <td>10000.0</td>
        <td>0.35</td>
    </tr>
    <tr>
        <td>Vishney</td>
        <td>10500.0</td>
        <td>0.25</td>
    </tr>
    <tr>
        <td>Ozer</td>
        <td>11500.0</td>
        <td>0.25</td>
    </tr>
    <tr>
        <td>Bloom</td>
        <td>10000.0</td>
        <td>0.2</td>
    </tr>
    <tr>
        <td>Abel</td>
        <td>11000.0</td>
        <td>0.3</td>
    </tr>
    <tr>
        <td>Hartstein</td>
        <td>13000.0</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Baer</td>
        <td>10000.0</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Higgins</td>
        <td>12000.0</td>
        <td>None</td>
    </tr>
</table>




```python
# 查询部门编号不是在90到110之间，或者工资高于15000的员工信息
%sql select last_name from employees where (department_id > 90 and department_id < 110) or (salary > 15000);
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    9 rows affected.





<table>
    <tr>
        <th>last_name</th>
    </tr>
    <tr>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>Kochhar</td>
    </tr>
    <tr>
        <td>De Haan</td>
    </tr>
    <tr>
        <td>Greenberg</td>
    </tr>
    <tr>
        <td>Faviet</td>
    </tr>
    <tr>
        <td>Chen</td>
    </tr>
    <tr>
        <td>Sciarra</td>
    </tr>
    <tr>
        <td>Urman</td>
    </tr>
    <tr>
        <td>Popp</td>
    </tr>
</table>



# 模糊查询

* like
* between and(包含临界值)
* in
* is null|is not null

like一般和通配符搭配使用

	通配符：
	% 任意多个字符,包含0个字符
	_ 任意单个字符

between and：

1. 使用between and 可以提高语句的简洁度
2. 包含临界值
2. 两个临界值不要调换顺序

in ：判断某字段的值是否属于in列表中的某一项

特点：
1. 使用in提高语句简洁度
2. in列表的值类型必须一致或兼容
3. in列表中不支持通配符(其实in就是= 和 or的 结合)

is null：

1. =或<>不能用于判断null值
2. is null或is not null 可以判断null值


```python
# 查询员工名中第三个字符为n，第五个字符为l的员工名和工资
%sql select last_name, salary from employees where last_name like "__n_l%";
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>last_name</th>
        <th>salary</th>
    </tr>
    <tr>
        <td>Hunold</td>
        <td>9000.0</td>
    </tr>
</table>




```python
# 查询员工名中第二个字符为_的员工名(使用转义)
%sql select last_name from employees where last_name like "_\_%";
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    2 rows affected.





<table>
    <tr>
        <th>last_name</th>
    </tr>
    <tr>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>K_ing</td>
    </tr>
</table>




```python
# 查询员工编号在100到120之间的员工信息
# select * from employees where department_id >= 100 and department_id <= 120;
%sql select * from employees where department_id between 100 and 120;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    8 rows affected.





<table>
    <tr>
        <th>employee_id</th>
        <th>first_name</th>
        <th>last_name</th>
        <th>email</th>
        <th>phone_number</th>
        <th>job_id</th>
        <th>salary</th>
        <th>commission_pct</th>
        <th>manager_id</th>
        <th>department_id</th>
        <th>hiredate</th>
    </tr>
    <tr>
        <td>108</td>
        <td>Nancy</td>
        <td>Greenberg</td>
        <td>NGREENBE</td>
        <td>515.124.4569</td>
        <td>FI_MGR</td>
        <td>12000.0</td>
        <td>None</td>
        <td>101</td>
        <td>100</td>
        <td>1998-03-03 00:00:00</td>
    </tr>
    <tr>
        <td>109</td>
        <td>Daniel</td>
        <td>Faviet</td>
        <td>DFAVIET</td>
        <td>515.124.4169</td>
        <td>FI_ACCOUNT</td>
        <td>9000.0</td>
        <td>None</td>
        <td>108</td>
        <td>100</td>
        <td>1998-03-03 00:00:00</td>
    </tr>
    <tr>
        <td>110</td>
        <td>John</td>
        <td>Chen</td>
        <td>JCHEN</td>
        <td>515.124.4269</td>
        <td>FI_ACCOUNT</td>
        <td>8200.0</td>
        <td>None</td>
        <td>108</td>
        <td>100</td>
        <td>2000-09-09 00:00:00</td>
    </tr>
    <tr>
        <td>111</td>
        <td>Ismael</td>
        <td>Sciarra</td>
        <td>ISCIARRA</td>
        <td>515.124.4369</td>
        <td>FI_ACCOUNT</td>
        <td>7700.0</td>
        <td>None</td>
        <td>108</td>
        <td>100</td>
        <td>2000-09-09 00:00:00</td>
    </tr>
    <tr>
        <td>112</td>
        <td>Jose Manuel</td>
        <td>Urman</td>
        <td>JMURMAN</td>
        <td>515.124.4469</td>
        <td>FI_ACCOUNT</td>
        <td>7800.0</td>
        <td>None</td>
        <td>108</td>
        <td>100</td>
        <td>2000-09-09 00:00:00</td>
    </tr>
    <tr>
        <td>113</td>
        <td>Luis</td>
        <td>Popp</td>
        <td>LPOPP</td>
        <td>515.124.4567</td>
        <td>FI_ACCOUNT</td>
        <td>6900.0</td>
        <td>None</td>
        <td>108</td>
        <td>100</td>
        <td>2000-09-09 00:00:00</td>
    </tr>
    <tr>
        <td>205</td>
        <td>Shelley</td>
        <td>Higgins</td>
        <td>SHIGGINS</td>
        <td>515.123.8080</td>
        <td>AC_MGR</td>
        <td>12000.0</td>
        <td>None</td>
        <td>101</td>
        <td>110</td>
        <td>2016-03-03 00:00:00</td>
    </tr>
    <tr>
        <td>206</td>
        <td>William</td>
        <td>Gietz</td>
        <td>WGIETZ</td>
        <td>515.123.8181</td>
        <td>AC_ACCOUNT</td>
        <td>8300.0</td>
        <td>None</td>
        <td>205</td>
        <td>110</td>
        <td>2016-03-03 00:00:00</td>
    </tr>
</table>




```python
# 查询员工的工种编号是 IT_PROG、AD_VP、AD_PRES中的一个员工名和工种编号
# SELECT last_name,job_id FROM employees WHERE job_id = 'IT_PROT' OR job_id = 'AD_VP' OR JOB_ID ='AD_PRES';
%sql SELECT last_name,job_id FROM employees WHERE job_id in ('IT_PROT','AD_VP','AD_PRES');
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    3 rows affected.





<table>
    <tr>
        <th>last_name</th>
        <th>job_id</th>
    </tr>
    <tr>
        <td>K_ing</td>
        <td>AD_PRES</td>
    </tr>
    <tr>
        <td>Kochhar</td>
        <td>AD_VP</td>
    </tr>
    <tr>
        <td>De Haan</td>
        <td>AD_VP</td>
    </tr>
</table>




```python
# 查询没有奖金的员工名和奖金率
%sql select last_name, commission_pct from employees where commission_pct is null;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    72 rows affected.





<table>
    <tr>
        <th>last_name</th>
        <th>commission_pct</th>
    </tr>
    <tr>
        <td>K_ing</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Kochhar</td>
        <td>None</td>
    </tr>
    <tr>
        <td>De Haan</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Hunold</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Ernst</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Austin</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Pataballa</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Lorentz</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Greenberg</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Faviet</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Chen</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Sciarra</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Urman</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Popp</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Raphaely</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Khoo</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Baida</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Tobias</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Himuro</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Colmenares</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Weiss</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Fripp</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Kaufling</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Vollman</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Mourgos</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Nayer</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Mikkilineni</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Landry</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Markle</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Bissot</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Atkinson</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Marlow</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Olson</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Mallin</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Rogers</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Gee</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Philtanker</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Ladwig</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Stiles</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Seo</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Patel</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Rajs</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Davies</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Matos</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Vargas</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Taylor</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Fleaur</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Sullivan</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Geoni</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Sarchand</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Bull</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Dellinger</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Cabrio</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Chung</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Dilly</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Gates</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Perkins</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Bell</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Everett</td>
        <td>None</td>
    </tr>
    <tr>
        <td>McCain</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Jones</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Walsh</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Feeney</td>
        <td>None</td>
    </tr>
    <tr>
        <td>OConnell</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Grant</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Whalen</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Hartstein</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Fay</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Mavris</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Baer</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Higgins</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Gietz</td>
        <td>None</td>
    </tr>
</table>




```python
# 查询有奖金的员工名和奖金率
%sql select last_name, commission_pct from employees where commission_pct is not null;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    35 rows affected.





<table>
    <tr>
        <th>last_name</th>
        <th>commission_pct</th>
    </tr>
    <tr>
        <td>Russell</td>
        <td>0.4</td>
    </tr>
    <tr>
        <td>Partners</td>
        <td>0.3</td>
    </tr>
    <tr>
        <td>Errazuriz</td>
        <td>0.3</td>
    </tr>
    <tr>
        <td>Cambrault</td>
        <td>0.3</td>
    </tr>
    <tr>
        <td>Zlotkey</td>
        <td>0.2</td>
    </tr>
    <tr>
        <td>Tucker</td>
        <td>0.3</td>
    </tr>
    <tr>
        <td>Bernstein</td>
        <td>0.25</td>
    </tr>
    <tr>
        <td>Hall</td>
        <td>0.25</td>
    </tr>
    <tr>
        <td>Olsen</td>
        <td>0.2</td>
    </tr>
    <tr>
        <td>Cambrault</td>
        <td>0.2</td>
    </tr>
    <tr>
        <td>Tuvault</td>
        <td>0.15</td>
    </tr>
    <tr>
        <td>K_ing</td>
        <td>0.35</td>
    </tr>
    <tr>
        <td>Sully</td>
        <td>0.35</td>
    </tr>
    <tr>
        <td>McEwen</td>
        <td>0.35</td>
    </tr>
    <tr>
        <td>Smith</td>
        <td>0.3</td>
    </tr>
    <tr>
        <td>Doran</td>
        <td>0.3</td>
    </tr>
    <tr>
        <td>Sewall</td>
        <td>0.25</td>
    </tr>
    <tr>
        <td>Vishney</td>
        <td>0.25</td>
    </tr>
    <tr>
        <td>Greene</td>
        <td>0.15</td>
    </tr>
    <tr>
        <td>Marvins</td>
        <td>0.1</td>
    </tr>
    <tr>
        <td>Lee</td>
        <td>0.1</td>
    </tr>
    <tr>
        <td>Ande</td>
        <td>0.1</td>
    </tr>
    <tr>
        <td>Banda</td>
        <td>0.1</td>
    </tr>
    <tr>
        <td>Ozer</td>
        <td>0.25</td>
    </tr>
    <tr>
        <td>Bloom</td>
        <td>0.2</td>
    </tr>
    <tr>
        <td>Fox</td>
        <td>0.2</td>
    </tr>
    <tr>
        <td>Smith</td>
        <td>0.15</td>
    </tr>
    <tr>
        <td>Bates</td>
        <td>0.15</td>
    </tr>
    <tr>
        <td>Kumar</td>
        <td>0.1</td>
    </tr>
    <tr>
        <td>Abel</td>
        <td>0.3</td>
    </tr>
    <tr>
        <td>Hutton</td>
        <td>0.25</td>
    </tr>
    <tr>
        <td>Taylor</td>
        <td>0.2</td>
    </tr>
    <tr>
        <td>Livingston</td>
        <td>0.2</td>
    </tr>
    <tr>
        <td>Grant</td>
        <td>0.15</td>
    </tr>
    <tr>
        <td>Johnson</td>
        <td>0.1</td>
    </tr>
</table>



安全等于：<=>

* IS NULL: 仅仅可以判断NULL值，可读性较高，建议使用
* <=>: 既可以判断NULL值，又可以判断普通的数值，可读性较低


```python
# 查询没有奖金的员工名和奖金率
%sql select last_name, commission_pct from employees where commission_pct <=> null;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    72 rows affected.





<table>
    <tr>
        <th>last_name</th>
        <th>commission_pct</th>
    </tr>
    <tr>
        <td>K_ing</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Kochhar</td>
        <td>None</td>
    </tr>
    <tr>
        <td>De Haan</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Hunold</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Ernst</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Austin</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Pataballa</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Lorentz</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Greenberg</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Faviet</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Chen</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Sciarra</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Urman</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Popp</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Raphaely</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Khoo</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Baida</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Tobias</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Himuro</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Colmenares</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Weiss</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Fripp</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Kaufling</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Vollman</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Mourgos</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Nayer</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Mikkilineni</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Landry</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Markle</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Bissot</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Atkinson</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Marlow</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Olson</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Mallin</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Rogers</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Gee</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Philtanker</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Ladwig</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Stiles</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Seo</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Patel</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Rajs</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Davies</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Matos</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Vargas</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Taylor</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Fleaur</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Sullivan</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Geoni</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Sarchand</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Bull</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Dellinger</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Cabrio</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Chung</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Dilly</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Gates</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Perkins</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Bell</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Everett</td>
        <td>None</td>
    </tr>
    <tr>
        <td>McCain</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Jones</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Walsh</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Feeney</td>
        <td>None</td>
    </tr>
    <tr>
        <td>OConnell</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Grant</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Whalen</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Hartstein</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Fay</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Mavris</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Baer</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Higgins</td>
        <td>None</td>
    </tr>
    <tr>
        <td>Gietz</td>
        <td>None</td>
    </tr>
</table>



# 常见函数

概念：类似于java的方法，将一组逻辑语句封装在方法体中，对外暴露方法名

好处：1、隐藏了实现细节  2、提高代码的重用性

调用：select 函数名(实参列表) 【from 表】;

特点：
	①叫什么（函数名）
	②干什么（函数功能）

分类：
	1. 单行函数：	如 concat、length、ifnull等
    
	2. 分组函数：	功能：做统计使用，又称为统计函数、聚合函数、组函数
	
常见函数：
	一、单行函数
    
	字符函数：
	length:获取字节个数(utf-8一个汉字代表3个字节,gbk为2个字节)
	concat
	substr
	instr
	trim
	upper
	lower
	lpad
	rpad
	replace
	
	数学函数：
	round
	ceil
	floor
	truncate
	mod
	
	日期函数：
	now
	curdate
	curtime
	year
	month
	monthname
	day
	hour
	minute
	second
	str_to_date
	date_format
    
	其他函数：
	version
	database
	user
    
	控制函数
	if
	case
    
## 字符函数


```python
# length 获取参数值的字节个数
%sql select length("山水");
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>length(&quot;山水&quot;)</th>
    </tr>
    <tr>
        <td>6</td>
    </tr>
</table>




```python
# substr(注意这里的索引从1开始): 截取字符串
# 截取从指定索引处(包含该索引)后面所有字符
%sql SELECT SUBSTR('曾经沧海难为水,除却巫山不是云',7);
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>SUBSTR(&#x27;曾经沧海难为水,除却巫山不是云&#x27;,7)</th>
    </tr>
    <tr>
        <td>水,除却巫山不是云</td>
    </tr>
</table>




```python
# 截取从指定索引处指定字符长度的字符
%sql SELECT SUBSTR('曾经沧海难为水,除却巫山不是云',7, 4);
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>SUBSTR(&#x27;曾经沧海难为水,除却巫山不是云&#x27;,7, 4)</th>
    </tr>
    <tr>
        <td>水,除却</td>
    </tr>
</table>




```python
# instr 返回子串第一次出现的索引，如果找不到返回0
%sql SELECT INSTR('我欲乘风破浪','乘风') AS out_put;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>out_put</th>
    </tr>
    <tr>
        <td>3</td>
    </tr>
</table>




```python
# trim 左右裁剪
%sql SELECT TRIM('    aaa    ') AS out_put;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>out_put</th>
    </tr>
    <tr>
        <td>aaa</td>
    </tr>
</table>




```python
%sql select trim('S' from email),email from employees;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    107 rows affected.





<table>
    <tr>
        <th>trim(&#x27;S|K&#x27; from email)</th>
        <th>email</th>
    </tr>
    <tr>
        <td>SKING</td>
        <td>SKING</td>
    </tr>
    <tr>
        <td>NKOCHHAR</td>
        <td>NKOCHHAR</td>
    </tr>
    <tr>
        <td>LDEHAAN</td>
        <td>LDEHAAN</td>
    </tr>
    <tr>
        <td>AHUNOLD</td>
        <td>AHUNOLD</td>
    </tr>
    <tr>
        <td>BERNST</td>
        <td>BERNST</td>
    </tr>
    <tr>
        <td>DAUSTIN</td>
        <td>DAUSTIN</td>
    </tr>
    <tr>
        <td>VPATABAL</td>
        <td>VPATABAL</td>
    </tr>
    <tr>
        <td>DLORENTZ</td>
        <td>DLORENTZ</td>
    </tr>
    <tr>
        <td>NGREENBE</td>
        <td>NGREENBE</td>
    </tr>
    <tr>
        <td>DFAVIET</td>
        <td>DFAVIET</td>
    </tr>
    <tr>
        <td>JCHEN</td>
        <td>JCHEN</td>
    </tr>
    <tr>
        <td>ISCIARRA</td>
        <td>ISCIARRA</td>
    </tr>
    <tr>
        <td>JMURMAN</td>
        <td>JMURMAN</td>
    </tr>
    <tr>
        <td>LPOPP</td>
        <td>LPOPP</td>
    </tr>
    <tr>
        <td>DRAPHEAL</td>
        <td>DRAPHEAL</td>
    </tr>
    <tr>
        <td>AKHOO</td>
        <td>AKHOO</td>
    </tr>
    <tr>
        <td>SBAIDA</td>
        <td>SBAIDA</td>
    </tr>
    <tr>
        <td>STOBIAS</td>
        <td>STOBIAS</td>
    </tr>
    <tr>
        <td>GHIMURO</td>
        <td>GHIMURO</td>
    </tr>
    <tr>
        <td>KCOLMENA</td>
        <td>KCOLMENA</td>
    </tr>
    <tr>
        <td>MWEISS</td>
        <td>MWEISS</td>
    </tr>
    <tr>
        <td>AFRIPP</td>
        <td>AFRIPP</td>
    </tr>
    <tr>
        <td>PKAUFLIN</td>
        <td>PKAUFLIN</td>
    </tr>
    <tr>
        <td>SVOLLMAN</td>
        <td>SVOLLMAN</td>
    </tr>
    <tr>
        <td>KMOURGOS</td>
        <td>KMOURGOS</td>
    </tr>
    <tr>
        <td>JNAYER</td>
        <td>JNAYER</td>
    </tr>
    <tr>
        <td>IMIKKILI</td>
        <td>IMIKKILI</td>
    </tr>
    <tr>
        <td>JLANDRY</td>
        <td>JLANDRY</td>
    </tr>
    <tr>
        <td>SMARKLE</td>
        <td>SMARKLE</td>
    </tr>
    <tr>
        <td>LBISSOT</td>
        <td>LBISSOT</td>
    </tr>
    <tr>
        <td>MATKINSO</td>
        <td>MATKINSO</td>
    </tr>
    <tr>
        <td>JAMRLOW</td>
        <td>JAMRLOW</td>
    </tr>
    <tr>
        <td>TJOLSON</td>
        <td>TJOLSON</td>
    </tr>
    <tr>
        <td>JMALLIN</td>
        <td>JMALLIN</td>
    </tr>
    <tr>
        <td>MROGERS</td>
        <td>MROGERS</td>
    </tr>
    <tr>
        <td>KGEE</td>
        <td>KGEE</td>
    </tr>
    <tr>
        <td>HPHILTAN</td>
        <td>HPHILTAN</td>
    </tr>
    <tr>
        <td>RLADWIG</td>
        <td>RLADWIG</td>
    </tr>
    <tr>
        <td>SSTILES</td>
        <td>SSTILES</td>
    </tr>
    <tr>
        <td>JSEO</td>
        <td>JSEO</td>
    </tr>
    <tr>
        <td>JPATEL</td>
        <td>JPATEL</td>
    </tr>
    <tr>
        <td>TRAJS</td>
        <td>TRAJS</td>
    </tr>
    <tr>
        <td>CDAVIES</td>
        <td>CDAVIES</td>
    </tr>
    <tr>
        <td>RMATOS</td>
        <td>RMATOS</td>
    </tr>
    <tr>
        <td>PVARGAS</td>
        <td>PVARGAS</td>
    </tr>
    <tr>
        <td>JRUSSEL</td>
        <td>JRUSSEL</td>
    </tr>
    <tr>
        <td>KPARTNER</td>
        <td>KPARTNER</td>
    </tr>
    <tr>
        <td>AERRAZUR</td>
        <td>AERRAZUR</td>
    </tr>
    <tr>
        <td>GCAMBRAU</td>
        <td>GCAMBRAU</td>
    </tr>
    <tr>
        <td>EZLOTKEY</td>
        <td>EZLOTKEY</td>
    </tr>
    <tr>
        <td>PTUCKER</td>
        <td>PTUCKER</td>
    </tr>
    <tr>
        <td>DBERNSTE</td>
        <td>DBERNSTE</td>
    </tr>
    <tr>
        <td>PHALL</td>
        <td>PHALL</td>
    </tr>
    <tr>
        <td>COLSEN</td>
        <td>COLSEN</td>
    </tr>
    <tr>
        <td>NCAMBRAU</td>
        <td>NCAMBRAU</td>
    </tr>
    <tr>
        <td>OTUVAULT</td>
        <td>OTUVAULT</td>
    </tr>
    <tr>
        <td>JKING</td>
        <td>JKING</td>
    </tr>
    <tr>
        <td>PSULLY</td>
        <td>PSULLY</td>
    </tr>
    <tr>
        <td>AMCEWEN</td>
        <td>AMCEWEN</td>
    </tr>
    <tr>
        <td>LSMITH</td>
        <td>LSMITH</td>
    </tr>
    <tr>
        <td>LDORAN</td>
        <td>LDORAN</td>
    </tr>
    <tr>
        <td>SSEWALL</td>
        <td>SSEWALL</td>
    </tr>
    <tr>
        <td>CVISHNEY</td>
        <td>CVISHNEY</td>
    </tr>
    <tr>
        <td>DGREENE</td>
        <td>DGREENE</td>
    </tr>
    <tr>
        <td>MMARVINS</td>
        <td>MMARVINS</td>
    </tr>
    <tr>
        <td>DLEE</td>
        <td>DLEE</td>
    </tr>
    <tr>
        <td>SANDE</td>
        <td>SANDE</td>
    </tr>
    <tr>
        <td>ABANDA</td>
        <td>ABANDA</td>
    </tr>
    <tr>
        <td>LOZER</td>
        <td>LOZER</td>
    </tr>
    <tr>
        <td>HBLOOM</td>
        <td>HBLOOM</td>
    </tr>
    <tr>
        <td>TFOX</td>
        <td>TFOX</td>
    </tr>
    <tr>
        <td>WSMITH</td>
        <td>WSMITH</td>
    </tr>
    <tr>
        <td>EBATES</td>
        <td>EBATES</td>
    </tr>
    <tr>
        <td>SKUMAR</td>
        <td>SKUMAR</td>
    </tr>
    <tr>
        <td>EABEL</td>
        <td>EABEL</td>
    </tr>
    <tr>
        <td>AHUTTON</td>
        <td>AHUTTON</td>
    </tr>
    <tr>
        <td>JTAYLOR</td>
        <td>JTAYLOR</td>
    </tr>
    <tr>
        <td>JLIVINGS</td>
        <td>JLIVINGS</td>
    </tr>
    <tr>
        <td>KGRANT</td>
        <td>KGRANT</td>
    </tr>
    <tr>
        <td>CJOHNSON</td>
        <td>CJOHNSON</td>
    </tr>
    <tr>
        <td>WTAYLOR</td>
        <td>WTAYLOR</td>
    </tr>
    <tr>
        <td>JFLEAUR</td>
        <td>JFLEAUR</td>
    </tr>
    <tr>
        <td>MSULLIVA</td>
        <td>MSULLIVA</td>
    </tr>
    <tr>
        <td>GGEONI</td>
        <td>GGEONI</td>
    </tr>
    <tr>
        <td>NSARCHAN</td>
        <td>NSARCHAN</td>
    </tr>
    <tr>
        <td>ABULL</td>
        <td>ABULL</td>
    </tr>
    <tr>
        <td>JDELLING</td>
        <td>JDELLING</td>
    </tr>
    <tr>
        <td>ACABRIO</td>
        <td>ACABRIO</td>
    </tr>
    <tr>
        <td>KCHUNG</td>
        <td>KCHUNG</td>
    </tr>
    <tr>
        <td>JDILLY</td>
        <td>JDILLY</td>
    </tr>
    <tr>
        <td>TGATES</td>
        <td>TGATES</td>
    </tr>
    <tr>
        <td>RPERKINS</td>
        <td>RPERKINS</td>
    </tr>
    <tr>
        <td>SBELL</td>
        <td>SBELL</td>
    </tr>
    <tr>
        <td>BEVERETT</td>
        <td>BEVERETT</td>
    </tr>
    <tr>
        <td>SMCCAIN</td>
        <td>SMCCAIN</td>
    </tr>
    <tr>
        <td>VJONES</td>
        <td>VJONES</td>
    </tr>
    <tr>
        <td>AWALSH</td>
        <td>AWALSH</td>
    </tr>
    <tr>
        <td>KFEENEY</td>
        <td>KFEENEY</td>
    </tr>
    <tr>
        <td>DOCONNEL</td>
        <td>DOCONNEL</td>
    </tr>
    <tr>
        <td>DGRANT</td>
        <td>DGRANT</td>
    </tr>
    <tr>
        <td>JWHALEN</td>
        <td>JWHALEN</td>
    </tr>
    <tr>
        <td>MHARTSTE</td>
        <td>MHARTSTE</td>
    </tr>
    <tr>
        <td>PFAY</td>
        <td>PFAY</td>
    </tr>
    <tr>
        <td>SMAVRIS</td>
        <td>SMAVRIS</td>
    </tr>
    <tr>
        <td>HBAER</td>
        <td>HBAER</td>
    </tr>
    <tr>
        <td>SHIGGINS</td>
        <td>SHIGGINS</td>
    </tr>
    <tr>
        <td>WGIETZ</td>
        <td>WGIETZ</td>
    </tr>
</table>




```python
# lpad 用指定的字符实现左填充指定长度, 这里的12指的是字符长度
%sql SELECT RPAD('殷素素',12,'ab')

```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>RPAD(&#x27;殷素素&#x27;,12,&#x27;ab&#x27;)</th>
    </tr>
    <tr>
        <td>殷素素ababababa</td>
    </tr>
</table>




```python
# replace 替换
%sql SELECT REPLACE('aaabbbcccddd','a','0') AS out_put;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>out_put</th>
    </tr>
    <tr>
        <td>000bbbcccddd</td>
    </tr>
</table>



## 数学函数




```python
# round 四舍五入
%sql select round(1.23)
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>round(1.23)</th>
    </tr>
    <tr>
        <td>1</td>
    </tr>
</table>




```python
# 第2个参数表示保留几位小数
%sql select round(1.23, 1)
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>round(1.23, 1)</th>
    </tr>
    <tr>
        <td>1.2</td>
    </tr>
</table>




```python
# ceil 向上取整,返回>=该参数的最小整数
%sql select ceil(1)
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>ceil(1)</th>
    </tr>
    <tr>
        <td>1</td>
    </tr>
</table>




```python
%sql select ceil(1.23)
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>ceil(1.23)</th>
    </tr>
    <tr>
        <td>2</td>
    </tr>
</table>




```python
# floor 向下取整，返回<=该参数的最大整数
%sql select floor(1.2)
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>floor(1.2)</th>
    </tr>
    <tr>
        <td>1</td>
    </tr>
</table>




```python
# truncate 截断
%sql select truncate(1.23, 0)
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>truncate(1.23, 0)</th>
    </tr>
    <tr>
        <td>1</td>
    </tr>
</table>




```python
%sql select truncate(1.23, 1)
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>truncate(1.23, 1)</th>
    </tr>
    <tr>
        <td>1.2</td>
    </tr>
</table>




```python
# mod取余 a mod b   a - a/b*b  这里的 / 是整除
%sql select mod(10, 4);
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>mod(10, 4)</th>
    </tr>
    <tr>
        <td>2</td>
    </tr>
</table>



## 日期函数

now 返回当前系统日期+时间
SELECT NOW();

curdate 返回当前系统日期，不包含时间
SELECT CURDATE();

curtime 返回当前时间，不包含日期
SELECT CURTIME();

str_to_date 将字符通过指定的格式转换成日期(告诉解析器每个字符对应的是年还有月或日等)
date_format 将日期转换成字符

DATE_ADD(date,INTERVAL expr type) 从日期加上指定的时间间隔
DATE_SUB(date,INTERVAL expr type) 从日期减去指定的时间间隔

DATEDIFF(date1,date2)：两个日期相减 date1 - date2，返回天数
TIMEDIFF(time1,time2)：两个日期相减 time1 - time2，返回 TIME 差值

两个日期可以比较大小，但不能直接相减，日期相减应该用函数DATEDIFF，该函数返回相差的天数。同样，两个时间可通过>或<比较大小，也可通过时间相减函数subtime(time1,time2)。

日期与时间都参与比较: 单纯的得出大小，用 > 或 < 运算即可，要得出具体相差的时间是多少，似乎没有一个函数可直接做到，则需要分别计算日期与时间差，最后换算为相应时间单位后相加得到最终结果。

需用到的函数：TIME_TO_SEC(datetime)：将时间部分转化为秒数。


```python
# 查询入职日期为1992-4-3的员工信息
# SELECT * FROM employees WHERE hiredate = '1992-4-3';
%sql SELECT * FROM employees WHERE hiredate = STR_TO_DATE('4-3 1992','%c-%d %Y');


```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    5 rows affected.





<table>
    <tr>
        <th>employee_id</th>
        <th>first_name</th>
        <th>last_name</th>
        <th>email</th>
        <th>phone_number</th>
        <th>job_id</th>
        <th>salary</th>
        <th>commission_pct</th>
        <th>manager_id</th>
        <th>department_id</th>
        <th>hiredate</th>
    </tr>
    <tr>
        <td>100</td>
        <td>Steven</td>
        <td>K_ing</td>
        <td>SKING</td>
        <td>515.123.4567</td>
        <td>AD_PRES</td>
        <td>24000.0</td>
        <td>None</td>
        <td>None</td>
        <td>90</td>
        <td>1992-04-03 00:00:00</td>
    </tr>
    <tr>
        <td>101</td>
        <td>Neena</td>
        <td>Kochhar</td>
        <td>NKOCHHAR</td>
        <td>515.123.4568</td>
        <td>AD_VP</td>
        <td>17000.0</td>
        <td>None</td>
        <td>100</td>
        <td>90</td>
        <td>1992-04-03 00:00:00</td>
    </tr>
    <tr>
        <td>102</td>
        <td>Lex</td>
        <td>De Haan</td>
        <td>LDEHAAN</td>
        <td>515.123.4569</td>
        <td>AD_VP</td>
        <td>17000.0</td>
        <td>None</td>
        <td>100</td>
        <td>90</td>
        <td>1992-04-03 00:00:00</td>
    </tr>
    <tr>
        <td>103</td>
        <td>Alexander</td>
        <td>Hunold</td>
        <td>AHUNOLD</td>
        <td>590.423.4567</td>
        <td>IT_PROG</td>
        <td>9000.0</td>
        <td>None</td>
        <td>102</td>
        <td>60</td>
        <td>1992-04-03 00:00:00</td>
    </tr>
    <tr>
        <td>104</td>
        <td>Bruce</td>
        <td>Ernst</td>
        <td>BERNST</td>
        <td>590.423.4568</td>
        <td>IT_PROG</td>
        <td>6000.0</td>
        <td>None</td>
        <td>103</td>
        <td>60</td>
        <td>1992-04-03 00:00:00</td>
    </tr>
</table>




```python
# 查询有奖金的员工名和入职日期(xx月/xx日 xx年)
%sql SELECT last_name,DATE_FORMAT(hiredate,'%m月/%d日 %y年') 入职日期 FROM employees WHERE commission_pct IS NOT NULL;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    35 rows affected.





<table>
    <tr>
        <th>last_name</th>
        <th>入职日期</th>
    </tr>
    <tr>
        <td>Russell</td>
        <td>12月/23日 02年</td>
    </tr>
    <tr>
        <td>Partners</td>
        <td>12月/23日 02年</td>
    </tr>
    <tr>
        <td>Errazuriz</td>
        <td>12月/23日 02年</td>
    </tr>
    <tr>
        <td>Cambrault</td>
        <td>12月/23日 02年</td>
    </tr>
    <tr>
        <td>Zlotkey</td>
        <td>12月/23日 02年</td>
    </tr>
    <tr>
        <td>Tucker</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Bernstein</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Hall</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Olsen</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Cambrault</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Tuvault</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>K_ing</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Sully</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>McEwen</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Smith</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Doran</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Sewall</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Vishney</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Greene</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Marvins</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Lee</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Ande</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Banda</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Ozer</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Bloom</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Fox</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Smith</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Bates</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Kumar</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Abel</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Hutton</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Taylor</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Livingston</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Grant</td>
        <td>03月/05日 14年</td>
    </tr>
    <tr>
        <td>Johnson</td>
        <td>03月/05日 14年</td>
    </tr>
</table>




```python
# 查询2014年以后入职的员工姓名
%sql select last_name,hiredate from employees where YEAR(hiredate) > 2014;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    7 rows affected.





<table>
    <tr>
        <th>last_name</th>
        <th>hiredate</th>
    </tr>
    <tr>
        <td>Whalen</td>
        <td>2016-03-03 00:00:00</td>
    </tr>
    <tr>
        <td>Hartstein</td>
        <td>2016-03-03 00:00:00</td>
    </tr>
    <tr>
        <td>Fay</td>
        <td>2016-03-03 00:00:00</td>
    </tr>
    <tr>
        <td>Mavris</td>
        <td>2016-03-03 00:00:00</td>
    </tr>
    <tr>
        <td>Baer</td>
        <td>2016-03-03 00:00:00</td>
    </tr>
    <tr>
        <td>Higgins</td>
        <td>2016-03-03 00:00:00</td>
    </tr>
    <tr>
        <td>Gietz</td>
        <td>2016-03-03 00:00:00</td>
    </tr>
</table>




```python
%sql SELECT DATEDIFF('2017-06-05','2017-05-29');
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>DATEDIFF(&#x27;2017-06-05&#x27;,&#x27;2017-05-29&#x27;)</th>
    </tr>
    <tr>
        <td>7</td>
    </tr>
</table>




```python
%sql SELECT TIMEDIFF('2017-06-05 19:28:37', '2017-06-05 17:00:00');
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>TIMEDIFF(&#x27;2017-06-05 19:28:37&#x27;, &#x27;2017-06-05 17:00:00&#x27;)</th>
    </tr>
    <tr>
        <td>2:28:37</td>
    </tr>
</table>




```python
%sql SELECT DATE_ADD('2017-05-15 10:37:14.123456',INTERVAL 1 YEAR);
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>DATE_ADD(&#x27;2017-05-15 10:37:14.123456&#x27;,INTERVAL 1 YEAR)</th>
    </tr>
    <tr>
        <td>2018-05-15 10:37:14.123456</td>
    </tr>
</table>




```python
%sql SELECT DATE_SUB('2017-05-15 10:37:14.123456',INTERVAL 1 YEAR);
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>DATE_SUB(&#x27;2017-05-15 10:37:14.123456&#x27;,INTERVAL 1 YEAR)</th>
    </tr>
    <tr>
        <td>2016-05-15 10:37:14.123456</td>
    </tr>
</table>



## 流程控制函数

if函数： 类似于三元表达式

case

使用方式一(类似于switch case)
```
case 要判断的字段或表达式
when 常量1 then 要显示的值1或语句1;
when 常量2 then 要显示的值2或语句2;
...
else 要显示的值n或语句n;
end
```
使用方式二(类似于多重if)
```
case 
when 条件1 then 要显示的值1或语句1
when 条件2 then 要显示的值2或语句2
...
else 要显示的值n或语句n
end
```


```python
%sql SELECT IF(10<5,'大','小');
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>IF(10&lt;5,&#x27;大&#x27;,&#x27;小&#x27;)</th>
    </tr>
    <tr>
        <td>小</td>
    </tr>
</table>




```python
%sql SELECT last_name,commission_pct,IF(commission_pct IS NULL,'没奖金','有奖金') 备注 FROM employees;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    107 rows affected.





<table>
    <tr>
        <th>last_name</th>
        <th>commission_pct</th>
        <th>备注</th>
    </tr>
    <tr>
        <td>K_ing</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Kochhar</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>De Haan</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Hunold</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Ernst</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Austin</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Pataballa</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Lorentz</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Greenberg</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Faviet</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Chen</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Sciarra</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Urman</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Popp</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Raphaely</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Khoo</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Baida</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Tobias</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Himuro</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Colmenares</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Weiss</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Fripp</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Kaufling</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Vollman</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Mourgos</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Nayer</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Mikkilineni</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Landry</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Markle</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Bissot</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Atkinson</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Marlow</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Olson</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Mallin</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Rogers</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Gee</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Philtanker</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Ladwig</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Stiles</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Seo</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Patel</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Rajs</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Davies</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Matos</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Vargas</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Russell</td>
        <td>0.4</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Partners</td>
        <td>0.3</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Errazuriz</td>
        <td>0.3</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Cambrault</td>
        <td>0.3</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Zlotkey</td>
        <td>0.2</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Tucker</td>
        <td>0.3</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Bernstein</td>
        <td>0.25</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Hall</td>
        <td>0.25</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Olsen</td>
        <td>0.2</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Cambrault</td>
        <td>0.2</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Tuvault</td>
        <td>0.15</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>K_ing</td>
        <td>0.35</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Sully</td>
        <td>0.35</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>McEwen</td>
        <td>0.35</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Smith</td>
        <td>0.3</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Doran</td>
        <td>0.3</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Sewall</td>
        <td>0.25</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Vishney</td>
        <td>0.25</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Greene</td>
        <td>0.15</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Marvins</td>
        <td>0.1</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Lee</td>
        <td>0.1</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Ande</td>
        <td>0.1</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Banda</td>
        <td>0.1</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Ozer</td>
        <td>0.25</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Bloom</td>
        <td>0.2</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Fox</td>
        <td>0.2</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Smith</td>
        <td>0.15</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Bates</td>
        <td>0.15</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Kumar</td>
        <td>0.1</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Abel</td>
        <td>0.3</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Hutton</td>
        <td>0.25</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Taylor</td>
        <td>0.2</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Livingston</td>
        <td>0.2</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Grant</td>
        <td>0.15</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Johnson</td>
        <td>0.1</td>
        <td>有奖金</td>
    </tr>
    <tr>
        <td>Taylor</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Fleaur</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Sullivan</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Geoni</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Sarchand</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Bull</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Dellinger</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Cabrio</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Chung</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Dilly</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Gates</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Perkins</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Bell</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Everett</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>McCain</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Jones</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Walsh</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Feeney</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>OConnell</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Grant</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Whalen</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Hartstein</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Fay</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Mavris</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Baer</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Higgins</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
    <tr>
        <td>Gietz</td>
        <td>None</td>
        <td>没奖金</td>
    </tr>
</table>




```python
# 查询员工的工资，要求部门号=30，显示的工资为1.1倍, 部门号=40，显示的工资为1.2倍, 部门号=50，显示的工资为1.3倍, 其他部门，显示的工资为原工资
%sql select salary 原始工资,case department_id when 30 then salary * 1.1 when 40 then salary * 1.2 when 50 then salary * 1.3 else salary end as 新工资 from employees;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    107 rows affected.





<table>
    <tr>
        <th>原始工资</th>
        <th>新工资</th>
    </tr>
    <tr>
        <td>24000.0</td>
        <td>24000.0</td>
    </tr>
    <tr>
        <td>17000.0</td>
        <td>17000.0</td>
    </tr>
    <tr>
        <td>17000.0</td>
        <td>17000.0</td>
    </tr>
    <tr>
        <td>9000.0</td>
        <td>9000.0</td>
    </tr>
    <tr>
        <td>6000.0</td>
        <td>6000.0</td>
    </tr>
    <tr>
        <td>4800.0</td>
        <td>4800.0</td>
    </tr>
    <tr>
        <td>4800.0</td>
        <td>4800.0</td>
    </tr>
    <tr>
        <td>4200.0</td>
        <td>4200.0</td>
    </tr>
    <tr>
        <td>12000.0</td>
        <td>12000.0</td>
    </tr>
    <tr>
        <td>9000.0</td>
        <td>9000.0</td>
    </tr>
    <tr>
        <td>8200.0</td>
        <td>8200.0</td>
    </tr>
    <tr>
        <td>7700.0</td>
        <td>7700.0</td>
    </tr>
    <tr>
        <td>7800.0</td>
        <td>7800.0</td>
    </tr>
    <tr>
        <td>6900.0</td>
        <td>6900.0</td>
    </tr>
    <tr>
        <td>11000.0</td>
        <td>12100.0</td>
    </tr>
    <tr>
        <td>3100.0</td>
        <td>3410.0</td>
    </tr>
    <tr>
        <td>2900.0</td>
        <td>3190.0</td>
    </tr>
    <tr>
        <td>2800.0</td>
        <td>3080.0</td>
    </tr>
    <tr>
        <td>2600.0</td>
        <td>2860.0</td>
    </tr>
    <tr>
        <td>2500.0</td>
        <td>2750.0</td>
    </tr>
    <tr>
        <td>8000.0</td>
        <td>10400.0</td>
    </tr>
    <tr>
        <td>8200.0</td>
        <td>10660.0</td>
    </tr>
    <tr>
        <td>7900.0</td>
        <td>10270.0</td>
    </tr>
    <tr>
        <td>6500.0</td>
        <td>8450.0</td>
    </tr>
    <tr>
        <td>5800.0</td>
        <td>7540.0</td>
    </tr>
    <tr>
        <td>3200.0</td>
        <td>4160.0</td>
    </tr>
    <tr>
        <td>2700.0</td>
        <td>3510.0</td>
    </tr>
    <tr>
        <td>2400.0</td>
        <td>3120.0</td>
    </tr>
    <tr>
        <td>2200.0</td>
        <td>2860.0</td>
    </tr>
    <tr>
        <td>3300.0</td>
        <td>4290.0</td>
    </tr>
    <tr>
        <td>2800.0</td>
        <td>3640.0</td>
    </tr>
    <tr>
        <td>2500.0</td>
        <td>3250.0</td>
    </tr>
    <tr>
        <td>2100.0</td>
        <td>2730.0</td>
    </tr>
    <tr>
        <td>3300.0</td>
        <td>4290.0</td>
    </tr>
    <tr>
        <td>2900.0</td>
        <td>3770.0</td>
    </tr>
    <tr>
        <td>2400.0</td>
        <td>3120.0</td>
    </tr>
    <tr>
        <td>2200.0</td>
        <td>2860.0</td>
    </tr>
    <tr>
        <td>3600.0</td>
        <td>4680.0</td>
    </tr>
    <tr>
        <td>3200.0</td>
        <td>4160.0</td>
    </tr>
    <tr>
        <td>2700.0</td>
        <td>3510.0</td>
    </tr>
    <tr>
        <td>2500.0</td>
        <td>3250.0</td>
    </tr>
    <tr>
        <td>3500.0</td>
        <td>4550.0</td>
    </tr>
    <tr>
        <td>3100.0</td>
        <td>4030.0</td>
    </tr>
    <tr>
        <td>2600.0</td>
        <td>3380.0</td>
    </tr>
    <tr>
        <td>2500.0</td>
        <td>3250.0</td>
    </tr>
    <tr>
        <td>14000.0</td>
        <td>14000.0</td>
    </tr>
    <tr>
        <td>13500.0</td>
        <td>13500.0</td>
    </tr>
    <tr>
        <td>12000.0</td>
        <td>12000.0</td>
    </tr>
    <tr>
        <td>11000.0</td>
        <td>11000.0</td>
    </tr>
    <tr>
        <td>10500.0</td>
        <td>10500.0</td>
    </tr>
    <tr>
        <td>10000.0</td>
        <td>10000.0</td>
    </tr>
    <tr>
        <td>9500.0</td>
        <td>9500.0</td>
    </tr>
    <tr>
        <td>9000.0</td>
        <td>9000.0</td>
    </tr>
    <tr>
        <td>8000.0</td>
        <td>8000.0</td>
    </tr>
    <tr>
        <td>7500.0</td>
        <td>7500.0</td>
    </tr>
    <tr>
        <td>7000.0</td>
        <td>7000.0</td>
    </tr>
    <tr>
        <td>10000.0</td>
        <td>10000.0</td>
    </tr>
    <tr>
        <td>9500.0</td>
        <td>9500.0</td>
    </tr>
    <tr>
        <td>9000.0</td>
        <td>9000.0</td>
    </tr>
    <tr>
        <td>8000.0</td>
        <td>8000.0</td>
    </tr>
    <tr>
        <td>7500.0</td>
        <td>7500.0</td>
    </tr>
    <tr>
        <td>7000.0</td>
        <td>7000.0</td>
    </tr>
    <tr>
        <td>10500.0</td>
        <td>10500.0</td>
    </tr>
    <tr>
        <td>9500.0</td>
        <td>9500.0</td>
    </tr>
    <tr>
        <td>7200.0</td>
        <td>7200.0</td>
    </tr>
    <tr>
        <td>6800.0</td>
        <td>6800.0</td>
    </tr>
    <tr>
        <td>6400.0</td>
        <td>6400.0</td>
    </tr>
    <tr>
        <td>6200.0</td>
        <td>6200.0</td>
    </tr>
    <tr>
        <td>11500.0</td>
        <td>11500.0</td>
    </tr>
    <tr>
        <td>10000.0</td>
        <td>10000.0</td>
    </tr>
    <tr>
        <td>9600.0</td>
        <td>9600.0</td>
    </tr>
    <tr>
        <td>7400.0</td>
        <td>7400.0</td>
    </tr>
    <tr>
        <td>7300.0</td>
        <td>7300.0</td>
    </tr>
    <tr>
        <td>6100.0</td>
        <td>6100.0</td>
    </tr>
    <tr>
        <td>11000.0</td>
        <td>11000.0</td>
    </tr>
    <tr>
        <td>8800.0</td>
        <td>8800.0</td>
    </tr>
    <tr>
        <td>8600.0</td>
        <td>8600.0</td>
    </tr>
    <tr>
        <td>8400.0</td>
        <td>8400.0</td>
    </tr>
    <tr>
        <td>7000.0</td>
        <td>7000.0</td>
    </tr>
    <tr>
        <td>6200.0</td>
        <td>6200.0</td>
    </tr>
    <tr>
        <td>3200.0</td>
        <td>4160.0</td>
    </tr>
    <tr>
        <td>3100.0</td>
        <td>4030.0</td>
    </tr>
    <tr>
        <td>2500.0</td>
        <td>3250.0</td>
    </tr>
    <tr>
        <td>2800.0</td>
        <td>3640.0</td>
    </tr>
    <tr>
        <td>4200.0</td>
        <td>5460.0</td>
    </tr>
    <tr>
        <td>4100.0</td>
        <td>5330.0</td>
    </tr>
    <tr>
        <td>3400.0</td>
        <td>4420.0</td>
    </tr>
    <tr>
        <td>3000.0</td>
        <td>3900.0</td>
    </tr>
    <tr>
        <td>3800.0</td>
        <td>4940.0</td>
    </tr>
    <tr>
        <td>3600.0</td>
        <td>4680.0</td>
    </tr>
    <tr>
        <td>2900.0</td>
        <td>3770.0</td>
    </tr>
    <tr>
        <td>2500.0</td>
        <td>3250.0</td>
    </tr>
    <tr>
        <td>4000.0</td>
        <td>5200.0</td>
    </tr>
    <tr>
        <td>3900.0</td>
        <td>5070.0</td>
    </tr>
    <tr>
        <td>3200.0</td>
        <td>4160.0</td>
    </tr>
    <tr>
        <td>2800.0</td>
        <td>3640.0</td>
    </tr>
    <tr>
        <td>3100.0</td>
        <td>4030.0</td>
    </tr>
    <tr>
        <td>3000.0</td>
        <td>3900.0</td>
    </tr>
    <tr>
        <td>2600.0</td>
        <td>3380.0</td>
    </tr>
    <tr>
        <td>2600.0</td>
        <td>3380.0</td>
    </tr>
    <tr>
        <td>4400.0</td>
        <td>4400.0</td>
    </tr>
    <tr>
        <td>13000.0</td>
        <td>13000.0</td>
    </tr>
    <tr>
        <td>6000.0</td>
        <td>6000.0</td>
    </tr>
    <tr>
        <td>6500.0</td>
        <td>7800.0</td>
    </tr>
    <tr>
        <td>10000.0</td>
        <td>10000.0</td>
    </tr>
    <tr>
        <td>12000.0</td>
        <td>12000.0</td>
    </tr>
    <tr>
        <td>8300.0</td>
        <td>8300.0</td>
    </tr>
</table>




```python
# 查询员工的工资的情况: 如果工资>20000,显示A级别, 如果工资>15000,显示B级别, 如果工资>10000，显示C级别, 否则，显示D级别
%sql SELECT salary, CASE WHEN salary>20000 THEN 'A' WHEN salary>15000 THEN 'B' WHEN salary>10000 THEN 'C' ELSE 'D' END AS 工资级别 FROM employees;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    107 rows affected.





<table>
    <tr>
        <th>salary</th>
        <th>工资级别</th>
    </tr>
    <tr>
        <td>24000.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>17000.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>17000.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>9000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>6000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>4800.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>4800.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>4200.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>12000.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>9000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>8200.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>7700.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>7800.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>6900.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>11000.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>3100.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2900.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2800.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2600.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2500.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>8000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>8200.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>7900.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>6500.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>5800.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>3200.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2700.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2400.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2200.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>3300.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2800.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2500.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2100.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>3300.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2900.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2400.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2200.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>3600.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>3200.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2700.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2500.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>3500.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>3100.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2600.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2500.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>14000.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>13500.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>12000.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>11000.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>10500.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>10000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>9500.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>9000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>8000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>7500.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>7000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>10000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>9500.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>9000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>8000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>7500.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>7000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>10500.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>9500.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>7200.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>6800.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>6400.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>6200.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>11500.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>10000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>9600.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>7400.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>7300.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>6100.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>11000.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>8800.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>8600.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>8400.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>7000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>6200.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>3200.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>3100.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2500.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2800.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>4200.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>4100.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>3400.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>3000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>3800.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>3600.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2900.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2500.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>4000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>3900.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>3200.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2800.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>3100.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>3000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2600.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>2600.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>4400.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>13000.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>6000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>6500.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>10000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>12000.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>8300.0</td>
        <td>D</td>
    </tr>
</table>



# 排序

语法：
select 查询列表
from 表名
【where  筛选条件】
order by 排序的字段或表达式;


特点：

1、asc代表的是升序，可以省略
desc代表的是降序

2、order by子句可以支持 单个字段、别名、表达式、函数、多个字段, 还可以支持别名(因为select后的语句执行在order by之前)

3、order by子句在查询语句的最后面，除了limit子句


```python
# 查询员工信息 按年薪升序
%sql select last_name, salary*12*(ifnull(commission_pct, 1)) 年薪 from employees order by 年薪 ASC;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    107 rows affected.





<table>
    <tr>
        <th>last_name</th>
        <th>年薪</th>
    </tr>
    <tr>
        <td>Kumar</td>
        <td>7320.0</td>
    </tr>
    <tr>
        <td>Banda</td>
        <td>7440.0</td>
    </tr>
    <tr>
        <td>Johnson</td>
        <td>7440.0</td>
    </tr>
    <tr>
        <td>Ande</td>
        <td>7680.0</td>
    </tr>
    <tr>
        <td>Lee</td>
        <td>8160.0</td>
    </tr>
    <tr>
        <td>Marvins</td>
        <td>8640.0</td>
    </tr>
    <tr>
        <td>Tuvault</td>
        <td>12600.0</td>
    </tr>
    <tr>
        <td>Grant</td>
        <td>12600.0</td>
    </tr>
    <tr>
        <td>Bates</td>
        <td>13140.0</td>
    </tr>
    <tr>
        <td>Smith</td>
        <td>13320.0</td>
    </tr>
    <tr>
        <td>Greene</td>
        <td>17100.0</td>
    </tr>
    <tr>
        <td>Cambrault</td>
        <td>18000.0</td>
    </tr>
    <tr>
        <td>Olsen</td>
        <td>19200.0</td>
    </tr>
    <tr>
        <td>Livingston</td>
        <td>20160.0</td>
    </tr>
    <tr>
        <td>Taylor</td>
        <td>20640.0</td>
    </tr>
    <tr>
        <td>Sewall</td>
        <td>21000.0</td>
    </tr>
    <tr>
        <td>Fox</td>
        <td>23040.0</td>
    </tr>
    <tr>
        <td>Bloom</td>
        <td>24000.0</td>
    </tr>
    <tr>
        <td>Olson</td>
        <td>25200.0</td>
    </tr>
    <tr>
        <td>Zlotkey</td>
        <td>25200.0</td>
    </tr>
    <tr>
        <td>Markle</td>
        <td>26400.0</td>
    </tr>
    <tr>
        <td>Philtanker</td>
        <td>26400.0</td>
    </tr>
    <tr>
        <td>Hutton</td>
        <td>26400.0</td>
    </tr>
    <tr>
        <td>Hall</td>
        <td>27000.0</td>
    </tr>
    <tr>
        <td>Doran</td>
        <td>27000.0</td>
    </tr>
    <tr>
        <td>Bernstein</td>
        <td>28500.0</td>
    </tr>
    <tr>
        <td>Landry</td>
        <td>28800.0</td>
    </tr>
    <tr>
        <td>Gee</td>
        <td>28800.0</td>
    </tr>
    <tr>
        <td>Smith</td>
        <td>28800.0</td>
    </tr>
    <tr>
        <td>Colmenares</td>
        <td>30000.0</td>
    </tr>
    <tr>
        <td>Marlow</td>
        <td>30000.0</td>
    </tr>
    <tr>
        <td>Patel</td>
        <td>30000.0</td>
    </tr>
    <tr>
        <td>Vargas</td>
        <td>30000.0</td>
    </tr>
    <tr>
        <td>Sullivan</td>
        <td>30000.0</td>
    </tr>
    <tr>
        <td>Perkins</td>
        <td>30000.0</td>
    </tr>
    <tr>
        <td>Himuro</td>
        <td>31200.0</td>
    </tr>
    <tr>
        <td>Matos</td>
        <td>31200.0</td>
    </tr>
    <tr>
        <td>OConnell</td>
        <td>31200.0</td>
    </tr>
    <tr>
        <td>Grant</td>
        <td>31200.0</td>
    </tr>
    <tr>
        <td>Vishney</td>
        <td>31500.0</td>
    </tr>
    <tr>
        <td>Mikkilineni</td>
        <td>32400.0</td>
    </tr>
    <tr>
        <td>Seo</td>
        <td>32400.0</td>
    </tr>
    <tr>
        <td>Tobias</td>
        <td>33600.0</td>
    </tr>
    <tr>
        <td>Atkinson</td>
        <td>33600.0</td>
    </tr>
    <tr>
        <td>Geoni</td>
        <td>33600.0</td>
    </tr>
    <tr>
        <td>Jones</td>
        <td>33600.0</td>
    </tr>
    <tr>
        <td>Ozer</td>
        <td>34500.0</td>
    </tr>
    <tr>
        <td>Baida</td>
        <td>34800.0</td>
    </tr>
    <tr>
        <td>Rogers</td>
        <td>34800.0</td>
    </tr>
    <tr>
        <td>Gates</td>
        <td>34800.0</td>
    </tr>
    <tr>
        <td>Tucker</td>
        <td>36000.0</td>
    </tr>
    <tr>
        <td>Cabrio</td>
        <td>36000.0</td>
    </tr>
    <tr>
        <td>Feeney</td>
        <td>36000.0</td>
    </tr>
    <tr>
        <td>Khoo</td>
        <td>37200.0</td>
    </tr>
    <tr>
        <td>Davies</td>
        <td>37200.0</td>
    </tr>
    <tr>
        <td>Fleaur</td>
        <td>37200.0</td>
    </tr>
    <tr>
        <td>Walsh</td>
        <td>37200.0</td>
    </tr>
    <tr>
        <td>McEwen</td>
        <td>37800.0</td>
    </tr>
    <tr>
        <td>Nayer</td>
        <td>38400.0</td>
    </tr>
    <tr>
        <td>Stiles</td>
        <td>38400.0</td>
    </tr>
    <tr>
        <td>Taylor</td>
        <td>38400.0</td>
    </tr>
    <tr>
        <td>McCain</td>
        <td>38400.0</td>
    </tr>
    <tr>
        <td>Bissot</td>
        <td>39600.0</td>
    </tr>
    <tr>
        <td>Mallin</td>
        <td>39600.0</td>
    </tr>
    <tr>
        <td>Cambrault</td>
        <td>39600.0</td>
    </tr>
    <tr>
        <td>Abel</td>
        <td>39600.0</td>
    </tr>
    <tr>
        <td>Sully</td>
        <td>39900.0</td>
    </tr>
    <tr>
        <td>Dellinger</td>
        <td>40800.0</td>
    </tr>
    <tr>
        <td>Rajs</td>
        <td>42000.0</td>
    </tr>
    <tr>
        <td>K_ing</td>
        <td>42000.0</td>
    </tr>
    <tr>
        <td>Ladwig</td>
        <td>43200.0</td>
    </tr>
    <tr>
        <td>Errazuriz</td>
        <td>43200.0</td>
    </tr>
    <tr>
        <td>Dilly</td>
        <td>43200.0</td>
    </tr>
    <tr>
        <td>Chung</td>
        <td>45600.0</td>
    </tr>
    <tr>
        <td>Everett</td>
        <td>46800.0</td>
    </tr>
    <tr>
        <td>Bell</td>
        <td>48000.0</td>
    </tr>
    <tr>
        <td>Partners</td>
        <td>48600.0</td>
    </tr>
    <tr>
        <td>Bull</td>
        <td>49200.0</td>
    </tr>
    <tr>
        <td>Lorentz</td>
        <td>50400.0</td>
    </tr>
    <tr>
        <td>Sarchand</td>
        <td>50400.0</td>
    </tr>
    <tr>
        <td>Whalen</td>
        <td>52800.0</td>
    </tr>
    <tr>
        <td>Austin</td>
        <td>57600.0</td>
    </tr>
    <tr>
        <td>Pataballa</td>
        <td>57600.0</td>
    </tr>
    <tr>
        <td>Russell</td>
        <td>67200.0</td>
    </tr>
    <tr>
        <td>Mourgos</td>
        <td>69600.0</td>
    </tr>
    <tr>
        <td>Ernst</td>
        <td>72000.0</td>
    </tr>
    <tr>
        <td>Fay</td>
        <td>72000.0</td>
    </tr>
    <tr>
        <td>Vollman</td>
        <td>78000.0</td>
    </tr>
    <tr>
        <td>Mavris</td>
        <td>78000.0</td>
    </tr>
    <tr>
        <td>Popp</td>
        <td>82800.0</td>
    </tr>
    <tr>
        <td>Sciarra</td>
        <td>92400.0</td>
    </tr>
    <tr>
        <td>Urman</td>
        <td>93600.0</td>
    </tr>
    <tr>
        <td>Kaufling</td>
        <td>94800.0</td>
    </tr>
    <tr>
        <td>Weiss</td>
        <td>96000.0</td>
    </tr>
    <tr>
        <td>Chen</td>
        <td>98400.0</td>
    </tr>
    <tr>
        <td>Fripp</td>
        <td>98400.0</td>
    </tr>
    <tr>
        <td>Gietz</td>
        <td>99600.0</td>
    </tr>
    <tr>
        <td>Hunold</td>
        <td>108000.0</td>
    </tr>
    <tr>
        <td>Faviet</td>
        <td>108000.0</td>
    </tr>
    <tr>
        <td>Baer</td>
        <td>120000.0</td>
    </tr>
    <tr>
        <td>Raphaely</td>
        <td>132000.0</td>
    </tr>
    <tr>
        <td>Greenberg</td>
        <td>144000.0</td>
    </tr>
    <tr>
        <td>Higgins</td>
        <td>144000.0</td>
    </tr>
    <tr>
        <td>Hartstein</td>
        <td>156000.0</td>
    </tr>
    <tr>
        <td>Kochhar</td>
        <td>204000.0</td>
    </tr>
    <tr>
        <td>De Haan</td>
        <td>204000.0</td>
    </tr>
    <tr>
        <td>K_ing</td>
        <td>288000.0</td>
    </tr>
</table>




```python

```

# 分组查询


分组查询一般会使用到分组函数, 对于分组函数，sum和avg的计算都是不包括null值的。

语法：

select 查询列表
from 表
【where 筛选条件】
group by 分组的字段
【having 筛选条件】
【order by 排序的字段】; 

排序一般是放在后面的，但是limit比排序还要靠后。

```
特点：
1、和分组函数一同查询的字段必须是group by后出现的字段
2、筛选分为两类：分组前筛选和分组后筛选
		   针对的表			      位置		连接的关键字
分组前筛选	原始表				group by前	   where
	
分组后筛选	group by后的结果集     group by后	   having

问题1：分组函数做筛选能不能放在where后面
答：不能

问题2：where和having

一般来讲，能用分组前筛选的，尽量使用分组前筛选，提高效率

3、分组可以按单个字段也可以按多个字段
4、可以搭配着排序使用
```


```python
# 查询每个部门的员工个数
%sql select count(*), department_id from employees group by department_id; 
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    12 rows affected.





<table>
    <tr>
        <th>count(*)</th>
        <th>department_id</th>
    </tr>
    <tr>
        <td>1</td>
        <td>None</td>
    </tr>
    <tr>
        <td>1</td>
        <td>10</td>
    </tr>
    <tr>
        <td>2</td>
        <td>20</td>
    </tr>
    <tr>
        <td>6</td>
        <td>30</td>
    </tr>
    <tr>
        <td>1</td>
        <td>40</td>
    </tr>
    <tr>
        <td>45</td>
        <td>50</td>
    </tr>
    <tr>
        <td>5</td>
        <td>60</td>
    </tr>
    <tr>
        <td>1</td>
        <td>70</td>
    </tr>
    <tr>
        <td>34</td>
        <td>80</td>
    </tr>
    <tr>
        <td>3</td>
        <td>90</td>
    </tr>
    <tr>
        <td>6</td>
        <td>100</td>
    </tr>
    <tr>
        <td>2</td>
        <td>110</td>
    </tr>
</table>




```python
# 查询每个工种的员工平均工资
%sql select avg(salary), job_id from employees group by job_id
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    19 rows affected.





<table>
    <tr>
        <th>avg(salary)</th>
        <th>job_id</th>
    </tr>
    <tr>
        <td>8300.0</td>
        <td>AC_ACCOUNT</td>
    </tr>
    <tr>
        <td>12000.0</td>
        <td>AC_MGR</td>
    </tr>
    <tr>
        <td>4400.0</td>
        <td>AD_ASST</td>
    </tr>
    <tr>
        <td>24000.0</td>
        <td>AD_PRES</td>
    </tr>
    <tr>
        <td>17000.0</td>
        <td>AD_VP</td>
    </tr>
    <tr>
        <td>7920.0</td>
        <td>FI_ACCOUNT</td>
    </tr>
    <tr>
        <td>12000.0</td>
        <td>FI_MGR</td>
    </tr>
    <tr>
        <td>6500.0</td>
        <td>HR_REP</td>
    </tr>
    <tr>
        <td>5760.0</td>
        <td>IT_PROG</td>
    </tr>
    <tr>
        <td>13000.0</td>
        <td>MK_MAN</td>
    </tr>
    <tr>
        <td>6000.0</td>
        <td>MK_REP</td>
    </tr>
    <tr>
        <td>10000.0</td>
        <td>PR_REP</td>
    </tr>
    <tr>
        <td>2780.0</td>
        <td>PU_CLERK</td>
    </tr>
    <tr>
        <td>11000.0</td>
        <td>PU_MAN</td>
    </tr>
    <tr>
        <td>12200.0</td>
        <td>SA_MAN</td>
    </tr>
    <tr>
        <td>8350.0</td>
        <td>SA_REP</td>
    </tr>
    <tr>
        <td>3215.0</td>
        <td>SH_CLERK</td>
    </tr>
    <tr>
        <td>2785.0</td>
        <td>ST_CLERK</td>
    </tr>
    <tr>
        <td>7280.0</td>
        <td>ST_MAN</td>
    </tr>
</table>



可以实现分组前的筛选


```python
# 查询邮箱中包含a字符的 每个部门的最高工资
%sql select max(salary), department_id from employees where email like "%a%" group by department_id
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    11 rows affected.





<table>
    <tr>
        <th>max(salary)</th>
        <th>department_id</th>
    </tr>
    <tr>
        <td>7000.0</td>
        <td>None</td>
    </tr>
    <tr>
        <td>4400.0</td>
        <td>10</td>
    </tr>
    <tr>
        <td>13000.0</td>
        <td>20</td>
    </tr>
    <tr>
        <td>11000.0</td>
        <td>30</td>
    </tr>
    <tr>
        <td>6500.0</td>
        <td>40</td>
    </tr>
    <tr>
        <td>8200.0</td>
        <td>50</td>
    </tr>
    <tr>
        <td>9000.0</td>
        <td>60</td>
    </tr>
    <tr>
        <td>10000.0</td>
        <td>70</td>
    </tr>
    <tr>
        <td>13500.0</td>
        <td>80</td>
    </tr>
    <tr>
        <td>17000.0</td>
        <td>90</td>
    </tr>
    <tr>
        <td>9000.0</td>
        <td>100</td>
    </tr>
</table>



分组后筛选


```python
# 查询哪个部门的员工个数>5
%sql select department_id,count(1) from employees group by department_id having count(1) > 5;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    4 rows affected.





<table>
    <tr>
        <th>department_id</th>
        <th>count(1)</th>
    </tr>
    <tr>
        <td>30</td>
        <td>6</td>
    </tr>
    <tr>
        <td>50</td>
        <td>45</td>
    </tr>
    <tr>
        <td>80</td>
        <td>34</td>
    </tr>
    <tr>
        <td>100</td>
        <td>6</td>
    </tr>
</table>




```python
# 每个工种有奖金的员工的最高工资>12000的工种编号和最高工资
%sql select job_id, max(salary) from employees where commission_pct is not null group by job_id having max(salary)>12000;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>job_id</th>
        <th>max(salary)</th>
    </tr>
    <tr>
        <td>SA_MAN</td>
        <td>14000.0</td>
    </tr>
</table>



添加排序


```python
# 每个工种有奖金的员工的最高工资>6000的工种编号和最高工资,按最高工资升序
%sql select job_id, max(salary) from employees where commission_pct is not null group by job_id having max(salary)>6000 order by max(salary);
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    2 rows affected.





<table>
    <tr>
        <th>job_id</th>
        <th>max(salary)</th>
    </tr>
    <tr>
        <td>SA_REP</td>
        <td>11500.0</td>
    </tr>
    <tr>
        <td>SA_MAN</td>
        <td>14000.0</td>
    </tr>
</table>



按多个字段分组


```python
# 查询每个工种每个部门的最低工资,并按最低工资降序
%sql select min(salary) from employees group by job_id, department_id;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    20 rows affected.





<table>
    <tr>
        <th>min(salary)</th>
    </tr>
    <tr>
        <td>24000.0</td>
    </tr>
    <tr>
        <td>17000.0</td>
    </tr>
    <tr>
        <td>4200.0</td>
    </tr>
    <tr>
        <td>12000.0</td>
    </tr>
    <tr>
        <td>6900.0</td>
    </tr>
    <tr>
        <td>11000.0</td>
    </tr>
    <tr>
        <td>2500.0</td>
    </tr>
    <tr>
        <td>5800.0</td>
    </tr>
    <tr>
        <td>2100.0</td>
    </tr>
    <tr>
        <td>10500.0</td>
    </tr>
    <tr>
        <td>6100.0</td>
    </tr>
    <tr>
        <td>7000.0</td>
    </tr>
    <tr>
        <td>2500.0</td>
    </tr>
    <tr>
        <td>4400.0</td>
    </tr>
    <tr>
        <td>13000.0</td>
    </tr>
    <tr>
        <td>6000.0</td>
    </tr>
    <tr>
        <td>6500.0</td>
    </tr>
    <tr>
        <td>10000.0</td>
    </tr>
    <tr>
        <td>12000.0</td>
    </tr>
    <tr>
        <td>8300.0</td>
    </tr>
</table>



分组函数和distinct搭配


```python
%sql SELECT COUNT(DISTINCT salary),COUNT(salary) FROM employees;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>COUNT(DISTINCT salary)</th>
        <th>COUNT(salary)</th>
    </tr>
    <tr>
        <td>57</td>
        <td>107</td>
    </tr>
</table>



# 连接查询


含义：又称多表查询，当查询的字段来自于多个表时，就会用到连接查询

笛卡尔乘积现象：表1 有m行，表2有n行，结果=m*n行

发生原因：没有有效的连接条件

如何避免：添加有效的连接条件

分类：

	按年代分类：
	sql92标准:仅仅支持内连接
	sql99标准【推荐】：支持内连接+外连接（左外和右外）+交叉连接
	
	按功能分类：
		内连接：
			等值连接
			非等值连接
			自连接
		外连接：
			左外连接
			右外连接
			全外连接
		
		交叉连接

## sql92

sql92指的是92年出现的sql语法


### 内连接

内连接是基于笛卡尔积做的

#### 等值连接

1. 多表等值连接的结果为多表的交集部分
2. n表连接，至少需要n-1个连接条件
3. 多表的顺序没有要求
4. 一般需要为表起别名
5. 可以搭配前面介绍的所有子句使用，比如排序、分组、筛选

为表起别名：
1. 提高语句的简洁度
2. 区分多个重名的字段

注意：如果为表起了别名，则查询的字段就不能使用原来的表名去限定


```python
# 查询员工名和对应的部门名
%sql select e.last_name, d.department_name \
from employees e, departments d \
where e.department_id = d.department_id;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    106 rows affected.





<table>
    <tr>
        <th>last_name</th>
        <th>department_name</th>
    </tr>
    <tr>
        <td>Whalen</td>
        <td>Adm</td>
    </tr>
    <tr>
        <td>Hartstein</td>
        <td>Mar</td>
    </tr>
    <tr>
        <td>Fay</td>
        <td>Mar</td>
    </tr>
    <tr>
        <td>Raphaely</td>
        <td>Pur</td>
    </tr>
    <tr>
        <td>Khoo</td>
        <td>Pur</td>
    </tr>
    <tr>
        <td>Baida</td>
        <td>Pur</td>
    </tr>
    <tr>
        <td>Tobias</td>
        <td>Pur</td>
    </tr>
    <tr>
        <td>Himuro</td>
        <td>Pur</td>
    </tr>
    <tr>
        <td>Colmenares</td>
        <td>Pur</td>
    </tr>
    <tr>
        <td>Mavris</td>
        <td>Hum</td>
    </tr>
    <tr>
        <td>Weiss</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Fripp</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Kaufling</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Vollman</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Mourgos</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Nayer</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Mikkilineni</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Landry</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Markle</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Bissot</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Atkinson</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Marlow</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Olson</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Mallin</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Rogers</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Gee</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Philtanker</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Ladwig</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Stiles</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Seo</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Patel</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Rajs</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Davies</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Matos</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Vargas</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Taylor</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Fleaur</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Sullivan</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Geoni</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Sarchand</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Bull</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Dellinger</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Cabrio</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Chung</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Dilly</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Gates</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Perkins</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Bell</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Everett</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>McCain</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Jones</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Walsh</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Feeney</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>OConnell</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Grant</td>
        <td>Shi</td>
    </tr>
    <tr>
        <td>Hunold</td>
        <td>IT</td>
    </tr>
    <tr>
        <td>Ernst</td>
        <td>IT</td>
    </tr>
    <tr>
        <td>Austin</td>
        <td>IT</td>
    </tr>
    <tr>
        <td>Pataballa</td>
        <td>IT</td>
    </tr>
    <tr>
        <td>Lorentz</td>
        <td>IT</td>
    </tr>
    <tr>
        <td>Baer</td>
        <td>Pub</td>
    </tr>
    <tr>
        <td>Russell</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Partners</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Errazuriz</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Cambrault</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Zlotkey</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Tucker</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Bernstein</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Hall</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Olsen</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Cambrault</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Tuvault</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>K_ing</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Sully</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>McEwen</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Smith</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Doran</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Sewall</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Vishney</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Greene</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Marvins</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Lee</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Ande</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Banda</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Ozer</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Bloom</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Fox</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Smith</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Bates</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Kumar</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Abel</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Hutton</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Taylor</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Livingston</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Johnson</td>
        <td>Sal</td>
    </tr>
    <tr>
        <td>K_ing</td>
        <td>Exe</td>
    </tr>
    <tr>
        <td>Kochhar</td>
        <td>Exe</td>
    </tr>
    <tr>
        <td>De Haan</td>
        <td>Exe</td>
    </tr>
    <tr>
        <td>Greenberg</td>
        <td>Fin</td>
    </tr>
    <tr>
        <td>Faviet</td>
        <td>Fin</td>
    </tr>
    <tr>
        <td>Chen</td>
        <td>Fin</td>
    </tr>
    <tr>
        <td>Sciarra</td>
        <td>Fin</td>
    </tr>
    <tr>
        <td>Urman</td>
        <td>Fin</td>
    </tr>
    <tr>
        <td>Popp</td>
        <td>Fin</td>
    </tr>
    <tr>
        <td>Higgins</td>
        <td>Acc</td>
    </tr>
    <tr>
        <td>Gietz</td>
        <td>Acc</td>
    </tr>
</table>



可以加筛选


```python
# 查询城市名中第二个字符为o的部门名和城市名
%sql select department_name, city from departments, locations where city like "_o%" and departments.location_id=locations.location_id;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    4 rows affected.





<table>
    <tr>
        <th>department_name</th>
        <th>city</th>
    </tr>
    <tr>
        <td>IT</td>
        <td>Southlake</td>
    </tr>
    <tr>
        <td>Shi</td>
        <td>South San Francisco</td>
    </tr>
    <tr>
        <td>Mar</td>
        <td>Toronto</td>
    </tr>
    <tr>
        <td>Hum</td>
        <td>London</td>
    </tr>
</table>



可以加分组



```python
# 查询有奖金的每个部门的部门名和部门的领导编号和该部门的最低工资
%sql select d.department_name, min(salary) from departments as d, employees as e where e.commission_pct is not null and d.department_id=e.department_id group by d.department_id
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    1 rows affected.





<table>
    <tr>
        <th>department_name</th>
        <th>min(salary)</th>
    </tr>
    <tr>
        <td>Sal</td>
        <td>6100.0</td>
    </tr>
</table>



#### 非等值连接



```python
# 查询员工的工资和工资级别
%sql select salary,grade_level from employees e, job_grades g where salary between g.lowest_sal AND g.highest_sal;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    107 rows affected.





<table>
    <tr>
        <th>salary</th>
        <th>grade_level</th>
    </tr>
    <tr>
        <td>24000.0</td>
        <td>E</td>
    </tr>
    <tr>
        <td>17000.0</td>
        <td>E</td>
    </tr>
    <tr>
        <td>17000.0</td>
        <td>E</td>
    </tr>
    <tr>
        <td>9000.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>6000.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>4800.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>4800.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>4200.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>12000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>9000.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>8200.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>7700.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>7800.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>6900.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>11000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>3100.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>2900.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>2800.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>2600.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>2500.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>8000.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>8200.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>7900.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>6500.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>5800.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>3200.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>2700.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>2400.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>2200.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>3300.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>2800.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>2500.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>2100.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>3300.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>2900.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>2400.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>2200.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>3600.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>3200.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>2700.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>2500.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>3500.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>3100.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>2600.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>2500.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>14000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>13500.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>12000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>11000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>10500.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>10000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>9500.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>9000.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>8000.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>7500.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>7000.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>10000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>9500.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>9000.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>8000.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>7500.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>7000.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>10500.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>9500.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>7200.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>6800.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>6400.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>6200.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>11500.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>10000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>9600.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>7400.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>7300.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>6100.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>11000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>8800.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>8600.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>8400.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>7000.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>6200.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>3200.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>3100.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>2500.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>2800.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>4200.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>4100.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>3400.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>3000.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>3800.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>3600.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>2900.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>2500.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>4000.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>3900.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>3200.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>2800.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>3100.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>3000.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>2600.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>2600.0</td>
        <td>A</td>
    </tr>
    <tr>
        <td>4400.0</td>
        <td>B</td>
    </tr>
    <tr>
        <td>13000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>6000.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>6500.0</td>
        <td>C</td>
    </tr>
    <tr>
        <td>10000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>12000.0</td>
        <td>D</td>
    </tr>
    <tr>
        <td>8300.0</td>
        <td>C</td>
    </tr>
</table>



#### 自连接



```python
# 查询 员工名和上级的名称
%sql select A.last_name 员工, B.last_name 上级 from employees A, employees B where A.manager_id = B.employee_id;
```

     * mysql+pymysql://root@localhost/myemployees
       mysql+pymysql://root@localhost/test
    106 rows affected.





<table>
    <tr>
        <th>员工</th>
        <th>上级</th>
    </tr>
    <tr>
        <td>Kochhar</td>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>De Haan</td>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>Hunold</td>
        <td>De Haan</td>
    </tr>
    <tr>
        <td>Ernst</td>
        <td>Hunold</td>
    </tr>
    <tr>
        <td>Austin</td>
        <td>Hunold</td>
    </tr>
    <tr>
        <td>Pataballa</td>
        <td>Hunold</td>
    </tr>
    <tr>
        <td>Lorentz</td>
        <td>Hunold</td>
    </tr>
    <tr>
        <td>Greenberg</td>
        <td>Kochhar</td>
    </tr>
    <tr>
        <td>Faviet</td>
        <td>Greenberg</td>
    </tr>
    <tr>
        <td>Chen</td>
        <td>Greenberg</td>
    </tr>
    <tr>
        <td>Sciarra</td>
        <td>Greenberg</td>
    </tr>
    <tr>
        <td>Urman</td>
        <td>Greenberg</td>
    </tr>
    <tr>
        <td>Popp</td>
        <td>Greenberg</td>
    </tr>
    <tr>
        <td>Raphaely</td>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>Khoo</td>
        <td>Raphaely</td>
    </tr>
    <tr>
        <td>Baida</td>
        <td>Raphaely</td>
    </tr>
    <tr>
        <td>Tobias</td>
        <td>Raphaely</td>
    </tr>
    <tr>
        <td>Himuro</td>
        <td>Raphaely</td>
    </tr>
    <tr>
        <td>Colmenares</td>
        <td>Raphaely</td>
    </tr>
    <tr>
        <td>Weiss</td>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>Fripp</td>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>Kaufling</td>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>Vollman</td>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>Mourgos</td>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>Nayer</td>
        <td>Weiss</td>
    </tr>
    <tr>
        <td>Mikkilineni</td>
        <td>Weiss</td>
    </tr>
    <tr>
        <td>Landry</td>
        <td>Weiss</td>
    </tr>
    <tr>
        <td>Markle</td>
        <td>Weiss</td>
    </tr>
    <tr>
        <td>Bissot</td>
        <td>Fripp</td>
    </tr>
    <tr>
        <td>Atkinson</td>
        <td>Fripp</td>
    </tr>
    <tr>
        <td>Marlow</td>
        <td>Fripp</td>
    </tr>
    <tr>
        <td>Olson</td>
        <td>Fripp</td>
    </tr>
    <tr>
        <td>Mallin</td>
        <td>Kaufling</td>
    </tr>
    <tr>
        <td>Rogers</td>
        <td>Kaufling</td>
    </tr>
    <tr>
        <td>Gee</td>
        <td>Kaufling</td>
    </tr>
    <tr>
        <td>Philtanker</td>
        <td>Kaufling</td>
    </tr>
    <tr>
        <td>Ladwig</td>
        <td>Vollman</td>
    </tr>
    <tr>
        <td>Stiles</td>
        <td>Vollman</td>
    </tr>
    <tr>
        <td>Seo</td>
        <td>Vollman</td>
    </tr>
    <tr>
        <td>Patel</td>
        <td>Vollman</td>
    </tr>
    <tr>
        <td>Rajs</td>
        <td>Mourgos</td>
    </tr>
    <tr>
        <td>Davies</td>
        <td>Mourgos</td>
    </tr>
    <tr>
        <td>Matos</td>
        <td>Mourgos</td>
    </tr>
    <tr>
        <td>Vargas</td>
        <td>Mourgos</td>
    </tr>
    <tr>
        <td>Russell</td>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>Partners</td>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>Errazuriz</td>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>Cambrault</td>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>Zlotkey</td>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>Tucker</td>
        <td>Russell</td>
    </tr>
    <tr>
        <td>Bernstein</td>
        <td>Russell</td>
    </tr>
    <tr>
        <td>Hall</td>
        <td>Russell</td>
    </tr>
    <tr>
        <td>Olsen</td>
        <td>Russell</td>
    </tr>
    <tr>
        <td>Cambrault</td>
        <td>Russell</td>
    </tr>
    <tr>
        <td>Tuvault</td>
        <td>Russell</td>
    </tr>
    <tr>
        <td>K_ing</td>
        <td>Partners</td>
    </tr>
    <tr>
        <td>Sully</td>
        <td>Partners</td>
    </tr>
    <tr>
        <td>McEwen</td>
        <td>Partners</td>
    </tr>
    <tr>
        <td>Smith</td>
        <td>Partners</td>
    </tr>
    <tr>
        <td>Doran</td>
        <td>Partners</td>
    </tr>
    <tr>
        <td>Sewall</td>
        <td>Partners</td>
    </tr>
    <tr>
        <td>Vishney</td>
        <td>Errazuriz</td>
    </tr>
    <tr>
        <td>Greene</td>
        <td>Errazuriz</td>
    </tr>
    <tr>
        <td>Marvins</td>
        <td>Errazuriz</td>
    </tr>
    <tr>
        <td>Lee</td>
        <td>Errazuriz</td>
    </tr>
    <tr>
        <td>Ande</td>
        <td>Errazuriz</td>
    </tr>
    <tr>
        <td>Banda</td>
        <td>Errazuriz</td>
    </tr>
    <tr>
        <td>Ozer</td>
        <td>Cambrault</td>
    </tr>
    <tr>
        <td>Bloom</td>
        <td>Cambrault</td>
    </tr>
    <tr>
        <td>Fox</td>
        <td>Cambrault</td>
    </tr>
    <tr>
        <td>Smith</td>
        <td>Cambrault</td>
    </tr>
    <tr>
        <td>Bates</td>
        <td>Cambrault</td>
    </tr>
    <tr>
        <td>Kumar</td>
        <td>Cambrault</td>
    </tr>
    <tr>
        <td>Abel</td>
        <td>Zlotkey</td>
    </tr>
    <tr>
        <td>Hutton</td>
        <td>Zlotkey</td>
    </tr>
    <tr>
        <td>Taylor</td>
        <td>Zlotkey</td>
    </tr>
    <tr>
        <td>Livingston</td>
        <td>Zlotkey</td>
    </tr>
    <tr>
        <td>Grant</td>
        <td>Zlotkey</td>
    </tr>
    <tr>
        <td>Johnson</td>
        <td>Zlotkey</td>
    </tr>
    <tr>
        <td>Taylor</td>
        <td>Weiss</td>
    </tr>
    <tr>
        <td>Fleaur</td>
        <td>Weiss</td>
    </tr>
    <tr>
        <td>Sullivan</td>
        <td>Weiss</td>
    </tr>
    <tr>
        <td>Geoni</td>
        <td>Weiss</td>
    </tr>
    <tr>
        <td>Sarchand</td>
        <td>Fripp</td>
    </tr>
    <tr>
        <td>Bull</td>
        <td>Fripp</td>
    </tr>
    <tr>
        <td>Dellinger</td>
        <td>Fripp</td>
    </tr>
    <tr>
        <td>Cabrio</td>
        <td>Fripp</td>
    </tr>
    <tr>
        <td>Chung</td>
        <td>Kaufling</td>
    </tr>
    <tr>
        <td>Dilly</td>
        <td>Kaufling</td>
    </tr>
    <tr>
        <td>Gates</td>
        <td>Kaufling</td>
    </tr>
    <tr>
        <td>Perkins</td>
        <td>Kaufling</td>
    </tr>
    <tr>
        <td>Bell</td>
        <td>Vollman</td>
    </tr>
    <tr>
        <td>Everett</td>
        <td>Vollman</td>
    </tr>
    <tr>
        <td>McCain</td>
        <td>Vollman</td>
    </tr>
    <tr>
        <td>Jones</td>
        <td>Vollman</td>
    </tr>
    <tr>
        <td>Walsh</td>
        <td>Mourgos</td>
    </tr>
    <tr>
        <td>Feeney</td>
        <td>Mourgos</td>
    </tr>
    <tr>
        <td>OConnell</td>
        <td>Mourgos</td>
    </tr>
    <tr>
        <td>Grant</td>
        <td>Mourgos</td>
    </tr>
    <tr>
        <td>Whalen</td>
        <td>Kochhar</td>
    </tr>
    <tr>
        <td>Hartstein</td>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>Fay</td>
        <td>Hartstein</td>
    </tr>
    <tr>
        <td>Mavris</td>
        <td>Kochhar</td>
    </tr>
    <tr>
        <td>Baer</td>
        <td>Kochhar</td>
    </tr>
    <tr>
        <td>Higgins</td>
        <td>Kochhar</td>
    </tr>
    <tr>
        <td>Gietz</td>
        <td>Higgins</td>
    </tr>
</table>



## sql99

sql99指的是99年出现的sql语法, 平常的开发过程中一般使用这个年代的写法。

sql99语法
```
语法：
	select 查询列表
	from 表1 别名 【连接类型】
	join 表2 别名 
	on 连接条件
	【where 筛选条件】
	【group by 分组】
	【having 筛选条件】
	【order by 排序列表】
	

分类：
内连接（★）：inner
外连接
	左外(★):left 【outer】
	右外(★)：right 【outer】
	全外：full【outer】mysql不支持
交叉连接：cross(类似sql92语法中的笛卡尔乘积, 需要使用where加连接条件)
```
### 内连接

查询多表之间的<font color="red">交集</font>

语法：
```
select 查询列表
from 表1 别名
inner join 表2 别名
on 连接条件;

分类：
等值
非等值
自连接

特点：
1. 添加排序、分组、筛选
2. inner可以省略
3. 筛选条件放在where后面，连接条件放在on后面，提高分离性，便于阅读
4. inner join连接和sql92语法中的等值连接效果是一样的，都是查询多表的交集
```
#### 等值连接


```python
# 查询部门员工个数>3的部门名和员工个数，并按员工个数降序
%sql select d.department_name 部门名, count(*) 员工个数 from departments as d \
inner join employees as e \
on d.department_id = e.department_id \
group by d.department_id having count(*) > 3 \
order by 员工个数 desc

```

     * mysql+pymysql://root@localhost/myemployees
    5 rows affected.





<table>
    <tr>
        <th>部门名</th>
        <th>员工个数</th>
    </tr>
    <tr>
        <td>Shi</td>
        <td>45</td>
    </tr>
    <tr>
        <td>Sal</td>
        <td>34</td>
    </tr>
    <tr>
        <td>Fin</td>
        <td>6</td>
    </tr>
    <tr>
        <td>Pur</td>
        <td>6</td>
    </tr>
    <tr>
        <td>IT</td>
        <td>5</td>
    </tr>
</table>



#### 非等值连接




```python
# 查询员工的工资级别
%sql select e.last_name, g.grade_level from employees as e \
inner join job_grades as g \
on e.salary between g.lowest_sal and g.highest_sal 
```

     * mysql+pymysql://root@localhost/myemployees
    107 rows affected.





<table>
    <tr>
        <th>last_name</th>
        <th>grade_level</th>
    </tr>
    <tr>
        <td>K_ing</td>
        <td>E</td>
    </tr>
    <tr>
        <td>Kochhar</td>
        <td>E</td>
    </tr>
    <tr>
        <td>De Haan</td>
        <td>E</td>
    </tr>
    <tr>
        <td>Hunold</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Ernst</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Austin</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Pataballa</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Lorentz</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Greenberg</td>
        <td>D</td>
    </tr>
    <tr>
        <td>Faviet</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Chen</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Sciarra</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Urman</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Popp</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Raphaely</td>
        <td>D</td>
    </tr>
    <tr>
        <td>Khoo</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Baida</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Tobias</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Himuro</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Colmenares</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Weiss</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Fripp</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Kaufling</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Vollman</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Mourgos</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Nayer</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Mikkilineni</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Landry</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Markle</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Bissot</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Atkinson</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Marlow</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Olson</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Mallin</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Rogers</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Gee</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Philtanker</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Ladwig</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Stiles</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Seo</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Patel</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Rajs</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Davies</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Matos</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Vargas</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Russell</td>
        <td>D</td>
    </tr>
    <tr>
        <td>Partners</td>
        <td>D</td>
    </tr>
    <tr>
        <td>Errazuriz</td>
        <td>D</td>
    </tr>
    <tr>
        <td>Cambrault</td>
        <td>D</td>
    </tr>
    <tr>
        <td>Zlotkey</td>
        <td>D</td>
    </tr>
    <tr>
        <td>Tucker</td>
        <td>D</td>
    </tr>
    <tr>
        <td>Bernstein</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Hall</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Olsen</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Cambrault</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Tuvault</td>
        <td>C</td>
    </tr>
    <tr>
        <td>K_ing</td>
        <td>D</td>
    </tr>
    <tr>
        <td>Sully</td>
        <td>C</td>
    </tr>
    <tr>
        <td>McEwen</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Smith</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Doran</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Sewall</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Vishney</td>
        <td>D</td>
    </tr>
    <tr>
        <td>Greene</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Marvins</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Lee</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Ande</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Banda</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Ozer</td>
        <td>D</td>
    </tr>
    <tr>
        <td>Bloom</td>
        <td>D</td>
    </tr>
    <tr>
        <td>Fox</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Smith</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Bates</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Kumar</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Abel</td>
        <td>D</td>
    </tr>
    <tr>
        <td>Hutton</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Taylor</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Livingston</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Grant</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Johnson</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Taylor</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Fleaur</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Sullivan</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Geoni</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Sarchand</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Bull</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Dellinger</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Cabrio</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Chung</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Dilly</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Gates</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Perkins</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Bell</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Everett</td>
        <td>B</td>
    </tr>
    <tr>
        <td>McCain</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Jones</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Walsh</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Feeney</td>
        <td>B</td>
    </tr>
    <tr>
        <td>OConnell</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Grant</td>
        <td>A</td>
    </tr>
    <tr>
        <td>Whalen</td>
        <td>B</td>
    </tr>
    <tr>
        <td>Hartstein</td>
        <td>D</td>
    </tr>
    <tr>
        <td>Fay</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Mavris</td>
        <td>C</td>
    </tr>
    <tr>
        <td>Baer</td>
        <td>D</td>
    </tr>
    <tr>
        <td>Higgins</td>
        <td>D</td>
    </tr>
    <tr>
        <td>Gietz</td>
        <td>C</td>
    </tr>
</table>




```python
# 查询工资级别的个数>20的个数，并且按工资级别降序(通过查询发现C级的个数最多，大多数人是贫穷的？)
%sql select g.grade_level, count(*) from employees as e \
inner join job_grades as g \
on e.salary between g.lowest_sal and g.highest_sal \
group by g.grade_level having count(*) > 20 \
order by g.grade_level desc
```

     * mysql+pymysql://root@localhost/myemployees
    3 rows affected.





<table>
    <tr>
        <th>grade_level</th>
        <th>count(*)</th>
    </tr>
    <tr>
        <td>C</td>
        <td>38</td>
    </tr>
    <tr>
        <td>B</td>
        <td>26</td>
    </tr>
    <tr>
        <td>A</td>
        <td>24</td>
    </tr>
</table>



#### 自连接



```python
# 查询姓名中包含字符k的员工的名字、上级的名字
%sql select A.last_name, B.last_name from employees as A \
inner join employees as B \
on A.manager_id = B.employee_id \
where A.last_name like "%k%"
```

     * mysql+pymysql://root@localhost/myemployees
    12 rows affected.





<table>
    <tr>
        <th>last_name</th>
        <th>last_name_1</th>
    </tr>
    <tr>
        <td>Kochhar</td>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>Khoo</td>
        <td>Raphaely</td>
    </tr>
    <tr>
        <td>Kaufling</td>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>Mikkilineni</td>
        <td>Weiss</td>
    </tr>
    <tr>
        <td>Markle</td>
        <td>Weiss</td>
    </tr>
    <tr>
        <td>Atkinson</td>
        <td>Fripp</td>
    </tr>
    <tr>
        <td>Philtanker</td>
        <td>Kaufling</td>
    </tr>
    <tr>
        <td>Zlotkey</td>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>Tucker</td>
        <td>Russell</td>
    </tr>
    <tr>
        <td>K_ing</td>
        <td>Partners</td>
    </tr>
    <tr>
        <td>Kumar</td>
        <td>Cambrault</td>
    </tr>
    <tr>
        <td>Perkins</td>
        <td>Kaufling</td>
    </tr>
</table>



###  外连接

应用场景：用于查询一个表中有，另一个表没有的记录

特点：
```
1. 外连接的查询结果为主表中的所有记录
   如果从表中有和它匹配的，则显示匹配的值
   如果从表中没有和它匹配的，则显示null
   外连接查询结果=内连接结果+主表中有而从表没有的记录
2. 左外连接，left join左边的是主表
   右外连接，right join右边的是主表
3. 左外和右外交换两个表的顺序，可以实现同样的效果 
4. 全外连接=内连接的结果+表1中有但表2没有的+表2中有但表1没有的
```


```python
# 查询哪个部门没有员工
%sql select d.department_name from departments as d \
left join employees as e \
on d.department_id = e.department_id \
where e.employee_id is null;
```

     * mysql+pymysql://root@localhost/myemployees
    16 rows affected.





<table>
    <tr>
        <th>department_name</th>
    </tr>
    <tr>
        <td>Tre</td>
    </tr>
    <tr>
        <td>Cor</td>
    </tr>
    <tr>
        <td>Con</td>
    </tr>
    <tr>
        <td>Sha</td>
    </tr>
    <tr>
        <td>Ben</td>
    </tr>
    <tr>
        <td>Man</td>
    </tr>
    <tr>
        <td>Con</td>
    </tr>
    <tr>
        <td>Con</td>
    </tr>
    <tr>
        <td>Ope</td>
    </tr>
    <tr>
        <td>IT </td>
    </tr>
    <tr>
        <td>NOC</td>
    </tr>
    <tr>
        <td>IT </td>
    </tr>
    <tr>
        <td>Gov</td>
    </tr>
    <tr>
        <td>Ret</td>
    </tr>
    <tr>
        <td>Rec</td>
    </tr>
    <tr>
        <td>Pay</td>
    </tr>
</table>



# 子查询

含义：出现在其他语句中的select语句，称为子查询或内查询，外部的查询语句，称为主查询或外查询

分类：
```
按子查询出现的位置：
	select后面：
		仅仅支持标量子查询
	
	from后面：
		支持表子查询
        
	where或having后面：★
		标量子查询（单行） √
		列子查询  （多行） √
		行子查询
        表子查询
		
	exists后面（相关子查询）
		表子查询
按结果集的行列数不同：
	标量子查询（结果集只有一行一列）
	列子查询（结果集只有一列多行）
	行子查询（结果集有一行多列）
	表子查询（结果集一般为多行多列）

```

## where或having后面

1. 标量子查询（单值）
2. 列子查询（单列）
3. 行子查询（单行）
4. 行子查询（多行多列）

特点：
* 子查询放在小括号内
* 子查询一般放在条件的右侧
* 标量子查询，一般搭配着单行操作符使用: `> < >= <= = <>`

列子查询，一般搭配着多行操作符使用: in、any/some、all

子查询的执行优先于主查询执行，主查询的条件用到了子查询的结果

### 标量子查询

查询出一个值然后进行单值的比较, 一般搭配着单行操作符使用: > < >= <= = <>



```python
# 哪些人的工资比 Abel 高?
%sql select last_name from employees where salary > (select salary from employees where last_name="Abel");
```

     * mysql+pymysql://root@localhost/myemployees
    10 rows affected.





<table>
    <tr>
        <th>last_name</th>
    </tr>
    <tr>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>Kochhar</td>
    </tr>
    <tr>
        <td>De Haan</td>
    </tr>
    <tr>
        <td>Greenberg</td>
    </tr>
    <tr>
        <td>Russell</td>
    </tr>
    <tr>
        <td>Partners</td>
    </tr>
    <tr>
        <td>Errazuriz</td>
    </tr>
    <tr>
        <td>Ozer</td>
    </tr>
    <tr>
        <td>Hartstein</td>
    </tr>
    <tr>
        <td>Higgins</td>
    </tr>
</table>




```python
# 返回公司工资最少的员工的last_name,job_id和salary
%sql select last_name,job_id, salary from employees where salary = (select min(salary) from employees)
```

     * mysql+pymysql://root@localhost/myemployees
    1 rows affected.





<table>
    <tr>
        <th>last_name</th>
        <th>job_id</th>
        <th>salary</th>
    </tr>
    <tr>
        <td>Olson</td>
        <td>ST_CLERK</td>
        <td>2100.0</td>
    </tr>
</table>




```python
# 查询最低工资大于50号部门最低工资的部门id和其最低工资
%sql SELECT MIN(salary),department_id \
FROM employees \
GROUP BY department_id \
HAVING MIN(salary)>(\
    SELECT  MIN(salary) \
    FROM employees \
    WHERE department_id = 50 \
)
```

     * mysql+pymysql://root@localhost/myemployees
    11 rows affected.





<table>
    <tr>
        <th>MIN(salary)</th>
        <th>department_id</th>
    </tr>
    <tr>
        <td>7000.0</td>
        <td>None</td>
    </tr>
    <tr>
        <td>4400.0</td>
        <td>10</td>
    </tr>
    <tr>
        <td>6000.0</td>
        <td>20</td>
    </tr>
    <tr>
        <td>2500.0</td>
        <td>30</td>
    </tr>
    <tr>
        <td>6500.0</td>
        <td>40</td>
    </tr>
    <tr>
        <td>4200.0</td>
        <td>60</td>
    </tr>
    <tr>
        <td>10000.0</td>
        <td>70</td>
    </tr>
    <tr>
        <td>6100.0</td>
        <td>80</td>
    </tr>
    <tr>
        <td>17000.0</td>
        <td>90</td>
    </tr>
    <tr>
        <td>6900.0</td>
        <td>100</td>
    </tr>
    <tr>
        <td>8300.0</td>
        <td>110</td>
    </tr>
</table>



### 列子查询

因为列子查询是单列多行，所以一般搭配着多行操作符使用: in、any/some、all


```python
# 返回location_id是1400或1700的部门中的所有员工姓名
%sql select last_name from employees where department_id in (select department_id from departments where location_id in (1400, 1700))
```

     * mysql+pymysql://root@localhost/myemployees
    23 rows affected.





<table>
    <tr>
        <th>last_name</th>
    </tr>
    <tr>
        <td>Hunold</td>
    </tr>
    <tr>
        <td>Ernst</td>
    </tr>
    <tr>
        <td>Austin</td>
    </tr>
    <tr>
        <td>Pataballa</td>
    </tr>
    <tr>
        <td>Lorentz</td>
    </tr>
    <tr>
        <td>Whalen</td>
    </tr>
    <tr>
        <td>Raphaely</td>
    </tr>
    <tr>
        <td>Khoo</td>
    </tr>
    <tr>
        <td>Baida</td>
    </tr>
    <tr>
        <td>Tobias</td>
    </tr>
    <tr>
        <td>Himuro</td>
    </tr>
    <tr>
        <td>Colmenares</td>
    </tr>
    <tr>
        <td>K_ing</td>
    </tr>
    <tr>
        <td>Kochhar</td>
    </tr>
    <tr>
        <td>De Haan</td>
    </tr>
    <tr>
        <td>Greenberg</td>
    </tr>
    <tr>
        <td>Faviet</td>
    </tr>
    <tr>
        <td>Chen</td>
    </tr>
    <tr>
        <td>Sciarra</td>
    </tr>
    <tr>
        <td>Urman</td>
    </tr>
    <tr>
        <td>Popp</td>
    </tr>
    <tr>
        <td>Higgins</td>
    </tr>
    <tr>
        <td>Gietz</td>
    </tr>
</table>




```python
# 返回其它工种中比job_id为IT_PROG工种任一工资低的员工的员工号、姓名、job_id 以及salary
%sql select last_name,employee_id,job_id,salary from employees where salary < any( \
select distinct salary from employees where job_id="IT_PROG") and job_id != "IT_PROG"
```

     * mysql+pymysql://root@localhost/myemployees
    76 rows affected.





<table>
    <tr>
        <th>last_name</th>
        <th>employee_id</th>
        <th>job_id</th>
        <th>salary</th>
    </tr>
    <tr>
        <td>Chen</td>
        <td>110</td>
        <td>FI_ACCOUNT</td>
        <td>8200.0</td>
    </tr>
    <tr>
        <td>Sciarra</td>
        <td>111</td>
        <td>FI_ACCOUNT</td>
        <td>7700.0</td>
    </tr>
    <tr>
        <td>Urman</td>
        <td>112</td>
        <td>FI_ACCOUNT</td>
        <td>7800.0</td>
    </tr>
    <tr>
        <td>Popp</td>
        <td>113</td>
        <td>FI_ACCOUNT</td>
        <td>6900.0</td>
    </tr>
    <tr>
        <td>Khoo</td>
        <td>115</td>
        <td>PU_CLERK</td>
        <td>3100.0</td>
    </tr>
    <tr>
        <td>Baida</td>
        <td>116</td>
        <td>PU_CLERK</td>
        <td>2900.0</td>
    </tr>
    <tr>
        <td>Tobias</td>
        <td>117</td>
        <td>PU_CLERK</td>
        <td>2800.0</td>
    </tr>
    <tr>
        <td>Himuro</td>
        <td>118</td>
        <td>PU_CLERK</td>
        <td>2600.0</td>
    </tr>
    <tr>
        <td>Colmenares</td>
        <td>119</td>
        <td>PU_CLERK</td>
        <td>2500.0</td>
    </tr>
    <tr>
        <td>Weiss</td>
        <td>120</td>
        <td>ST_MAN</td>
        <td>8000.0</td>
    </tr>
    <tr>
        <td>Fripp</td>
        <td>121</td>
        <td>ST_MAN</td>
        <td>8200.0</td>
    </tr>
    <tr>
        <td>Kaufling</td>
        <td>122</td>
        <td>ST_MAN</td>
        <td>7900.0</td>
    </tr>
    <tr>
        <td>Vollman</td>
        <td>123</td>
        <td>ST_MAN</td>
        <td>6500.0</td>
    </tr>
    <tr>
        <td>Mourgos</td>
        <td>124</td>
        <td>ST_MAN</td>
        <td>5800.0</td>
    </tr>
    <tr>
        <td>Nayer</td>
        <td>125</td>
        <td>ST_CLERK</td>
        <td>3200.0</td>
    </tr>
    <tr>
        <td>Mikkilineni</td>
        <td>126</td>
        <td>ST_CLERK</td>
        <td>2700.0</td>
    </tr>
    <tr>
        <td>Landry</td>
        <td>127</td>
        <td>ST_CLERK</td>
        <td>2400.0</td>
    </tr>
    <tr>
        <td>Markle</td>
        <td>128</td>
        <td>ST_CLERK</td>
        <td>2200.0</td>
    </tr>
    <tr>
        <td>Bissot</td>
        <td>129</td>
        <td>ST_CLERK</td>
        <td>3300.0</td>
    </tr>
    <tr>
        <td>Atkinson</td>
        <td>130</td>
        <td>ST_CLERK</td>
        <td>2800.0</td>
    </tr>
    <tr>
        <td>Marlow</td>
        <td>131</td>
        <td>ST_CLERK</td>
        <td>2500.0</td>
    </tr>
    <tr>
        <td>Olson</td>
        <td>132</td>
        <td>ST_CLERK</td>
        <td>2100.0</td>
    </tr>
    <tr>
        <td>Mallin</td>
        <td>133</td>
        <td>ST_CLERK</td>
        <td>3300.0</td>
    </tr>
    <tr>
        <td>Rogers</td>
        <td>134</td>
        <td>ST_CLERK</td>
        <td>2900.0</td>
    </tr>
    <tr>
        <td>Gee</td>
        <td>135</td>
        <td>ST_CLERK</td>
        <td>2400.0</td>
    </tr>
    <tr>
        <td>Philtanker</td>
        <td>136</td>
        <td>ST_CLERK</td>
        <td>2200.0</td>
    </tr>
    <tr>
        <td>Ladwig</td>
        <td>137</td>
        <td>ST_CLERK</td>
        <td>3600.0</td>
    </tr>
    <tr>
        <td>Stiles</td>
        <td>138</td>
        <td>ST_CLERK</td>
        <td>3200.0</td>
    </tr>
    <tr>
        <td>Seo</td>
        <td>139</td>
        <td>ST_CLERK</td>
        <td>2700.0</td>
    </tr>
    <tr>
        <td>Patel</td>
        <td>140</td>
        <td>ST_CLERK</td>
        <td>2500.0</td>
    </tr>
    <tr>
        <td>Rajs</td>
        <td>141</td>
        <td>ST_CLERK</td>
        <td>3500.0</td>
    </tr>
    <tr>
        <td>Davies</td>
        <td>142</td>
        <td>ST_CLERK</td>
        <td>3100.0</td>
    </tr>
    <tr>
        <td>Matos</td>
        <td>143</td>
        <td>ST_CLERK</td>
        <td>2600.0</td>
    </tr>
    <tr>
        <td>Vargas</td>
        <td>144</td>
        <td>ST_CLERK</td>
        <td>2500.0</td>
    </tr>
    <tr>
        <td>Olsen</td>
        <td>153</td>
        <td>SA_REP</td>
        <td>8000.0</td>
    </tr>
    <tr>
        <td>Cambrault</td>
        <td>154</td>
        <td>SA_REP</td>
        <td>7500.0</td>
    </tr>
    <tr>
        <td>Tuvault</td>
        <td>155</td>
        <td>SA_REP</td>
        <td>7000.0</td>
    </tr>
    <tr>
        <td>Smith</td>
        <td>159</td>
        <td>SA_REP</td>
        <td>8000.0</td>
    </tr>
    <tr>
        <td>Doran</td>
        <td>160</td>
        <td>SA_REP</td>
        <td>7500.0</td>
    </tr>
    <tr>
        <td>Sewall</td>
        <td>161</td>
        <td>SA_REP</td>
        <td>7000.0</td>
    </tr>
    <tr>
        <td>Marvins</td>
        <td>164</td>
        <td>SA_REP</td>
        <td>7200.0</td>
    </tr>
    <tr>
        <td>Lee</td>
        <td>165</td>
        <td>SA_REP</td>
        <td>6800.0</td>
    </tr>
    <tr>
        <td>Ande</td>
        <td>166</td>
        <td>SA_REP</td>
        <td>6400.0</td>
    </tr>
    <tr>
        <td>Banda</td>
        <td>167</td>
        <td>SA_REP</td>
        <td>6200.0</td>
    </tr>
    <tr>
        <td>Smith</td>
        <td>171</td>
        <td>SA_REP</td>
        <td>7400.0</td>
    </tr>
    <tr>
        <td>Bates</td>
        <td>172</td>
        <td>SA_REP</td>
        <td>7300.0</td>
    </tr>
    <tr>
        <td>Kumar</td>
        <td>173</td>
        <td>SA_REP</td>
        <td>6100.0</td>
    </tr>
    <tr>
        <td>Hutton</td>
        <td>175</td>
        <td>SA_REP</td>
        <td>8800.0</td>
    </tr>
    <tr>
        <td>Taylor</td>
        <td>176</td>
        <td>SA_REP</td>
        <td>8600.0</td>
    </tr>
    <tr>
        <td>Livingston</td>
        <td>177</td>
        <td>SA_REP</td>
        <td>8400.0</td>
    </tr>
    <tr>
        <td>Grant</td>
        <td>178</td>
        <td>SA_REP</td>
        <td>7000.0</td>
    </tr>
    <tr>
        <td>Johnson</td>
        <td>179</td>
        <td>SA_REP</td>
        <td>6200.0</td>
    </tr>
    <tr>
        <td>Taylor</td>
        <td>180</td>
        <td>SH_CLERK</td>
        <td>3200.0</td>
    </tr>
    <tr>
        <td>Fleaur</td>
        <td>181</td>
        <td>SH_CLERK</td>
        <td>3100.0</td>
    </tr>
    <tr>
        <td>Sullivan</td>
        <td>182</td>
        <td>SH_CLERK</td>
        <td>2500.0</td>
    </tr>
    <tr>
        <td>Geoni</td>
        <td>183</td>
        <td>SH_CLERK</td>
        <td>2800.0</td>
    </tr>
    <tr>
        <td>Sarchand</td>
        <td>184</td>
        <td>SH_CLERK</td>
        <td>4200.0</td>
    </tr>
    <tr>
        <td>Bull</td>
        <td>185</td>
        <td>SH_CLERK</td>
        <td>4100.0</td>
    </tr>
    <tr>
        <td>Dellinger</td>
        <td>186</td>
        <td>SH_CLERK</td>
        <td>3400.0</td>
    </tr>
    <tr>
        <td>Cabrio</td>
        <td>187</td>
        <td>SH_CLERK</td>
        <td>3000.0</td>
    </tr>
    <tr>
        <td>Chung</td>
        <td>188</td>
        <td>SH_CLERK</td>
        <td>3800.0</td>
    </tr>
    <tr>
        <td>Dilly</td>
        <td>189</td>
        <td>SH_CLERK</td>
        <td>3600.0</td>
    </tr>
    <tr>
        <td>Gates</td>
        <td>190</td>
        <td>SH_CLERK</td>
        <td>2900.0</td>
    </tr>
    <tr>
        <td>Perkins</td>
        <td>191</td>
        <td>SH_CLERK</td>
        <td>2500.0</td>
    </tr>
    <tr>
        <td>Bell</td>
        <td>192</td>
        <td>SH_CLERK</td>
        <td>4000.0</td>
    </tr>
    <tr>
        <td>Everett</td>
        <td>193</td>
        <td>SH_CLERK</td>
        <td>3900.0</td>
    </tr>
    <tr>
        <td>McCain</td>
        <td>194</td>
        <td>SH_CLERK</td>
        <td>3200.0</td>
    </tr>
    <tr>
        <td>Jones</td>
        <td>195</td>
        <td>SH_CLERK</td>
        <td>2800.0</td>
    </tr>
    <tr>
        <td>Walsh</td>
        <td>196</td>
        <td>SH_CLERK</td>
        <td>3100.0</td>
    </tr>
    <tr>
        <td>Feeney</td>
        <td>197</td>
        <td>SH_CLERK</td>
        <td>3000.0</td>
    </tr>
    <tr>
        <td>OConnell</td>
        <td>198</td>
        <td>SH_CLERK</td>
        <td>2600.0</td>
    </tr>
    <tr>
        <td>Grant</td>
        <td>199</td>
        <td>SH_CLERK</td>
        <td>2600.0</td>
    </tr>
    <tr>
        <td>Whalen</td>
        <td>200</td>
        <td>AD_ASST</td>
        <td>4400.0</td>
    </tr>
    <tr>
        <td>Fay</td>
        <td>202</td>
        <td>MK_REP</td>
        <td>6000.0</td>
    </tr>
    <tr>
        <td>Mavris</td>
        <td>203</td>
        <td>HR_REP</td>
        <td>6500.0</td>
    </tr>
    <tr>
        <td>Gietz</td>
        <td>206</td>
        <td>AC_ACCOUNT</td>
        <td>8300.0</td>
    </tr>
</table>




```python
# 返回其它部门中比job_id为‘IT_PROG’部门所有工资都低的员工的员工号、姓名、job_id 以及salary
%sql select last_name,employee_id,job_id,salary from employees where salary < all( \
select distinct salary from employees where job_id="IT_PROG") and job_id != "IT_PROG"
```

     * mysql+pymysql://root@localhost/myemployees
    44 rows affected.





<table>
    <tr>
        <th>last_name</th>
        <th>employee_id</th>
        <th>job_id</th>
        <th>salary</th>
    </tr>
    <tr>
        <td>Khoo</td>
        <td>115</td>
        <td>PU_CLERK</td>
        <td>3100.0</td>
    </tr>
    <tr>
        <td>Baida</td>
        <td>116</td>
        <td>PU_CLERK</td>
        <td>2900.0</td>
    </tr>
    <tr>
        <td>Tobias</td>
        <td>117</td>
        <td>PU_CLERK</td>
        <td>2800.0</td>
    </tr>
    <tr>
        <td>Himuro</td>
        <td>118</td>
        <td>PU_CLERK</td>
        <td>2600.0</td>
    </tr>
    <tr>
        <td>Colmenares</td>
        <td>119</td>
        <td>PU_CLERK</td>
        <td>2500.0</td>
    </tr>
    <tr>
        <td>Nayer</td>
        <td>125</td>
        <td>ST_CLERK</td>
        <td>3200.0</td>
    </tr>
    <tr>
        <td>Mikkilineni</td>
        <td>126</td>
        <td>ST_CLERK</td>
        <td>2700.0</td>
    </tr>
    <tr>
        <td>Landry</td>
        <td>127</td>
        <td>ST_CLERK</td>
        <td>2400.0</td>
    </tr>
    <tr>
        <td>Markle</td>
        <td>128</td>
        <td>ST_CLERK</td>
        <td>2200.0</td>
    </tr>
    <tr>
        <td>Bissot</td>
        <td>129</td>
        <td>ST_CLERK</td>
        <td>3300.0</td>
    </tr>
    <tr>
        <td>Atkinson</td>
        <td>130</td>
        <td>ST_CLERK</td>
        <td>2800.0</td>
    </tr>
    <tr>
        <td>Marlow</td>
        <td>131</td>
        <td>ST_CLERK</td>
        <td>2500.0</td>
    </tr>
    <tr>
        <td>Olson</td>
        <td>132</td>
        <td>ST_CLERK</td>
        <td>2100.0</td>
    </tr>
    <tr>
        <td>Mallin</td>
        <td>133</td>
        <td>ST_CLERK</td>
        <td>3300.0</td>
    </tr>
    <tr>
        <td>Rogers</td>
        <td>134</td>
        <td>ST_CLERK</td>
        <td>2900.0</td>
    </tr>
    <tr>
        <td>Gee</td>
        <td>135</td>
        <td>ST_CLERK</td>
        <td>2400.0</td>
    </tr>
    <tr>
        <td>Philtanker</td>
        <td>136</td>
        <td>ST_CLERK</td>
        <td>2200.0</td>
    </tr>
    <tr>
        <td>Ladwig</td>
        <td>137</td>
        <td>ST_CLERK</td>
        <td>3600.0</td>
    </tr>
    <tr>
        <td>Stiles</td>
        <td>138</td>
        <td>ST_CLERK</td>
        <td>3200.0</td>
    </tr>
    <tr>
        <td>Seo</td>
        <td>139</td>
        <td>ST_CLERK</td>
        <td>2700.0</td>
    </tr>
    <tr>
        <td>Patel</td>
        <td>140</td>
        <td>ST_CLERK</td>
        <td>2500.0</td>
    </tr>
    <tr>
        <td>Rajs</td>
        <td>141</td>
        <td>ST_CLERK</td>
        <td>3500.0</td>
    </tr>
    <tr>
        <td>Davies</td>
        <td>142</td>
        <td>ST_CLERK</td>
        <td>3100.0</td>
    </tr>
    <tr>
        <td>Matos</td>
        <td>143</td>
        <td>ST_CLERK</td>
        <td>2600.0</td>
    </tr>
    <tr>
        <td>Vargas</td>
        <td>144</td>
        <td>ST_CLERK</td>
        <td>2500.0</td>
    </tr>
    <tr>
        <td>Taylor</td>
        <td>180</td>
        <td>SH_CLERK</td>
        <td>3200.0</td>
    </tr>
    <tr>
        <td>Fleaur</td>
        <td>181</td>
        <td>SH_CLERK</td>
        <td>3100.0</td>
    </tr>
    <tr>
        <td>Sullivan</td>
        <td>182</td>
        <td>SH_CLERK</td>
        <td>2500.0</td>
    </tr>
    <tr>
        <td>Geoni</td>
        <td>183</td>
        <td>SH_CLERK</td>
        <td>2800.0</td>
    </tr>
    <tr>
        <td>Bull</td>
        <td>185</td>
        <td>SH_CLERK</td>
        <td>4100.0</td>
    </tr>
    <tr>
        <td>Dellinger</td>
        <td>186</td>
        <td>SH_CLERK</td>
        <td>3400.0</td>
    </tr>
    <tr>
        <td>Cabrio</td>
        <td>187</td>
        <td>SH_CLERK</td>
        <td>3000.0</td>
    </tr>
    <tr>
        <td>Chung</td>
        <td>188</td>
        <td>SH_CLERK</td>
        <td>3800.0</td>
    </tr>
    <tr>
        <td>Dilly</td>
        <td>189</td>
        <td>SH_CLERK</td>
        <td>3600.0</td>
    </tr>
    <tr>
        <td>Gates</td>
        <td>190</td>
        <td>SH_CLERK</td>
        <td>2900.0</td>
    </tr>
    <tr>
        <td>Perkins</td>
        <td>191</td>
        <td>SH_CLERK</td>
        <td>2500.0</td>
    </tr>
    <tr>
        <td>Bell</td>
        <td>192</td>
        <td>SH_CLERK</td>
        <td>4000.0</td>
    </tr>
    <tr>
        <td>Everett</td>
        <td>193</td>
        <td>SH_CLERK</td>
        <td>3900.0</td>
    </tr>
    <tr>
        <td>McCain</td>
        <td>194</td>
        <td>SH_CLERK</td>
        <td>3200.0</td>
    </tr>
    <tr>
        <td>Jones</td>
        <td>195</td>
        <td>SH_CLERK</td>
        <td>2800.0</td>
    </tr>
    <tr>
        <td>Walsh</td>
        <td>196</td>
        <td>SH_CLERK</td>
        <td>3100.0</td>
    </tr>
    <tr>
        <td>Feeney</td>
        <td>197</td>
        <td>SH_CLERK</td>
        <td>3000.0</td>
    </tr>
    <tr>
        <td>OConnell</td>
        <td>198</td>
        <td>SH_CLERK</td>
        <td>2600.0</td>
    </tr>
    <tr>
        <td>Grant</td>
        <td>199</td>
        <td>SH_CLERK</td>
        <td>2600.0</td>
    </tr>
</table>



### 行子查询


```python
# 查询员工编号最小并且工资最高的员工信息
"""
SELECT *
FROM employees
WHERE employee_id=(
    SELECT MIN(employee_id)
    FROM employees


)AND salary=(
    SELECT MAX(salary)
    FROM employees
);
"""
%sql SELECT * \
FROM employees \
WHERE (employee_id,salary)=( \
    SELECT MIN(employee_id),MAX(salary) \
    FROM employees \
);
```

     * mysql+pymysql://root@localhost/myemployees
    1 rows affected.





<table>
    <tr>
        <th>employee_id</th>
        <th>first_name</th>
        <th>last_name</th>
        <th>email</th>
        <th>phone_number</th>
        <th>job_id</th>
        <th>salary</th>
        <th>commission_pct</th>
        <th>manager_id</th>
        <th>department_id</th>
        <th>hiredate</th>
    </tr>
    <tr>
        <td>100</td>
        <td>Steven</td>
        <td>K_ing</td>
        <td>SKING</td>
        <td>515.123.4567</td>
        <td>AD_PRES</td>
        <td>24000.0</td>
        <td>None</td>
        <td>None</td>
        <td>90</td>
        <td>1992-04-03 00:00:00</td>
    </tr>
</table>



## select后面

仅仅支持标量子查询, 可以用于补充列


```python
# 查询每个部门的员工个数
%sql select d.*,(select count(*) from employees e where e.department_id=d.department_id) 员工个数 from departments d
```

     * mysql+pymysql://root@localhost/myemployees
    27 rows affected.





<table>
    <tr>
        <th>department_id</th>
        <th>department_name</th>
        <th>manager_id</th>
        <th>location_id</th>
        <th>员工个数</th>
    </tr>
    <tr>
        <td>10</td>
        <td>Adm</td>
        <td>200</td>
        <td>1700</td>
        <td>1</td>
    </tr>
    <tr>
        <td>20</td>
        <td>Mar</td>
        <td>201</td>
        <td>1800</td>
        <td>2</td>
    </tr>
    <tr>
        <td>30</td>
        <td>Pur</td>
        <td>114</td>
        <td>1700</td>
        <td>6</td>
    </tr>
    <tr>
        <td>40</td>
        <td>Hum</td>
        <td>203</td>
        <td>2400</td>
        <td>1</td>
    </tr>
    <tr>
        <td>50</td>
        <td>Shi</td>
        <td>121</td>
        <td>1500</td>
        <td>45</td>
    </tr>
    <tr>
        <td>60</td>
        <td>IT</td>
        <td>103</td>
        <td>1400</td>
        <td>5</td>
    </tr>
    <tr>
        <td>70</td>
        <td>Pub</td>
        <td>204</td>
        <td>2700</td>
        <td>1</td>
    </tr>
    <tr>
        <td>80</td>
        <td>Sal</td>
        <td>145</td>
        <td>2500</td>
        <td>34</td>
    </tr>
    <tr>
        <td>90</td>
        <td>Exe</td>
        <td>100</td>
        <td>1700</td>
        <td>3</td>
    </tr>
    <tr>
        <td>100</td>
        <td>Fin</td>
        <td>108</td>
        <td>1700</td>
        <td>6</td>
    </tr>
    <tr>
        <td>110</td>
        <td>Acc</td>
        <td>205</td>
        <td>1700</td>
        <td>2</td>
    </tr>
    <tr>
        <td>120</td>
        <td>Tre</td>
        <td>None</td>
        <td>1700</td>
        <td>0</td>
    </tr>
    <tr>
        <td>130</td>
        <td>Cor</td>
        <td>None</td>
        <td>1700</td>
        <td>0</td>
    </tr>
    <tr>
        <td>140</td>
        <td>Con</td>
        <td>None</td>
        <td>1700</td>
        <td>0</td>
    </tr>
    <tr>
        <td>150</td>
        <td>Sha</td>
        <td>None</td>
        <td>1700</td>
        <td>0</td>
    </tr>
    <tr>
        <td>160</td>
        <td>Ben</td>
        <td>None</td>
        <td>1700</td>
        <td>0</td>
    </tr>
    <tr>
        <td>170</td>
        <td>Man</td>
        <td>None</td>
        <td>1700</td>
        <td>0</td>
    </tr>
    <tr>
        <td>180</td>
        <td>Con</td>
        <td>None</td>
        <td>1700</td>
        <td>0</td>
    </tr>
    <tr>
        <td>190</td>
        <td>Con</td>
        <td>None</td>
        <td>1700</td>
        <td>0</td>
    </tr>
    <tr>
        <td>200</td>
        <td>Ope</td>
        <td>None</td>
        <td>1700</td>
        <td>0</td>
    </tr>
    <tr>
        <td>210</td>
        <td>IT </td>
        <td>None</td>
        <td>1700</td>
        <td>0</td>
    </tr>
    <tr>
        <td>220</td>
        <td>NOC</td>
        <td>None</td>
        <td>1700</td>
        <td>0</td>
    </tr>
    <tr>
        <td>230</td>
        <td>IT </td>
        <td>None</td>
        <td>1700</td>
        <td>0</td>
    </tr>
    <tr>
        <td>240</td>
        <td>Gov</td>
        <td>None</td>
        <td>1700</td>
        <td>0</td>
    </tr>
    <tr>
        <td>250</td>
        <td>Ret</td>
        <td>None</td>
        <td>1700</td>
        <td>0</td>
    </tr>
    <tr>
        <td>260</td>
        <td>Rec</td>
        <td>None</td>
        <td>1700</td>
        <td>0</td>
    </tr>
    <tr>
        <td>270</td>
        <td>Pay</td>
        <td>None</td>
        <td>1700</td>
        <td>0</td>
    </tr>
</table>



## from后面

将子查询结果充当一张表，要求必须起别名


```python
# 查询每个部门的平均工资的工资等级
%sql select * from job_grades inner join \
(select avg(salary) as av from employees group by department_id) as ag \
on ag.av between lowest_sal AND highest_sal;
```

     * mysql+pymysql://root@localhost/myemployees
    12 rows affected.





<table>
    <tr>
        <th>grade_level</th>
        <th>lowest_sal</th>
        <th>highest_sal</th>
        <th>av</th>
    </tr>
    <tr>
        <td>C</td>
        <td>6000</td>
        <td>9999</td>
        <td>7000.0</td>
    </tr>
    <tr>
        <td>B</td>
        <td>3000</td>
        <td>5999</td>
        <td>4400.0</td>
    </tr>
    <tr>
        <td>C</td>
        <td>6000</td>
        <td>9999</td>
        <td>9500.0</td>
    </tr>
    <tr>
        <td>B</td>
        <td>3000</td>
        <td>5999</td>
        <td>4150.0</td>
    </tr>
    <tr>
        <td>C</td>
        <td>6000</td>
        <td>9999</td>
        <td>6500.0</td>
    </tr>
    <tr>
        <td>B</td>
        <td>3000</td>
        <td>5999</td>
        <td>3475.555556</td>
    </tr>
    <tr>
        <td>B</td>
        <td>3000</td>
        <td>5999</td>
        <td>5760.0</td>
    </tr>
    <tr>
        <td>D</td>
        <td>10000</td>
        <td>14999</td>
        <td>10000.0</td>
    </tr>
    <tr>
        <td>C</td>
        <td>6000</td>
        <td>9999</td>
        <td>8955.882353</td>
    </tr>
    <tr>
        <td>E</td>
        <td>15000</td>
        <td>24999</td>
        <td>19333.333333</td>
    </tr>
    <tr>
        <td>C</td>
        <td>6000</td>
        <td>9999</td>
        <td>8600.0</td>
    </tr>
    <tr>
        <td>D</td>
        <td>10000</td>
        <td>14999</td>
        <td>10150.0</td>
    </tr>
</table>



## exists后面（相关子查询）

exists(完整的查询语句):结果为1或0(true和false).

相关子查询的"相关"体现在需要用到主查询的表。



```python
# 查询有员工的部门名
%sql select department_name from departments where exists \
(select * from employees where employees.department_id=departments.department_id)
```

     * mysql+pymysql://root@localhost/myemployees
    11 rows affected.





<table>
    <tr>
        <th>department_name</th>
    </tr>
    <tr>
        <td>Adm</td>
    </tr>
    <tr>
        <td>Mar</td>
    </tr>
    <tr>
        <td>Pur</td>
    </tr>
    <tr>
        <td>Hum</td>
    </tr>
    <tr>
        <td>Shi</td>
    </tr>
    <tr>
        <td>IT</td>
    </tr>
    <tr>
        <td>Pub</td>
    </tr>
    <tr>
        <td>Sal</td>
    </tr>
    <tr>
        <td>Exe</td>
    </tr>
    <tr>
        <td>Fin</td>
    </tr>
    <tr>
        <td>Acc</td>
    </tr>
</table>



# 分页查询

应用场景：当要显示的数据，一页显示不全，需要分页提交sql请求
语法：
```
	select 查询列表
	from 表
	【join type join 表2
	on 连接条件
	where 筛选条件
	group by 分组字段
	having 分组后的筛选
	order by 排序的字段】
	limit 【offset,】size;
	
	offset要显示条目的起始索引（起始索引从0开始）
	size 要显示的条目个数
```
特点：
```
	1. limit语句放在查询语句的最后
	2. 公式
	要显示的页数 page，每页的条目数size
	
	select 查询列表
	from 表
	limit (page-1)*size,size;
	
	size=10
	page  
	1	0
	2    10
	3	20
```


```python
# 查询第11条——第25条(25-14+1 总共15条)
%sql select * from departments limit 10,15;
```

     * mysql+pymysql://root@localhost/myemployees
    15 rows affected.





<table>
    <tr>
        <th>department_id</th>
        <th>department_name</th>
        <th>manager_id</th>
        <th>location_id</th>
    </tr>
    <tr>
        <td>110</td>
        <td>Acc</td>
        <td>205</td>
        <td>1700</td>
    </tr>
    <tr>
        <td>120</td>
        <td>Tre</td>
        <td>None</td>
        <td>1700</td>
    </tr>
    <tr>
        <td>130</td>
        <td>Cor</td>
        <td>None</td>
        <td>1700</td>
    </tr>
    <tr>
        <td>140</td>
        <td>Con</td>
        <td>None</td>
        <td>1700</td>
    </tr>
    <tr>
        <td>150</td>
        <td>Sha</td>
        <td>None</td>
        <td>1700</td>
    </tr>
    <tr>
        <td>160</td>
        <td>Ben</td>
        <td>None</td>
        <td>1700</td>
    </tr>
    <tr>
        <td>170</td>
        <td>Man</td>
        <td>None</td>
        <td>1700</td>
    </tr>
    <tr>
        <td>180</td>
        <td>Con</td>
        <td>None</td>
        <td>1700</td>
    </tr>
    <tr>
        <td>190</td>
        <td>Con</td>
        <td>None</td>
        <td>1700</td>
    </tr>
    <tr>
        <td>200</td>
        <td>Ope</td>
        <td>None</td>
        <td>1700</td>
    </tr>
    <tr>
        <td>210</td>
        <td>IT </td>
        <td>None</td>
        <td>1700</td>
    </tr>
    <tr>
        <td>220</td>
        <td>NOC</td>
        <td>None</td>
        <td>1700</td>
    </tr>
    <tr>
        <td>230</td>
        <td>IT </td>
        <td>None</td>
        <td>1700</td>
    </tr>
    <tr>
        <td>240</td>
        <td>Gov</td>
        <td>None</td>
        <td>1700</td>
    </tr>
    <tr>
        <td>250</td>
        <td>Ret</td>
        <td>None</td>
        <td>1700</td>
    </tr>
</table>



# 联合查询

union 联合 合并：将多条查询语句的结果合并成一个结果

语法：
```
查询语句1
union
查询语句2
union
...
```


应用场景：
要查询的结果来自于多个表，且多个表没有直接的连接关系，但查询的信息一致时

特点：
1. 要求多条查询语句的查询列数是一致的！
2. 要求多条查询语句的查询的每一列的类型和顺序最好一致, 这样才有实际意义
3. union关键字默认去重，如果使用union all 可以包含重复项


```python
# 查询中国用户中男性的信息以及外国用户中年男性的用户信息, 下面sql语句得到的表的列名是id cname
%sql SELECT id,cname FROM t_ca WHERE csex='男'
UNION ALL
SELECT t_id,tname FROM t_ua WHERE tGender='male';
```
