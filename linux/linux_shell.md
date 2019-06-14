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
  - [Shell传递参数](#Shell参数)
    - [注意事项](#注意事项)
    - [实例](#实例)
    - [特殊字符](#特殊字符)
      - [特殊字符实例](#特殊字符实例)
  - [Shell基本运算符](#Shell基本运算符)
    - [算数运算符](#算数运算符)
    - [关系运算符](#关系运算符)
    - [布尔运算符](#布尔运算符)
    - [字符串运算符](#字符串运算符)
    - [文件测试运算符](#文件测试运算符)
  - [Shell输入/输出重定向](#Shell输入/输出重定向)
    - [命令列表](#命令列表)
    - [输出重定向](#输出重定向)
    - [输入重定向](#输入重定向)
    - [重定向深入讲解](#重定向深入讲解)
    - [特殊的重定向方式Here Doucument](#特殊的重定向方式)
    - [/dev/null文件](#/dev/null文件)
  - [Shell 文件包含](#Shell文件包含)
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

## Shell参数
我们可以在执行 Shell 脚本时，向脚本传递参数，脚本内获取参数的格式为：$n。n 代表一个数字，1 为执行脚本的第一个参数，2 为执行脚本的第二个参数，以此类推,其中 $0 为执行的文件名
### 注意事项
> 在为shell脚本传递的参数中如果包含空格，应该使用单引号或者双引号将该参数括起来，以便于脚本将这个参数作为整体来接收
> 在有参数时，可以使用对参数进行校验的方式处理以减少错误发生
```
if [ -n "$1" ]; then
    echo "包含第一个参数"
else
    echo "没有包含第一参数"
fi
```
> 中括号 [] 与其中间的代码应该有空格隔开
> 在进行字符串比较时，最好使用双中括号 [[ ]]. 因为单中括号可能会导致一些错误，因此最好避开它们
> 检查两个字符串是否相同 `[[ $str1 = $str2 ]]`, 当 str1等于str1等于str2 时，返回真。也就是说，str1 和 str2 包含的文本是一样的,其中的单等于号也可以写成双等于号
> 上面的字符串比较等效于 `[[ $str1 == $str2 ]]`, 注意 = 前后有一个空格，如果忘记加空格, 就变成了赋值语句，而非比较关系了
> 算术比较, 比如一个变量是否为0, [ $var -eq 0 ]
> 文件属性测试，比如一个文件是否存在，[ -e $var ], 是否是目录，[ -d $var ]
> [] 常常可以使用 test 命令来代替,`if [ $var -eq 0 ]; then echo "True"; fi` 等价于`if test $var -eq 0; then echo "True"; fi`

### 实例
+ 创建`test_argument.sh`
```
vim test_argument.sh
#!/bin/bash
echo "Shell 传递参数实例";
echo "执行的文件名：$0";
echo "第一个参数为：$1";
echo "第二个参数为：$2";
echo "第三个参数为：$3";
```
+ 执行脚本,并传入3个参数
```
chmod u+x test_argument.sh 
./test_argument.sh 1 2 3 
```
+ 执行结果
```
Shell 传递参数实例
执行的文件名：./test_argument.sh
第一个参数为：1
第二个参数为：2
第三个参数为：3
```
### 特殊字符
+ `$#` 传递到脚本的参数个数
+ `$*` 使用时加引号 `"$*"`,以"$1 $2 … $n"的形式输出所有参数
+ `$@` 使用时加引号 `"$@"`,以"$1" "$2" … "$n" 的形式输出所有参数
+ `$?` 显示最后命令的退出状态。0表示没有错误，其他任何值表明有错误。
  
#### 特殊字符实例
+ 创建文件`test_special_char.sh`
```
vim test_special_char.sh
#!/bin/bash
echo "-- \$* 演示 ---"
echo "参数个数\$#：$#"
for i in "$*"; do
    echo $i
done

echo "-- \$@ 演示 ---"
echo "参数个数\$#：$#"
for i in "$@"; do
    echo $i
done
```
+ 执行脚本，并出入3个参数，看一下`$*`和`$@`区别
```
chmod u+x test_special_char.sh
./test_special_char.sh 1 2 3
```
+ 执行结果
```
-- $* 演示 ---
参数个数$#：3
1 2 3
-- $@ 演示 ---
参数个数$#：3
1
2
3
```

## Shell基本运算符
+ 算数运算符     `+ - * \ % = == !=`
+ 关系运算符
+ 布尔运算符
+ 字符串运算符
+ 文件测试运算符
  
> 原生bash不支持简单的数学运算，但是可以通过其他命令来实现，例如 `awk` 和 `expr`，`expr` 最常用,`expr` 是一款表达式计算工具，使用它能完成表达式的求值操作
> 数学运算 `expr 表达式` 等同于 `$((表达式))`, `$((表达式))`此处表达式中的 "*" 不需要转义符号 "\" 
例如两个数相加(注意使用的是反引号 ` 而不是单引号 ')
```
#!/bin/bash
val=`expr 2 + 2`
echo "两数之和为 : $val"
```
输出结果 `两数之和为 : 4`
> 表达式和运算符之间要有空格，例如 `2+2` 是不对的，必须写成` 2 + 2`
> 完整的表达式要被 ` ` 包含，注意这个字符不是常用的单引号，在 Esc 键下边

### 算数运算符
假定变量 a 为 10，变量 b 为 20
```
+   加法                                            `expr $a + $b` 结果为 30
-   减法                                            `expr $a - $b` 结果为 -10
*   乘法                                            `expr $a \* $b` 结果为  200。
/   除法                                            `expr $b / $a` 结果为 2
%   取余                                            `expr $b % $a` 结果为 0
=   赋值                                             a=$b 将把变量 b 的值赋给 a
==  相等。用于比较两个数字，相同则返回 true            [ $a == $b ] 返回 false
!=  不相等。用于比较两个数字，不相同则返回 true         [ $a != $b ] 返回 true
```
> 注意：条件表达式要放在方括号之间，并且要有空格，例如: [$a==$b] 是错误的，必须写成 [ $a == $b ]。
> 乘号(*)前边必须加反斜杠(\)才能实现乘法运算
```
#!/bin/bash
a=10
b=20

val=`expr $a + $b`
echo "a + b : $val"

val=`expr $a - $b`
echo "a - b : $val"

val=`expr $a \* $b`
echo "a * b : $val"

val=`expr $b / $a`
echo "b / a : $val"

val=`expr $b % $a`
echo "b % a : $val"

if [ $a == $b ]
then
   echo "a 等于 b"
fi
if [ $a != $b ]
then
   echo "a 不等于 b"
fi
```
输出结果
```
a + b : 30
a - b : -10
a * b : 200
b / a : 2
b % a : 0
a 不等于 b
```

### 关系运算符
**关系运算符只支持数字，不支持字符串，除非字符串的值是数字**
```
假定变量 a 为 10，变量 b 为 20
-eq   检测两个数是否相等，相等返回 true                           [ $a -eq $b ] 返回 false
-ne   检测两个数是否不相等，不相等返回 true                       [ $a -ne $b ] 返回 true
-gt   检测左边的数是否大于右边的，如果是，则返回 true              [ $a -gt $b ] 返回 false
-lt   检测左边的数是否小于右边的，如果是，则返回 true              [ $a -lt $b ] 返回 true
-ge   检测左边的数是否大于等于右边的，如果是，则返回 true           [ $a -ge $b ] 返回 false
-le   检测左边的数是否小于等于右边的，如果是，则返回 true           [ $a -le $b ] 返回 true
```
#### 实例
```
#!/bin/bash
a=10
b=20

if [ $a -eq $b ]
then
   echo "$a -eq $b : a 等于 b"
else
   echo "$a -eq $b: a 不等于 b"
fi
if [ $a -ne $b ]
then
   echo "$a -ne $b: a 不等于 b"
else
   echo "$a -ne $b : a 等于 b"
fi
if [ $a -gt $b ]
then
   echo "$a -gt $b: a 大于 b"
else
   echo "$a -gt $b: a 不大于 b"
fi
if [ $a -lt $b ]
then
   echo "$a -lt $b: a 小于 b"
else
   echo "$a -lt $b: a 不小于 b"
fi
if [ $a -ge $b ]
then
   echo "$a -ge $b: a 大于或等于 b"
else
   echo "$a -ge $b: a 小于 b"
fi
if [ $a -le $b ]
then
   echo "$a -le $b: a 小于或等于 b"
else
   echo "$a -le $b: a 大于 b"
fi
```
输出
```
10 -eq 20: a 不等于 b
10 -ne 20: a 不等于 b
10 -gt 20: a 不大于 b
10 -lt 20: a 小于 b
10 -ge 20: a 小于 b
10 -le 20: a 小于或等于 b
```
### 布尔运算符
```
假定变量 a 为 10，变量 b 为 20
!	   非运算，表达式为 true 则返回 false，否则返回 true。	  [ ! false ] 返回 true。
-o	 或运算，有一个表达式为 true 则返回 true。	           [ $a -lt 20 -o $b -gt 100 ] 返回 true。
-a	 与运算，两个表达式都为 true 才返回 true。	           [ $a -lt 20 -a $b -gt 100 ] 返回 false。
```
#### 实例
```
#!/bin/bash
a=10
b=20

if [ $a != $b ]
then
   echo "$a != $b : a 不等于 b"
else
   echo "$a == $b: a 等于 b"
fi
if [ $a -lt 100 -a $b -gt 15 ]
then
   echo "$a 小于 100 且 $b 大于 15 : 返回 true"
else
   echo "$a 小于 100 且 $b 大于 15 : 返回 false"
fi
if [ $a -lt 100 -o $b -gt 100 ]
then
   echo "$a 小于 100 或 $b 大于 100 : 返回 true"
else
   echo "$a 小于 100 或 $b 大于 100 : 返回 false"
fi
if [ $a -lt 5 -o $b -gt 100 ]
then
   echo "$a 小于 5 或 $b 大于 100 : 返回 true"
else
   echo "$a 小于 5 或 $b 大于 100 : 返回 false"
fi
```
输出结果
```
10 != 20 : a 不等于 b
10 小于 100 且 20 大于 15 : 返回 true
10 小于 100 或 20 大于 100 : 返回 true
10 小于 5 或 20 大于 100 : 返回 false
```

### 逻辑运算符
```
假定变量 a 为 10，变量 b 为 20
&&	 逻辑的 AND	          [[ $a -lt 100 && $b -gt 100 ]]    返回 false
||	 逻辑的 OR	          [[ $a -lt 100 || $b -gt 100 ]]      返回 true
```
#### 实例
```
#!/bin/bash
a=10
b=20

if [[ $a -lt 100 && $b -gt 100 ]]
then
   echo "返回 true"
else
   echo "返回 false"
fi

if [[ $a -lt 100 || $b -gt 100 ]]
then
   echo "返回 true"
else
   echo "返回 false"
fi
```
输出结果
```
返回 false
返回 true
```

### 字符串运算符
```
假定变量 a 为 "abc"，变量 b 为 "efg"
=	    检测两个字符串是否相等，相等返回 true。	      [ $a = $b ] 返回 false。
!=	  检测两个字符串是否相等，不相等返回 true。	    [ $a != $b ] 返回 true。
-z	  检测字符串长度是否为0，为0返回 true。	       [ -z $a ] 返回 false。
-n	  检测字符串长度是否为0，不为0返回 true。	     [ -n "$a" ] 返回 true。
$	    检测字符串是否为空，不为空返回 true。	       [ $a ] 返回 true。
```
#### 实例
```
#!/bin/bash
a="abc"
b="efg"

if [ $a = $b ]
then
   echo "$a = $b : a 等于 b"
else
   echo "$a = $b: a 不等于 b"
fi
if [ $a != $b ]
then
   echo "$a != $b : a 不等于 b"
else
   echo "$a != $b: a 等于 b"
fi
if [ -z $a ]
then
   echo "-z $a : 字符串长度为 0"
else
   echo "-z $a : 字符串长度不为 0"
fi
if [ -n "$a" ]
then
   echo "-n $a : 字符串长度不为 0"
else
   echo "-n $a : 字符串长度为 0"
fi
if [ $a ]
then
   echo "$a : 字符串不为空"
else
   echo "$a : 字符串为空"
fi
```
输出结果
```
abc = efg: a 不等于 b
abc != efg : a 不等于 b
-z abc : 字符串长度不为 0
-n abc : 字符串长度不为 0
abc : 字符串不为空
```
### 文件测试运算符
```
-b file	     检测文件是否是块设备文件，如果是，则返回 true。	                            [ -b $file ] 返回 false。
-c file	     检测文件是否是字符设备文件，如果是，则返回 true。	                          [ -c $file ] 返回 false。
-d file	     检测文件是否是目录，如果是，则返回 true。	                                 [ -d $file ] 返回 false。
-f file	     检测文件是否是普通文件（既不是目录，也不是设备文件），如果是，则返回 true。 	  [ -f $file ] 返回 true。
-g file	     检测文件是否设置了 SGID 位，如果是，则返回 true。	                         [ -g $file ] 返回 false。
-k file	     检测文件是否设置了粘着位(Sticky Bit)，如果是，则返回 true。	               [ -k $file ] 返回 false。
-p file	     检测文件是否是有名管道，如果是，则返回 true。	                             [ -p $file ] 返回 false。
-u file	     检测文件是否设置了 SUID 位，如果是，则返回 true。	                         [ -u $file ] 返回 false。
-r file	     检测文件是否可读，如果是，则返回 true。	                                   [ -r $file ] 返回 true。
-w file	     检测文件是否可写，如果是，则返回 true。	                                   [ -w $file ] 返回 true。
-x file	     检测文件是否可执行，如果是，则返回 true。	                                 [ -x $file ] 返回 true。
-s file	     检测文件是否为空（文件大小是否大于0），不为空返回 true。	                    [ -s $file ] 返回 true。
-e file	     检测文件（包括目录）是否存在，如果是，则返回 true。	                        [ -e $file ] 返回 true。
```

#### 实例
```
#!/bin/bash
file="/home/Peter/test.sh"
if [ -r $file ]
then
   echo "文件可读"
else
   echo "文件不可读"
fi
if [ -w $file ]
then
   echo "文件可写"
else
   echo "文件不可写"
fi
if [ -x $file ]
then
   echo "文件可执行"
else
   echo "文件不可执行"
fi
if [ -f $file ]
then
   echo "文件为普通文件"
else
   echo "文件为特殊文件"
fi
if [ -d $file ]
then
   echo "文件是个目录"
else
   echo "文件不是个目录"
fi
if [ -s $file ]
then
   echo "文件不为空"
else
   echo "文件为空"
fi
if [ -e $file ]
then
   echo "文件存在"
else
   echo "文件不存在"
fi
```
输出结果
```
文件可读
文件可写
文件可执行
文件为普通文件
文件不是个目录
文件不为空
文件存在
```

## Shell输入/输出重定向
### 命令列表
```
command > file	              将输出重定向到 file。
command < file	              将输入重定向到 file。
command >> file	              将输出以追加的方式重定向到 file。
n > file	                    将文件描述符为 n 的文件重定向到 file。
n >> file	                    将文件描述符为 n 的文件以追加的方式重定向到 file。
n >& m	                      将输出文件 m 和 n 合并。
n <& m	                      将输入文件 m 和 n 合并。
<< tag	                      将开始标记 tag 和结束标记 tag 之间的内容作为输入。
```
> 需要注意的是文件描述符 0 通常是标准输入（STDIN），1 是标准输出（STDOUT），2 是标准错误输出（STDERR）

### 输出重定向
语法： `command1 > file1`，这个命令执行command1然后将输出的内容存入file1
> 注意任何file1内的已经存在的内容将被新内容替代。如果要将新内容添加在文件末尾，请使用`>>`操作符
```
who > users                # 将who命令的完整的输出重定向在用户文件中(users),执行后，并没有在终端输出信息，这是因为输出已被从默认的标准输出设备（终端）重定向到指定的文件
cat users                  # 使用 cat 命令查看文件内容
```

### 输入重定向
语法： `command1 < file1` 这个命令从键盘获取输入的命令会转移到文件读取内容
```
wc -l users                # 2 users
wc -l < users              # 2
```
> 注意：上面两个例子的结果不同：第一个例子，会输出文件名；第二个不会，因为它仅仅知道从标准输入读取内容

### 重定向深入讲解
`command1 < infile > outfile`  同时替换输入和输出，执行command1，从文件infile读取内容，然后将输出写入到outfile中
一般情况下，每个 Unix/Linux 命令运行时都会打开三个文件
+ 标准输入文件(stdin)：stdin的文件描述符为0，Unix程序默认从stdin读取数据
+ 标准输出文件(stdout)：stdout 的文件描述符为1，Unix程序默认向stdout输出数据
+ 标准错误文件(stderr)：stderr的文件描述符为2，Unix程序会向stderr流中写入错误信息
默认情况下，command > file 将 stdout 重定向到 file，command < file 将stdin 重定向到 file
```
command 2 > file                                # stderr 重定向到 file
command 2 >> file                               # stderr 追加到 file 文件末尾
command > file 2>&1                             # 将 stdout 和 stderr 合并后重定向到 file
command >> file 2>&1                            # 将 stdout 和 stderr 合并后重定向到 file
command < file1 >file2                          # 将 stdin 重定向到 file1，将 stdout 重定向到 file2
``` 
### 特殊的重定向方式
Here Document 是 Shell 中的一种特殊的重定向方式，用来将输入重定向到一个交互式 Shell 脚本或程序,语法：
```
command << delimiter
    document
delimiter
```
它的作用是将两个 delimiter 之间的内容(document) 作为输入传递给 command
> 注意：
> 结尾的delimiter 一定要顶格写，前面不能有任何字符，后面也不能有任何字符，包括空格和 tab 缩进
> 开始的delimiter前后的空格会被忽略掉

#### 实例
+ 在命令行中通过 wc -l 命令计算 Here Document 的行数
```
wc -l << EOF
    Whisper
    Thunder
    Misty
EOF
```
输出
```
3          # 输出结果为 3 行
```
+ 在脚本中使用Here Document
```
#!/bin/bash
cat << EOF
    Whisper
    Thunder
    Misty
EOF
```
输出结果
```
 Whisper
 Thunder
 Misty
```

### /dev/null文件
+ 如果希望执行某个命令，但又不希望在屏幕上显示输出结果，那么可以将输出重定向到 /dev/null,语法:`command > /dev/null`
+ `/dev/null` 是一个特殊的文件，写入到它的内容都会被丢弃；如果尝试从该文件读取内容，那么什么也读不到。但是 /dev/null 文件非常有用，将命令的输出重定向到它，会起到"禁止输出"的效果
+ 如果希望屏蔽 stdout 和 stderr，可以这样写 `command > /dev/null 2>&1`,合并标准输出1和标准错误2，输出到文件/dev/null,实现屏蔽stdout和stderr的效果


## Shell文件包含
Shell 也可以包含外部脚本。这样可以很方便的封装一些公用的代码作为一个独立的文件,语法格式：
```
. filename   # 注意点号(.)和文件名中间有一空格
或
source filename
```
### 实例
创建两个 shell 脚本文件test1.sh,test2.sh,在test2.sh中通过`source`或者`.`引入test1.sh，注意在test2.sh就可以使用test1.sh定义的一些变量
+ `test1.sh`
```
#!/bin/bash
smart_name="Whisper"
```
+ `test2.sh`
```
#!/bin/bash
#使用 . 号来引用test1.sh 文件
. ./test1.sh
# 或者使用以下包含文件代码
# source ./test1.sh
echo "smart name ：${smart_name}"
```
+ 执行
```
 chmod u+x test2.sh
 ./test2.sh 
```
输出结果
```
smart name ：Whisper
```
> 注：被包含的文件 test1.sh 不需要可执行权限