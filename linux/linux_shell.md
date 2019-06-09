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

用户在命令行输入命令后，一般情况下Shell会fork并exec该命令，但是Shell的内建命令例外，执行内建命令相当于调用Shell进场中的一个函数，并不创建新的进程。以前学过的cd,alias,umask,exit等命令即是内建没拿命令，凡是用which命令查不到的程序文件所在位置的命令都是内建命令，内建命令没有单独的man手册，要在man手册中查看内建命令，应该执行`man bash-builtins`
如export、shift、if、eval、[、for、while等等。内建命令虽然不创建新的进程，但也会有Exit Status,通常也用0表示成功非零表示失败，虽然内建命令不创建新的进程，但执行结束后也会有一个状态码，也可以用特殊变量$?读出。