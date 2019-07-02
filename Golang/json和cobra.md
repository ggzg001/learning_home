## json

json数组用于编码数组和slice, json对象用于编码map和结构体

### 序列化

```go
var movies = []string{"jack", "alex"}
// prefix： 每一行输出的前缀，indent表示每一个层级的缩进
data, _ := json.MarshalIndent(movies, "", "  ")
// 把[]byte打印成字符串
fmt.Printf("%s", data)
```

结构体Tag：Color bool `json:"color,omitempty"`

omitempty表示Go的结构体成员为空或零值的时候该结构体成员不生成在json对象里面。

### 反序列化

通过定义合适的数据结构，我们可以选择性解码JSON中感兴趣的数据。

```go
package main

import (
	"encoding/json"
	"fmt"
)

type Student struct {
	Name string `json:"name"`
	//Age int `json:"age,omitempty"`
}


func main() {
	var s Student
	data := "{\"age\": 23, \"name\": \"jack\"}"
	json.Unmarshal([]byte(data), &s)
	fmt.Println(s)
}
```

## flag

内置的flag包能完成比较简单的解析工作

```go
package main

import (
	"flag"
	"fmt"
)

func main() {
	var name string
	// 注册
	flag.StringVar(&name, "name", "jack", "这里填你的姓名")
	// 下面这一句必须写
	flag.Parse()
	fmt.Println(name)
}
```

```go
➜  main  ./main -help     
Usage of ./main:
  -name string
        这里填你的姓名 (default "jack")

```

支持的参数解析格式如下：

```
-name=jack
--name=jack
-name jack
--name jack
```

## cobra

？？？？