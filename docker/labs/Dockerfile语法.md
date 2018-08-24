## Dockerfile
+ [github Dockerfile学习例子](https://github.com/docker-library)
+ [语法](https://docs.docker.com/engine/reference/builder/)
### FROM
+ `FROM scratch`        						# 制作base image
+ `FROM centos `        						# 使用base image
+ `FROM ubuntu:14.04` 
> 尽量使用官方的image作为base image

### LABEL
+ `LABEL maintainer="peterhlycf@gmail.com"`      # 作者
+ `LABEL version="1.0"`						     # 版本
+ `LABEL description="This is description"`	     # 描述
> LABEL Metadata不可少！

### RUN  执行命令并创建新的Image layer
+ `RUN yum update && yum install -y vim python-dev`
+ `RUN apt-get update && apt-get install -y perl pwgen --no-install-recommend && rm -rf /var/lib/apt/lists/*`
+ `RUN /bin/bash -c 'source $HOME/.bashrc;echo $HOME'`
> 为了美观，复杂的RUN请用反斜线换行，避免无用分层，合并多条命令成一行

### WORKDIR  设定当前工作目录
+ `WORKDIR /root`
+ `WORKDIR /test ` 如果没有test目录会自动创建test目录
+ `WORKDIR demo`
+ `RUN pwd`       输出结果应该是 /test/demo
> 用WORKDIR，不要用RUN cd！
> 尽量使用绝对目录

### ADD and COPY  
+ `ADD hello / ` 把hello文件添加放到根目录
+ `ADD test.tar.gz / ` 添加到根目录并解压
+ ADD and COPY
```
WORKDIR /root
ADD hello test/     #/root/test/hello
WORKDIR /root
COPY hello test/
```
> 大部分情况，COPY 优于 ADD
> ADD 除了 COPY 还有额外功能(解压)！
> 添加远程文件 / 目录请使用curl 或者 wget！

### ENV
```
ENV MYSQL_VERSION 5.6 # 设置常量
RUN apt-get install -y mysql-server="${MYSQL_VERSION}" \
    && rm -rf /var/lib/apt/list/*    #引用常量
```
> 尽量使用ENV增加可维护性

### VOLUME and EXPOSE  存储和网络

### CMD and ENTRYPOINT 
+ RUN 执行命令并创建新的Image layer
+ CMD  设置容器启动后默认执行的命令和参数
	+ 容器启动后默认执行的命令和参数
	+ 如果Docker run 指定了其他命令，CMD命令被忽略
	+ 如果定义了多个CMD，只有最后一个会执行
+ ENTRYPOINT 设置容器启动时运行的命令
	+ 让容器以应用程序或者服务的形式运行
	+ 不会被忽略，一定会执行
	+ 最佳实践：写一个shell脚本作为entrypoint
	```
		COPY docker-entrypoint.sh /usr/local/bin/
		ENTRYPOINT ["docker-entrypoint.sh"]
		EXPOSE 27017
		CMD ["mongod"]
	```
+ shell和exec格式
	+ shell格式
	```
		RUN apt-get install -y vim
		CMD echo "hello docker"
		ENTRYPOINT echo "hello docker"
	```
	+ exec 格式
	```
		RUN ["apt-get", "install", "-y", "vim"]
		CMD ["bin/echo", "hello docker"]
		ENTRYPOINT ["bin/echo", "hello docker"]
	```
+ 实例
	+ Dockerfile1
	```
		FROM centos
		ENV name Docker
		ENTRYPOINT echo "hello $name"     			##输出 hello Docker
	```
	+ 生成ENTRYPOINT的shell 的image和container
	```
		docker build -t peterhly/centos-entrypoint-shell .    ## 构建image
		docker run peterhly/centos-entrypoint-shell           ## 生成container并运行
	```
	+ Dockerfile2
	```
		FROM centos
		ENV name Docker
		ENTRYPOINT ["bin/echo", "hello $name"]     ##输出hello $name
		//ENTRYPOINT ["bin/bash","-c", "echo hello $name"]     ##输出hello Docker
	```
	+ 生成ENTRYPOINT的exec 的 image和containter
	```
		docker build -t peterhly/centos-entrypoint-exec  .    ## 构建image
		docker run peterhly/centos-entrypoint-exec           ## 生成container并运行
	```
	+ Dockerfile3
	```
		FROM centos
		ENV name Docker
		CMD echo "hello $name"       ## 输出hello Docker
	```
	+ 生成CMD 的image和containter
	```
		docker build -t peterhly/centos-cmd-shell  .    ## 构建image
		docker run peterhly/centos-cmd-shell            ## 生成container并运行
		docker run  -it peterhly/centos-cmd-shell /bin/bash 此时不会输出hello Docker,因为我们指定了/bin/bash
		docker run  -it peterhly/centos-entrypoint-shell /bin/bash 此时一定输出hello Docker,虽然我们指定了/bin/bash
	```