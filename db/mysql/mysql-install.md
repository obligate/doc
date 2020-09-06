## mysql 
### install
> 使用`mysql8.0.15`版本
> `https://dev.mysql.com/downloads/mysql/`
> `https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.15-linux-glibc2.12-x86_64.tar.xz`
```
[root@node2 ~]# wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.15-linux-glibc2.12-x86_64.tar.xz
[root@node2 ~]# xz -d mysql-8.0.15-linux-glibc2.12-x86_64.tar.xz
[root@node2 ~]# tar -xvf mysql-8.0.15-linux-glibc2.12-x86_64.tar 
[root@node2 ~]# mv mysql-8.0.15-linux-glibc2.12-x86_64 /usr/local/mysql
# 配置
[root@node2 ~]# useradd mysql
[root@node2 ~]# mv my.cnf /etc/my.cnf
[root@node2 ~]# cd /usr/local/mysql
[root@node2 mysql]# mkdir data sql_log  undo
[root@node2 mysql]# chown mysql:mysql -R data/ sql_log/  undo/
[root@node2 mysql]# vim /etc/profile
export PATH=$PATH:/usr/local/mysql/bin
[root@node2 mysql]# source /etc/profile
# 初始化
[root@node2 mysql]# mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
mysqld: error while loading shared libraries: libaio.so.1: cannot open shared object file: No such file or directory
[root@node2 mysql]# yum -y install libaio
[root@node2 mysql]# mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
[root@node2 mysql]# ls data/   # 此时改目录机会生成一些文件了
# 启动
[root@node2 mysql]# cp /usr/local/mysql/support-files/mysql.server  /etc/init.d/mysqld
[root@node2 mysql]# /etc/init.d/mysqld  start
Starting MySQL... SUCCESS! 
[root@node2 mysql]# ps -ef|grep mysql
mysql     9093  9060  0 Sep05 ?        00:00:08 /metrics-sidecar
root     15182     1  0 09:57 pts/0    00:00:00 /bin/sh /usr/local/mysql/bin/mysqld_safe --datadir=/usr/local/mysql/data/ --pid-file=/usr/local/mysql/data//node2.pid
mysql    16116 15182  3 09:57 pts/0    00:00:01 /usr/local/mysql/bin/mysqld --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --plugin-dir=/usr/local/mysql/lib/plugin --user=mysql --log-error=/usr/local/mysql/sql_log/mysql-error.log --open-files-limit=65535 --pid-file=/usr/local/mysql/data//node2.pid --socket=/usr/local/mysql/data/mysql.sock --port=3306
root     16466 28293  0 09:58 pts/0    00:00:00 grep --color=auto mysql
# 获取root的初始化密码
[root@node2 mysql]# grep password /usr/local/mysql/sql_log/mysql-error.log 
2020-09-06T09:54:12.535921Z 5 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: 13aC#ntNVdo3
# 登录,并修改root的初始密码
[root@node2 mysql]# mysql -uroot -p13aC#ntNVdo3[root@node2 mysql]# mysql -uroot -p13aC#ntNVdo3
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.0.15

Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> alter user user() identified by '123456';     # 修改root的初始密码为 123456
Query OK, 0 rows affected (0.00 sec)
```