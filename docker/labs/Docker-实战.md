## 实战1-初体验-使用docker安装wordpress
+ 准备`docker-compose.yml`
+ 进入`01-first\wordpress\docker-compose.yml`所在目录
```
docker-compose up                                # 第一次启动会有点慢，需要去拉取镜像
docker-compose up -d 
docker-compose ps 
docker-compose logs
配置 wordpress，浏览器输入 http://dockerhostIp:8080
docker-compose run db env                       # 此处的db为Service名称，在docker-compose.yml文件定义的
docker-compose exec db bash                     # 此处的db为Service名称
docker-compose exec wordpress bash              # 此处的wordpress为Service名称
```
### Refer
+ [docker-compose参考](https://docs.docker.com/compose/wordpress/#define-the-project)
+ [wordpress](https://codex.wordpress.org/)

## 实战2 Docker
### 1.获取hello-world这个base image
```
docker image ls               
docker pull hello-world          # 拉取一个hello-world image
docker run hello-world           # 从一个hello-world的image运行一个container
```
### 2.image 制作
+ 1.切换目录`02-docker\hello-world`
+ 2.创建hello.c
```
mkdir helloworld
vim hello.c
#include<stdio.h>
int main()
{
   printf("hello docker\n");
}
```
+ 3.编译运行
```
history |grep yum                   # 查看是否通过yum安装了gcc 和glibc-static
sudo yum install gcc
sudo yum install glibc-static
gcc -static hello.c  -o hello       # 编译
./hello                             # 运行
```
+ 4.创建一个Dockerfile
```
vim Dockerfile
FROM scratch
ADD hello /
CMD ["/hello"]
```
+ 5.测试
```
docker build -t peterhly/hello-world .  在当前目录查找dockerfile创建base image,标签名称为peterhlycf/helloworld,版本默认是latest
docker image ls 
docker history imageId  查看imageid的分层情况
docker run  peterhly/hello-world  运行一个container
```

### 3.创建容器`docker run`
```
docker version
docker info
docker container ls			       列出当前正在运行的容器
docker container ls -a 		       列出当前正在运行的容器以及退出的
docker run centos  			       创建并运行一个centos container
docker run -it centos              交互运行一个container，进入到centos这个容器里面，进行操作，exit可以退出
docker image ls
docker images
docker ps -a 
docker image rm imageid
docker rmi imageid
docker container rm containerId
docker rm containerId
docker container ls -aq 拿到所有运行及退出的容器id
类似于
docker container ls -a |awk '{print $1}'
docker rm  $(docker container ls -aq)  					 批量删除所有的容器
docker rm  $(docker container ls -f "status=exited" -q)  批量删除所有退出的容器
```
### 4.创建容器`docker container commit`，不推荐，只做了解即可
+ `docker container commit`构建，不推荐
```
docker container commit   可以简写为docker commit         把container重新变成一个image
docker image build        可以简写为 docker build 
例子演示：
docker run -it centos  进入centos，安装自己的软件
例如在容器里面，安装vim，  yum -y install vim 然后退出
docker container ls -a 
docker commit containerName或者id peterhly/centos-vim 把一个container提交成一个image
docker image ls  
docker history imageId  查看image的layer的情况
```
+ `docker image build ` 构建
```
把刚才的vim镜像删除，通过build方式创建
docker image rm imageId
mkdir docker-centos-vim
cd docker-centos-vim
vim Dockerfile
FROM centos
RUN yum install -y vim
保存运行
docker build -t peterhly/centos-vim-new .
```
### 5. flask-hello-world
将fdockerlask-hello-world打包到容器，进行访问
```
docker\labs\02-docker\flask-hello-world
docker build -t peterhly/flask-hello-world .
如果报错，可以通过以下方式调试
docker run -it 报错临时生成的imageid /bin/bash   #通过报错临时生成的imageid使用bash进入
=============
docker run peterhly/flask-hello-world         ##启动container
docker run -d peterhly/flask-hello-world      ##后台运行container，使用-d
docker ps 
```


## Refer
+ [Docker Hub](https://docs.docker.com)
+ [163 Hub](https://c.163yun.com/hub#/m/home/)