# git的优势

* 分布式：在本地可以完成，不需要联网，svn无法联网就不能做操作，在本地无法完成代码的版本控制
* 完整性保证：仓库的代码和下载的代码hash一致，保证传输过程不会被修改
* 版本控制尽可能增加数据而不是删除和修改数据，版本回退和前进更有保障
* 分支操作非常流畅, gitbash的操作和linux兼容

# git的结构

git分为三部分： 工作区  暂存区 本地库，分别用于写代码  临时存储  版本管理
git的远程仓库有好几个：局域网有gitlab，外网有github  码云
本地库既然已经可以做版本控制，为啥还需要远程库呢？代码托管中心的两种场景：团队内合作  和  跨团队合作(先 fork 下来再发pull request 审核之后最后才merge)

# git 设置签名

git提交代码需要责任到人，所以提交的时候需要提供用户签名。注意：签名和github等登录的用户名密码没关系   
签名分两种级别：

1. 项目/仓库级别  `git config user.name jack  git config user.email jack@xx.com`
2. 系统级别 `git config --global user.name jack`
两种级别必须有一个，否则报错，远程仓库是无法区别属于哪一个
项目/仓库级别签名信息保存在 .git/config  系统级别存放在哪里~.gitconfig

# git常用命令

git rm --cached good.txt: 对于新增的文件，从暂存区到工作区
git checkout -f: 对于修改的文件保存在暂存区的怎么回到工作区
在这有几个英文词语需要注意一下：staged 暂存;track 追综;include(首次创建文件)  update(往后修改文件) 
创建和修改的git提示是不一样的，有一点细微的差别
```
➜  workdir git:(master) ✗ git commit -m 'first'
[master (root-commit) 54e20f2] first
 1 file changed, 1 insertion(+)
 create mode 100644 a.txt
```

# git的版本前进和后退

git的版本回退与前进都是通过HEAD指针来进行操作的
git log：看当前所在版本和这个版本后面的版本记录 
git relog： 看所有的版本记录
看起来不方便：
```
git log --pretty=oneline: 54e20f24c912cf4460eccfc13954e3c13311e875 (HEAD -> master) first 
git log --online: 54e20f2 (HEAD -> master) first
```
git reflog: 可以看到去到某一个版本需要移动几步
```
54e20f2 (HEAD -> master) HEAD@{0}: commit (initial): first
```
查看log记录的时候快捷键： 空格向下翻页  b向上翻页  q退出

## 版本控制有三种方式
 
基于索引: 推荐使用 结合 git reflog
^： 只能往后 结合 git log --oneline   git reset --hard HEAD^^  退两步
~:  只能往后 结合 git reset --hard HEAD~3 退3步
git reset --hard 索引值一部分 
查看具体文档：git help reset 

## reset 的几种格式

```
--soft  仅仅在本地库移动指针	 本地库变动 三者就不会处在同一水平线  本地库后退，工作区和暂存区相对本地库来说就是前进，此时颜色是绿色
--mixed  在本地库移动head指针   重置暂存区   git status 看暂存区 本地库和暂存区后退，那么工作区就前进，此时颜色是红色
--hard  在本地库移动head指针   重置暂存区  重置工作区
```

git reset --hard HEAD

## 恢复已删除的文件

要想恢复已删除的文件，那么必须增加删除的记录，文件会被删除但是删除记录不会被删除

## 比较文件差异

git diff a.txt： 默认是和上一个版本的暂存区内容进行比较，所以git add 之后git diff a.txt就不好使了,解决方法：
git diff HEAD a.txt(加HEAD参数是为了表明和HEAD的本地库版本数据进行比较，git diff HEAD^ a.txt 和当前指针的上一个版本进行比较)
git的修改的形式是删除一行并新增一行的形式

## git分支

git的分支非常轻量级，除此之外还有别的好处：同时推进多个功能；各个分支在开发过程中，有失败的不影响别的分支
git branch -v: 查看所有分支
git checkout branch_name: 切换分支名

# github

head 表示当前分支的内容  master 表示要merge的分支的内容
用github做团队内的协同开发，必然会遇到的问题是冲突。

1. 解决冲突之后 要把冲突标记为已解决的状态
2. 解决冲突后的git commit -m 不需要接文件名
3. 冲突的文件的名称head表示当前分支的内容，名称 master 表示要merge的分支的内容，具体要哪一个由程序员取舍

## 远程库的地址

1. 首先远程库和本地库名称可以不一样，但是为了可读性方便还是建议保持一致。
2. 添加远程库的地址
```
git remote -v
git remote add origin https://github.com/longyunfeigu/worki.git   origin是别名
git push origin master: 把当前分支的内容推送到origin的master分支
git remote set-url origin remote_git_address: 修改origin
git remote remove origin 删掉原来git源
git push origin --delete first-branch  删除远程分支
```
3. git clone https://github.com/longyunfeigu/worki.git：三个效果  把库下载到本地; 创建.git;创建远程地址别名
4. 跨团队协作：在repository的settings里面collaboarators选择github用户，拷贝邀请地址给对方，对方accept即可

## 团队协作常用命令

pull = fetch + merge
pull 是读操作，不需要什么权限
git fetch origin master： 把远程库的master分支抓取下来，fetch没有更改本地工作区内容
git checkout origin/master: 看fetch下来的内容
远程库的内容审查完毕后再merge: git checkout master; git merge origin/master

## 跨团队协作

1. 登录我个人的账号去点fork，fork下来之后可以clone弄到本地
2. 在本人fork下面的new pull request, 发消息给对方
3. 别人的pull requests 就会有内容了,这里还可以给我发送消息，达到隔空对话的效果
4. 别人审核代码，可以看commits那部分，以及有哪些修改fiels changed
5. 最后再merge pull request

pub 复制到github
genkey 使用的github的注册邮箱号，不一定是账号名

## git的工作流

git工作流： gitflow工作流；forking工作流等
/Users/guwanhua/Library/Containers/com.tencent.WeWorkMac/Data/Library/Application Support/WXWork/Temp/ScreenCapture/企业微信截图_9682e54c-66a6-4a7a-9de5-6335fea3b6d3.png

## 删除本地分支和远程分支

删除本地分支：git branch -D 本地分支名
删除远程分支：git push origin --delete 远程分支名或者 git push origin :branch-name

jobs 和 pipeline, 其中pipeline 比 jobs 要少
编译用来多少时间，测试又用来多长时间
CI/CD: build + tests

docker -e "PAAS_APP_NAME=bioinfo" 接环境变量
 















 