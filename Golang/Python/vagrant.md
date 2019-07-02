本人之所以使用vagrant, 是因为想玩一下ansible的时候需要用到多台服务器。因为VM太重了，本人的mac的配置不是很高，所以选择了更轻量级的vagrant.

准备工作：

下载安装 VirtualBox ：<https://www.virtualbox.org/>

下载安装 Vagrant ：<http://www.vagrantup.com/>

下载centos7: [https://github.com/tommy-muehle/puppet-vagrant-boxes/releases/download/1.1.0/centos-7.0-x86_64.box(管理员账号和密码是root/vagrant)](https://github.com/tommy-muehle/puppet-vagrant-boxes/releases/download/1.1.0/centos-7.0-x86_64.box(%E7%AE%A1%E7%90%86%E5%91%98%E8%B4%A6%E5%8F%B7%E5%92%8C%E5%AF%86%E7%A0%81%E6%98%AFroot/vagrant))

VirtualBox是类似于VM的一款虚拟机, vagrant是一套命令可以用来管理VirtualBox上跑的各种系统, 比如开机关机等。

可以在 <http://www.vagrantbox.es/> 这里下载更多不同系统甚至是已经配置好环境直接可以用的box，虽然可以直接在Vagrant直接使用网址，由Vagrant自动下载安装，但是考虑到网络情况，还是建议自行先下载好放在指定的boxes目录下。

# 简单使用

1. vagrant box add base /tmp/boxes/centos-7.0-x86_64.box
2. vagrant init
3. vagrant up
4. vagrant ssh
5. vagrant halt

首先在本地创建好工作目录，并在命令行下切换到对应目录，执行`vagrant box add base /tmp/boxes/centos-7.0-x86_64.box`.

base 表示指定默认的box，也可以为box指定名称，比如 centos7 ，使用base时，之后可以直接使用 vagrant init 进行初始化，如果自行指定名称，则初始化的时候需要指定box的名称。当然如果使用`vagrant box add /tmp/boxes/centos-7.0-x86_64.box`, 那么init的时候需要知道名称才行。

centos-7.0-x86_64.box 是box对应的文件名，这里可以是本地保存box的路径，也可以是可以下载box的网址，如果是网址的话，Vagrant会自动启动下载。

设置好虚拟机需要用到的镜像box之后，在当前工作目录运行`vagrant init`生成Vagrantfile配置文件。

之后启动虚拟机`vagrant up`并ssh登陆到虚拟机`vagrant ssh`, 使用完之后关闭虚拟机`vagrant halt`.



# vagrant 网络配置

Vagrant可以指定三种网络：端口转发（Forwarded Ports），私有网络（Private Network），公有网络（Public Network）。

### Vagrant 网络模型

#### 端口转发：

```
    config.vm.network :forwarded_port, guest: 80, host: 8080
```

将虚拟机（被称作guest）的端口80映射为宿主机的端口8080。

**端口转发隐含着一个provider的NAT网络将被首先创建**。
 所以，如果你单独定义一条端口转发的配置语句的话，VM将会自动建立NAT网络环境。

#### 私有网络：

```
    config.vm.network :private_network, ip: "192.168.1.104"
```

你可以从宿主机自由访问虚拟机，但LAN网络中的其他人不需要也无法访问虚拟机。

值得注意的是，ip地址“192.168.1.104”不是随便指定的。
 首先你可以不指定，这表示虚机启动时会DHCP到一个可用的IP地址（例如：192.168.33.101），这是vagrant通过virtualbox私有网络的DHCP机制获得的。
 如果你要自行指定明确的IP地址，要保证该地址是在恰当的网段中，例如192.168.33.71。

多台虚拟机在私有网络模式下也可以互相访问，只要设置为相同的网段就可以。

本质上说，这是使用provider的HostOnly模式。

#### 公有网络：

公有网络实际上是表示将虚拟机暴露为LAN（例如你的宿主机所在的办公室网络）中的一台主机。

例如使用LAN的DHCP自动获得IP地址：

```
    config.vm.network :public_network
```

也可以指定LAN网段中的一个可用的地址，但需要注意不要和LAN中已有的主机或者保留的IP地址相冲突。

本质上说，这是使用provider的桥接网络模式。

# 常用管理命令

在不进入虚拟机的情况下，还可以使用下面的命令对 虚拟机进行管理：

**vagrant up** （启动虚拟机）
**vagrant halt** （关闭虚拟机——对应就是关机）
**vagrant suspend** （暂停虚拟机——只是暂停，虚拟机内存等信息将以状态文件的方式保存在本地，可以执行恢复操作后继续使用）
**vagrant resume** （恢复虚拟机 —— 与前面的暂停相对应）
**vagrant destroy** （删除虚拟机，删除后在当前虚拟机所做进行的除开Vagrantfile中的配置都不会保留）

# 打包现有环境box

当在启动Vagrant后，对于虚拟机有进行过安装环境相关的配置，如果并不希望写在Vagrant的启动shell里面每次都重新安装配置一遍，可以将当前配置好的虚拟机打包成box.

```
`vagrant package --output NAME --vagrantfile FILE` `可选参数：` `--output NAME ： （可选）设置通过NAME来指定输出的文件名` `--vagrantfile FILE：（可选）可以将Vagrantfile直接封进box中`
```

注：如果网络模式中使用 private_network 的话，在打包之前需要清除一下private_network的设置，避免不必要的错误：

```
`sudo rm ``-f` `/etc/udev/rule.d/70-persistent-net.rules`
```

制作完成之后直接将box文件拿到其他计算机上配置即可使用。

# 常用配置文件

## Vagrantfile

```shell
# coding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  config.vm.box = "bionic"

  # 不检查 box 更新
  config.vm.box_check_update = false

  # 设置虚拟机的主机名
  config.vm.hostname = "arcimedes.node"

  # 设置虚拟机的IP (en0 为桥接本机的网卡)
  config.vm.network "public_network", ip: "192.168.31.10",
                    bridge: "en0: Wi-Fi (AirPort)"

  # 设置主机与虚拟机的共享目录
  config.vm.synced_folder "~/Developer/coding/", "/opt/"

  # VirtaulBox相关配置
  config.vm.provider "virtualbox" do |v|
    # 设置虚拟机的名称
    v.name = "arcimedes"

    # 设置虚拟机的内存大小
    v.memory = "2048"

    # 设置虚拟机的CPU个数
    v.cpus = 2

    # 启动时是否现实 VirtualBox 窗口
    v.gui = false
  end

  # 设置磁盘大小
  config.disksize.size = '20GB'

  # 配置 ssh 的登录名
  # config.ssh.username = "gauss"

  # 增加各节点 host 配置
  # config.vm.provision :hosts do |provisioner|
  #   vms.each do |x|
  #     provisioner.add_host "192.168.1.1#{x}", ["config#{x}.node"]
  #   end
  # end

  # 自定义执行脚本
  config.vm.provision "shell", path: "init.sh"

  # 每次开机后重启 network 和 ssh，解决公网网卡不启动问题
  config.vm.provision "shell", run: "always", inline: <<-SHELL
                systemctl restart sshd
                echo -e "\033[32mvirtual machine arcimedes init success!\033[0m"
            SHELL
end
```

## init.sh

```shell
# 替换国外源到国内阿里的源
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo cp /vagrant/sources.list /etc/apt/sources.list

# 安装 zsh
sudo apt-get update && sudo apt-get -y install zsh

# 安装 oh-my-zsh
# git clone git://github.com/robbyrussell/oh-my-zsh.git /home/vagrant/.oh-my-zsh
cp -r /vagrant/oh-my-zsh /home/vagrant/.oh-my-zsh
cp /home/vagrant/.oh-my-zsh/templates/zshrc.zsh-template /home/vagrant/.zshrc
sed -i 's#/home/vagrant:/bin/bash#/home/vagrant:/bin/zsh#' /etc/passwd

# 安装 tmux
sudo apt-get update && sudo apt-get -y install tmux
cp -r /vagrant/tmux /home/vagrant/.tmux
ln -s -f /home/vagrant/.tmux/.tmux.conf .tmux.conf
cp /home/vagrant/.tmux/.tmux.conf.local /home/vagrant/

# 安装 docker
sudo apt-get update && sudo apt-get install -y docker.io
sudo usermod -aG docker vagrant

# 安装 python3
sudo apt-get update && sudo apt-get -y install python3.6 python3-pip
pip3 install -r /vagrant/requirements.txt

# 安装 mysql 数据库
# sudo apt-get update && sudo apt-get -y install mysql-server
# mysql -u root < /vagrant/init.sql

# 安装 postgresql 数据库
# sudo apt-get update && sudo apt-get -y install postgresql-10

# 安装 redis
# sudo apt-get update && sudo apt-get -y install redis-server

# 安装 mangoDB 数据库

# 安装 java 开发环境
# sudo apt-get update && sudo apt-get -y install openjdk-8-jdk gradle
# echo 'export M2_HOME=/opt/bin/apache-maven/' >> /home/vagrant/.zshrc
# echo 'export PATH=$PATH:${M2_HOME}/bin' >> /home/vagrant/.zshrc

```

## init.sql

```mysql
CREATE USER 'admin'@'localhost' IDENTIFIED BY '123456';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;
CREATE USER 'admin'@'%' IDENTIFIED BY '123456';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;
```









