## 1.导入epel安装源 
```
yum  install epel-release            # 导入epel安装源 
yum remove VirtualBox-4*             # 如果已经安装有老版本，需要先卸载原来版本
```
## 2.添加VirtualBox安装源
+ RHEL/CentOS 7/6/5
```
# cd /etc/yum.repos.d/
# wget http://download.virtualbox.org/virtualbox/rpm/rhel/virtualbox.repo 
```
+ RHEL/CentOS 5
```
# wget http://dl.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
# rpm -Uvh epel-release-5-4.noarch.rpm
```
+ Fedora 24-12
```
# cd /etc/yum.repos.d/
# wget http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo
```
## 3.安装相关依赖包
```
yum update
yum install binutils qt gcc make patch libgomp glibc-headers glibc-devel kernel-headers kernel-devel dkms
yum install kernel-plus-devel
或
yum install kernel-plus-devel-3.10.0-862.11.6.el7.centos.plus.1.x86_64
```
## 4.安装VirtualBox 5.1
```
yum install VirtualBox-5.1
```
## 5.重建VirtualBox 5.1内核模块
```
------------- Fedora 24-19 and CentOS/RHEL 7 -------------
＃/usr/lib/virtualbox/vboxdrv.sh setup
------------- Fedora 18-16 and CentOS/RHEL 6/5 -------------
#/etc/init.d/vboxdrv setup
## OR ##
#service vboxdrv setup
```
## 6.添加用户到vboxusers中 （user_name替换为相应的用户名)
```
usermod -a -G vboxusers user_name
```
## 如果有关于KERN_DIR的错误，则需要设置相应的全局变量
```
## RHEL / CentOS / Fedora ##
KERN_DIR=/usr/src/kernels/3.10.0-229.7.2.el7.x86_64
## Export KERN_DIR ##
export KERN_DIR
```