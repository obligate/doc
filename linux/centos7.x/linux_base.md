## 网络
### 防火墙
+ 关闭firewall
```
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