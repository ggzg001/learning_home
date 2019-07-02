mac下的安装和启动

`brew install rabbitmq`

安装目录：`/usr/local/Cellar/rabbitmq/3.7.12`

启动命令：`brew service start rabbitmq`

器输入http://localhost:15672即可进入rabbitmq控制终端登录页面，默认用户名和密码为 guest/guest.

查看队列情况：`./rabbitmqctl list_queues`

创建用户：`./rabbitmqctl add_user admin admin`

赋予用户权限：`./rabbitmqctl set_user_tags admin administrator`

# rabbitmq整体架构

![img](https://ws4.sinaimg.cn/large/006tKfTcgy1g1dy9s3620j30m20ciq4j.jpg)

rabbitmq可以用来处理多个分布式机器的进程通信，这个通信不仅仅是通过一个队列来实现，而是通过一个叫做exchange的交互器来实现。

# **发布/订阅**

## 生产者

```python
import pika
import sys

username = 'admin'   #指定远程rabbitmq的用户名密码
pwd = 'admin'
user_pwd = pika.PlainCredentials(username, pwd)
s_conn = pika.BlockingConnection(pika.ConnectionParameters('127.0.0.1', credentials=user_pwd))#创建连接
chan = s_conn.channel()  #在连接上创建一个频道

chan.queue_declare(queue='hello') #声明一个队列，生产者和消费者都要声明一个相同的队列，用来防止万一某一方挂了，另一方能正常运行
chan.basic_publish(exchange='',  #交换机,为空表示先不使用exchange的功能
                   routing_key='hello',#路由键，写明将消息发往哪个队列，本例是将消息发往队列hello
                   body='hello world')#生产者要发送的消息
print("[生产者] send 'hello world")

s_conn.close()#当生产者发送完消息后，可选择关闭连接


输出：
[生产者] send 'hello world
```

## 消费者

```python
import pika

username = 'admin'#指定远程rabbitmq的用户名密码
pwd = 'admin'
user_pwd = pika.PlainCredentials(username, pwd)
s_conn = pika.BlockingConnection(pika.ConnectionParameters('127.0.0.1', credentials=user_pwd))#创建连接
chan = s_conn.channel()#在连接上创建一个频道

chan.queue_declare(queue='hello')#声明一个队列，生产者和消费者都要声明一个相同的队列，用来防止万一某一方挂了，另一方能正常运行


def callback(ch,method,properties,body): #定义一个回调函数，用来接收生产者发送的消息
    print("[消费者] recv %s" % body)

chan.basic_consume(callback,  #调用回调函数，从队列里取消息
                   queue='hello',#指定取消息的队列名
                   no_ack=True) #取完一条消息后，不给生产者发送确认消息，默认是False的，即  默认给rabbitmq发送一个收到消息的确认，一般默认即可
print('[消费者] waiting for msg .')
chan.start_consuming()#开始循环取消息

输出：
[消费者] waiting for msg .
[消费者] recv b'hello world'
```

## no_ack

这里如果把消费者的no_ack设置为False,那么消费者取了数据但是正在运行还未死掉，list_queus发现队列里的数据依然存在，此时再来一个消费者，这个消费者取不到数据(即使队列里有这个数据)。no_ack参数常和消息持久化一起使用。

# 持久化

持久化分为消息持久化，队列持久化和两者结合的持久化。

## 消息持久化

消息持久化的背景：消费者把数据拿走之后，如果消费者处理失败应该怎么做？为了确保消息都被正确处理，那么消费者和生产者得相互配合来完成这样的需求。消费者把数据发送过去的时候，就这条消息需要持久化在队列的，如果消费者正确处理了数据，那么才能发消息把这条消息从队列中删除。

标记消息为持久化并不能完全保证消息不会丢失，尽管已经告诉RabbitMQ将消息保存到磁盘，但RabbitMQ接收到的消息在还没有保存的时候，仍然有一个短暂的时间窗口。RabbitMQ不会对每个消息都执行同步 --- 可能只是保存到缓存cache还没有写入到磁盘中。因此这个持久化保证并不是很强，但这比我们简单的任务queue要好很多，如果想要很强的持久化保证，可以使用 publisher confirms。

### 生产者

```python
import pika


s_conn = pika.BlockingConnection(pika.ConnectionParameters("localhost")) #创建连接
channel = s_conn.channel()  #在连接上创建一个频道

channel.queue_declare(queue='task_queue') #创建一个新队列task_queue，设置队列持久化，注意不要跟已存在的队列重名，否则有报错

message = "Hello World"
channel.basic_publish(exchange='',
                      routing_key='task_queue',#写明将消息发送给队列worker
                      body=message,    #要发送的消息
                      properties=pika.BasicProperties(delivery_mode=2,)#设置消息持久化，将要发送的消息的属性标记为2，表示该消息要持久化
                      )
print(" [生产者] Send %r " % message)
```

### 消费者

```python
import pika
import time


s_conn = pika.BlockingConnection(pika.ConnectionParameters('127.0.0.1'))#创建连接
channel = s_conn.channel()#在连接上创建一个频道

channel.queue_declare(queue='task_queue') #创建一个新队列task_queue，设置队列持久化，注意不要跟已存在的队列重名，否则有报错.RabbitMQ不允许你重新定义一个已经存在、但属性不同的queue


def callback(ch, method, properties, body):
    print(" [消费者] Received %r" % body)
    print("method", method)
    print("properties", properties)
    time.sleep(5)
    print(" [消费者] Done")
    ch.basic_ack(delivery_tag=method.delivery_tag) #  接收到消息后会给rabbitmq发送一个确认，每次method.delivery_tag都会变化，默认是递增

channel.basic_qos(prefetch_count=1)   # 消费者给rabbitmq发送一个信息：在消费者处理完消息之前不要再给消费者发送消息

channel.basic_consume(callback,
                      queue='task_queue',
                      no_ack=False      # 需要确认
                      )
channel.start_consuming()
```

在消费者消费的过程中crtl + c异常终止程序后可以发现数据还在队列中

## 队列持久化

如果一个队列中放了很多数据还没有被消费，此时重启rabbitmq服务，会发现队列不存在了，那么队列中的数据自然也不存在了。只需要在声明队列的时候指定一个参数`durable=True`就能把队列设置成持久的了。

## 公平调度

在一个消费者未处理完一个消息之前不要分发新的消息给它，而是将这个新消息分发给另一个不是很忙的消费者进行处理。为了解决这个问题我们可以在消费者代码中使用 channel.basic.qos ( prefetch_count = 1 )，将消费者设置为公平调度。

# **Exchange Type**

exchange：交换机。生产者不是将消息发送给队列，而是将消息发送给交换机，由交换机决定将消息发送给哪个队列。所以exchange必须准确知道消息是要送到哪个队列，还是要被丢弃。因此要在exchange中给exchange定义规则，所有的规则都是在exchange的类型中定义的。

![img](https://ws1.sinaimg.cn/large/006tKfTcgy1g1dyac3hraj30fl058wek.jpg)

在绑定（Binding）Exchange和Queue的同时，一般会指定一个Binding Key，生产者将消息发送给Exchange的时候，一般会产生一个Routing Key，当Routing Key和Binding Key对应上的时候，消息就会发送到对应的Queue中去。那么Exchange有四种类型，不同的类型有着不同的策略。也就是表明不同的类型将决定绑定的Queue不同，换言之就是说生产者发送了一个消息，Routing Key的规则是A，那么生产者会将Routing Key=A的消息推送到Exchange中，这时候Exchange中会有自己的规则，对应的规则去筛选生产者发来的消息，如果能够对应上Exchange的内部规则就将消息推送到对应的Queue中去。那么接下来就来详细讲解下Exchange里面类型。



## fanout

 fanout类型的Exchange路由规则非常简单，它会把所有发送到该Exchange的消息路由到所有与它绑定的Queue中。



![img](https://ws4.sinaimg.cn/large/006tKfTcgy1g1dycnql2zj30ht08ldg6.jpg)

### 生产者

```python
import pika


s_conn = pika.BlockingConnection(
    pika.ConnectionParameters('127.0.0.1'))  # 创建连接
chan = s_conn.channel()  # 在连接上创建一个频道

# 创建一个fanout(广播)类型的交换机exchange，名字为logs。
chan.exchange_declare('logs', 'fanout')#创建一个fanout(广播)类型的交换机exchange，名字为logs。
chan.basic_publish(exchange="logs",  # 指定交换机exchange为logs，这里只需要指定将消息发给交换机logs就可以了，不需要指定队列，因为生产者消息是发送给交换机的
                   routing_key="",  # 在fanout类型中，绑定关键字routing_key必须忽略，写空即可
                   body="hello world")
s_conn.close()

```

### 消费者

```python
import pika

s_conn = pika.BlockingConnection(pika.ConnectionParameters('127.0.0.1'))  # 创建连接
channel = s_conn.channel()  # 在连接上创建一个频道

channel.exchange_declare('logs', 'fanout')  # 消费者需再次声明一个exchange 以及类型。

result = channel.queue_declare(exclusive=True)  # 创建一个队列，exclusive=True（唯一性）表示在消费者与rabbitmq断开连接时，该队列会自动删除掉。
queue_name = result.method.queue  # 因为rabbitmq要求新队列名必须是与现存队列名不同，所以为保证队列的名字是唯一的，method.queue方法会随机创建一个队列名字，如：‘amq.gen-JzTY20BRgKO-HjmUJj0wLg‘。

channel.queue_bind(exchange='logs',
                   queue=queue_name)  # 将交换机logs与接收消息的队列绑定。表示生产者将消息发给交换机logs，logs将消息发给随机队列queue，消费者在随机队列queue中取消息

print(' [消费者] Waiting for logs. To exit press CTRL+C')


def callback(ch, method, properties, body):
    print(" [消费者] %r" % body)


channel.basic_consume(callback,  # 调用回调函数从queue中取消息
                      queue=queue_name,
                      no_ack=True)  # 设置为消费者不给rabbitmq回复确认。

channel.start_consuming()  # 循环等待接收消息。s
```

* 开启多个消费者后，会同时从生产者接收相同的消息
* 广播类型，生产者将消息发送给所有消费者，如果某个消费者没有收到当前消息，就再也收不到了（消费者就像收音机）

## direct

 direct类型的Exchange路由规则也很简单，它会把消息路由到那些binding key与routing key完全匹配的Queue中

### ![458325-20160107091457637-428564110](https://ws1.sinaimg.cn/large/006tKfTcgy1g1dz69rrsoj30ht08lmxq.jpg)生产者

```python
import pika


s_conn = pika.BlockingConnection(pika.ConnectionParameters('127.0.0.1'))#创建连接
channel = s_conn.channel()  #在连接上创建一个频道

channel.exchange_declare('direct_logs', 'direct')#创建一个交换机并声明exchange的类型为：关键字类型，表示该交换机会根据消息中不同的关键字将消息发送给不同的队列

severity = 'info'#severity这里只能为一个字符串，这里为‘info’表明本生产者只将下面的message发送到info队列中，消费者也只能从info队列中接收info消息
message = 'Hello World!'
channel.basic_publish(exchange='direct_logs',#指明用于发布消息的交换机、关键字
                      routing_key=severity,#绑定关键字，即将message与关键字info绑定，明确将消息发送到哪个关键字的队列中。
                      body=message)
print(" [生产者] Sent %r:%r" % (severity, message))
s_conn.close()
```

### 消费者

```python
import pika
import sys


s_conn = pika.BlockingConnection(pika.ConnectionParameters('127.0.0.1'))#创建连接
channel = s_conn.channel()  #在连接上创建一个频道

channel.exchange_declare('direct_logs', 'direct')#创建交换机，命名为‘direct_logs’并声明exchange类型为关键字类型。

result = channel.queue_declare(exclusive=True)#创建随机队列，当消费者与rabbitmq断开连接时，这个队列将自动删除。
queue_name = result.method.queue#分配随机队列的名字。

severities = ['info', 'err']#可以接收绑定关键字info或err的消息，列表中也可以只有一个
if not severities: #判断如果输入有误，输出用法
    sys.stderr.write("Usage: %s [info] [warning] [error]\n" % sys.argv[0])
    sys.exit(1)

for severity in severities:
    channel.queue_bind(exchange='direct_logs',#将交换机、队列、关键字绑定在一起，使消费者只能根据关键字从不同队列中取消息
                       queue=queue_name,
                       routing_key=severity) #该消费者绑定的关键字。

print(' [消费者] Waiting for logs. To exit press CTRL+C')

def callback(ch, method, properties, body):#定义回调函数，接收消息
    print(" [消费者] %r:%r" % (method.routing_key, body))

channel.basic_consume(callback,
                      queue=queue_name,
                      no_ack=True)#消费者接收消息后，不给rabbimq回执确认。

channel.start_consuming()#循环等待消息接收。
```

## topic

direct规则是严格意义上的匹配，换言之Routing Key必须与Binding Key相匹配的时候才将消息传送给Queue，那么topic这个规则就是模糊匹配，可以通过通配符满足一部分规则就可以传送.

消息发送到topic类型的exchange上时不能随意指定routing_key（一定是指由一系列由点号连接单词的字符串，单词可以是任意的，但一般都会与消息或多或少的有些关联）。Routing key的长度不能超过255个字节。

Binding key也一定要是同样的方式。Topic类型的exchange就像一个直接的交换：一个由生产者指定了确定routing key的消息将会被推送给所有Binding key能与之匹配的消费者。然而这种绑定有两种特殊的情况：

- *（星号）：可以（只能）匹配一个单词
- \#（井号）：可以匹配多个单词（或者零个）

下边来举个例子：

![222234326373928](https://ws2.sinaimg.cn/large/006tKfTcgy1g1dyznf4jyj30bs04rmx8.jpg)

在这个例子中，我们将会发送一些描述动物的消息。Routing key的第一个单词是描述速度的，第二个单词是描述颜色的，第三个是描述物种的：“<speed>.<colour>.<species>”。

这里我们创建三个Binding：Binding key为”*.orange.*”的Q1，和binding key为”*.*.rabbit”和”lazy.#”的Q2。

这些binding可以总结为：

- Q1对所有橘色的（orange）的动物感兴趣；
- Q2希望能拿到所有兔子的（rabbit）信息，还有比较懒惰的（lazy.#）动物信息。

一条以” quick.orange.rabbit”为routing key的消息将会推送到Q1和Q2两个queue上，routing key为“lazy.orange.elephant”的消息同样会被推送到Q1和Q2上。但如果routing key为”quick.orange.fox”的话，消息只会被推送到Q1上；routing key为”lazy.brown.fox”的消息会被推送到Q2上，routing key为"lazy.pink.rabbit”的消息也会被推送到Q2上，但同一条消息只会被推送到Q2上一次。

如果在发送消息时所指定的exchange和routing key在消费者端没有对应的exchange和binding key与之绑定的话，那么这条消息将会被丢弃掉。例如："orange"和"quick.orange.male.rabbit"。但是routing为”lazy.orange.male.rabbit”的消息，将会被推到Q2上。

### 消费者

```python
import pika
import sys


s_conn = pika.BlockingConnection(pika.ConnectionParameters('127.0.0.1'))#创建连接
channel = s_conn.channel()#在连接上创建一个频道

channel.exchange_declare('topic_logs', 'topic')  # 声明exchange的类型为模糊匹配。

result = channel.queue_declare(exclusive=True)  # 创建随机一个队列当消费者退出的时候，该队列被删除。
queue_name = result.method.queue  # 创建一个随机队列名字。

binding_keys = ['*.orange.*', '*.*.rabbit', "lazy.#"]#绑定键。‘#’匹配所有字符，‘*’匹配一个单词。这里列表中可以为一个或多个条件，能通过列表中字符匹配到的消息，消费者都可以取到
if not binding_keys:
    sys.stderr.write("Usage: %s [binding_key]...\n" % sys.argv[0])
    sys.exit(1)

for binding_key in binding_keys:#通过循环绑定多个“交换机-队列-关键字”，只要消费者在rabbitmq中能匹配到与关键字相应的队列，就从那个队列里取消息
    channel.queue_bind(exchange='topic_logs',
                       queue=queue_name,
                       routing_key=binding_key)

print(' [*] Waiting for logs. To exit press CTRL+C')


def callback(ch, method, properties, body):
    print(" [x] %r:%r" % (method.routing_key, body))


channel.basic_consume(callback,
                      queue=queue_name,
                      no_ack=True)#不给rabbitmq发送确认

channel.start_consuming()#循环接收消息
```

### 生产者

```python
import pika

s_conn = pika.BlockingConnection(pika.ConnectionParameters('127.0.0.1'))#创建连接
channel = s_conn.channel()  #在连接上创建一个频道

channel.exchange_declare('topic_logs', 'topic')  # 创建模糊匹配类型的exchange。。

routing_key = 'lazy'##这里关键字必须为点号隔开的单词，以便于消费者进行匹配。引申：这里可以做一个判断，判断产生的日志是什么级别，然后产生对应的routing_key，使程序可以发送多种级别的日志
message = 'Hello World!'
channel.basic_publish(exchange='topic_logs',#将交换机、关键字、消息进行绑定
                      routing_key=routing_key,  # 绑定关键字，将队列变成[warn]日志的专属队列
                      body=message)
print(" [x] Sent %r:%r" % (routing_key, message))
s_conn.close()
```

# RPC

基于rabbitmq的rpc远程调用，主要有几点需要注意：

1. client端告诉server需要把结果数据放在哪个队列中，因为可能有多个client, 一个server, 把client发送过来的数据放到哪个队列中由client来决定
2. 因为client可以发送多条命令，多条命令的结果也是放在一个队列中，所以需要对结果加以区分

基于rabbitmq的rpc大致流程如下：

* 当客户端启动后，它创建一个匿名的唯一的回调队列
* 对一个RPC请求, 客户端发送一个消息包含两个属性： reply_to （用来设置回调队列）和 correlation_id（用来为每个请求设置一个唯一标识）
* 请求发送到 rpc_queue队列
* RPC worker( 服务端) 在那个队列中等待请求，当一个请求出现后，服务端就执行一个job并将结果消息发送给客户端，使用reply_to字段中的队列

* 客户端在callback 队列中等待数据, 当一个消息出现后，检查这个correlation_id属性,如果和请求中的值匹配将返回给应用

![img](https://ws1.sinaimg.cn/large/006tKfTcgy1g1e5ptrj7ej30g005kweo.jpg)

## rpc client

```python
import pika
import uuid


class FibonacciRpcClient(object):
    def __init__(self):
        self.connection = pika.BlockingConnection(pika.ConnectionParameters(
            host='localhost'))

        self.channel = self.connection.channel()

        result = self.channel.queue_declare(exclusive=True)
        self.callback_queue = result.method.queue

        self.channel.basic_consume(self.on_response, no_ack=True,
                                   queue=self.callback_queue)

    def on_response(self, ch, method, props, body):
        if self.corr_id == props.correlation_id:
            self.response = body

    def call(self, n):
        self.response = None
        self.corr_id = str(uuid.uuid4())
        self.channel.basic_publish(exchange='',
                                   routing_key='rpc_queue',
                                   properties=pika.BasicProperties(
                                       reply_to=self.callback_queue,
                                       correlation_id=self.corr_id,
                                   ),
                                   body=str(n))
        while self.response is None:
            """
            所有和coon绑定的channel，都会正式发布和正式接受数据
            这也是为啥init的basic_consume准备接受数据可以奏效，在这一点类似于start_consume
            """
            self.connection.process_data_events()
        return int(self.response)


fibonacci_rpc = FibonacciRpcClient()

print(" [x] Requesting fib(30)")
response = fibonacci_rpc.call(30)
print(" [.] Got %r" % response)
```

## rpc server 

```python
import pika
import time

connection = pika.BlockingConnection(pika.ConnectionParameters(
    host='localhost'))

channel = connection.channel()

channel.queue_declare(queue='rpc_queue')


def fib(n):
    if n == 0:
        return 0
    elif n == 1:
        return 1
    else:
        return fib(n - 1) + fib(n - 2)


def on_request(ch, method, props, body):
    n = int(body)

    print(" [.] fib(%s)" % n)
    response = fib(n)

    ch.basic_publish(exchange='',
                     routing_key=props.reply_to,
                     properties=pika.BasicProperties(correlation_id= \
                                                         props.correlation_id),
                     body=str(response))
    ch.basic_ack(delivery_tag=method.delivery_tag)


channel.basic_qos(prefetch_count=1)
channel.basic_consume(on_request, queue='rpc_queue')

print(" [x] Awaiting RPC requests")
channel.start_consuming()
```

<font color="red">celery channel和连接池管理</font>