# rpc

## 什么是rpc

RPC的核心并不在于使用什么协议。RPC的目的是让你在本地调用远程的方法，而对你来说这个调用是透明的，你并不知道这个调用的方法是部署哪里。通过RPC能解耦服务，这才是使用RPC的真正目的。

简单的说，

- RPC就是从一台机器（客户端）上通过参数传递的方式调用另一台机器（服务器）上的一个函数或方法（可以统称为服务）并得到返回的结果。
- RPC 会隐藏底层的通讯细节（不需要直接处理Socket通讯或Http通讯） RPC 是一个请求响应模型。
- 客户端发起请求，服务器返回响应（类似于Http的工作方式） RPC 在使用形式上像调用本地函数（或方法）一样去调用远程的函数（或方法）。

## http和rpc

* http 宽泛上来说：http是rpc的一种，两者是普通话和方言之间的关系。方言属于公司内部的，既然是方言，那么就会各种不同。rpc可以是基于http或者基于tcp协议来做

* 两者不同：围绕资源(http)，围绕动作(rpc，说白了就是一个函数)。rpc其实是从一台机器，执行网络上另外一个机器的函数

一般我们考虑用 RPC 而不是 HTTP 构建自己的服务，通常是考虑到下面的因素：

- 接口是否需要 Schema 约束
- 是否需要更高效的传输协议（TCP，HTTP 2.0）
- 是否对数据包的大小非常敏感

比如 HTTP 是基于文本的协议，头部有非常多冗余（对于 RPC 服务而言）。HTTP 中我们用的最多就是 RESTful ，而 RESTful 是个弱 Schema 约束，大家通过文档沟通，但是如果我就是不在实现的时候对接口文档约定的参数做检查，你也不能把我怎么样。这个时候 Thrift 这种序列化协议的优势就体现出来了，由于 Schema 的存在，可以保证服务端接受的参数和 Schema 保持一致

## rpc的通信

![729358-839e7a32b598953e](https://ws1.sinaimg.cn/large/006tKfTcly1g1gjlofk8cj30dw08qtc8.jpg)

本地机器的RPC框架反序列化出执行结果，函数return这个结果。

client stub 可以完成数据的序列化和反序列化.

实际情况下，RPC很少用到http协议来进行数据传输，毕竟我只是想传输一下数据而已，何必动用到一个文本传输的应用层协议呢，我为什么不直接使用**二进制传输**.

# RPC没那么简单

**要实现一个RPC不算难，难的是实现一个高性能高可靠的RPC框架。**

比如，既然是分布式了，那么一个服务可能有多个实例，你在调用时，要如何获取这些实例的地址呢？

这时候就需要一个服务注册中心，比如在Dubbo里头，就可以使用Zookeeper作为注册中心，在调用时，从Zookeeper获取服务的实例列表，再从中选择一个进行调用。

那么选哪个调用好呢？这时候就需要负载均衡了，于是你又得考虑如何实现复杂均衡，比如Dubbo就提供了好几种负载均衡策略。

这还没完，总不能每次调用时都去注册中心查询实例列表吧，这样效率多低呀，于是又有了缓存，有了缓存，就要考虑缓存的更新问题，blablabla......

你以为就这样结束了，没呢，还有这些：

- 客户端总不能每次调用完都干等着服务端返回数据吧，于是就要支持异步调用；
- 服务端的接口修改了，老的接口还有人在用，怎么办？总不能让他们都改了吧？这就需要版本控制了；
- 服务端总不能每次接到请求都马上启动一个线程去处理吧？于是就需要线程池；
- 服务端关闭时，还没处理完的请求怎么办？是直接结束呢，还是等全部请求处理完再关闭呢？
- ......

如此种种，都是一个优秀的RPC框架需要考虑的问题。



## rpc需要解决的问题

1. **解决分布式系统中，服务之间的调用问题。**
2. **远程调用时，要能够像本地调用一样方便，让调用者感知不到远程调用的逻辑**(restful接口会让人知道是在调用远端)

# Thrift

## 例子一

`docker pull thrift`

如下为一个简单的Thrift文件`HelloService.thrift`。

```
service HelloService {      
	void sayHello()   
  string getData(1:string input)  
 }  
```

编写完成Thrift文件后，可以执行如下代码来编译Thrift文件，从而生成一个Python的项目文件夹:

`docker run -v "$PWD:/data" thrift thrift -o /data --gen py /data/HelloService.thrift`

其中：

- `-v "$PWD:/data"`表示将当前目录映射到容器的`/data`文件夹。
- `-o`表示输出文件夹的位置在`/data`目录下。
- `--gen py`表示生成Server端的代码是Python项目。
- `/data/HelloService.thrift`指定了要编译的Thrift文件。

执行完成后，我们查看当前文件夹可以发现目前在文件夹下已经有了一个新的文件夹，名为`gen-py`

可以在gen-py创建server.py和client.py

server.py

```
#!/usr/bin/env python
# -*- coding: utf-8 -*-
from HelloService import HelloService
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift.server import TServer
class HelloServiceHandler:
    """
    # HelloServiceHandler是中定义的方法用于实现在thrift文件中定义的接口
    """
    def __init__(self):
        self.log = {}
    def sayHello(self):
        # sayHello接口的实现
        print('sayHello')
    def getData(self, input):
        # getData接口的实现
        return input+' from server 1024'
# 实例化Handler
handler = HelloServiceHandler()
# 根据handler创建一个processor
processor = HelloService.Processor(handler)
# 指定端口启动transport
transport = TSocket.TServerSocket(port=9090)
# 创建tfactory, pfactory
tfactory = TTransport.TBufferedTransportFactory()  
pfactory = TBinaryProtocol.TBinaryProtocolFactory()  
# 创建Server
server = TServer.TSimpleServer(processor, transport, tfactory, pfactory)  
print('Starting the server...')
# 启动server
server.serve()  
print('done.')

```

client.py

```
#!/usr/bin/env python
# -*- coding: utf-8 -*-
from HelloService import HelloService
from thrift import Thrift
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
try:
    # 连接Socket
    transport = TSocket.TSocket('localhost', 9090)
    # 获取Transport
    transport = TTransport.TBufferedTransport(transport)
    # 获取TBinaryProtocol
    protocol = TBinaryProtocol.TBinaryProtocol(transport)
    # 创建一个Client
    client = HelloService.Client(protocol)
    # 连接通道transport
    transport.open()
    # 调用某个没有返回值的函数
    client.sayHello()
    # 调用某个有返回值的函数
    print(client.getData("client access"))
    # 关闭通道transport
    transport.close()
except Thrift.TException as tx:
    print('%s' % (tx.message))

```

## 例子二

example.thrift：

```
namespace py example
struct Data {
    1: string text
}

service format_data {
    Data do_format(1:Data data),
}
```

进入 thrift_file 目录执行：$ thrift -out .. --gen py example.thrift，就会在 thrift_file 的同级目录下生成 python 的包：example

Server.py

```
from example import format_data
from example import ttypes
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift.server import TServer

__HOST = 'localhost'
__PORT = 8080

class FormatDataHandler(object):
    def do_format(self, data):
        return ttypes.Data(data.text.upper())


if __name__ == '__main__':
    handler = FormatDataHandler()

    processor = format_data.Processor(handler)
    transport = TSocket.TServerSocket(__HOST, __PORT)
    tfactory = TTransport.TBufferedTransportFactory()
    pfactory = TBinaryProtocol.TBinaryProtocolFactory()

    rpcServer = TServer.TSimpleServer(processor,transport, tfactory, pfactory)

    print('Starting the rpc server at', __HOST,':', __PORT)
    rpcServer.serve()
```

```
#! /usr/bin/env python
# -*- coding: utf-8 -*-

from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from example.format_data import Client
from example.format_data import Data

__HOST = 'localhost'
__PORT = 8080

tsocket = TSocket.TSocket(__HOST, __PORT)
transport = TTransport.TBufferedTransport(tsocket)
protocol = TBinaryProtocol.TBinaryProtocol(transport)
client = Client(protocol)

data = Data('hello,world!')
transport.open()

print(client.do_format(data).text)
```

rpc框架做的事就是把应用层的调用者和真正执行函数的进行解耦，两者之间通过rcp框架进行组合。 