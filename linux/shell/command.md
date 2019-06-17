## getopts
+ getopts是shell的一个内置命令,被shell程序用来分析位置参数,用于获取命令行中的参数
    + 语法： `getopts optstring name [args]`
    + 内置变量: `OPTIND,OPTARG,OPTERR`
+ getopts 后面的字符串就是可以使用的选项列表，每个字母代表一个选项，后面带:的意味着选项除了定义本身之外，还会带上一个参数作为选项的值，比如 a:在实际的使用中就会对应-a 11，选项的值就是 11；getopts 字符串中没有跟随:的是开关型选项，不需要再指定值，相当于 true/false，只要带了这个参数就是 true。如果命令行中包含了没有在 getopts 列表中的选项，会有警告信息，如果在整个 getopts 字符串前面也加上个:，就能消除警告信息了
+ optstring
  + 包含需要被识别的选项字符，如果这里的字符后面跟着一个冒号，表明该字符选项需要传入一个参数，如果不传入回报错，例如`a:`、`a:b:`,`ab:`,`:a:b:`,`:ab:`
  + 传入参数需要以空格分隔`-a 1`。冒号和问号不能被用作选项字符
+ name
  + getopts每次被调用时，它会将下一个选项字符放置到变量name
> optstring选项之间使用冒号:分隔`a:b`，也可以直接连接`ab:`， `:`表示选项后面需要传值，不加`:`表示选项后面不需要传值
> 当getopts命令发现冒号后，会从命令行该选项后读取该值,如该值存在，将保存在特殊的变量OPTARG中
> 当option_string用`:`开头,则会进入静默模式，getopts会区分invalid option错误和miss option argument错误，invalid option时, name会被设成`?`即`name=?`,miss option argument时，name会被设成`:`即`name=:`
> 当option_string不用`:`开头，invalid option错误和miss option argument错误都会使name被设成`?`即`name=?`
+ `OPTARG` 保存选项后的参数值
+ `OPTIND` 表示命令行下一个选项或参数的索引
### 使用getopts命令获取参数
+ 创建文件`vim test_getopts_1.sh`
```
#!/bin/bash
while getopts a:b:c:d opts; do
    case $opts in
        a) a=$OPTARG ;;
        b) b=$OPTARG ;;
        c) c=$OPTARG ;;
        d) d=$OPTARG ;;
        ?) ;;
    esac
done

echo "a=$a"
echo "b=$b"
echo "c=$c"
echo "d=$d"

exit 0
```
+ 执行1
```
./test_getopts_1.sh -a 1 -b 2 -c 3 -d 4
a=1
b=2
c=3
d=
```
> option_string `a:b:c:d`, a,b,c后都有`:`，d后没有`: ` **所以可以获取到a,b,c的值** 

+ 执行2 `-c 不传值`,此时会报错，如何解决，可以在option_string前加`:`
```
./test_getopts_1.sh -a 1 -b 2 -c
./test_getopts_1.sh: option requires an argument -- c
a=1
b=2
c=
d=
```
### option_string前加:进入静默模式
+ 上例执行2中，如果a,b,c任意一个没有传值，将会提示出错。例如 -c 不传值
+ 我们在option_string前加上:，则可以屏蔽这个错误
+ 修改代码`vim test_getopts_2.sh`
```
#!/bin/bash

while getopts :a:b:c:d opts; do
    case $opts in
        a) a=$OPTARG ;;
        b) b=$OPTARG ;;
        c) c=$OPTARG ;;
        d) d=$OPTARG ;;
        ?) ;;
    esac
done

echo "a=$a"
echo "b=$b"
echo "c=$c"
echo "d=$d"

exit 0
```
+ 执行1输出
```
./test_getopts_2.sh -a 1 -b 2 -c
a=1
b=2
c=
d=
```
+ 执行2输出,例如缺失a的传值，命令会把-a后的-b作为了-a的值，导致错误
```
./test_getopts_2.sh -a -b 2 -c 3
a=-b
b=
c=
d=
```
+ 执行3输出，例如a不传值，则-a不要加入命令行
```
./test_getopts_2.sh -b 2 -c 3
a=
b=2
c=3
d=
```
> 在option_string前加上:，可以屏蔽缺失传值的错误，但如果缺失的是前面选项的值，那么获取到的值将会错误,参见执行2输出
> 因此使用getopts命令时，对于没有传值的选项，选项名称不要加入命令行中，参见执行3输出


### optstring选项之间直接连接
+ optstring选项之间直接连接`ab:`，相当于a可以不用传入值，b后面有`:`需要传入值,执行的时候可以传入`-ab 1`或者`-b 1`
+ 创建文件`vim test_getopts_3.sh`
```
#!/bin/sh
while getopts :ab:c: OPTION;do
    case $OPTION in
    a)echo "get option a and parameter is $OPTARG" ;; 
    b)echo "get option b and parameter is $OPTARG" ;; 
    c)echo "get option c and parameter is $OPTARG" ;; 
    ?)echo "get a non option $OPTARG and OPTION is $OPTION" ;; 
    esac
done
```
+ 执行1输出
```
./test_getopts_3.sh -ab 1 -p -c
get option a and parameter is         # a后面没有:，getopts不会读取值
get option b and parameter is 1
get option c and parameter is ?
get a non option $OPTARG and OPTION is :
```
>-a和-b是正确的选项，-p和-c分别对应错误选项的两种情况
+ 执行2 输出
```
./test_getopts_3.sh -a 1 -b 1
get option a and parameter is 
```
+ 执行3输出
```
./test_getopts_3.sh  -b 1 -c 1
get option b and parameter is 1
get option c and parameter is 1
```
