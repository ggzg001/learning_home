初始化：

```
application = tornado.web.Application([
    (r"/index", MainHandler),
])
```

fcntl的close-on-exec

```
# 下面的一段代码是为了应对子进程情况，在子进程exec的之前就关闭子进程的fd(不影响主进程的fd)
flags = fcntl.fcntl(self._socket.fileno(), fcntl.F_GETFD)
flags |= fcntl.FD_CLOEXEC
fcntl.fcntl(self._socket.fileno(), fcntl.F_SETFD, flags)
```

每个文件描述符都有一个**close-on-exec**标志。默认情况下，这个标志最后一位被设置为 0。这个标志符的具体作用在于当开辟其他进程调用exec 族函数时，在调用exec函数之前为exec族函数释放对应的文件描述符。python的os模块有exec 族方法。

 无论是fork还是system()出子进程，如果父进程里在open某个文件后（包括socket fd：特别是port在子进程里被占用）没有设置FD_CLOSEEXEC标志，就会引起各种不可预料的问题。

注意，这里文件描述符包括了普通文件的fd，以及socket的fd，这些都需要注意，特别是socket的fd本身又包括了本机ip，端口号等信息资源，如果该socketfd被子进程继承并占用，或者未关闭，就会导致新的父进程重新启动时不能正常使用这些网络端口，严重的就是设备掉线。

另外，如果子进程继承的时候这些fd就是打开的，本身就有越权的行为可能存在，操作它不该操作的东西。

注意，这里的close-on-exec 仅仅针对程序子进程使用exec去切换到另外的上下文去执行代码。子进程的 exec 执行代码的现象就是 是否会出现 $.

下面是不调用exec的情况

```python
import os

def child():
    print('hello from child', os.getpid())
    os._exit(0)
def parent():
    pid = os.fork()
    if pid == 0:
        child()
        print 'fork child process error!'#如果打印该字符串,说明调用child()出错
    else:
        print('hello from parent', os.getpid(), pid)

parent()
"""
('hello from parent', 29888, 29889)
('hello from child', 29889)
"""
```

### fork和exec的组合

从上面的例子来看,调用child()方法后就直接退出了.但在实际的应用中,我们希望分支出来的子进程能独立运行另外一个新的程序.这时需要用到exec方法替换子进程,并且替换后进程的pid不会改变.exec方法不会返回.

newprocess.py代码如下:

```python
#!/usr/bin/python
#coding=utf-8
import os

def child():
    print('hello from child', os.getpid())
    os._exit(0)

child()
```

主代码如下:

```python
import os

def child():
    print('hello from child', os.getpid())
    os._exit(0)

def parent():
    pid = os.fork()
    if pid == 0:
        os.execlp('python', 'python', 'newprocess.py')
        assert False, 'fork child process error!'
    else:
        print('hello from parent', os.getpid(), pid)
parent()
```

```
$ python TestFork.py 
('hello from parent', 30791, 30792)
$ ('hello from child', 30792)
```

## io复用的边沿触发和水平触发

1. 水平触发（LT）：使用此种模式，当数据可读的时候，epoll_wait()将会一直返回就绪事件。如果你没有处理完全部数据，并且再次在该 epoll实例上调用epoll_wait()才监听描述符的时候，它将会再次返回就绪事件，因为有数据可读。ET只支持非阻塞socket。

2. 边缘触发（ET）：使用此种模式，只能获取一次就绪通知，如果没有处理完全部数据，并且再次调用epoll_wait()的时候，它将会阻塞，因为就绪事件已经释放出来了。

LT模式可能触发的次数更多, 一旦触发的次数多, 也就意味着效率会下降; 但这样也不能就说LT模式就比ET模式效率更低, 因为ET的使用对编程人员提出了更高更精细的要求,一旦使用者编程水平不够, 那ET模式还不如LT模式。

## 按位与或运算

按位的运算，都按位的运算，都是把参加运算的数的二进制形式进行运算。

1.与运算：A与B值均为1时，A、B与的运算结果才为1，否则为0 （运算符：&）

2.或运算：A或B值为1时，A、B或的运算结果才为1，否则为0  （运算符：|）

3.异或运算：A与B不同为1时，A、B的预算结果才为1，否则为0  （运算符：^）

4.按位翻转(按位取反)：将内存中表示数字的2进制数取反0取1，1取0 （运算符：~）

运算方式：

1.与运算：5&3计算过程为 0101(2)&0011(2)=0001(2)=1

注释：意思是把两个数全部转换为二进制进行比较，如上例：5的二进制为0101,3的二进制为0011.则这两个数的二进制数种第一位相同，取一，其余全部取零。得0001，再转换为十进制结果为 1

为方便理解再举个例子，《python核心编程》中表5-4中的例子：>>>30&45  结果为12

即30=（011110）， 45=（101101）位运算得12（1100）

其余三种位运算与此相同

2.或运算：5|3计算过程为 0101(2)|0011(2)=0111(2)=7

3.异或运算：5^3计算过程为 0101(2)^0011(2)=0110(2)=6

4.按位翻转（按位取反）：5=0101(2) 计算过程~5=1010(2)   例如：X的按位运算为-(X+1)

## iostream

ioloop 中 socket 事件发生后，调用 IOStream._handle_events 方法，对事件进行分发。 
对应的事件处理过程中，如果满足注册的回调条件，则调用回调函数 
回调函数在 IOStream._handle_events 中被调用. handle_events 是一个总体的入口方法。

## epoll 的各种事件

EPOLLIN 连接到达；有数据来临；

EPOLLOUT 有数据要写

EPOLLERR：只有采取动作时，才能知道是否对方异常。即对方突然断掉，是不可能有此事件发生的。只有自己采取动作（当然自己此刻也不知道），read，
write时，出EPOLLERR错，说明对方已经异常关闭。

EPOLLRDHUP：客户端正常关闭。此时分系统不同有不同的情况:  某些系统某个sockfd可读，即epollin来临。我们可以recv一下 ， 如果返回0再掉用epoll_ctl 中的EPOLL_CTL_DEL , 同时close(sockfd)。有些系统会直接收到一个EPOLLRDHUP，当然检测这个是最好不过了。

EPOLLHUP： 可以简单地理解为指定的文件描述符数据被读取完毕后被挂起

EPOLLET 边缘触发模式

EPOLLLT 边缘触发模式

EPOLLONESHOT - (从 linux 2.6.17 开始)设置指定文件描述符为单次模式。这意味着，在设置后只会有一次从epoll_wait() 中捕获到事件，之后你必须要重新调用 epoll_ctl() 重新设置。

首先要理解send之后，数据只是去了缓冲区，而缓冲区满了会触发EAGAIN
EPOLLOUT说明缓冲区可写了。

1、单个epoll并不能解决所有问题，特别是你的每个操作都比较费时的时候，因为epoll是串行处理的。 所以你有还是必要建立线程池来发挥更大的效能。

2、如果fd被注册到两个epoll中时，如果有时间发生则两个epoll都会触发事件。3、如果注册到epoll中的fd被关闭，则其会自动被清除出epoll监听列表。
4、如果多个事件同时触发epoll，则多个事件会被联合在一起返回。
5、epoll_wait会一直监听epollhup事件发生，所以其不需要添加到events中。
6、为了避免大数据量io时，et模式下只处理一个fd,其他fd被饿死的情况发生。linux建议可以在fd联系到的结构中增加ready位，然后epoll_wait触发事件之后仅将其置位为ready模式，然后在下边轮询ready fd列表。

events | self.ERROR： 这个到底应该怎么样精确地理解。

Linux： hasattr(select, "epoll") True   mac 系统的hasattr(select, "epoll") False.



xsrf  攻击是什么？为啥和cookie也有关系？

ETag是HTTP1.1中才加入的一个属性，用来帮助服务器控制Web端的缓存验证。它的原理是这样的，当浏览器请求服务器的某项资源(A)时, 服务器根据A算出一个哈希值(3f80f-1b6-3e1cb03b)并通过 ETag 返回给浏览器，浏览器把"3f80f-1b6-3e1cb03b" 和 A 同时缓存在本地，当下次再次向服务器请求A时，会通过类似 `If-None-Match: "3f80f-1b6-3e1cb03b"` 的请求头把ETag发送给服务器，服务器再次计算A的哈希值并和浏览器返回的值做比较，如果发现A发生了变化就把A返回给浏览器(200)，如果发现A没有变化就给浏览器返回一个304未修改。这样通过控制浏览器端的缓存，可以节省服务器的带宽，因为服务器不需要每次都把全量数据返回给客户端。

注：HTTP中并没有指定如何生成ETag，哈希是比较理想的选择。



tornado  为啥说是非线程安全的呢?





