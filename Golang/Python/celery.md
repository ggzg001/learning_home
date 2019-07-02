# celery 是什么

Celery 本身不是任务队列, 是管理分布式任务队列的工具. 它封装了操作常见任务队列的各种操作, 我们使用它可以快速进行任务队列的使用与管理.它的基本工作就是管理分配任务到不同的服务器，并且取得结果。至于说服务器之间是如何进行通信的？这个Celery本身不能解决。

一个Celery有三个核心组件：

- 客户端: 用于发布后台作业；当与 Flask 一起工作的时候，客户端与 Flask 应用一起运行。
- workers: 运行后台作业的进程。Celery 支持本地和远程的 workers，可以在本地服务器上启动一个单独的 worker，也可以在远程服务器上启动worker，需要拷贝代码；
- 消息代理: 客户端通过消息队列和 workers 进行通信，Celery 支持多种方式来实现这些队列。最常用的代理就是 RabbitMQ 和 Redis

RabbitMQ作为消息管理系统已经可以实现异步的发送消息，为什么还要使用Celery?

Celery相当于包装了一个现成的系统，可以方便的在项目中操作RabbitMQ这个消息队列介质，减少在RabbitMQ上编写脚本的任务。最直接的例子就是在Celery Python里，只需要config一下settings，然后就可以用decorator轻松使用消息队列，而不用在RabbitMQ上编写复杂的脚本。

# celery特性

```
方便查看定时任务的执行情况, 如 是否成功, 当前状态, 执行任务花费的时间等.
使用功能齐备的管理后台或命令行添加,更新,删除任务.
方便把任务和配置管理相关联.
可选 多进程, Eventlet 和 Gevent 三种模型并发执行.
提供错误处理机制.
提供多种任务原语, 方便实现任务分组,拆分,和调用链.
支持多种消息代理和存储后端.
Celery 是语言无关的.它提供了python 等常见语言的接口支持

```

# celery组件

## Celery 扮演生产者和消费者的角色

* Celery Beat : 任务调度器. Beat 进程会读取配置文件的内容, 周期性的将配置中到期需要执行的任务发送给任务队列.

* Celery Worker : 执行任务的消费者, 通常会在多台服务器运行多个消费者, 提高运行效率.

* Broker : 消息代理, 队列本身. 也称为消息中间件. 接受任务生产者发送过来的任务消息, 存进队列再按序分发给任务消费方(通常是消息队列或者数据库).

* Producer : 任务生产者. 调用 Celery API , 函数或者装饰器, 而产生任务并交给任务队列处理的都是任务生产者.

* Result Backend : 任务处理完成之后保存状态信息和结果, 以供查询

## 产生任务的方式

1. 发布者发布任务(WEB 应用)
2. 任务调度按期发布任务(定时任务)

# Celery 序列化

在客户端和消费者之间传输数据需要 序列化和反序列化. Celery 支出的序列化方案如下所示:

| 方案    | 说明                                                         |
| ------- | ------------------------------------------------------------ |
| pickle  | pickle 是Python 标准库中的一个模块, 支持 Pyuthon 内置的数据结构, 但他是 Python 的专有协议. Celery 官方不推荐. |
| json    | json 支持多种语言, 可用于跨语言方案.                         |
| yaml    | yaml 表达能力更强, 支持的数据类型较 json 多, 但是 python 客户端的性能不如 json |
| msgpack | 二进制的类 json 序列化方案, 但比 json 的数据结构更小, 更快.  |



# 适用场景

* 可以在 Request-Response 循环之外执行的操作：发送邮件、推送消息。
* 耗时的操作：调用第三方 API、视频处理（前端通过 AJAX 展示进度和结果）
* 周期性任务：取代 crontab。

# 尝鲜

一般redis做结果存储，使用rabbitmq做任务队列

```python
# tasks.py
from celery import Celery
app = Celery('tasks', broker='amqp://username:passwd@ip:port/varhost',backend='redis://username:passwd@ip:6390/db')

@app.task
def add(x, y):
    return x + y

if __name__ == '__main__':
    result = add.delay(30, 42)

# broker:任务队列的中间人；
# backend:任务执行结果的存储；
```

- app.task装饰add函数成一个Task实例，add.delay函数将task实例序列化后，通过librabbitmq库的方法将任务发送到rabbitmq；
- 该过程创建一个名字为celery的exchange交换机，类型为direct（直连交换机）;创建一个名为celery的queue，队列和交换机使用路由键celery绑定；
- 打开rabbitmq管理后台，可以看到有一条消息已经在celery队列中；

序列化的数据反序列化：

```python
import pickle
import base64
result = base64.b64decode('gAJ9cQAoWAQAAAB0YXNrcQFYGAAAAHRlc3RfY2VsZXJ5LmFkZF90b2dldGhlcnECWAIAAABpZHEDWCQAAAA2NmQ1YTg2Yi0xZDM5LTRjODgtYmM5OC0yYzE4YjJjOThhMjFxBFgEAAAAYXJnc3EFSwlLKoZxBlgGAAAAa3dhcmdzcQd9cQhYBwAAAHJldHJpZXNxCUsAWAMAAABldGFxCk5YBwAAAGV4cGlyZXNxC05YAwAAAHV0Y3EMiFgJAAAAY2FsbGJhY2tzcQ1OWAgAAABlcnJiYWNrc3EOTlgJAAAAdGltZWxpbWl0cQ9OToZxEFgHAAAAdGFza3NldHERTlgFAAAAY2hvcmRxEk51Lg==')
print(pickle.loads(result))
```



启动worker：`celery -A app.celery_tasks.celery worker -Q queue --loglevel=info`

```python
-A(APP)参数指定创建的celery对象的位置，该app.celery_tasks.celery指的是app包下面的celery_tasks.py模块的celery实例，注意一定是初始化后的实例，后面加worker表示该实例就是任务执行者；
-Q参数指的是该worker接收指定的队列的任务，这是为了当多个队列有不同的任务时可以独立；如果不设会接收所有的队列的任务；
-l参数指定worker输出的日志级别；
-P: –pool=prefork, 并发模型，可选：prefork (默认，multiprocessing), eventlet, gevent, threads.
-c: –concurrency=10, 并发级别，prefork 模型下就是子进程数量，默认等于 CPU 核心数

```

任务结果存储在redis中,存在一个string类型的键值对

`celery-task-meta-7165049d-4141-447f-b9ce-f606d6953ef7`s

值为`{\"status\": \"SUCCESS\", \"result\": 3, \"traceback\": null, \"children\": [], \"task_id\": \"7165049d-4141-447f-b9ce-f606d6953ef7\"}`

该键值对的失效时间默认为24小时

# 配置

基本配置

```
CELERY_DEFAULT_QUEUE：默认队列
BROKER_URL  : 代理人即rabbitmq的网址
CELERYD_CONCURRENCY: 进程数
CELERY_RESULT_BACKEND：结果存储地址
CELERY_TASK_SERIALIZER：任务序列化方式
CELERY_RESULT_SERIALIZER：任务执行结果序列化方式
CELERY_TASK_RESULT_EXPIRES：任务过期时间
CELERY_ACCEPT_CONTENT：指定任务接受的内容序列化类型(序列化)，一个列表；
```

常用配置

```
# 注意，celery4版本后，CELERY_BROKER_URL改为BROKER_URL
BROKER_URL = 'amqp://username:passwd@host:port/虚拟主机名'
# 指定结果的接受地址
CELERY_RESULT_BACKEND = 'redis://username:passwd@host:port/db'
# 指定任务序列化方式
CELERY_TASK_SERIALIZER = 'msgpack' 
# 指定结果序列化方式
CELERY_RESULT_SERIALIZER = 'msgpack'
# 任务过期时间,celery任务执行结果的超时时间
CELERY_TASK_RESULT_EXPIRES = 60 * 20   
# 指定任务接受的序列化类型.
CELERY_ACCEPT_CONTENT = ["msgpack"]   
# 任务发送完成是否需要确认，这一项对性能有一点影响     
CELERY_ACKS_LATE = True  
# 压缩方案选择，可以是zlib, bzip2，默认是发送没有压缩的数据
CELERY_MESSAGE_COMPRESSION = 'zlib' 
# 规定完成任务的时间
CELERYD_TASK_TIME_LIMIT = 5  # 在5s内完成任务，否则执行该任务的worker将被杀死，任务移交给父进程
# celery worker的并发数，默认是服务器的内核数目,也是命令行-c参数指定的数目
CELERYD_CONCURRENCY = 4 
# celery worker 每次去rabbitmq预取任务的数量
CELERYD_PREFETCH_MULTIPLIER = 4 
# 每个worker执行了多少任务就会死掉，默认是无限的
CELERYD_MAX_TASKS_PER_CHILD = 40 
# 设置默认的队列名称，如果一个消息不符合其他的队列就会放在默认队列里面，如果什么都不设置的话，数据都会发送到默认的队列中
CELERY_DEFAULT_QUEUE = "default" 
# 设置详细的队列
CELERY_QUEUES = {
    "default": { # 这是上面指定的默认队列
        "exchange": "default",
        "exchange_type": "direct",
        "routing_key": "default"
    },
    "topicqueue": { # 这是一个topic队列 凡是topictest开头的routing key都会被放到这个队列
        "routing_key": "topic.#",
        "exchange": "topic_exchange",
        "exchange_type": "topic",
    },
    "task_eeg": { # 设置扇形交换机
        "exchange": "tasks",
        "exchange_type": "fanout",
        "binding_key": "tasks",
    },
}
```

### ETA and countdown

eta必须是一个datatime对象。你可以设定一个eta，可以让你的任务在这个eta开始。
 countdown是一个整型，它是eta的简版，以秒为单位。
 这两个都保证任务会在这个时间后执行，但是这个时间无法非常确定，因为各方面的原因（网络延时，任务队列太繁忙）

### Expiration

expires参数定义了一个可选的到期时间，可以以秒为单位，也可以以datetime。



# celery对象

```
class Celery(object):
    def __init__(self, main=None, loader=None, backend=None,
                 amqp=None, events=None, log=None, control=None,
                 set_as_current=True, accept_magic_kwargs=False,
                 tasks=None, broker=None, include=None, changes=None,
                 config_source=None, fixups=None, task_cls=None,
                 autofinalize=True, **kwargs):

# 常用的需要配置的参数   
main:如果作为__main__运行，则为主模块的名称。用作自动生成的任务名称的前缀
loader:当前加载器实例。
backend:任务结果url；
amqp:AMQP对象或类名，一般不管；
log:日志对象或类名；
set_as_current:将本实例设为全局当前应用
tasks:任务注册表。
broker:使用的默认代理的URL,任务队列；
include:每个worker应该导入的模块列表，以实例创建的模块的目录作为起始路径；
```

这些参数都是celery实例化的配置，我们也可以不写，然后使用config_from_object方法加载配置。

## 创建异步任务的方法task

任何被task修饰的方法都会被创建一个Task对象，变成一个可序列化并发送到远程服务器的任务；它有多种修饰方式

* 默认参数

  `@celery.task
  def function_name():
  pass`

* 指定参数

  ```
  @celery.task(bind=True, name='name')
  def function_name():
      pass
  
  # task方法参数
  name:可以显式指定任务的名字；默认是模块的命名空间中本函数的名字。
  serializer：指定本任务的序列化的方法；
  bind:一个bool值，设置是否绑定一个task的实例，如果绑定，task实例会作为参数传递到任务方法中，可以访问task实例的所有的属性，即前面反序列化中那些属性
  base:定义任务的基类，可以以此来定义回调函数，默认是Task类，我们也可以定义自己的Task类
  default_retry_delay：设置该任务重试的延迟时间，当任务执行失败后，会自动重试，单位是秒，默认3分钟；
  autoretry_for：设置在特定异常时重试任务，默认False即不重试；
  retry_backoff：默认False，设置重试时的延迟时间间隔策略；
  retry_backoff_max：设置最大延迟重试时间，默认10分钟，如果失败则不再重试；
  retry_jitter：默认True，即引入抖动，避免重试任务集中执行
  ```

  ```
  # 当bind=True时，add函数第一个参数是self，指的是task实例
  @task(bind=True)  # 第一个参数是self，使用self.request访问相关的属性
  def add(self, x, y):
      try:
          logger.info(self.request.id)
      except:
          self.retry() # 当任务失败则进行重试
  ```

  ## 

## 自定义Task基类

```
import celery

class MyTask(celery.Task):
    # 任务失败时执行
    def on_failure(self, exc, task_id, args, kwargs, einfo):
        print('{0!r} failed: {1!r}'.format(task_id, exc))
    # 任务成功时执行
    def on_success(self, retval, task_id, args, kwargs):
        pass
    # 任务重试时执行
    def on_retry(self, exc, task_id, args, kwargs, einfo):
        pass

@task(base=MyTask)
def add(x, y):
    raise KeyError()

#方法相关的参数
exc:失败时的错误的类型；
task_id:任务的id；
args:任务函数的参数；
kwargs:键值对参数；
einfo:失败或重试时的异常详细信息；
retval:任务成功执行的返回值；
```

## 调用异步任务

调用异步任务有三个方法:

```
task.delay():这是apply_async方法的别名,但接受的参数较为简单；
task.apply_async(args=[arg1, arg2], kwargs={key:value, key:value})：可以接受复杂的参数
send_task():可以发送未被注册的异步任务，即没有被celery.task装饰的任务；
```

### send_task

```
# tasks.py
from celery import Celery
app = Celery()
def add(x,y):
    return x+y

app.send_task('tasks.add',args=[3,4])  # 参数基本和apply_async函数一样
# 但是send_task在发送的时候是不会检查tasks.add函数是否存在的，即使为空也会发送成功，所以celery执行是可能找不到该函数报错；
```

### delay

delay方法是apply_async方法的简化版，不支持执行选项，只能传递任务的参数

```
@app.task
def add(x, y, z=0):
    return x + y

add.delay(30,40,z=5) # 包括位置参数和关键字参数
```

### apply_async

apply_async支持执行选项，它会覆盖全局的默认参数和定义该任务时指定的执行选项，本质上还是调用了send_task方法.

```
add.apply_async(args=[30,40], kwargs={'z':5})

# 其他参数
task_id:为任务分配唯一id，默认是uuid;
countdown : 设置该任务等待一段时间再执行，单位为s；
eta : 定义任务的开始时间；eta=time.time()+10;
expires : 设置任务时间，任务在过期时间后还没有执行完毕或者没有被执行则被丢弃；
retry : 如果任务失败后, 是否重试;使用true或false，默认为true
shadow：重新指定任务的名字str，覆盖其在日志中使用的任务名称；
retry_policy : {},重试策略.如下：
    max_retries : 最大重试次数, 默认为 3 次.
    interval_start : 重试等待的时间间隔秒数, 默认为 0 , 表示直接重试不等待.
    interval_step : 每次重试让重试间隔增加的秒数, 可以是数字或浮点数, 默认为 0.2
    interval_max : 重试间隔最大的秒数, 即 通过 interval_step 增大到多少秒之后, 就不在增加了, 可以是数字或者浮点数, 默认为 0.2 .

routing_key:自定义路由键；
queue：指定发送到哪个队列；
exchange：指定发送到哪个交换机；
priority：任务队列的优先级，0到255之间，对于rabbitmq来说0是最高优先级；
serializer：任务序列化方法；通常不设置；
compression：压缩方案，通常有zlib, bzip2
headers：为任务添加额外的消息；
link：任务成功执行后的回调方法；是一个signature对象；可以用作关联任务；
link_error: 任务失败后的回调方法，是一个signature对象；

# 如下
add.apply_async((2, 2), retry=True, retry_policy={
    'max_retries': 3,
    'interval_start': 0,
    'interval_step': 0.2,
    'interval_max': 0.2,
})
```

eta 和 expires 其实是两种不同的表现形式

## 获取任务结果和状态

由于celery发送的都是去其他进程执行的任务，如果需要在客户端监控任务的状态.

```
r = task.apply_async()
r.ready()     # 查看任务状态，返回布尔值,  任务执行完成, 返回 True, 否则返回 False.
r.wait()      # 会阻塞等待任务完成, 返回任务执行结果，很少使用；
r.get(timeout=1)       # 获取任务执行结果，可以设置等待时间，如果超时但任务未完成返回None；
r.result      # 任务执行结果，未完成返回None；
r.state       # PENDING, START, SUCCESS，任务当前的状态
r.status      # PENDING, START, SUCCESS，任务当前的状态
r.successful  # 任务成功返回true
r.traceback  # 如果任务抛出了一个异常，可以获取原始的回溯信息 
```

# celery 工作流

**Celery 的工作流具有非常浓厚的函数式编程风格**

## 任务签名 signature

使用 Celery Signature 签名（Subtask 子任务），可生成一个特殊的对象——任务签名。任务签名和函数签名类似，除了包含函数的常规声明信息（形参、返回值）之外，还包含了执行该函数所需要的调用约定和（全部/部分）实参列表。你可以在任意位置直接使用该签名，甚至不需要考虑实参传递的问题（实参可能在生成签名时就已经包含）。<font color="red">可见，任务签名的这种特性能够让不同任务间的组合、嵌套、调配变得简单。</font>

**任务签名支持「直接执行」和「Worker 执行」两种方式**

### **生成任务签名并直接执行**

```shell
# 方式一
>>> add.signature((3, 4), countdown=10)
proj.task.tasks.add(3, 4)
>>> s_add = add.signature((3, 4), countdown=10)
>>> s_add()
7


# 方式二
>>> add.s(3, 4)
proj.task.tasks.add(3, 4)
>>> s_add = add.s(3, 4)
>>> s_add()
7

```

### **生成任务签名并交由 Worker 执行**

```shell
# 调用 delay/apply_async 方法将签名加载到 Worker 中执行
>>> s_add = add.s(2, 2)
>>> s_add.delay()       
<AsyncResult: 75be3776-b36b-458e-9a89-512121cdaa32>
>>> s_add.apply_async()
<AsyncResult: 4f1bf824-331a-42c0-9580-48b5a45c2f7a>


>>> s_add = add.s(2, 2)
>>> s_add.delay(debug=True)     # 任务签名支持动态传递实参
<AsyncResult: 1a1c97c5-8e81-4871-bb8d-def39eb539fc>
>>> s_add.apply_async(kwargs={'debug': True})
<AsyncResult: 36d10f10-3e6f-46c4-9dde-d2eabb24c61c>

```

Celery 中的偏函数实际上就是固化了部分参数的任务签名.

## 回调函数

回调函数就是一个通过函数指针（函数名）来调用的函数。如果你把函数指针作为参数传递给另一个函数，当这个指针被用来调用其所指向的函数时，我们就称之为回调。回调函数在发生特定事件或满足指定条件时被回调，从而对该事件或条件进行响应。

Celery 中的回调函数依旧是一个任务签名，而触发回调的事件或条件就是「任务执行成功」和「任务执行失败」。 调用 apply_async 方法的 link/link_error 来指定回调函数.

```python
# filename: tasks.py
from proj.celery import app

@app.task
def add(x, y, debug=False):
    if debug:
        print("x: %s; y: %s" % (x, y))
    return x + y

@app.task
def log(msg):
    return "LOG: %s" % msg

```

### 任务成功执行的回调

```shell
# 默认的，回调函数的实参来自于上一个任务的执行结果
>>> from proj.task.tasks import add, log
>>> result = add.apply_async(args=(1, 2), link=log.s())
>>> result.get()
3

```

### **任务执行失败回调**

```sh
>>> result = add.apply_async(args=(1, 2), link_error=log.s())
>>> result.status
u'SUCCESS'
>>> result.get()
3
```

如果你希望回调函数的实参不来自于上一个任务的结果，那么你可以将回调函数的实参设置为 immutable（不可变的）

```shell
>>> add.apply_async((2, 2), link=log.signature(args=('Task SUCCESS', ), immutable=True))
<AsyncResult: c136ad34-68b4-49a9-8462-84ac8cd75810>
# 简易写法
>>> add.apply_async((2, 2), link=log.si('Task SUCCESS'))
<AsyncResult: bbb35212-5a6b-427b-a6a6-d1eb5359365e>

```

回调函数和偏函数可以结合使用，拥有了更好的灵活性

```
result = add.apply_async((2, 2), link=add.s(2))
```

需要注意的是，回调函数的结果不会被返回，所以使用 Result.get 只也能获取第一个任务的结果

```
>>> result = add.apply_async((2, 2), link=add.s(2))
>>> result.get()
4
```

## group 任务组

任务组函数接收一组任务签名列表，返回一个新的任务签名——签名组，调用签名组会并行执行其包含的所有任务签名，并返回所有结果的列表。常用于一次性创建多个任务.

```
>>> from celery import group
>>> from proj.task.tasks import add
>>> add_group_sig = group(add.s(i, i) for i in range(10))
>>> result = add_group_sig.delay()
>>> result.get()
[0, 2, 4, 6, 8, 10, 12, 14, 16, 18]
# 返回多个结果
>>> result.results
[<AsyncResult: 1716cfd0-e87c-4b3d-a79f-1112958111b1>, 
 <AsyncResult: a7a18bde-726e-49b2-88ed-aeba5d3bf5f2>, 
 <AsyncResult: b9d9c538-2fad-475a-b3d1-bd1488278ce2>, 
 <AsyncResult: 6f370fdd-ed7e-430a-a335-af4650ca15cf>, 
 <AsyncResult: a6ddbe14-5fbd-4079-9f12-35ebbc89d89b>, 
 <AsyncResult: 65dece11-9f38-4940-9fa0-7fcf09266c7a>, 
 <AsyncResult: 8205ffc0-1056-469a-a642-96676d1518e7>, 
 <AsyncResult: e77b7e2b-66d2-48b8-9ffd-4f8fa7d9f4a4>, 
 <AsyncResult: 355b7d01-72c1-4b00-8572-407e751d76c3>, 
 <AsyncResult: aa561ac3-656f-4c81-9e3c-00c64ca49181>] 

```

## chain 任务链

任务链函数接收若干个任务签名，并返回一个新的任务签名——链签名。调用链签名会并串行执行其所含有的任务签名，每个任务签名的执行结果都会作为第一个实参传递给下一个任务签名，最后只返回一个结果。

```
>>> from celery import chain
>>> from proj.task.tasks import add
>>> add_chain_sig = chain(add.s(1, 2), add.s(3))
# 精简语法
>>> add_chain_sig = (add.s(1, 2) | add.s(3))
>>> result = add_chain_sig.delay()          # ((1 + 2) + 3)
>>> result.status
u’SUCCESS’
>>> result.get()
6
# 仅返回最终结果
>>> result.results
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
AttributeError: 'AsyncResult' object has no attribute 'results'
# 结合偏函数
>>> add_chain_sig = chain(add.s(1), add.s(3))
>>> result = add_chain_sig.delay(3)        # ((3 + 1) + 3)
>>> result.get()
7

```

## chord 复合任务

复合任务函数生成一个任务签名时，会先执行一个组签名（不支持链签名），等待任务组全部完成时执行一个回调函数。

```
>>> from proj.task.tasks import add, log
>>> from celery import chord, group, chain
>>> add_chord_sig = chord(group(add.s(i, i) for i in range(10)), log.s())
>>> result = add_chord_sig.delay()
>>> result.status
u'SUCCESS'
>>> result.get()
u'LOG: [0, 2, 4, 6, 8, 10, 12, 16, 14, 18]'

```

任务组函数依旧是并行执行的，但任务组和回调函数时串行执行的，所以 chord 被称为复合任务函数。

## chunks 任务块

任务块函数能够让你将需要处理的大量对象分为分成若干个任务块，如果你有一百万个对象，那么你可以创建 10 个任务块，每个任务块处理十万个对象。有些人可能会担心，分块处理会导致并行性能下降，实际上，由于避免了消息传递的开销，因此反而会大大的提高性能。

```
>>> add_chunks_sig = add.chunks(zip(range(100), range(100)), 10)
>>> result = add_chunks_sig.delay()
>>> result.get()
[[0, 2, 4, 6, 8, 10, 12, 14, 16, 18], 
 [20, 22, 24, 26, 28, 30, 32, 34, 36, 38], 
 [40, 42, 44, 46, 48, 50, 52, 54, 56, 58], 
 [60, 62, 64, 66, 68, 70, 72, 74, 76, 78], 
 [80, 82, 84, 86, 88, 90, 92, 94, 96, 98], 
 [100, 102, 104, 106, 108, 110, 112, 114, 116, 118], 
 [120, 122, 124, 126, 128, 130, 132, 134, 136, 138], 
 [140, 142, 144, 146, 148, 150, 152, 154, 156, 158], 
 [160, 162, 164, 166, 168, 170, 172, 174, 176, 178], 
 [180, 182, 184, 186, 188, 190, 192, 194, 196, 198]]

```

## map/starmap 任务映射

映射函数，与 Python 函数式编程中的 map 内置函数相似。都是将序列对象中的元素作为实参依次传递给一个特定的函数。 
map 和 starmap 的区别在于，前者的参数只有一个，后者支持的参数有多个

```
>>> add.starmap(zip(range(10), range(100)))
[proj.task.tasks.add(*x) for x in [(0, 0), (1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7), (8, 8), (9, 9)]]
>>> result = add.starmap(zip(range(10), range(100))).delay()
>>> result.get()
[0, 2, 4, 6, 8, 10, 12, 14, 16, 18]

```







Expires 参数表示任务在这个时间还没执行结束就会被放弃