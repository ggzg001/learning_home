# 内置的log模块

golang的日志输出一般用的是标准库log库包

log包几个常用的方法说明：

```go
//定义logger, 传入参数 文件，前缀字符串，flag标记
func New(out io.Writer, prefix string, flag int) *Logger
 
//设置flag格式
func SetFlags(flag int)
 
//配置log的输出格式
func SetPrefix(prefix string)
```

下面是golang log包参数中flag的用法。 flag有根据时间的，也有根据code行号的。 

```go
Ldate     				      // the date: 2009/01/23 形如 2009/01/23 的日期
Ltime                         // the time: 01:23:23   形如 01:23:23   的时间
Lmicroseconds                 // microsecond resolution: 01:23:23.123123.  形如01:23:23.123123   的时间
Llongfile                     // full file name and line number: /a/b/c/d.go:23 全路径文件名和行号
Lshortfile                    // final file name element and line number: d.go:23. overrides Llongfile 文件名和行号
LstdFlags     = Ldate | Ltime // 日期和时间
```

实例

```go
package main
import (
	"log"
	"os"
)
func main(){
	// 定义一个文件
	fileName := "ll.log"
	logFile,err  := os.Create(fileName)
	defer logFile.Close()

	if err != nil {
		// 2019/03/11 11:29:25 open file error !
		log.Fatalln("open file error !")
	}
	// 创建一个日志对象
	debugLog := log.New(logFile,"[Debug]",log.LstdFlags)
	debugLog.Println("A debug message here")
	//配置一个日志格式的前缀
	debugLog.SetPrefix("[Info]")
	debugLog.Println("A Info Message here ")
	//配置log的Flag参数
	debugLog.SetFlags(debugLog.Flags() | log.Lshortfile)
	debugLog.Println("A different prefix")
}
"""
[Debug]2019/03/11 11:30:55 A debug message here
[Info]2019/03/11 11:30:55 A Info Message here 
[Info]2019/03/11 11:30:55 main.go:24: A different prefix
"""
```

# seelog

日常需求：

1. 能设置不同的级别
2. 能把日志同时输出到终端和文件
3. 能对日志进行分割，能基于日期或者指定日志文件大小进行日志切割
4. 能在控制台对不同级别的日志以颜色加以区分

seelog模块能满足上述4个常用需求

## 官网配置

### 配置说明

```
1. type: 日志输出类型，有4中类型，分别是：sync，asyncloop(default)，asynctimer，adaptive
   type=“sync”：在同一个go中处理日志消息，仅当调用日志函数时才被执行。
   type=“asyncloop”：在单独的go中独自处理日志消息，循环从日志队列中读取日志并消费(输出到控制台或者文件)。
   type="asynctimer"：在单独的go中独自处理日志消息，在指定时间间隔去读取日志队列消息，所以该类型还需要配置一个间隔时间(纳秒)。
   type="adaptive"：在单独的go中独自处理日志消息，但是不是固定的每隔指定时间去读取日志消息，间隔时间与队列剩余的日志量有关，如果剩余日志量多，则间隔时间短，反之亦然
2. minlevel: 全局最低输出日志级别
3. maxlevel: 全局最高输出日志级别
4. exceptions: 日志的特殊处理情况，可根据指定文件或者函数进行日志输出
5. formatid: 输出格式标签，可以在formats中找到对应的标签
6. console: 将日志输出到控制台
7. splitter: 用于细分outputs日志格式，支持: file(文件), rollingfile(滚动文件), buffered(缓存到内存再输出到文件), smtp(发送日志邮件), con(网络转发)
8. rollingfile: 滚动文件，可基于日期(type="date")或者文件大小(type="size")进行日志切割，maxsize: 单个日志文件最大size，如果设置为100M，则maxsize=100*1024*1024，maxrolls: 最大文件数量，超出的日志文件数量会被滚动删除
9. buffered: 将日志先存在内存中，定期写入文件，适合日志并发量较大或 IO 比较紧张的场合，size:缓存大小, flushperiod:缓存时间
10. filter: 单独处理某级别的日志
11. formats: 日志输出格式

```

### 配置文件

```xml

<seelog type="asynctimer" asyncinterval="5000000" minlevel="debug" maxlevel="error">
    <exceptions>
        <exception funcpattern="*main.test*Something*" minlevel="info"/>
        <exception filepattern="*main.go" minlevel="error"/>
    </exceptions>
    <outputs formatid="main">
        <console/>

        <splitter formatid="format1">
            <file path="log.log"/>
            <file path="log2.log"/>
        </splitter>
        <splitter formatid="format2">
            <file path="log3.log"/>
            <file path="log4.log"/>
        </splitter>

        <rollingfile formatid="someformat" type="size" filename="./log/roll.log" maxsize="100" maxrolls="5" />

        <buffered formatid="testlevels" size="10000" flushperiod="1000">
            <file path="./log/bufFileFlush.log"/>
        </buffered>

        <filter levels="error">
            <file path="./log/error.log"/>
            <smtp senderaddress="noreply-notification-service@none.org" 
                  sendername="Automatic notification service" 
                  hostname="mail.none.org" 
                  hostport="587" 
                  username="nns" 
                  password="123">
                <recipient address="john-smith@none.com"/>
                <recipient address="hans-meier@none.com"/>
            </smtp>
            <conn net="tcp4" addr="server.address:5514" tls="true" insecureskipverify="true" />
        </filter>

    </outputs>
    <formats>
        <format id="main" format="%Date(2006 Jan 02/3:04:05.000000000 PM MST) [%Level] %Msg%n"/>
        <format id="someformat" format="%Ns [%Level] %Msg%n"/>
        <format id="testlevels" format="%Level %Lev %LEVEL %LEV %l %Msg%n"/>
        <format id="usetags" format="&lt;msg&gt;%Msg&lt;/time&gt;"/>
        <format id="format1" format="%Date/%Time [%LEV] %Msg%n"/>
        <format id="format2" format="%File %FullPath %RelFile %Msg%n"/>
    </formats>
</seelog>
```

### 实例

```go
package main

import (
	log "github.com/cihub/seelog"
)

func main() {
	defer log.Flush()

	logger, err := log.LoggerFromConfigAsFile("/Users/guwanhua/go/src/config.xml")
	if err != nil {
		log.Errorf("parse config.xml error: %v", err)
		return
	}

	log.ReplaceLogger(logger)

	log.Info("seelog test begin")

	for i := 0; i < 1000; i++ {
		log.Tracef("hello seelog trace, i = %d", i)
		log.Debugf("hello seelog debug, i = %d", i)
		log.Infof("hello seelog info, i = %d", i)
		log.Warnf("hello seelog warn, i = %d", i)
		log.Errorf("hello seelog error, i = %d", i)
		log.Criticalf("hello seelog critical, i = %d", i)
	}

	log.Debug("seelog test end")
}
```

Config.xml

```xml
<seelog minlevel="debug" maxlevel="error">
    <!-- 日志输出 -->
    <outputs formatid="main">
        <!-- 对控制台输出的Log按级别分别用颜色显示。6种日志级别我仅分了三组颜色，如果想每个级别都用不同颜色则需要简单修改即可 -->
        <filter levels="trace,debug,info">
            <console formatid="colored-default"/>
        </filter>

        <filter levels="warn">
            <console formatid="colored-warn"/>
        </filter>

        <filter levels="error,critical">
            <console formatid="colored-error"/>
        </filter>
        <!-- flushperiod 时间是毫秒,达到大小或达到时间就把缓冲数据到bufFileFlush.log -->
        <buffered formatid="main" size="1024" flushperiod="1000">
            <file path="/Users/guwanhua/go/src/go_code/project26/bufFileFlush.log"/>
         </buffered>

        <!-- 将日志输出到磁盘文件，按文件大小进行切割日志，单个文件最大1k，最多5个日志文件 -->
        <rollingfile formatid="main" type="size" filename="/Users/guwanhua/go/src/go_code/project26/default.log" maxsize="1024" maxrolls="5" />

    </outputs>

    <!-- 格式化 -->
    <formats>
        <format id="colored-default"  format="%EscM(38)%Date %Time [%LEV] %File:%Line | %Msg%n%EscM(0)"/>
        <format id="colored-warn"  format="%EscM(33)%Date %Time [%LEV] %File:%Line | %Msg%n%EscM(0)"/>
        <format id="colored-error"  format="%EscM(31)%Date %Time [%LEV] %File:%Line | %Msg%n%EscM(0)"/>
        <format id="main" format="%Date %Time [%LEV] %File:%Line | %Msg%n"/>
    </formats>

</seelog>
```



