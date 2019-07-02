并行和并发

并行：借助多核CPU来实现

并发：

 * 宏观：用户体验上，程序在并行执行
 * 微观：多个计划任务，顺序执行，cpu在飞速地进行切换

可以说，并行是并发的一部分



# 进程

## 进程状态

进程基本的状态有5种，分别为初始态、就绪态、运行态、挂起态和终止态。其中初始态是进程准备状态，常和就绪态结合来看。

就绪态：等待cpu分配时间片

挂起：主动放弃cpu, 等待除cpu以外的其他资源

## 孤儿进程和僵尸进程

父进程无法预测子进程的到底什么时候结束，需要通过系统调用来获取子进程的终止状态。

孤儿进程：父进程先于孤儿进程死亡，此时需要最顶层的init进程来收尸

僵尸进程：子进程终止，父进程不帮忙收尸，子进程残留资源存放于内核中

# 线程同步

同步即协同步调，按预定的先后顺序执行

线程同步，指一个线程发出某一个功能调用时，在没有得到结果之前，该调用不返还。同时其他线程为保证数据的一致性，不能调用该功能。

同步的目的是为了避免数据混乱，解决和时间有关的错误。其实，多个控制流，共同操作一个共享资源的情况，都需要同步

## 线程同步机制

互斥锁：又名建议锁，拿到锁以后，才能访问数据，没有拿到锁的线程，阻塞等待，等待拿锁的线程释放锁。

读写锁：一把锁(具有读属性和写属性)。写独占，读共享，写锁优先级高。

# Go并发

Go在语言层面实现并发(不需要程序员写代码去设计并发，只要学会基本的Go语法就能达到并发效果)，在Go中实现并发的两种手段：goroutine和channel。

主go程结束的时候，进程也随之结束了，那么进程里的所有协程也会全部退出。

## runtime包

### Gosched

用于让出CPU时间片，让出当前协程的执行权限，调度器安排其他等待的任务运行，并在下次获得CPU时间轮片的时候，从让出CPU的位置继续执行。

```go
package main

import (
	"fmt"
	"runtime"
)

func main() {
	go func() {
		for {
			runtime.Gosched()
			fmt.Println("this is in test")
		}
	}()
	for {
		fmt.Println("this is in main")
	}
}


```

### Goexit

立即终止当前go程，但是go程虽然终止了，但是调度器仍然确保所有已注册defer都会被执行

```go
package main

import (
	"fmt"
	"runtime"
)

func test()  {
	defer fmt.Println("ccc")
	runtime.Goexit()
	fmt.Println("ddd")
}

func main() {
	go func() {
		defer fmt.Println("aaa")
		test()
		defer fmt.Println("bbbb")
	}()
	for {
		;
	}
}
/*
ccc
aaa

test结束，go程结束，此时运行不到defer fmt.Println("bbbb")这一行代码
*/

```

### GOMAXPROC

用于设置可以并行的CPU的核数，并返回之前设置的值。

## channel

channel  是Go中的一个核心类型,用于解决协程的同步问题和协程之间数据共享的问题。Go中奉行通过通信来共享内存，而不是通过共享内存来通信。

channel根据长度的大小可以分为无缓冲channel和有缓冲channel

### 无缓冲channel

```go
package main

import "fmt"

func main()  {
	ch := make(chan bool)
	go func() {
		for i := 0; i < 2; i++ {
			fmt.Println("ok")
		}
		ch <- true
	}()
	ok := <- ch
	if ok {
		fmt.Println("main")
	}
}
/*
fmt.Println 打印是一个IO耗时操作，很容易失去CPU权限
*/
```

len(chan)：chan剩余未读取的数据个数，cap是容量

### 有缓冲channel

无缓冲channel是同步通信，有缓冲channel是异步通信。

### 关闭channel

一端往里写数据，一端从里读数据。读端怎么判断对端已经没有数据往里放了呢？此时可以借助channel的关闭来实现

if num, ok := <- chan 

关闭：num 无值，ok为false

没关闭：num有值，ok为true

写端已经关闭channel，可以从中读取数据。

 * 读无缓冲channel,读到0，说明写端关闭
 * 读有缓冲channel:如果缓冲区有数据，先读数据，读完数据后，可以继续读，读到0

### 单向channel

默认的双向channel可以隐式地转换为单向channel

## 生产者消费者模型

缓冲区的作用：解耦；并发；缓存(速度不一致暂存数据)

## 定时器

Timer: 创建定时器，指定定时时长，时间达到后，系统会把当前时间写入成员变量C中，此时可以进行读取，完成对chan的一次读操作。

After: 效果和Timer一样，只不过创建的时候返回可读channel

```go
package main

import (
	"fmt"
	"time"
)

func main()  {
	myTimer := time.NewTimer(time.Second * 2)
	go func() {
		// 定时器stop之后，系统不再往里放时间，此时没有死锁，因为channel没有关闭
		<- myTimer.C
		fmt.Println("定时达到了")
	}()
	myTimer.Stop()
	for {
		;
	}
}

```

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	fmt.Println("当前时间", time.Now())
	now := <- time.After(time.Second * 3)
	fmt.Println("现在的时间", now)
}


```



```go
package main

import (
	"fmt"
	"time"
)

func main()  {
	fmt.Println(time.Now())
	myTimer := time.NewTimer(time.Second * 10)
	myTimer.Reset(time.Second * 1)
	go func() {
		// 定时器stop之后，系统不再往里放时间，此时没有死锁，因为channel没有关闭
		data := <- myTimer.C
		fmt.Println("定时达到了", data)
	}()

	for {
		;
	}
}

```

### time.Ticker

Ticker是一个周期触发定时的定时器，它会按照一个时间间隔往channel发送当前时间，而channel的接受者可以以固定的时间间隔从channel中读取时间。

```go
package main

import (
	"fmt"
	"time"
)

func main()  {
	myTicker := time.NewTicker(time.Second * 2)
	go func() {
		for {
			now := <- myTicker.C
			fmt.Println(now)
		}

	}()

	for {
		;
	}
}

```

## select

Go中提供了一个关键字，可以用来监听channel上的数据流动。

与switch相比，select有比较多的限制，其中最大的一条限制是每个case语句必须是一个IO操作。

在一个select语句中，Go会按照顺序从头到尾评估每一个发送和接收的语句。

如果其中任意一条语句可以继续执行(即没有被阻塞)，那么就可以从可以任意执行的语句中随机选择一条来执行，然后退出select语句。

如果没有任意一条语句可以执行(即所有通道都阻塞)，那么可能有两种情况：

* 如果给出了default,那么就会执行default语句，同时程序的执行会从select语句后的语句中恢复
* 如果没有default语句，那么select将会被阻塞，直到最少有一个通信可以继续下去

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	ch := make(chan int)
	quit := make(chan bool)
	go func() {
		for i := 0; i < 5; i++ {
			ch <- i
			time.Sleep(time.Second)
		}
		close(ch)
		quit <- true
	}()

	for {
		select {
			case num := <- ch:
				fmt.Println("读到数据：", num)
			case b := <- quit:
				if b {
					return
				}
		//default:
		//	fmt.Println("什么都没有发生")
		}
	}
}


```

### 超时

```go
package main

import (
	"fmt"
	"runtime"
	"time"
)

func main() {
	c := make(chan int)
	b := make(chan bool)
	go func() {
		for {
			select {
			case v := <-c:
				fmt.Println(v) 
				// 超时会重置，也就是当某一次如果能取出数据，那么下一次记时从0开始
			case <- time.After(time.Second * 3):
				fmt.Println("time out")
				b <- true
				runtime.Goexit()
			}
		}
	}()
	<- b
	
}


```

## 锁

除了channel之外，但是Go也提供了传统的同步机制：锁

## 死锁

一般死锁问题，Go的编译器是可以检查出来的。但是对于隐式死锁(锁和channel混用)，Go编译器就无法检测出来。

1. 单go程自己死锁
2. go程间访问channel顺序死锁
3. 多go程，多channel交叉死锁

###单go程自己死锁

```go
package main

import "fmt"

func main() {
	c := make(chan int)
	c <- 789
	
	num := <- c
	fmt.Println(num)
}

```

channel的数据没有机会被消费，此时编译器检查出来这个现象就会报错。所以，channel应该至少在2个以上的go程中进行通信，否则死锁

### go程间访问channel顺序死锁

```go
package main

import "fmt"

func main() {
	ch := make(chan int)
	num := <- ch
	fmt.Println("num = ", num)
	go func() {
		ch <- 789
	}()
}
```

使用channel一端读(写), 要保证另一端写(读)操作，同时有机会执行。

### 多go程，多channel交叉死锁

```go
package main

func main() {
	ch1 := make(chan int)
	ch2 := make(chan int)
	go func() {
		for {
			select {
			case num := <- ch1:
				ch2 <- num
			}
		}
	}()
	for {
		select {
		case num := <- ch2:
			ch1 <- num
		}
	}
}


```

A go程，掌握M的同时，尝试拿N;  B go程，掌握N的同时，尝试拿M，造成僵持

## 互斥锁

```go
package main

import (
	"fmt"
	"sync"
	"time"
)

var mutex sync.Mutex

func printer(str string)  {
	mutex.Lock()
	for _, c := range str {
		fmt.Printf("%c", c)
		time.Sleep(time.Second)
	}
	mutex.Unlock()
}

func person1()  {
	printer("hello")
}

func person2()  {
	printer("world")
}

func main() {
	go person1()
	go person2()
	for {
		;
	}
}


```

## 读写锁

读写锁是一把锁，只不过同时拥有读属性和写顺序两种。有两组方法

一组是对写操作的锁定和解锁，简称写锁定和写解锁 Lock 和 Unlock

另一组是对写操作的锁定和解锁，简称写锁定和写解锁 RLock 和 RUnlock

### 隐式死锁

```go
package main

import (
	"fmt"
	"math/rand"
	"sync"
	"time"
)

var mutex sync.RWMutex

func read(in <- chan int, idx int)  {
	mutex.RLock()
	num := <- in
	fmt.Printf("%d th 写 %d", idx, num)
	mutex.RUnlock()
}

func write(out chan<- int, idx int)  {
	num := rand.Intn(100)
	mutex.Lock()
	out <- num
	fmt.Printf("%d th 写 %d", idx, num)
	mutex.Unlock()
}

func main() {
	rand.Seed(time.Now().UnixNano())
	ch := make(chan int)
	for i := 0; i < 5; i++ {
		go read(ch, i)
	}
	for i := 0; i < 5; i++ {
		go write(ch, i)
	}
	for {
		;
	}
	
}


```

go 程 read 在num := <- in这一句阻塞，go程在拿锁的时候mutex.Lock()阻塞。造成了隐式死锁. 为了防止这种情况，一般建议channel和锁不要混合使用。一种解决方式如下：

```go
package main

import (
	"fmt"
	"math/rand"
	"sync"
	"time"
)

var mutex sync.RWMutex

var m int

func read(in <- chan int, idx int)  {
	for {
		mutex.RLock()
		fmt.Printf("%d go程 读 %d\n", idx, m)
		time.Sleep(time.Second)
		mutex.RUnlock()
	}

}

func write(out chan<- int, idx int)  {
	for {
		num := rand.Intn(100)
		mutex.Lock()
		m = num
		fmt.Printf("%d go程 写 %d\n", idx, num)
		mutex.Unlock()
	}

}

func main() {
	rand.Seed(time.Now().UnixNano())
	ch := make(chan int)
	for i := 0; i < 5; i++ {
		go read(ch, i)
	}
	for i := 0; i < 5; i++ {
		go write(ch, i)
	}
	for {
		;
	}
	
}


```

## 条件变量

条件变量的作用并不保证在同一时刻仅有一个协程访问共享区的数据资源，而是在对应的共享数据的状态发生变化时，通知阻塞在某个条件下的协程。条件变量不是锁，在并发中不能达到同步的目的，但是条件变量总数和锁一起使用。

sync.Cond类型

```go
type Cond struct {
	noCopy noCopy

	// L is held while observing or changing the condition
	L Locker

	notify  notifyList
	checker copyChecker
}
```

### Wait

1. 阻塞(调用wait意味着想要等)
2. 释放锁(把锁让给其他人去做操作，例如消费者只有拿到锁取走数据生产者才能往里放东西)，和1是原子操作
3. 当被唤醒时，接触阻塞并重新获取锁

### Signal

单反通知

### Broadcast

广播

### 使用流程

1. 创建条件变量
2. 指定条件变量使用的锁
3. cond.L.Lock()  给公共区加锁(互斥量)
4. 判断是否达到阻塞条件， for 去判断，而不是if判断()
5. 访问公共区
6. 解锁条件变量使用的锁
7. 唤醒对端

```go
package main

import (
	"fmt"
	"math/rand"
	"sync"
	"time"
)

var cond sync.Cond

func producer(out chan<- int) {
	for {
		cond.L.Lock()
		/*
		这边采用for，其实是多了一次判断
		考虑这样一个情况，某个生产者是最后往里放，此时数据满了，发出一个信号
		如果是生产者被这个信号唤醒，那么就执行wait之后的代码，也就是 },如果
		是if，那么此时就会往里放数据，此时满了会阻塞，但是这种阻塞不能被唤醒，
		如果是for循环，你把我叫醒，那么我就再看看长度是不是满了，满了我就继续等待
		*/

		for len(out) == 3 {
			cond.Wait()
		}
		num := rand.Intn(100)
		out <- num
		fmt.Println("生产者生产了数据",num)
		cond.L.Unlock()
		cond.Signal()
		time.Sleep(time.Second)
	}
}

func consumer(in <- chan int)  {
	for {
		cond.L.Lock()
		for len(in) == 0 {
			cond.Wait()
		}
		num := <- in
		fmt.Println("消费者取到数据", num)
		cond.L.Unlock()
		cond.Signal()
		time.Sleep(time.Second)

	}

}

func main() {
	rand.Seed(time.Now().UnixNano())
	quit := make(chan bool)
	product := make(chan int, 3)
	cond.L = new(sync.Mutex)
	for i := 0; i < 5; i++ {
		go producer(product)
	}
	for i := 0; i < 3; i++ {
		go consumer(product)
	}
	// 这里的quit没有造成死锁，因为这里的其他go程可能会往里放数据，所以go编译器就没有判定为死锁
	<-quit
	
}


```































## 













今日问题：栈和堆(heap)，所有的函数都是在栈里面的，new的东西得到的结果是放在heap里面的，但是new出的变量p是放在stack里面的。stack的大小是很小的，一般就1到8M，但是heap，也就是可以new出来的空间却是很大的

空指针：未被初始化的指针

野指针：让一个指针指向无效的内存空间



