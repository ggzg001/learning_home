## 单一职责原则（single responsibility principle）

 简称SRP

**定义：不要存在多于一个导致类变更的原因。**通俗的说，即一个类只负责一项职责。

**问题由来：**类T负责两个不同的职责：职责P1，职责P2。当由于职责P1需求发生改变而需要修改类T时，有可能会导致原本运行正常的职责P2功能发生故障。

**解决方案：**遵循单一职责原则。分别建立两个类T1、T2，使T1完成职责P1功能，T2完成职责P2功能。这样，当修改类T1时，不会使职责P2发生故障风险；同理，当修改T2时，也不会使职责P1发生故障风险。

说到单一职责原则，很多人都会不屑一顾。因为它太简单了。稍有经验的程序员即使从来没有读过设计模式、从来没有听说过单一职责原则，在设计软件时也会自觉的遵守这一重要原则，因为这是常识。在软件编程中，谁也不希望因为修改了一个功能导致其他的功能发生故障。而避免出现这一问题的方法便是遵循单一职责原则。虽然单一职责原则如此简单，并且被认为是常识，但是即便是经验丰富的程序员写出的程序，也会有违背这一原则的代码存在。为什么会出现这种现象呢？因为有职责扩散。**所谓职责扩散，就是因为某种原因，职责P被分化为粒度更细的职责P1和P2。**

比如：类T只负责一个职责P，这样设计是符合单一职责原则的。后来由于某种原因，也许是需求变更了，也许是程序的设计者境界提高了，需要将职责P细分为粒度更细的职责P1，P2，这时如果要使程序遵循单一职责原则，需要将类T也分解为两个类T1和T2，分别负责P1、P2两个职责。但是在程序已经写好的情况下，这样做简直太费时间了。所以，简单的修改类T，用它来负责两个职责是一个比较不错的选择，虽然这样做有悖于单一职责原则。(这样做的风险在于职责扩散的不确定性, 因为我们不会想到这个职责P, 在未来可能会扩散为P1，P2，P3，P4……Pn。所以记住，在职责扩散到我们无法控制的程度之前，立刻对代码进行重构。)

现在网络上说明单一职责的最普遍的一个例子就是动物类

```python
class Animal(object):
    def __init__(self):
        pass
 
    def breathe(self, name):
        print('%s 呼吸空气' %name)
 
 
# caller
class Client(object):
    def __init__(self):
        pass
 
    def work(self):
        animal = Animal()
        animal.breathe('牛')
        animal.breathe('羊')
        animal.breathe('猪')
 
 
if __name__ == '__main__':
    client = Client()
    client.work()

```

上述代码实现了一个类Animal，仅仅实现了一个职责---breathe。客户端调用后得到上面的结果。

但如果又增加了一种动物---鱼，很明显鱼是不能呼吸空气得的，因此要对类Animal进行修改，或者把类直接拆分为两个类分别实现水生动物的breathe和陆生动物的breathe.

```python
class Terrestrialanimal(object):
 
    def __init__(self):
        pass
 
    def breathe(self, name):
        print('%s 呼吸空气' %name)
 
 
class Aquaticanimal(object):
 
    def __init__(self):
        pass
 
    def breathe(self, name):
        print('%s 呼吸水' %name)
 
 
# caller
class Client(object):
    def __init__(self):
        pass
 
    def work(self):
        terrestrialanimal = Terrestrialanimal()
        terrestrialanimal.breathe('牛')
        terrestrialanimal.breathe('羊')
        terrestrialanimal.breathe('猪')
 
        aquatic = Aquaticanimal()
        aquatic.breathe('鱼')
 
 
if __name__ == '__main__':
    client = Client()
    client.work()

```

## 开放封闭原则

开放封闭原则，是面向对象编程的核心，也是其他五大设计原则实现的终极目标。只有对抽象编程，而不是对具体编程才是遵循了开放封闭原则。所谓的对抽象编程，就是面向接口编程，具体指的是具体地实现这些接口。

开放：指的是软件对扩展开放。封闭:指的是软件对修改封闭。

即软件增加或改变需求是通过扩展来到，而不是通过修改来实现的。<font color="red">即一个类定型后尽量不要去修改。而是通过增加新类来满足需求。</font>

##  接口隔离原则（Interface Segregation Principle）

1. 客户端（调用方）不应该依赖于它不需要的接口
2. 类之间的依赖关系应该建立在最小接口上

例如把动物的飞、游等抽象成两个接口，而不是用一个统一的动物接口。简而言之，就是接口最小化、精细化。

## 里氏替换原则

通用定义： **所有引用基类（父类）的地方必须能透明地使用其子类的对象。**

简单来说就是父类的方法签名和子类的方法签名需保持一致。

## 依赖倒置原则（Dependence Inversion Principle）

1. 高层级的模块不应该依赖于低层次的模块，它应该依赖于低层次模块的抽象
2. 抽象不应该依赖于具体，具体应该依赖于抽象

高层次模型，通常所说的客户端(这里的客户端指的是调用类的代码)就是高层次模型，而其调用的接口即是低层次的模型，这句话也可以说，客户端不应该依赖于接口的具体，而是依赖于接口的抽象。

现在有一款自动驾驶系统，它可以装在buick，ford两款车上使用。先上个未符合依赖倒置的例子。这个例子中，客户端即autosystem依赖于具体接口（buick，ford）。而不是依赖于抽象 car。

```python
class Ford(object):
    def __init__(self):
        self.type = 'ford'
 
    def ford_run(self):
        print('%s is running' % self.type)
 
    def ford_turn(self):
        print('%s is turning' % self.type)
 
    def ford_stop(self):
        print('%s is stopping' % self.type)
 
 
class Buick(object):
    def __init__(self):
        self.type = 'buick'
 
    def buick_run(self):
        print('%s is running' % self.type)
 
    def buick_turn(self):
        print('%s is turning' % self.type)
 
    def buick_stop(self):
        print('%s is stopping' % self.type)
 
 
class AutoSystem(object):
 
    def __init__(self, car):
        self.car = car
 
    def car_run(self):
        if self.car.type == 'ford':
            self.car.ford_run()
        else:
            self.car.buick_run()
            
    def car_turn(self):
        if self.car.type == 'ford':
            self.car.ford_turn()
        else:
            self.car.buick_turn()
 
    def car_stop(self):
        if self.car.type == 'ford':
            self.car.ford_stop()
        else:
            self.car.buick_stop()
 
 
if __name__ == '__main__':
    ford = Ford()
    buick = Buick()
    autosystem = AutoSystem(ford)
    autosystem.car_run()
    autosystem.car_turn()
    autosystem.car_stop()
    autosystem.car = buick
    print('*' * 100)
    autosystem.car_run()
    autosystem.car_turn()
    autosystem.car_stop()

```

如果现在想把这种自动驾驶系统用在卡迪拉克（cadillac），那么就要修改上层的客户端了，就要写很多if else，这对于喜欢偷懒的程序员是致命的。<font color="red">更何况，无论是哪款车，不都是跑路吗，都用run方法得了，用得着分ford_run、buick_run吗</font>。为此，出现了面向对象。下面实现符合依赖倒置原则的代码。首先要抽象出car类.

```python

import abc
 
 
class Car(object):
    __metaclass__ = abc.ABCMeta
 
    @abc.abstractmethod
    def car_run(self, *args, **kwargs):
        pass
 
    @abc.abstractmethod
    def car_turn(self, *args, **kwargs):
        pass
 
    @abc.abstractmethod
    def car_stop(self, *args, **kwargs):
        pass
 
 
class Ford(Car):
    def __init__(self):
        self.type = 'ford'
 
    def car_run(self):
        print('%s is running' % self.type)
 
    def car_turn(self):
        print('%s is turning' % self.type)
 
    def car_stop(self):
        print('%s is stopping' % self.type)
 
 
class Buick(Car):
    def __init__(self):
        self.type = 'buick'
 
    def car_run(self):
        print('%s is running' % self.type)
 
    def car_turn(self):
        print('%s is turning' % self.type)
 
    def car_stop(self):
        print('%s is stopping' % self.type)
 
 
class Cadillac(Car):
    def __init__(self):
        self.type = 'cadillac'
 
    def car_run(self):
        print('%s is running' % self.type)
 
    def car_turn(self):
        print('%s is turning' % self.type)
 
    def car_stop(self):
        print('%s is stopping' % self.type)
 
 
class AutoSystem(object):
 
    def __init__(self, car):
        self.car = car
 
    def car_run(self):
        self.car.car_run()
 
    def car_turn(self):
        self.car.car_turn()
 
    def car_stop(self):
        self.car.car_stop()
 
 
if __name__ == '__main__':
    ford = Ford()
    buick = Buick()
    cadillac = Cadillac()
    autosystem = AutoSystem(ford)
    autosystem.car_run()
    autosystem.car_turn()
    autosystem.car_stop()
    autosystem.car = buick
    print('*'*100)
    autosystem.car_run()
    autosystem.car_turn()
    autosystem.car_stop()
    print("*"*100)
    autosystem.car = cadillac
    autosystem.car_run()
    autosystem.car_turn()
    autosystem.car_stop()
```

抽象不应该依赖于具体，具体应该依赖于抽象对于这句话，我的理解是：这句话针对类继承来说的，抽象类不能继承自具体的类，而具体的类应该继承自抽象的类.

## 迪米特原则

迪米特原则又称最少知识原则（least knowledge principle）简称LKP。意思是说一个对象应该对其他对象有尽可能少的了解。

迪米特原则的一个解释是（talk only to your immediate friends）。只与直接朋友对话。什么是直接朋友呢。两个类有耦合就是朋友关系。直接朋友，<font color="red">我的理解是类之间是通过参数调用产生关系的, 而不是直接内嵌的, 也就是说不是直接在类的某个方法里去实例化别的类</font>

不遵从迪米特原则的例子

体育课上，体育老师要进行点名，她让体育课代表去点名。类Teacher与类 StudentList, Student, Representative都有耦合关系，但他们都是内嵌到类Teacher的command方法中。这就不符合迪米特原则了。代码如下:

```python
class Teacher(object):
 
    def __init__(self):
        pass
 
    def command(self):
        print('体育老师让课代表点名')
        studentlist = StudentList()
        for _ in range(20):
            studentlist.append(Student())
        print('课代表开始点名')
        representative = Representative()
        representative.count(studentlist)
 
 
class Student(object):
    pass
 
 
class StudentList(list):
    pass
 
 
class Representative(object):
 
    def count(self, studentlist):
        print('课代表已经点完名，共有人数%d' % len(studentlist))
 
 
class Client(object):
 
    def main(self, teacher):
        teacher.command()
 
if __name__ == '__main__':
    client = Client()
    teacher = Teacher()
    client.main(teacher)
```

从上面的代码可知，teacher的下级是representative，其应该只与representative是直接朋友关系。representative也应该只与studentlist是直接朋友关系。因此代码可以修改为这样:

```python
class Teacher(object):
 
    def __init__(self, representative):
        self.representative = representative
 
    def command(self):
        print('老师让课代表点名')
        self.representative.count()
 
 
class Representative(object):
 
    def __init__(self, studentlist):
        self.studentlist = studentlist
 
    def count(self):
        print('课代表开始点名')
        self.studentlist.size()
 
 
class StudentList(list):
 
    def add_student(self, num):
        for _ in range(num):
            self.append(Student())
 
    def size(self):
        print('学生的人数为%s' % str(len(self)))
 
 
class Student(object):
    pass
 
 
class Client(object):
    def main(self, teacher):
        teacher.command()
 
if __name__ == '__main__':
    studentlist = StudentList()
    studentlist.add_student(10)
    representative = Representative(studentlist)
    teacher = Teacher(representative)
    client = Client()
    client.main(teacher)
```

从修改后的代码可以看出，teacher，representative，studentlist是<font color="red">层级关系</font>，这种关系也可以以内嵌的形式都写进teacher的command方法中，也可以像修改后的代码一样，采用逐级传递参数的方式来反映层级关系.



