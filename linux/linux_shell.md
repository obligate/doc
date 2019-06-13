- [Shell编程](#Shell编程)
  - [shell历史](#shell历史)
  - [shell变量](#shell变量)
    - [定义变量](#定义变量)
    - [使用变量](#使用变量)
    - [只读变量](#只读变量)
    - [删除变量](#删除变量)
  - [Shell字符串](#Shell字符串)
    - [单引号](#单引号)
    - [双引号](#双引号)
    - [拼接字符串](#拼接字符串)
    - [获取字符串长度](#获取字符串长度)
    - [提取子字符串](#提取子字符串)
    - [查找子字符串](#查找子字符串)
  - [Shell数组](#Shell数组)
    - [定义数组](#定义数组)
    - [读取数组](#读取数组)
  - [Shell注释](#Shell注释) 
    - [单行注释](#单行注释)
    - [多行注释](#多行注释)

# Shell编程
## shell历史
shell的作用是解释执行用户的命令，用户输入一条命令，shell就解释执行一条，这种方式称为交互式(Interactive),shell还有一种执行命令的方式称为批处理(Batch),用户事先写一个Shell脚本(Script),其中有很多条命令，让shell一次把这些命令执行完，而不必一条一条地敲命令。Shell脚本和编程语言很相似，也有变量和流程控制语句，但Shell脚本是解释执行的，不需要编译，Shell程序从脚本中一行一行读取并执行这些命令，相当于一个用户把脚本中的命令一行一行敲到Shell提示符下执行。
由于历史原因，UNIX系统上有很多Shell：
+ 1.sh(Bourne Shell): 由Steve Bourne开发，各种UNIX系统都配有sh.
+ 2.csh(C Shell): 由Bill Joy开发，随BSD UNIX发布，它的流程控制语句很像C语言，支持很多Bourne Shell所不支持的功能： 作业控制，命令历史，命令行编辑。
+ 3.ksh(Korn Shell):由David Korn开发，向后兼容sh的功能，并且添加了csh引入的新功能，是目前很多UNIX系统标准配置的Shell，在这些系统上/bin/sh往往是指向/bin/sh的符号链接。
+ 4.tcsh(TENEX C Shell):是csh的增强版本，引入了命令行补全等功能，在FreeBSD、MacOS X等系统上替代了csh
+ 5.bash（Bourne Again Shell): 由GNU开发的Shell,主要目标是与POSIX标准保持一致，同时兼顾对sh的兼容,bash从csh和ksh借鉴了很多功能，是各种Linux发行版标准配置的Shell，在Linux系统上 /bin/sh 往往是指向/bin/bash 的符号链接。虽然如此，bash和sh还是有很多不同的，一方面，bash扩展了一些命令和参数，另一方面，bash并不完全和sh兼容，有些行为并不一致，所以bash需要模拟sh的行为：当我们通过sh这个程序启动bash时，bash可以假装自己是sh，不认扩展的命令，并且行为和sh保持一致。 
> 查看当前系统的shell命令，`echo $SHELL`
> 通过`vim /etc/passwd` 其中最后一列显示了用户对应的shell类型

### 运行 Shell 脚本有两种方法
+ 1.作为可执行程序
```
chmod +x ./test.sh  #使脚本具有执行权限
./test.sh           #执行脚本,用`./test.sh`告诉系统说，就在当前目录找.注意，一定要写成 ./test.sh，而不是 test.sh，运行其它二进制的程序也一样，直接写 test.sh，linux 系统会去 PATH 里寻找有没有叫 test.sh 的，而只有 /bin, /sbin, /usr/bin，/usr/sbin 等在 PATH 里，你的当前目录通常不在 PATH 里，所以写成 test.sh 是会找不到命令的.
```
+ 2.作为解释器参数
```
/bin/sh test.sh    # 这种方式运行的脚本，不需要在第一行指定解释器信息，写了也没用
```
## shell变量
### 定义变量
`smart_name="Whisper"`
> 注意，**变量名和等号之间不能有空格**
变量名的命名规则:
- 命名只能使用英文字母，数字和下划线，首个字符不能以数字开头。
- 中间不能有空格，可以使用下划线（_）。
- 不能使用标点符号。
- 不能使用bash里的关键字（可用help命令查看保留关键字）

除了显式地直接赋值，还可以用语句给变量赋值，如：将/etc 下目录的文件名循环出来
```
for file in `ls /etc`
或
for file in $(ls /etc)
```
### 使用变量
使用一个定义过的变量，只要在变量名前面加美元符号即可，如：
```
smart_name="Whisper"
echo $smart_name
echo ${smart_name}
```
**变量名外面的花括号是可选的，加不加都行，加花括号是为了帮助解释器识别变量的边界**，比如下面这种情况
```
for skill in Go Python Node Java; do
    echo "I am good at ${skill}Script"
done
```
如果不给skill变量加花括号，写成echo "I am good at $skillScript"，解释器就会把$skillScript当成一个变量（其值为空），代码执行结果就不是我们期望的样子了。
**推荐给所有变量加上花括号，这是个好的编程习惯**。
**已定义的变量，可以被重新定义**,如：
```
smart_name="Whisper"
echo $smart_name
smart_name="Misty"
echo $smart_name
```
> 这样写是合法的，但注意，第二次赋值的时候不能写$smart_name="Flash"，使用变量的时候才加美元符（$）

### 只读变量
使用 readonly 命令可以将变量定义为只读变量，只读变量的值不能被改变
```
#!/bin/bash
smart_name="Whisper"
readonly smart_name
smart_name="Thunder"
```
运行脚本，结果如下
`/bin/sh: smart_name: This variable is read only.`

### 删除变量
使用 unset 命令可以删除变量。语法: `unset variable_name`
> 变量被删除后不能再次使用。unset 命令不能删除只读变量。
```
#!/bin/bash
smart_name="Whisper"
unset smart_name
echo $smart_name
```
以上实例执行将没有任何输出

## Shell字符串
字符串是shell编程中最常用最有用的数据类型（除了数字和字符串，也没啥其它类型好用了），字符串可以用单引号，也可以用双引号，也可以不用引号。
### 单引号
`str='this is a string'`
单引号字符串的限制
+ 单引号里的任何字符都会原样输出，单引号字符串中的变量是无效的
+ 单引号字串中不能出现单独一个的单引号（对单引号使用转义符后也不行），但可成对出现，作为字符串拼接使用

### 双引号
```
smart_name="Whisper"
str="Hello, I know you are \"$smart_name\"! \n"
echo -e $str
```
输出结果为:
`Hello, I know you are "Whisper"! `
双引号的优点
+ 双引号里可以有变量
+ 双引号里可以出现转义字符

### 拼接字符串
```
smart_name="Whisper"
# 使用双引号拼接
greeting="hello, "$smart_name" !"
greeting_1="hello, ${smart_name} !"
echo $greeting  $greeting_1
# 使用单引号拼接
greeting_2='hello, '$smart_name' !'
greeting_3='hello, ${smart_name} !'
echo $greeting_2  $greeting_3
```
输出结果为：
```
hello, runoob ! hello, Whisper !
hello, runoob ! hello, ${your_name} !
```
### 获取字符串长度
```
smart_name="Whisper"
echo ${#smart_name} #输出 7
```

### 提取子字符串
以下实例从字符串第 2 个字符开始截取 4 个字符
```
string="Whisper is a good boy"
echo ${string:1:4} # 输出 hisp
```
### 查找子字符串
查找字符 i 或 o 的位置(哪个字母先出现就计算哪个)
```
string="Whisper is a good boy"
echo `expr index "$string" io`  # 输出 3
```
> 注意： 以上脚本中 ` 是反引号，而不是单引号 '


## Shell数组
bash支持一维数组（不支持多维数组），并且没有限定数组的大小,数组元素的下标由 0 开始编号。获取数组中的元素要利用下标，下标可以是整数或算术表达式，其值应大于或等于 0
### 定义数组
在 Shell 中，用括号来表示数组，数组元素用"空格"符号分割开。定义数组的一般形式为
```
数组名=(值1 值2 ... 值n)
```
例如
```
array_name=(value0 value1 value2 value3)
```
或者
```
array_name=(
value0
value1
value2
value3
)
```
或者可以单独定义数组的各个分量
```
array_name[0]=value0
array_name[1]=value1
array_name[n]=valuen
```
> 可以不使用连续的下标，而且下标的范围没有限制

### 读取数组
读取数组元素值的一般格式是 
```
${数组名[下标]}
```
例如:
```
valuen=${array_name[n]}
```
使用 @ 符号可以获取数组中的所有元素，例如
```
echo ${array_name[@]}
```

### 获取数组的长度
```
# 取得数组元素的个数
length=${#array_name[@]}
# 或者
length=${#array_name[*]}
# 取得数组单个元素的长度
lengthn=${#array_name[n]}
```

## Shell注释
### 单行注释  
以 # 开头的行就是注释  
```
# echo
```

### 多行注释
```
:<<EOF
注释内容...
注释内容...
注释内容...
EOF
```
EOF 也可以使用其他符号
```
:<<'
注释内容...
注释内容...
注释内容...
'
:<<!
注释内容...
注释内容...
注释内容...
!
```