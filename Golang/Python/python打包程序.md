# setup.py 应用场景

在安装python的相关模块和库时，我们一般使用“pip install  模块名”或者“python setup.py install”，前者是在线安装，会安装该包的相关依赖包；后者是下载源码包然后在本地安装，不会安装该包的相关依赖包。所以在安装普通的python包时，利用pip工具相当简单。但是在如下场景下，使用python setup.py install会更适合需求.

**在编写相关系统时，python 如何实现连同依赖包一起打包发布？**

 假如在本机开发一个程序，需要用到python的redis、mysql模块以及自己编写的redis_run.py模块。怎么实现在服务器上去发布该系统，如何实现依赖模块和自己编写的模块redis_run.py一起打包，实现一键安装呢。

在这种应用场景下，pip工具似乎派不上了用场，只能使用python的构建工具setup.py了，使用此构建工具可以实现上述应用场景需求，只需在 setup.py 文件中写明依赖的库和版本，然后到目标机器上使用python setup.py install安装。

# setup() 参数说明

## packages

对于所有 packages 列表里提到的纯 *Python **模块***做处理 。<font color="red">需要在 setup 脚本里有一个包名到目录的映射,否则找不到目录会报错</font>。如果不指定目录映射，那么默认对于 setup.py 脚本所在目录下同名的目录即视为包所在目录, 即默认有一个package_dir的目录映射。例如：

当在 setup 脚本中写入 packages = ['src'] 时， setup 脚本的同级目录下可以找到 `src/__init__.py`,并把src下和`__init__.py`同级的py文件打包进去，但是不会打包src里面更深层次的模块。如果没有找到对应文件，disutils 不会直接报错，而是给出一个告警然后继续进行有问题的打包流程。

## package_dir

阐明包名到目录的映射，见 packages。

`package_dir = {'': 'src'}`

空的键代表packages列表指定的模块，如src, src.bioinfo等模块都可以在src目录递归找到。

这里需要注意的是package_dir的键为空或非空寻找包(也就是`__init__.py`)是不一样的。

### 键为空

```python
packages = ['foo']
package_dir = {'': 'lib'}
```

指明包位于 lib/foo/, `lib/foo/__init__.py` 这个文件存在.所以foo必须和存在的包名也就是目录名名称保持一致。这时候会把lib下的foo整个目录打包, 打包的只是lib下的foo目录，不包括lib这个包的一些py文件。

### 键不为空

直接将 foo 这个包的内容全部放入 lib 而不是在 lib 下建一个 foo 目录。

```python
packages = ['foo']
package_dir = {'foo': 'lib'}
```

此时表明foo包的内容是lib这个包下(不包括lib底下的包)的文件,这时候foo的名字可以随便起。

<font color="red">一个在 package_dir 字典中的 package: dir 映射会对当前包下的所有包都生效， 所以 foo.bar 会自动生效. 在这个例子当中， `packages = ['foo', 'foo.bar']` 告诉 distutils 去寻找 `lib/__init__.py` 和 `lib/bar/__init__.py`.</font>

## py_modules

对于一个相对较小的模块的发布，可能更想要列出所有模块而不是列出所有的包，尤其是对于那种根目录下就是一个简单模块的类型.

`py_modules = ['src/src', "test"]`

默认的“包：目录”映射关系表明你可以在 setup 脚本所在的路径下找到 test.py 和 src/src.py。如果不写package_dir，那么lib下会有src目录和test.py，src下会有src.py.其实，只要py_modules里面有`/`这种层级关系，那么lib下就不会单纯地放置一些py文件，而是会有目录层次

当然，也可以用 package_dir 选项重写这层映射关系就是了(默认是从setup.py同级的目录里找)。

## find_packages

packages=find_packages(exclude=('tests', 'robot_server.scripts')),
exclude 里面是包名，而非路径

## include_package_data

引入包内的非 Python 文件, include_package_data 需要配合 MANIFEST.in 一起使用.

MANIFEST.in:

```
include myapp/scripts/start.py
recursive-include myapp/static *
```

```
setup(
    name='MyApp',         # 应用名
    version='1.0',        # 版本号
    packages=['myapp'],   # 包括在安装包内的Python包
    include_package_data=True    # 启用清单文件MANIFEST.in
)
```

```
setup-demo/
  ├ mydata.data      # 数据文件
  ├ setup.py         # 安装文件
  ├ MANIFEST.in      # 清单文件
  └ myapp/           # 源代码
      ├ static/      # 静态文件目录
      ├ __init__.py
      ...
```

## exclude_package_data

排除一部分包文件{'myapp':['.gitignore]}，就表明只排除 myapp 包下的所有.gitignore 文件(不包括myapp底下的包)。

## data_files

指定其他的一些文件（如配置文件）

```python
data_files=[('bitmaps', ['bm/b1.gif', 'bm/b2.gif']),
            ('config', ['cfg/data.cfg']),
            ('/etc/init.d', ['src/init-script'])]
```

规定了哪些文件被安装到哪些目录中。 如果目录名是相对路径(比如 bitmaps)，则是相对于 sys.prefix(/usr) 或 sys.exec_prefix 的路径。 否则安装到绝对路径(比如 /etc/init.d )。

## entry_points

```
entry_points={
            'console_scripts': [
                'add = demo.add:add'
            ],
        }
```

安装时会把add放到bin目录下，启动demo是packages列表里的包，add:add 表示add模块里的add函数

## cmdclass

定制化命令，通过继承 setuptools.command 下的命令类来进行定制化。

```python
class UploadCommand(Command):
    """Support setup.py upload."""
    ...

    def run(self):
        try:
            self.status('Removing previous builds…')
            rmtree(os.path.join(here, 'dist'))
        except OSError:
            pass

        self.status('Building Source and Wheel (universal) distribution…')
        os.system('{0} setup.py sdist bdist_wheel --universal'.format(sys.executable))

        self.status('Uploading the package to PyPI via Twine…')
        os.system('twine upload dist/*')

        self.status('Pushing git tags…')
        os.system('git tag v{0}'.format(about['__version__']))
        os.system('git push --tags')

        sys.exit()

setup(
    ...
    # $ setup.py publish support.
    cmdclass={
        'upload': UploadCommand,
    },
)
```

## install_requires

安装这个包所需要的依赖，列表

```python
def install_requires():
    """
    Return requires in requirements.txt
    :return:
    """
    try:
        with open("requirements.txt") as f:
            return [line.strip() for line in f.readlines() if line.strip()]
    except OSError:
        return []
```

```
install_requires=install_requires()
```

```
pypinyin==0.12.0 # 指定版本（最日常的写法）
django-querycount>=0.5.0 # 大于某个版本
django-debug-toolbar>=1.3.1,<=1.3.3 # 版本范围
ipython # 默认（存在不替换，不存在安装最新版）
```

```python
from setuptools import setup, find_packages

def install_requires():
    with open("requirements.txt") as f:
        return [i.strip() for i in iter(f.readline, "")]

setup(
    name="biodemo_python",
    version="1.0",
    author="wanhua.gu",
    author_email="wanhua.gu@google.com",
    packages=find_packages("src", exclude=("*test*", )),
    package_dir={"": "src"},
    # 需要结合 MANIFEST.in 一起使用，否则install_requires()也会报找不到文件的错误
    include_package_data=True,
    install_requires=install_requires(),
    entry_points={
        "console_scripts": [
            "run=biodemo_python.app:run"
        ],
    },
    data_files=[("/Users/guwanhua/Downloads/project/app", ["src/a.txt"])],
)
```

