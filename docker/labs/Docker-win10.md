## 开启Centos7
```
docker pull centos
docker run -itd -p 44077:22 --name centos7 --privileged=true  centos  /usr/sbin/init
docker ps 
docker exec -it centos7 /bin/bash
yum install initscripts   -y                        # 可以使用ip a 和service命令
yum -y install net-tools                            # ifconfig
netstat -antp | grep sshd                           # 查看是否启动22端口
yum install openssh-server -y                       # install ssh service
service sshd start                                    
ssh -p 44077 root@宿主机ip                          # 通过宿主机ip登录centos7，本地直接用127.0.0.1,如何使用虚拟机的ip呢
docker start 容器id或者名称
docker logs 容器id或者名称
```

## win10 docker for windows 容器内网通过独立IP直接访问的方法
### 默认情况下
+ Docker的默认启动方式中，会产生一块虚拟网卡，然后容器内自行分配单独的网卡和IP。可以在宿宿主机上通过ipconfig命令看到这个虚拟网卡
![win10 docker nat](../img/win10_docker_nat.png)
+ 打开一个容器，可以看到容器ip地址为自动分配的
```
docker exec -it centos7 /bin/bash
```
![win10 docker centos container](../img/win10_docker_centos7.png)
+ 通过宿主机无法ping通

![win10 host ping centos7](../img/wn10_host_ping_centos.png)

### 配置宿主机的路由实现互通
+ 查看宿主机路由，`route print`
![win10 route print](../img/win10_route_print.png)  
+ 查看docker 的ip地址
![win10 docker for setting](../img/win10_docker_for_setting.png)
+ 暴露给宿主机的为10.0.75.1,宿主机添加路由
`route -p add 172.17.0.0 MASK 255.255.255.0 10.0.75.2`
> 删除路由 `route delete  172.17.0.0 MASK 255.255.255.0 10.0.75.2`
+ 重新ping容器地址,现在则可以直接通过ip访问
![win10 host ping centos7](../img/win10_host_ping_centos7.png)



## 启动nginx
### install
```
docker search nginx
docker pull nginx
docker images nginx
docker run --name nginx_aa -p 8081:80 -d nginx             # -d设置容器在在后台一直运行     -p 端口进行映射，将本地 8081 端口映射到容器内部的 80 端口  --name  nginx_aa 为容器的名字
docker ps
在浏览器中打开 http://127.0.0.1:8081/                       # 如何通过虚拟机的80端口访问呢？
```
### 部署
+ 宿主机创建目录 nginx, 用于存放后面的相关东西
```
mkdir -p ~/nginx/www ~/nginx/logs ~/nginx/conf
```
+ 拷贝容器内 Nginx 默认配置文件到本地当前目录下的 conf 目录，容器 ID 可以查看 docker ps 命令输入中的第一列
```
docker cp 容器id:/etc/nginx/nginx.conf ~/nginx/conf
# www: 目录将映射为 nginx 容器配置的虚拟目录
# logs: 目录将映射为 nginx 容器的日志目录
# conf: 目录里的配置文件将映射为 nginx 容器的配置文件
```
+ 部署,win10下会要求开启映射目录的共享
```
docker run -d -p 8082:80 --name nginx_bb -v ~/nginx/www:/usr/share/nginx/html -v ~/nginx/conf/nginx.conf:/etc/nginx/nginx.conf -v ~/nginx/logs:/var/log/nginx  nginx
# -p 8082:80： 将容器的 80 端口映射到主机的 8082 端口
# --name nginx_bb：将容器命名为 nginx_bb
# ~/nginx/www:/usr/share/nginx/html：将我们自己创建的 www 目录挂载到容器的 /usr/share/nginx/html
# -v ~/nginx/conf/nginx.conf:/etc/nginx/nginx.conf：将我们自己创建的 nginx.conf 挂载到容器的 /etc/nginx/nginx.conf
# -v ~/nginx/logs:/var/log/nginx：将我们自己创建的 logs 挂载到容器的 /var/log/nginx
```
+ 进入宿主机的 `~/nginx/www` 目录
`cd ~/nginx/www`
创建 index.html 文件，内容如下
```
vim index.html
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>nginx bb</title>
</head>
<body>
    <h1>我的第一个标题</h1>
    <p>我的第一个段落。</p>
</body>
</html>
```
在浏览器中打开 http://127.0.0.1:8082/  
+ 重新载入
如果要重新载入 NGINX 可以使用以下命令发送 HUP 信号到容器 `docker kill -s HUP container-name`
重启重启 NGINX 容器命令 `docker restart container-name`