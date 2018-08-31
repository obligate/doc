## 网络
### 防火墙
+ 关闭firewall
```
firewall-cmd --state             # 查看状态
systemctl stop firewalld.service #停止firewall
systemctl disable firewalld.service #禁止firewall开机启动
```
+ 安装iptables防火墙
```
#安装
yum install iptables-services 
```
+ 编辑防火墙配置文件
```
vi /etc/sysconfig/iptables
```
+ 重启
```
systemctl restart iptables.service #最后重启防火墙使配置生效
systemctl enable iptables.service #设置防火墙开机启动
```

## fdisk & mount
```
fdisk -l                                                                           # 查看新加入的硬盘
fidsk /dev/xvdb -> m 获取帮助 -> n 添加分区 -> p 主分区 -> w 写分区
yum -y install e4fsprogs
mkfs -t ext4 /dev/xvdb1
mount /dev/xvdb1 /mnt
vim /etc/fstab   
/dev/xvdb1  /mnt      ext4    defaults        0 0
```

## 常用配置
### hostname
```
# 一旦修改了静态主机名，/etc/hostname 将被自动更新。然而，/etc/hosts 不会更新以保存所做的修改，所以你每次在修改主机名后一定要手动更新/etc/hosts，之后再重启CentOS 7。否则系统再启动时会很慢
hostnamectl set-hostname node_master                       # 修改hostname
```
### 安装EPEL
```
rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install epel-release
yum clean all && yum makecache         # 清除系统所有的yum缓存 和 生成yum缓存
yum repolist
```

## 常用命令
### 端口占用情况
#### lsof -i:端口号
```
yum install lsof -y
lsof -i:端口号 用于查看某一端口的占用情况，比如查看8000端口使用情况，lsof -i:8000
```
#### netstat -tunlp |grep 端口号
```
netstat -tunlp |grep 端口号，用于查看指定的端口号的进程情况，如查看8000端口的情况，netstat -tunlp |grep 8000
-t (tcp) 仅显示tcp相关选项
-u (udp)仅显示udp相关选项
-n 拒绝显示别名，能显示数字的全部转化为数字
-l 仅列出在Listen(监听)的服务状态
-p 显示建立相关链接的程序名
```