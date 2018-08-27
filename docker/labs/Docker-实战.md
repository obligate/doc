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
### 4.通过容器创建image`docker container commit`，不推荐，只做了解即可
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
1. 可以手动的方式执行安装python，然后运行 python app.py,访问结果，如果访问不了，需要配置一下防火墙的策略
2. 通过Dockerfile 构建image，运行container进行访问
docker\labs\02-docker\flask-hello-world
docker build -t peterhly/flask-hello-world .
如果报错，可以通过以下方式调试
docker run -it 报错临时生成的imageid /bin/bash   #通过报错临时生成的imageid使用bash进入
=============
docker run peterhly/flask-hello-world         ##启动container
docker run -d peterhly/flask-hello-world      ##后台运行container，使用-d
docker ps 
docker inspect 容器id，获取一下ip地址为： 172.17.0.2
在docker host机器通过，curl http://172.17.0.2:5000  就可以进行访问， 此时其他机器访问不了
```
### 6. 容器build一个ubuntu的命令行工具：stress
+ 手工执行
```
docker run -it ubuntu                             # 运行并进入容器内部
apt-get update && apt-get install -y stress       # 安装stress
which stress
stress --help
stress --vm 2 --verbose                      ## 启动2个worker，默认一个worker内存是256M
stress --vm 1 --vm-bytes 500000M --verbose   ## 启动一个worker，自动启动的内存500000M,测试失败，受限于容器本身或者docker host
另一个docker host shell查看top 查看当前docker host的内存总量
```
+ Dockerfile执行
```
docker\labs\02-docker\ubuntu-stress
docker build -t peterhly/ubuntu-stree . 
docker image ls
docker run -it  peterhly/ubuntu-stree                     ## 类似于执行了stress命令的help信息
docker run -it  peterhly/ubuntu-stree --vm 1  --verbose   ## 类似于执行了stress命令的传入参数--vm 1 --verbose
```
## 实战3-Docker Network
### 1  多容器复杂应用的部署
```
### 场景 ----  python flask 访问redis
1. 启动redis
2. 根据Dockerfile构建一个flask-redis的image
3. 根据flask-redis，启动一个容器flask-redis，做一个单向的绑定 --link redis
4. 测试：
	1. 进入flask-redis容器内部，执行ping redis 和 curl http://127.0.0.1:5000(可以执行多次）
	2. 在dockerhost访问curl http://127.0.0.1:5000,结果不能访问，因为没有portmap
5. 删除flask-redis的容器，添加portmap
6. 测试：
	在docker host上访问curl http://127.0.0.1:5000，可以访问
#################### 命令#########################################
docker\labs\03-docker-network\flask-redis
sudo docker run -d --name redis redis    # 启动一个redis的container
sudo docker build -t peterhly/flask-redis .
sudo docker image ls
## -d 后台运行，--link和redis做一个单向绑定，在flask-redis容器内可以通过这个link访问redis
## -e 在当前的容器设置一个环境变量REDIS_HOST=redis,进入容器内部使用env可以看到设置的环境变量
sudo docker run -d --link redis --name flask-redis -e REDIS_HOST=redis  peterhly/flask-redis
sudo docker exec -it flask-redis /bin/bash
env   
ping redis
curl http://127.0.0.1:5000
curl http://127.0.0.1:5000
curl http://127.0.0.1:5000  执行多次
exit
此时外面无法访问curl http://127.0.0.1:5000，没有port map
sudo docker stop flask-redis
sudo docker rm flask-redis
sudo docker run -d -p 5000:5000 --link redis --name flask-redis -e REDIS_HOST=redis  peterhly/flask-redis
此时本地就可以访问 curl http://127.0.0.1:5000
```
## 实战4-Docker Compose
### 4.1  命令行部署wordpress
```
# 创建一个mysql container
docker run -d --name mysql -v mysql-data:/var/lib/mysql -e  MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=wordpress  mysql   
docker ps 
# 创建一个 wordpress container 
docker run -d -e WORDPRESS_DB_HOST=mysql:3306 --link mysql -p 8080:80 wordpress
docker ps
本地浏览器 http://127.0.0.1:8080 配置wordpress
```
### 4.2 docker-compose.yml部署wordpress
docker-compose的基本使用
```
labs\05-docker-compose\wordpress\
docker-compose up                           ## Create and start containers
docker-compose up -d                        ## 后台运行
docker-compose -f docker-compose.yml        ## Create and start containers
docker-compose ps                           ## 查看serive
docker-compose images 
docker-compose exec mysql bash              ## 进入mysql的bash,mysql是在yml文件中定义的
docker-compose stop                         ## stop
docker-compose start                        ## start
docker-compose down      	                ## stop and remove
docker-compose network ls
```
### 4.3 docker-compose.yml部署flask-redis
```
labs\05-docker-compose\flask-redis\
docker-compose up -d  默认开启
docker-compose down   
docker-compose up --scale  web=3 -d    此时scale会报错,因为端口问题，把yml中的端口映射去掉 ports:- 8080:80
docker-compose down
docker-compose up --scale  web=3 -d    去掉端口，启动就不会报错，这种不好，可以考虑使用loadbalance
```
### 4.4 scale采用haproxy 
```
labs\05-docker-compose\lb-sacle\
docker-compose up -d 
docker-compose ps 
curl 127.0.0.1:8080
docker-compose up --scale web=5 -d  扩展
docker-compose ps
curl 127.0.0.1:8080  多次访问的时候发现hostname不一样
curl 127.0.0.1:8080  
for i in `seq 10`;do curl 127.0.0.1:8080; done 
docker-compose up --scale web=3 -d 减少  
```
### 4.5 投票系统实战
```
docker-compose build
docker-compose up 
http://docker host ip:5000    # 投票
http://docker host ip:5001    # 显示结果
```
## 实战5 - Docker Swarm
### 5.1 手工部署wordpress
```
docker network create -d overlay demo      #此时在manager上有overlay，其他节点创建服务的时候就会把overlay同步过去
docker network ls
docker service create --name mysql --env MYSQL_ROOT_PASSWORD=root --env MYSQL_DATABASE=wordpress --network demo  --mount  type=volume,source=mysql-data,destination=/var/lib/mysql  mysql 
docker service ls
docker service ps mysql    看mysql容器在哪里，到对应的机器看一下docker ps 
docker service create --name wordpress -p 80:80 --env WORDPRESS_DB_PASSWORD=root --env WORDPRESS_DB_HOST=mysql     --network demo wordpress
docker service ps wordpress  查看对应的docker host，在浏览器通过ip访问，在swarm的机器的任意一个节点都可以访问wordpress
```
### 5.2 部署Wordpres
[compose-file/#deploy](https://docs.docker.com/compose/compose-file/#deploy)
```
cd labs\06-docker-swarm\wordpress\
more docker-compose.yml
docker stack deploy wordpress --compose-file=docker-compose.yml    ## 创建一个名为wordpress的stack
docker stack ls
docker stack ps wordpress          # 查看当前stack里面包含的container
docker stack services wordpress    # 查看当前stack里面包含的service
docker stack rm wordpress          # 删除当前的stack
验证：打开浏览器 http://192.168.0.11:8080
```
### 5.3 部署vote
+ stack 默认的network是overlay
+ 不能通过build方式构建，必须通过image，所以需要先生成image，此例子用的是hub上的example
```
cd labs\06-docker-swarm\example-vote-app
docker stack deploy example --compose-file=docker-compose.yml    ## 创建一个名字为example的stack
docker stack ls                    # 查看当前的service数量
docker stack service example       # 查看具体service的的情况
验证：
http://192.168.0.11:5000            # 投票
http://192.168.0.11:5001            # 应该打不开，使用的angular.js 需要翻墙才可以，或者自己build一个image
http://192.168.0.11:8080            # swarm的可视化工具
docker service scale example_vote=3   # 扩容到3
docker stack services example         # 查看example stack的情况
http://192.168.0.11:8080            # swarm的可视化工具，就会把example_vote变成3
docker stack rm example
```
### 5.4 更新service
```
docker\labs\06-docker-swarm\python-flask-demo
先确保有一个overylay的网络，没有可以创建一个
docker network ls 
docker network create -d overlay demo
docker service create --name web --publish 8080:5000 --network demo peterhly/python-flask-demo:1.0
docker service ps web   ## 查询web service所在的机器
docker service scale web=2   # 更新之前先把service为web的横向扩展为2，防止更新过程中，访问不中断
docker service ps web
curl 127.0.0.1:8080     返回正常
验证更新过程中是否中断，我们需要做一个测试，首先登陆到一个work上，例如 vagrant ssh swarm-work1
curl 127.0.0.1:8080     返回正常
sh -c "while true; do curl  127.0.0.1:8080&& echo "\n"&& sleep 1 ; done "   # 每隔1秒访问一次
在我们的manager的服务器进行 service 更新
docker service update --image peterhly/python-flask-demo:2.0 web          ## 更新image到2.0版本
docker service ps web     发现1.0版本的在shutdown
docker service update --publish-rm 8080:5000 --publish-add 8088:5000 web   ##更新端口,会中断一会
## docker stack 更新,还是通过docker stack deploy的方式来进行service的更新操作
docker stack deploy web -c=docker-compose.yml
```
## Refer
+ [Docker Hub](https://docs.docker.com)
+ [163 Hub](https://c.163yun.com/hub#/m/home/)