首先，需要理解一下IO模型的具体含义。IO模型是一个抽象的概念，指的是处理IO问题的几种不同的模式。大致分为以下几种：

* 阻塞IO
* 非阻塞IO
* IO多路复用
* 异步IO

对于这些概念的理解，鉴于不同的上下文环境，不同的人有不同的说法。

对于IO发送时涉及的对象和步骤.对于一个network IO (这里我们以read、recv举例)，它会涉及到两个系统对象，一个是调用这个IO的process (or thread)，另一个就是系统内核(kernel)。当一个read/recv读数据的操作发生时，该操作会经历两个阶段：

1. 等待数据准备 (Waiting for the data to be ready)

2. 将数据从内核拷贝到进程中(Copying the data from the kernel to the process)

socket相关的方法在IO的区别：

>1、输入操作：read、readv、recv、recvfrom、recvmsg共5个函数，如果会阻塞状态，则会经理wait data和copy data两个阶段，如果设置为非阻塞则在wait 不到data时抛出异常
>2、输出操作：write、writev、send、sendto、sendmsg共5个函数，在发送缓冲区满了会阻塞在原地，如果设置为非阻塞，则会抛出异常
>3、接收外来链接：accept，与输入操作类似
>4、发起外出链接：connect，与输出操作类似

# 阻塞IO

在linux中，默认情况下所有的socket都是blocking.

<font color="red">在用户进程这边，整个进程会被阻塞。</font>当kernel一直等到数据准备好了，它就会将数据从kernel中拷贝到用户内存，然后kernel返回结果，用户进程才解除block的状态，重新运行起来。

**在一个线程的IO模型中，我们recv的地方阻塞，我们就开启多线程，但是不管你开启多少个线程，这个recv的时间是不是没有被规避掉，不管是多线程还是多进程都没有规避掉这个IO时间。**

开启多进程或都线程的方式，在遇到要同时响应成百上千路的连接请求，则无论多线程还是多进程都会严重占据系统资源，降低系统对外界响应效率，而且线程与进程本身也更容易进入假死状态。

**在阻塞状态下，程序是不會浪費CPU的**。



# 非阻塞IO

Linux下，可以通过设置socket使其变为non-blocking.

当用户进程发出read操作时，如果kernel中的数据还没有准备好，那么它并不会block用户进程，而是立刻返回一个error。从用户进程角度讲 ，它发起一个read操作后，并不需要等待，而是马上就得到了一个结果。用户进程判断结果是一个error时，它就知道数据还没有准备好，于是用户就可以在本次到下次再发起read询问的时间间隔内做其他事情，或者直接再次发送read操作。一旦kernel中的数据准备好了，并且又再次收到了用户进程的system call，那么它马上就将数据拷贝到了用户内存（这一阶段仍然是阻塞的），然后返回。

也就是说非阻塞的recvform系统调用调用之后，进程并没有被阻塞，内核马上返回给进程，如果数据还没准备好，此时会返回一个error。进程在返回之后，可以干点别的事情，然后再发起recvform系统调用。重复上面的过程，循环往复的进行recvform系统调用。这个过程通常被称之为轮询。轮询检查内核数据，直到数据准备好，再拷贝数据到进程，进行数据处理。需要注意，拷贝数据整个过程，进程仍然是属于阻塞的状态。

<font color="red">在这应该分清用户进程和系统内核的角色不同，站在这个角度可以很好地理解这个事。</font>

```python
import time
import socket

sock = socket.socket()
sock.setblocking(False)
ip_port = ("127.0.0.1", 9000)
bufsize = 1000
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sock.bind(ip_port)
sock.listen(3)

r_conn_list = []
w_conn_dict = {}

while True:
    try:

        conn, addr = sock.accept()
        r_conn_list.append(conn)
    except BlockingIOError as e:
        # 暂时没有连接进来
        time.sleep(.5)
        r_conn_del = []
        w_conn_del = []
        for r_conn in r_conn_list:
            try:
                recv_data = r_conn.recv(bufsize)
            except BlockingIOError:
                continue
            w_conn_dict[r_conn] = recv_data
            r_conn_del.append(r_conn)
        for w_conn, data in w_conn_dict.items():
            w_conn.sendall(data)
            w_conn_del.append(w_conn)

        for i in r_conn_del:
            r_conn_list.remove(i)

        for i in w_conn_del:
            w_conn_dict.pop(i)
```

多线程客户端：

```python
from threading import Thread
import socket

ip_port = ('127.0.0.1', 9000)

def func():
    sock = socket.socket()

    sock.connect(ip_port)
    sock.sendall(b"hello")
    data = sock.recv(1024)
    print(data)

if __name__ == '__main__':
    for i in range(6):
        t = Thread(target=func)
        t.start()
```

**虽然我们上面的代码通过设置非阻塞，规避了IO操作，但是非阻塞IO模型绝不被推荐。**这种在用户进程做的死循环太low了。缺点很明显：循环调用recv()将大幅度推高CPU占用率；任务完成的响应延迟增大了，因为每过一段时间才去轮询一次read操作，而任务可能在两次轮询之间的任意时间完成。这会导致整体数据吞吐量的降低。

实际上，用户进程去检测socket是否准备好，这个如果是底层的操作系统帮忙做就好了，因为本质上我们自己的程序还是以操作系统为基础的，要是操作系统可以做那再好不过了。事实上，操作系统的确有几个机制来帮忙做这件事。

# IO多路复用

当用户进程调用了select，那么整个进程会被block。而同时，kernel会“监视”所有select负责的socket，当任何一个socket中的数据准备好了，select就会返回。这个时候用户进程再调用read操作，将数据从kernel拷贝到用户进程。确切地说，IO多路复用只是帮你监听，至于监听得到的socket怎么处理它不管。

IO多路复用不仅阻塞了还多需要使用两个系统调用(select和recvfrom)，而blocking IO只调用了一个系统调用(recvfrom)，当只有一个连接请求的时候，这个模型还不如阻塞IO效率高。但是，用select的优势在于它可以同时处理多个connection，而阻塞IO那里不能，我不管阻塞不阻塞，你所有的连接包括recv等操作，我都帮你监听着。

用户进程可以通过代码来来控制这个机制，和这个机制进行交互。

**在多路复用模型中，对于每一个socket，一般都设置成为non-blocking**。其实这样也比较合理，操作系统一看这个文件描述符拿不到数据就过，继续去看下一个fd.

IO多路复用复用的是什么东西，复用的是进程，一个进程处理多个请求。

select，poll，epoll本质上都是同步I/O，因为他们都需要在读写事件就绪后自己负责进行读写，也就是说这个读写过程是阻塞的，而异步I/O则无需自己负责进行读写，异步I/O的实现会负责把数据从内核拷贝到用户空间。

## select

1. 每次调用select，都需要把fd集合从用户态拷贝到内核态，这个开销在fd很多时会很大
2. 同时每次调用select都需要在内核遍历传递进来的所有fd，这个开销在fd很多时也很大
3. select支持的文件描述符数量太小了，默认是1024

每一次呼叫 select( ) 都需要先从 user space把 FD_SET复制到 kernel（约线性时间成本）。那么 为什么 select 不能像epoll一样，只做一次复制就好呢? 每一次呼叫 select()前，FD_SET都可能更动，而 epoll 提供了共享记忆存储结构(其实就是mmap，地址映射，用户空间的在内核空间可以通过地址直接访问到)，所以不需要有 kernel 与 user之间的数据沟通。

然后kernel还要轮询每个fd，约线性时间

假设现实中，有1百万个客户端同时与一个服务器保持着tcp连接，而每一个时刻，通常只有几百上千个tcp连接是活跃的，这时候我们仍然使用select/poll机制，kernel必须在搜寻完100万个fd之后，才能找到其中状态是active的，这样资源消耗大而且效率低下。

select的函数说明，包含返回值和参数类型说明：

`int select(int nfds, fd_ set *readfds, fd_ set *wr itefds,fd_ set *exceptfds, struct timeval *t imeout)`

返回的是有几个fd状态发生改变，具体是哪几个需要去轮询。





## poll

poll的描述符数量没有描述符数量限制.

- 描述fd集合的方式不同，poll使用 pollfd 结构而不是select结构fd_set结构，所以poll是链式的，没有最大连接数的限制.因为select使用的是列表的数据结构，受困于线性存储空间的连续地址分配的影响只能是1024，poll是链式的就不受连续地址的影响了
- poll有一个特点是水平触发，也就是通知程序fd就绪后，这次没有被处理，那么下次poll的时候会再次通知同个fd已经就绪。

## 

## epoll

epoll也需要查看是否有fd就绪，但是epoll之所以是被动触发，就在于它只要去查找就绪队列中有没有fd，就绪的fd是主动加到队列中，epoll不需要一个个轮询确认。

换一句话讲，就是select和poll只能通知有fd已经就绪了，但不能知道究竟是哪个fd就绪，所以select和poll就要去主动轮询一遍找到就绪的fd。而epoll则是不但可以知道有fd可以就绪，而且还具体可以知道就绪fd的编号，所以直接找到就可以不用轮询。

epoll除了提供select/ poll那种IO事件的电平触发(Leve1 Triggered) 外，还提供了边沿触发(Edge Triggered) ，这就使得用户空间程序有可能缓存IO状态，减少epoll_ wait/epoll_ pwait的调用，提高应用程序效率。ET就是如果上一次有数据没有处理，下一次因为没有变化就不会再通知了。

linux中查看可创建的最大的文件描述符个数的命令是：`cat /proc/sys/fs/file-max`

### epoll的API

1.创建一个epoll句柄，参数size用来告诉内核监听的文件描述符个数，跟内存大小有关: `int epoll_ create(int size)`

其实就是创建一颗红黑树，方便文件描述符的插入，删除，查找。先创建一个节点，然后后面再慢慢插入，返回的是一个文件描述符，通过这个文件描述符就可以找到这颗红黑树，也就是这颗红黑树的头节点。树具有数组的快速查找特征，有具有链表的快速插入和删除的特征，至于为什么要选红黑树.

2.控制某个epoll监控的文件描述符上的事件:注册、修改、删除

`int epoll_ ctl(int epfd, int op, int fd, struct epoll event *event)`

epfd:为epoll .creat的句柄**（也就是红黑树的头节点，说明这个文件描述符要插入哪颗红黑树上）**

op :表示动作，用3个宏来表示:

* EPoLL CTL ADD(注册新的fd到epfd)
* EPOLL CTL MOD(修改已经注册的fd的监听事件)
* EPoLL CTL DEL(从epfd删除一一个fd) ;

**对应了红黑树上的添加，修改，删除**

fd:就是你要插入到这颗红黑树上的文件描述符

event : 告诉内核需要监听的事件，也就是前面说的写数据，读数据啥的.

3.等待所监控文件描述符上有事件的产生，类似于select()调用。（前面两步就是准备好数据，这一步就是开启）

`int epoll wait(int epfd, struct epoll event *events, int maxevents, int timeout )`

epfd就是要开启的红黑树的头节点的文件描述符

events :用来从内核得到事件的集合，（也就是用一个指针接收从内核返回的存储就绪的队列）

maxevents : 告之内核这个events有多大，这个maxevents的值不能大于创建epoll create( )时的size, (肯定不会大于红黑树的数据量，不能太小，不然接收不完返回来的就绪队列数据.)





## selector

```python
from socket import *
import selectors

sel = selectors.DefaultSelector()

def accept(server_obj, mask):
    conn, addr = server_obj.accept()
    sel.register(conn, selectors.EVENT_READ, read)

def read(conn, mask):
    try:
        data = conn.recv(1024)
        if not data:
            sel.unregister(conn)
            conn.close()
            return
        conn.send(data)
    except Exception:
        sel.unregister(conn)
        conn.close()

if __name__ == '__main__':
    server_obj = socket()
    server_obj.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
    server_obj.bind(('127.0.0.1', 9000))
    server_obj.listen(5)
    sel.register(server_obj, selectors.EVENT_READ, accept)
    while True:
        ready = sel.select()
        for sel_obj, mask in ready:
            callback = sel_obj.data
            callback(sel_obj.fileobj,mask)
```

```
select(timeout=None)
　　作用： 用于选择满足我们监听的event的文件对象；
　　返回值： 是一个(key, events)的元组， 其中key是一个SelectorKey类的实例， 而events 就是 event Mask（EVENT_READ或EVENT_WRITE,或者二者的组合)
　　
模块定义了一个 SelectorKey类， 一般用这个类的实例 来描述一个已经注册的文件对象的状态， 这个类的几个属性常用到：
	fileobj：   表示已经注册的文件对象；
	fd:          表示文件对象的描述符，是一个整数，它是文件对象的 fileno()方法的返回值；
	events:    表示注册一个文件对象时，我们等待的events, 即上面的event Mask, 是可读呢还是可写呢！！
	data:       表示注册一个文件对象是邦定的data；
```

首先说一下 ET 和 LT。ET 和 LT 这两个术语实际上并不仅仅使用在 epoll 上（甚至被用于其他领域），它们的含义为：
LT：在特定状态下触发
ET：在状态变化时触发

网络 IO 管理中，告知逻辑层文件描述符可读和可写时，可以是在文件描述符处于可读和可写状态时（LT），也可以是文件描述符变为可读和可写状态时（ET）。

以可读为例，我们可以理解，在 ET 下，当出现数据可读，那么会通知逻辑层一次，如果逻辑层这次通知时没有完全读取完数据，那么不会再得到底层通知。相比下，LT 下，逻辑层会一直得到底层通知，直到文件描述符状态为不可读。

由于上面的情况，在 ET 下，文件描述符就不能是阻塞的，因为逻辑层需要在一次通知时不断读取数据，直到所有数据读取完成，读取操作是不能被阻塞的。

select，poll，epoll LT（可以认为是快速的 poll）都是 LT 的，所以文件描述符可以为阻塞的（当然也可以为非阻塞的）





# 异步IO

用户进程发起read操作之后，立刻就可以开始去做其它的事，完全不会阻塞。。而另一方面，从kernel的角度，当它受到一个asynchronous read之后，首先它会立刻返回，所以不会对用户进程产生任何block。然后，kernel操作系统会等待数据（阻塞）准备完成，然后将数据拷贝到用户内存，当这一切都完成之后，kernel会给用户进程发送一个signal，告诉它read操作完成了。至于对这个信号怎么理解，后续异步框架tornado、twstied的时候可以再体会。



yield的返回，因为yield也是在函数里面的

yield 之后的值其实不要紧，因为当前不要下一回合可能就需要了

你发东西给我，我处理了回过来yield给你



