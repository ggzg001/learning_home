1. Go 语言追求简洁优雅，所以，Go 语言不支持传统的 try...catch...finally 这种处理。

2. Go中引入的处理方式为:**defer**,**panic**,**recover**

3. 这几个异常的使用场景可以这么简单描述:Go 中可以抛出一个 panic 的异常，然后在 defer 中 

   通过 recover 捕获这个异常，然后正常处理 

```
package main

import "fmt"

func test()  {
	defer func() {
		err := recover()
		if err != nil {
			fmt.Println("err = ", err)
			fmt.Printf("%T", err)
		}
	}()
	num1 := 10
	num2 := 0
	res := num1 / num2
	fmt.Println("res = ", res)
}

func main()  {
	test()
}
```

## 自定义异常

Go 程序中，也支持自定义错误并在适当的时候抛出错误， 使用 errors.New 和 panic 内置函数。

```go
package main

import (
	"errors"
	"fmt"
)

func test() error {
	return errors.New("这是我自定义的错误")
}

func main()  {
	res := test()
	fmt.Println(res)
	panic("我随便抛出的错误")
}
```

结果为

```go
这是我自定义的错误
panic: 我随便抛出的错误

goroutine 1 [running]:
main.main()
	/Users/guwanhua/go/src/go_code/project26/main/main.go:15 +0xb4
```

