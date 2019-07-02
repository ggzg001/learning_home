1. `time.Now()` time.Time 类型
2. `time.Now().unix()` 整数，相当于python中的时间戳
3. 把time.Time格式化为string: `time.Now().Format("2006-01-02 15:04:05")`
4. 把string转为time.Time: `time.Parse("2006-01-02", "2019-10-34")`
5. 时间加减：`k = time.Now() sd, _ := time.ParseDuration("-24h") k.Add(sd)`

