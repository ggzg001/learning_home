# 介绍

ansible 是用于批量在远程主机上执行命令，连接方式使用ssh. ansible的主机角色大致分为两种：一台管理机和多台被管控机。

要想使用ansible去管理被管控机,  那么就管控机就必须能登录上被管控机，也就是ssh无密码登录。

ssh的登录方式有2种：

* 密码登录
* 秘钥登录

免密码的秘钥登录：

```
ssh-keygen # 用来生成ssh的密钥对
ssh-copy-id 192.168.107.131 # 复制秘钥到远程主机
ssh root@192.168.107.131  # 无密码登录即可
```

# ansible 命令格式

查看ansible生成的文件

```shell
[root@localhost ~]# rpm -ql ansible | more
/etc/ansible
/etc/ansible/ansible.cfg
/etc/ansible/hosts
/etc/ansible/roles
...
```

```shell
ansible <host-pattern> [options]

options:
-a MODULE_ARGS, --args=MODULE_ARGS #模块的参数
-C, --check # 检查
-f FORKS, --forks=FORKS #用来做高并发的
--list-hosts #列出主机列表
-m MODULE_NAME #模块名称
--syntax-check # 语法检查
-k 输入密码
```

使用ansible的第一件事就是修改/etc/ansible/hosts文件，hosts文件格式如下

```shell
# This is the default ansible 'hosts' file.
#
# It should live in /etc/ansible/hosts
#
#   - Comments begin with the '#' character # 用#来表示注释
#   - Blank lines are ignored # 空白行被忽略
#   - Groups of hosts are delimited by [header] elements # 主机组 需要在[]下面
#   - You can enter hostnames or ip addresses #可以写主机名或者ip地址
#   - A hostname/ip can be a member of multiple groups # 一台主机可以在多个组里面
# 001:006表示切片
www[001:006].example.com #表示从www001到www006的机器
```

host-pattern的格式

- 单个的主机： 指定ip即可
- 全部主机: all 关键字
- 多个的主机: 用逗号分隔
- 单个组：指定组名
- 多个组
  - 交集  web: &db: 主机既在web又在db组
  - 并集
    - web, db: web和db组有的主机的合
    - web: db
  - 差集  web: !db:  web组有的主机但是db组没有的主机

host-pattern的分组在日常的运维开发中使用的还是比较多的。

# ansible-doc 

ansible-doc 用来查看模块的帮助信息

```shell
ansible-doc [-l|-s] [options] [-t <plugin type] [plugin]

options:
-j # 以json的方式返回ansible的所有模块
-l, --list # 列出所有的ansible的模块
-s # 以片段式显示ansible某个模块的帮助信息
```

例如，想要查看command模块的一些帮助

```shell
[root@localhost ~]# ansible-doc -s command
- name: Executes a command on a remote node
  command:
      chdir:                 # Change into this directory before running the command.
      creates:               # A filename or (since 2.0) glob pattern, when it already exists, this step will *not* be run.
      free_form:             # (required) The command module takes a free form command to run.  There is no parameter actually named 'free form'. See the examples!
      removes:               # A filename or (since 2.0) glob pattern, when it does not exist, this step will *not* be run.
      stdin:                 # Set the stdin of the command directly to the specified value.
      warn:                  # If command_warnings are on in ansible.cfg, do not warn about this particular line if set to `no'.
```

# 模块

ansible提供了一系列的模块用于方便地管理被管控机，例如有一个模块叫shell, 就是用来在被管控机去执行shell命令的，还有默认的模块command也是类似的功能。

## 命令相关模块

### command

command是默认使用的模块，也就是说使用ansible 的时候不需要使用-m参数去指定模块。

```shell
[root@localhost ~]# ansible-doc -s command
- name: Executes a command on a remote node
  command:
      chdir:                 # Change into this directory before running the command.
      creates:               # A filename or (since 2.0) glob pattern, when it already exists, this step will *not* be run.
      free_form:             # (required) The command module takes a free form command to run.  There is no parameter actually named 'free form'. See the examples!
      removes:               # A filename or (since 2.0) glob pattern, when it does not exist, this step will *not* be run.
      stdin:                 # Set the stdin of the command directly to the specified value.
      warn:                  # If command_warnings are on in ansible.cfg, do not warn about this particular line if set to `no'.
```

一般关注的参数有chdir,creates, removes.

其中creates和removes和容易弄混, 其实只需要记住两者的定义：

 creates:  A filename or (since 2.0) glob pattern, when it already exists, this step will *not* be run.

removes:  A filename or (since 2.0) glob pattern, when it does not exist, this step will *not* be run.

发现两者的最后一句都是不执行，只不过 creates根据含义是存在不执行，removes根据含义是不存在才不执行。

例子：

```shell
ansible web -a 'ls /'#第一个命令
ansible web -a 'pwd'
ansible web -a 'chdir=/tmp pwd'# 切换目录执行命令，使用场景是编译安装时使用
ansible web -a 'creates=/tmp pwd' # 用来判断/tmp目录是否存在，存在就不执行操作
ansible web -a 'creates=/data pwd' # 因为data不存在，所有才会执行pwd命令
ansible web -a 'removes=/tmp pwd' #用来判断tmp目录是否存在，存在就执行操作
ansible web -a 'removes=/data pwd' #因为data不存在，所有才不会执行
```

### shell

一般情况下，简单执行linux命令使用command模块即可。但是command的命令中不能带有特殊字符比如 |  <  > 等，所以有一个比它规整更少的模块shell.

```shell
[root@localhost ~]# ansible-doc -s shell
- name: Execute commands in nodes.
  shell:
      chdir:                 # cd into this directory before running the command
      creates:               # a filename, when it already exists, this step will *not* be run.
      executable:            # change the shell used to execute the command. Should be an absolute path to the executable.
      free_form:             # (required) The shell module takes a free form command to run, as a string.  There's not an actual option named "free form".  See the examples!
      removes:               # a filename, when it does not exist, this step will *not* be run.
      stdin:                 # Set the stdin of the command directly to the specified value.
      warn:                  # if command warnings are on in ansible.cfg, do not warn about this particular line if set to no/false.
```

```shell
 ansible web -m shell -a 'echo "123" | passwd --stdin jack' # 批量创建密码
 ansible 192.168.107.131 -m shell -a 'bash a.sh' # 执行远程文件方式一, 文件可以没有执行权限
 ansible 192.168.107.131 -m shell -a '/root/a.sh' # 执行远程文件方式二, 文件必须有执行权限
 ansible 192.168.107.131 -m shell -a 'python /root/a.py' # 执行远端的Python脚本
```

### script

```shell
[root@localhost ~]# ansible-doc -s script
- name: Runs a local script on a remote node after transferring it
  script:
      chdir:                 # cd into this directory on the remote node before running the script
      creates:               # a filename, when it already exists, this step will *not* be run.
      decrypt:               # This option controls the autodecryption of source files using vault.
      free_form:             # (required) Path to the local script file followed by optional arguments. There is no parameter actually named 'free form'; see the examples!
      removes:               # a filename, when it does not exist, this step will *not* be run.
```

script是用来执行shell脚本的，shell脚本放置在管控机上，不需要把shell脚本拷贝到被管控机后使用shell模块去执行，但是shell脚本的执行还是在被管控机上去执行的。

```shell
ansible web -m script -a '/root/m.sh' # 执行本地的文件，执行管控机上的文件
ansible web -m script -a 'removes=/root/m.sh /root/m.sh' # 用来判断被管控机上是不是存在文件，如果存在，存在就执行，不存在就不执行
ansible web -m script -a 'creates=/root/a.sh /root/m.sh' #用来判断被管控机上是不是存在文件，如果存在，就不执行
```

## 文件相关模块

### copy

copy模块用于拷贝控制机的目录或文件到被管控机，并可以修改复制到被管控机的文件或目录的一些属性，比如权限、属主等。

copy模块有如下几个参数是比较常用的：

```
dest 目的地址
group 文件的属组
mode 文件的权限 r 4 w 2 x 1
owner 文件的属主
content 内容
src 源文件
```

```shell
# 通过md5码来判断是否需要复制,重复调用下面的命令两次发现返回的结果颜色是不一样的，也就是说第一次进行了copy，第二次检查内容没有发生改变就没有进行copy操作了
ansible db -m copy -a 'src=/root/m.sh dest=/tmp/a.sh' # 复制本地文件的到远程主机
ansible db -m copy -a 'src=/root/m.sh dest=/tmp/a.sh mode=755' # 修改文件的权限
ansible web -m copy -a 'src=/root/m.sh dest=/tmp/a.sh mode=755 owner=jack' 修改文件的属主
ansible web -m copy -a 'src=/etc/init.d dest=/tmp/ mode=755 owner=alex' # 复制本地目录到远程主机，如果改变文件的属性，则文件夹内的文件也会被改变, 复制成功后 /tmp 目录
ansible web -m copy -a 'src=/etc/init.d/ dest=/tmp/ mode=755 owner=alex' # 复制本地目录内的所有文件到远程主机
ansible web -m copy -a "content='大弦嘈嘈如急雨，小弦切切如私语\n' dest=/tmp/b.txt" # 直接将文本内容注入到远程主机的文件中
```

### file

file模块用于在被管控机上创建文件、文件夹或删除文件、文件夹等，以及创建软硬链接等。

```
ln -s a.py b.py 创建软连接(真实的数据源是a.py)
ln a.py c.py 创建硬链接
当 源文件变化时，软连接和硬链接文件都会跟着变化, 硬链接相当于多了一个引用, 类似于python中a=1, b=a
```

常用参数：

```
path
state
```

```shell
ansible db -m file -a 'path=/lzmly2  state=directory' #在远程机器上创建文件夹
ansible db -m file -a 'path=/root/q.txt  state=touch' #用来在远程机器上创建文件
ansible db -m file -a 'path=/tmp/f src=/etc/fstab state=link' #创建软连接src是源地址，path是目标地址
ansible db -m file -a 'path=/tmp/f state=absent' #用来删除文件或者文件夹
```

### fetch

fetch模块用于获取被管控机的文件到管控机，比如管控机想要做日志收集，可以把被管控机的相应的日志文件拿到本地管控机做统一处理。

常用的参数：

```
dest 目的地址
src 源地址
```

```shell
ansible web -m fetch -a 'src=/var/log/cron dest=/tmp' # 下载被控节点的文件，为web下的每台机器创建一个文件夹(以ip命名)，ip命名的文件夹里保留原来的目录结构
```

## 软件安装相关

### yum

包组是一系列软件的集合

```
yum grouplist # 查看包组信息
yum groupinstall 包名 # 安装包组
```

常用参数:

```shell
disablerepo   # 禁用源
enablerepo   # 启用源
name   # 包名
state  install (`present' or `installed', `latest'), or remove (`absent' or `removed')
```

```shell
ansible web -m yum -a 'name=wget' # 安装wget
ansible web -m yum -a 'name=python2-pip' # 安装python2-pip
ansible web -m yum -a 'name=wget state=absent' # 卸载软件包
ansible web -m yum -a 'name="@Development Tools"' # 安装包组
```

### pip

```
pip install 安装包
pip freeze > a.txt 将python的环境打包到文件中
pip install -r a.txt 安装文件中的包
pip list 查看所有的以安装成功的包
```

参数：

```shell
– chdir： 执行pip命令前cd进入的目录 
– name：要安装的Python库的名称或远程包的URL。 
– requirements：一个pip requirements.txt文件的路径，它应该是远程系统的本地文件，如果使用chdir选项，则可以将文件指定为相对路径。 
– version：指定的Python库的安装版本。 
– extra_args：额外的参数传递给pip。 
– executable：显式可执行文件或可执行文件的路径名，用于为系统中安装的特定版本的Python运行pip。 例如pip-3.3，如果系统中安装了Python 2.7和3.3，并且想要为Python 3.3安装运行pip。 它不能与“virtualenv”参数一起指定（在2.1中添加）。 默认情况下，它将采用适用于python解释器的版本。 pip3在python 3上，pip2或pip在python 2上。 
– virtualenv：要安装到的virtualenv目录的可选路径。 它不能与’executable’参数一起指定（在2.1中添加）。 如果virtualenv不存在，则将在安装软件包之前创建它。 可选的virtualenv_site_packages，virtualenv_command和virtualenv_python选项会影响virtualenv的创建。 
– virtualenv_command：用于创建虚拟环境的命令或路径名。 例如pyvenv，virtualenv，virtualenv2，~/bin /virtualenv，/usr/local/bin/virtualenv。 
– virtualenv_python：用于创建虚拟环境的Python可执行文件。 例如python3.5，python2.7。 未指定时，将使用用于运行ansible模块的Python版本。 当virtualenv_command使用pyvenv或-m venv模块时，不应使用此参数。 
– state：状态（present，absent，latest， forcereinstall），表示是安装还卸载 
   present:默认的，表示为安装 
   lastest: 安装为最新的版本 
   absent：表示删除 
   forcereinstall：“forcereinstall”选项仅适用于可ansible 2.1及更高
```

### service

```shell
ps -ef|grep nginx #查看进程
ss -tnlp # 查看端口信息
systemctl start nginx # centos7
service nginx start  # centos6
systemctl enabled nginx # centos7 开机自启动
chkconfig nginx on # centos6开机自启动
```

参数

```
用于管理服务，记得针对Centos7就不要使用这个模块了。 
– arguments：给命令行提供一些选项 
– enabled：是否开机启动 yes|no, 要求状态（state）和启用（enabled）中至少有一个。 
– name：必选项，服务名称 
– runlevel：运行级别 
– sleep：如果执行了restarted，在则stop和start之间沉睡几秒钟 
– state：对当前服务执行启动，停止、重启、重新加载等操作（started,stopped,restarted,reloaded）

```

```shell
ansible web -m service -a 'name=nginx state=started' # 启动nginx
ansible web -m service -a 'name=nginx state=stopped' # 关闭nginx
```

## 计划任务

```shell
* * * * * job 
分 时 日 月 周 任务
0 */2 *  * *  job  每隔两个小时
0 12,13 * * * job 12点和13点
0 12-17 * * * job 12点到17点
0 12-17/2 * * 1,3,6,0 周1,周3,周6,周7 12点到17点每隔两个小时 
crontab -e # 编辑计划任务
crontab -l # 查看计划任务
crontab -r # 删除计划任务
```

常用参数：

```
day   天
disabled  禁用
hour  小时
job  任务
minute  分钟
month  月
name  任务名字
weekday  周
```

```shell
ansible db -m cron -a 'minute=26 job="touch /tmp/xzmly.txt" name=touchfile' # 新建一个计划任务
ansible db -m cron -a 'name=touchfile state=absent' # 删除一个计划任务
ansible db -m cron -a 'minute=26 job="touch /tmp/xzmly.txt" name=touchfile disabled=yes'  # 禁用计划任务,以#表示禁用
```

## 服务器信息收集

setup模块用于被管控机信息收集：`ansible web -m setup`

```shell
ansible_all_ipv4_addresses # ipv4的所有地址
ansible_all_ipv6_addresses # ipv6的所有地址
ansible_date_time # 获取到控制节点时间
ansible_default_ipv4 # 默认的ipv4地址
ansible_distribution # 系统
ansible_distribution_major_version # 系统的大版本
ansible_distribution_version # 系统的版本号
ansible_domain #系统所在的域
ansible_env #系统的环境变量
ansible_hostname #系统的主机名
ansible_fqdn #系统的全名
ansible_machine #系统的架构
ansible_memory_mb #系统的内存信息
ansible_os_family # 系统的家族
ansible_pkg_mgr # 系统的包管理工具
ansible_processor_cores #系统的cpu的核数(每颗)
ansible_processor_count #系统cpu的颗数
ansible_processor_vcpus #系统cpu的总个数=cpu的颗数*CPU的核数
ansible_python # 系统上的python
```

查找想要的信息：

`ansible web -m setup -a "filter=*process*"`

# playbook剧本

ansible的剧本可以看做是一系列命名的集合,  本来这些命令可以从上往下进行堆叠的，但是为了书写更方便和规范，ansible对剧本有自己的解析协议。ansible剧本采用yaml文件格式。

```shell
ansible-playbook [options] playbook.yml [playbook2 ...] 

options:
-C, --check   # 检查,白跑,干跑
-f FORKS, --forks=FORKS #用来做并发
--list-hosts # 列出主机列表
--syntax-check # 语法检查 
```

一般写完ansible的yaml剧本都需要先check一下语法再去运行yaml剧本。

yaml格式：

- 冒号后面必须有空格
- 等号后面不能有空格
- \- 后面也要有空格
- 严格对齐

简单用法：

```yaml
- hosts: web
  tasks:
  - name: creategroup
    group: name=jack
  - name: createuser
    user: name=jack
```

上述yaml文件中，tasks表示需要执行的任务，name是每一个任务名，group和user分别代表模块名，name=jack表示的是模块参数。

## 传参

第一种方式:

`ansible-playbook -e "user=j1" y1.yaml`

第二种方式:

修改/etc/ansible/hosts:

```shell
[db]
192.168.107.132 user=j3
192.168.107.133 user=j4
```

第三种方式：

修改/etc/ansible/hosts:

```
[web]
192.168.1.11
[web:vars]
user=j4
```

第四种方式：

把变量埋在yaml文件里

```
- hosts: web
  vars:
  - user: j6
  tasks:
  - name: create{{ user }}
    user: name={{ user }}
```

第五种方式：

类似于管道符的注册：

```shell
- hosts: web
  tasks:
  - name: count
    shell: echo 4+5|bc
    register: user
  - name: create{{ user.stdout }}
    user: name={{ user.stdout }}
```

注册得到的user是一个字典

**优先级： -e > playbook vars > hosts文件**

## 条件判断

- 不同的系统
- 不同的版本
- 不同的环境
- 不同的用户

```shell
- hosts: db
  remote_user: root
  tasks:
  - name: createfile
    copy: content="大弦嘈嘈如急雨" dest=/tmp/a.txt
    when: a=="3"
  - name: cratefile
    copy: content="小弦切切如私语" dest=/tmp/a.txt
    when: a=="4"
```

这里需要注意的是3和4都是字符串形式的, 使用方式是`ansible-playbook -e "a=3" y1.yaml`

条件判断的一个使用场景是在不同的操作系统安装软件使用的工具是不同的，例如centos是yum，ubantu是apt-get

## tags

因为剧本是从上往下执行的，如果想要只执行剧本中的某一部分，那么久需要打上标签了。

```
- hosts: web
  tasks:
  - name: installnginx
    yum: name=nginx
  - name: copyfile
    copy: src=/etc/nginx/nginx.conf dest=/etc/nginx/nginx.conf
    tags: copyfile
  - name: start
    service: name=nginx state=started
```

使用-t参数使用标签：`ansible-playbook -t copyfile y1.yml `

使用场景：例如管控机都已经安装了nginx，现在需要对管控机的nginx进行替换，那么久可以使用tags.

## 循环

### 普通循环

```yaml
- hosts: web
  tasks:
  - name: crateuser
    user: name={{item}}
    with_items:
    - u30
    - u31
    - u32
  - name: crategroup
    group: name={{item}}
    with_items:
    - g20
    - g21
    - g22
```

都使用item做为标识，这个是不能修改的。

### 嵌套循环

```yaml
- hosts: web
  tasks:
  - name: create_g
    group: name={{ item }}
    with_items:
    - g1
    - g2
  - name: create
    user: user={{ item.user }} group={{ item.group }}
    with_items:
    - {user: "u1", group: "g1"}
    - {user: "u2", group: "g2"}
```

其中{{item}} 也就是说item前后都没有空格也是符合语法规范的。

## template

template和copy很相似，通过ansible-doc -s template 可以看到模块template和copy是相同的，两种的区别是：

- copy模块不替代参数
- template模块替代参数(替代的setup收集的参数)

```yaml
- hosts: web
  tasks:
  - name: installredis
    yum: name=redis
  - name: copyfile
    template: src=/etc/redis.conf dest=/etc/redis.conf
  - name: start
    service: name=redis state=started
```

目前的需求是配置文件 redis.conf 的bind参数需要在不同的机器上根据各自机器的ip动态变化(如果把相同的redis.conf拷贝到所有机器，那还得去不同机器做修改, template的作用是在执行playbook的时候根据setup的收集信息动态去修改拷贝到被管控机上的redis.conf文件.)

```shell
[root@localhost ~]# ansible web -m setup -a "filter=*ipv4*"
192.168.1.11 | SUCCESS => {
    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "10.0.2.15",
            "192.168.1.11"
        ],
        "ansible_default_ipv4": {
            "address": "10.0.2.15",
            "alias": "enp0s3",
            "broadcast": "10.0.2.255",
            "gateway": "10.0.2.2",
            "interface": "enp0s3",
            "macaddress": "08:00:27:de:0e:0e",
            "mtu": 1500,
            "netmask": "255.255.255.0",
            "network": "10.0.2.0",
            "type": "ether"
        }
    },
    "changed": false
}
```

此时管理机要拷贝到被管控机上的redis.conf文件要做的一行修改是：

`bind {{ ansible_default_ipv4.address }} `

值得注意的是，template的src参数可以是相对路径，做法是：

在和playbook的yaml同级的目录下新建一个templates(名称必须是templates)目录,然后把文件放在templates目录里面, 此时的yaml文件如下：

```yaml
- hosts: web
  tasks:
  - name: installredis
    yum: name=redis
  - name: copyfile
    template: src=redis.conf dest=/etc/redis.conf
  - name: start
    service: name=redis state=started
```

## handlers

现在的需求是如果配置文件发送修改，想要把新的配置文件推送到所有被管控机，因为被管控机的配置文件发送改变，我们希望依赖这个配置文件的服务需要重启，这时需要用到handlers。

```yaml
- hosts: web
  tasks:
  - name: installredis
    yum: name=redis
  - name: copyfile
    template: src=redis.conf dest=/etc/redis.conf
    tags: copyfile
    notify: restart
  - name: start
    service: name=redis state=started
  handlers:
  - name: restart
    service: name=redis state=restarted
```

handlers和tasks同级,  里面放置任务，并在相应的tasks下增加notify，notify的value是handler里的name对应的值。

# roles

考虑这样一个场景，现在我们编写了一个playbook的yaml文件，里面有copy的任务，既然是copy那么就涉及到管理机要拷贝到被管理机的文件。那么问题来了，如果这个文件在被管理机因为卸载软件丢失了，那么这个playbook就不能执行了。那么我们的想法就是把这个配置文件拿出来放在我们自己创建的指定的文件夹内，这样就不会因为软件卸载丢失配置文件了(当然你如果要删你自己创建的特定的文件夹那就无可奈何了，自己作死谁也拦不住)。另外，对于web组的一个playbook里写的多个任务，db组想要执行web这个playbook中的一部分任务应该怎么办？复制粘贴？太low了，最好的方式是能把任务进行拆分，让任务更原子化。所以，roles解决的问题是：

- 目录清晰
- 可以互相调用

使用方式：

1. 创建roles文件夹

2. 文件夹里面是要创建的每一个角色,每一个角色一个文件夹，这里的角色可以理解为web、db这样的群组

3. 每一个角色里面都有tasks(必须的),templates,files,handlers,vars目录(这些目录名也必须是固定的)

4. tasks目录都必须有main.yml文件作为入口,通过import_tasks来调用。

   

* files：存放一些file文件，脚本等等,tasks copy模块引用无需写绝对路径
* templates： 存放一些模版，比如一些配置文件引用变量可存放该目录下面,tasks template模块引用无需写绝对路径
* tasks/main.yml： 入口，执行一系列操作
* handlers/main.yml： 列出的 handlers 将被添加到play中
* vars/main.yml： 存放变量,tasks 引用变量无需引入file，可直接使用


```
[root@localhost ~]# tree
.
├── roles
│   ├── db
│   │   ├── files
│   │   ├── handlers
│   │   ├── tasks
│   │   │   └── createuser.yaml
│   │   ├── templates
│   │   └── vars
│   └── web
│       ├── files
│       ├── handlers
│       │   └── main.yaml
│       ├── tasks
│       │   ├── copyfile.yaml
│       │   ├── install.yaml
│       │   ├── main.yaml
│       │   └── start.yaml
│       ├── templates
│       └── vars
└── web.yaml
```

```
web.yaml
- hosts: web
  remote_user: root
  roles:
  - web
```

```
roles/web/tasks/main.yaml
- import_tasks: install.yaml
- import_tasks: copyfile.yaml
- import_tasks: start.yaml
- import_tasks: roles/db/tasks/createuser.yaml
```

```
roles/web/tasks/copyfile.yaml
- name: copyfile
  template: src=redis.conf dest=/etc/redis.conf
  tags: copy
  notify: restart
```

```
roles/web/handlers/main.yaml
- name: restart
  service: name=redis state=restarted
```

执行ansible-playbook web.yaml.

















包组：一组包用于开发

crontab 会用新的进程去做一些事