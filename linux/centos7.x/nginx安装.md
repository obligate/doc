## CentOS 安装 nginx
+ Mainline version：Mainline 是 Nginx 目前主力在做的版本，可以说是开发版
+ Stable version：最新稳定版，生产环境上建议使用的版本
+ Legacy versions：遗留的老版本的稳定版
### 1.方法一：rpm包安装
#### 1.1 配置nginx源
+ 配置nginx官方源（推荐）

```
[root@node1 ~]# vim /etc/yum.repos.d/nginx.repo
添加：
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1
```

+  或者 配epel源
```
备份(如有配置其他epel源)（推荐阿里epel源）
mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.backup
下载新repo 到/etc/yum.repos.d/
epel(RHEL 7)
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
epel(RHEL 6)
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
```

+ 或者直接安装rpm源
```
rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
```
#### 1.2 安装
```
yum list |grep nginx
yum -y install nginx            # 安装
nginx -v                        # 查看版本
```
### 2.方法二：源码编译安装nginx
#### 2.1 安装依赖
+ 安装gcc、gcc-c++、C/C++语言编译环境 `yum install gcc gcc-c++ autoconf automake make -y`
+ 或者 `yum groupinstall "Development Tools" "Server Platform Development" -y`
+ yum安装nginx依赖库 `yum install pcre-devel zlib-devel openssl openssl-devel libxml2-devel libxslt-devel perl-devel perl-ExtUtils-Embed libtool  patch -y`
+ 创建一个名为nginx且没有登录权限的用户和一个名为nginx的用户组
```
groupadd -r nginx
useradd -r -g nginx -M -s /sbin/nologin -d /usr/local/nginx nginx
id nginx
添加新用户参数：
-r: 添加系统用户( 这里指将要被创建的系统用户nginx)
-g: 指定要创建的用户所属组( 这里指添加到新系统用户nginx到nginx系统用户组 )
-s: 新帐户的登录shell( /sbin/nologin 这里设置为将要被创建系统用户nginx不能用来登录系统 )
-d: 新帐户的主目录( 这里指定将要被创建的系统用户nginx的家目录为 /usr/local/nginx )
-M: 不要创建用户的主目录( 也就是说将要被创建的系统用户nginx不会在 /home 目录下创建 nginx 家目录 )
```
#### 2.2 下载、解压
源码包下载地址：https://nginx.org/en/download.html
+ 下载稳定版（Stable version），例如我下载1.16.0 `wget https://nginx.org/download/nginx-1.16.0.tar.gz`
+ 解压 `tar xf nginx-1.14.0.tar.gz`
  
#### 2.3 配置编译参数
使用该configure命令配置构建。它定义了系统的各个方面，包括允许nginx用于连接处理的方法。最后它创造了一个Makefile。
官方参数说明：https://nginx.org/en/docs/configure.html
为方便以后支持tcp转发，推荐编译时添加stream模块，需要手动添加参数：--with-stream
```
[root@node1 ~]# ./configure \
--prefix=/usr/local/nginx \
--sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/run/nginx.lock \
--user=nginx \
--group=nginx \
--with-compat \
--with-file-aio \
--with-threads \
--with-http_addition_module \
--with-http_auth_request_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_mp4_module \
--with-http_random_index_module \
--with-http_realip_module \
--with-http_secure_link_module \
--with-http_slice_module \
--with-http_ssl_module \
--with-http_stub_status_module \
--with-http_sub_module \
--with-http_v2_module \
--with-stream \
--with-stream_realip_module \
--with-stream_ssl_module \
--with-stream_ssl_preread_module \
--with-ld-opt="-Wl,-E"
```
#### 2.4 编译 & 安装
```
make && make install
```