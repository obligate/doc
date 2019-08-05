## read使用
```
vim read.sh
#!/bin/bash
read -t 30 -p "pls input your name:" name                   #提示“请输入姓名”并等待30秒，把用户的输入保存入变量name中
echo "Name is $name" 
read -s -t 30 -p "pls enter your age:" age                  #年龄是隐私，所以用-s选项隐藏输入
echo -e "\n"
echo "Age is $age"
read -n 1 -t 30 -p "pls select your gender[M/F]:"gender     #使用“-n 1“选项只接受一个输入字符就会执行（都不用输入回车）
echo -e "\n"
echo "Sex is $gender"
```
## 备份数据库
```
#!/bin/bash
#备份mysql数据库
ntpdate asia.pool.ntp.org &>/dev/null  #同步系统时间
date=$(date +%y%m%d)   #把当前系统时间按照“年月日”格式赋予变量date
##date "+%Y-%m-%d %H:%M:%S" 
size=$(du -sh /var/lib/mysql)  #统计mysql数据的大小，并把大小赋予size变量
if [ -d /tmp/dbbak ] 
   then
	echo "Date:$date!" > /tmp/dbbak/dbinfo.txt
	echo "Data size : $size" >> /tmp/dbbak/dbinfo.txt
	cd /tmp/dbbak
	tar -zcf mysql-lib-$date.tar.gz /var/lib/mysql dbinfo.txt &>/dev/null
	rm -rf /tmp/dbbak/dbinfo.txt
else
	mkdir /tmp/dbbak
	echo "Date:$date!" > /tmp/dbbak/dbinfo.txt
	echo "Data size : $size" >> /tmp/dbbak/dbinfo.txt
	cd /tmp/dbbak
	tar -zcf mysql-lib-$date.tar.gz /var/lib/mysql dbinfo.txt &>/dev/null
	rm -rf /tmp/dbbak/dbinfo.txt
fi
```

## nmap
```
#!/bin/bash
port=$(nmap -sT 192.168.1.156 |grep tcp |grep http|awk '{print $2}')
#使用nmap命令扫描服务器，并截取apache服务的状态，赋予变量port
if [ $port == "open" ]
   then 
	echo "$(date) httpd is ok!" >> /tmp/autostart-acc.log
else
	/etc/rc.d/init.d/httpd start &>/dev/null
	echo "$(date) restart httpd !!" >> /tmp/autostart-err.log
fi
```

## 批量添加用户
```
#!/bin/bash
#批量添加指定数量的用户
read -p -t 30 "Please input user name:" name
read -p -t 30 "Please input the number of users:" num
read -p -t 30 "please input the password of users:" pass

if [ !-z "$name" -a ! -z "$num" -a ! -z "$pass"]
   then
	y=$(echo $num|sed 's/[0-9]//g')  #判断num是否为数字，用sed做替换
	if [ -z "$y" ]
	then
		for((i=1;i<=$num;i=i+1))
			do
				/usr/bin/useradd $name$i &>/dev/null
				echo $pass|/usr/bin/passwd --stdin $name$i &>/dev/null
			done
	fi
fi
```

## getopts
```
#!/bin/sh 
day=7  #default value 
while getopts ":d:" opt; do 
  case $opt in 
    d) 
      day=$OPTARG   #get the value 
      ;; 
    ?) 
      echo "How to use: $0 [-d DAY]" >&2 
      exit 1 
      ;; 
    :) 
      echo "Option -$OPTARG requires an argument." >&2 
      exit 1 
      ;; 
  esac 
done 
echo $day
```
`./sample -d 5`

## shift
```
#!/bin/bash
while [ -n "$*" ]
        do
                echo $1 $2 $3 $4 $5 $6
                shift
        done
运行输出
[fsy@localhost scripts]$ sh b.sh 1 2 3 4 5 6 7
1 2 3 4 5 6
2 3 4 5 6 7
3 4 5 6 7
4 5 6 7
5 6 7
6 7
7
```

## 获取随机码
```
cat /dev/urandom | tr -dc a-zA-Z0-9#@ | head -c 13;echo
tr -dc 'a-z' < /dev/urandom | fold -w 8 | head -1
```
> 备注:tr命令是替换或者删除字符的命令.-d的意思是删除后面集合中的字符,-c的意思是取反,就是说,除了后面的字符集合其他的都删除掉.我们可以通过后面的字符的集合来指定自己的密码复杂度



## git 代码统计
```
git log --author="Linus Torvalds" --date=iso | perl -nalE 'if (/^Date:\s+[\d-]{10}\s(\d{2})/) { say $1+0 }' | sort | uniq -c|perl -MList::Util=max -nalE '$h{$F[1]} = $F[0]; }{ $m = max values %h; foreach (0..23) { $h{$_} = 0 if not exists $h{$_} } foreach (sort {$a <=> $b } keys %h) { say sprintf "%02d - %4d %s", $_, $h{$_}, "*"x ($h{$_} / $m * 50); }'
```