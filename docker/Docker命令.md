## Docker
```
sudo docker version             # 查看版本
ps -ef |grep docker             # 查看docker的进程
docker info
```
### Docker image
```
docker image ls                          # 查看本地的image
docker images                            # 查看本地的image
docker image rm imageid                  # 根据imageid删除一个本地的image
docker rmi imageid						 # 根据imageid删除一个本地的image
docker pull hello-world                  # 拉取一个hello-world的image
docker pull ubuntu:14.04                 # 拉取一个ubuntu版本为14.04的image
docker build -t peterhly/hello-world .   # 从Dockerfile创建一个image
docker history imageId                   # 查看imageid的分层情况
docker run  peterhly/hello-world         # 创建并运行一个container
```
### Docker container
```
docker container ls                     # 列出当前正在运行的容器
docker container ls -a                  # 列出当前所有的容器已经退出的
docker run centos  			            # 创建并运行一个centos container
docker run -it centos                   # 交互运行一个container，进入到centos这个容器里面，进行操作，exit可以退出
docker ps -a                            # 拿到所有运行及退出的容器
docker container rm containerId         # 根据containerId删除一个container
docker rm containerId                   # 根据containerId删除一个container 
docker container ls -aq                                 # 拿到所有运行及退出的容器id
docker container ls -a |awk '{print $1}'                # 拿到所有运行及退出的容器id
docker rm  $(docker container ls -aq)  					# 批量删除所有的容器
docker rm  $(docker container ls -f "status=exited" -q) # 批量删除所有退出的容器
```
## Docker 镜像发布

## Docker compose

### 使用
```
cd yml文件所在的目录 
docker-compose build                       ## 拉取image
docker-compose -f  docker-compose.yml up   ##-f  docker-compose.yml 默认可以除掉
docker-compose ps 
docker-compose run db env                  ## 查看服务可用的环境变量
docker-compose stop   					   ## 停止
docker-compose rm
docker-compose down                        ## 停止并删除
docker-compose up -d                       ## 后台执行，调试不建议
docker-compose images 
docker-compose exec mysql bash             ## 进入mysql的bash,mysql是在yml文件中定义的
docker-compose exec wordpress bash
```
### 使用方法(参考)
```
docker-compose [选项] [子命令]
```

### 选项

| 选项      | 说明                                        |
| --------- | ------------------------------------------- |
| -f        | 指定配置文件, 默认为 `./docker-compose.yml` |
| -p        | 设置项目名, 默认为配置文件上级目录名        |
| --verbose | 输出详细信息                                |
| -H        | 指定docker服务器, 相当于 `docker -H`        |



### 子命令列表

| 子命令  | 说明                                                         |
| ------- | ------------------------------------------------------------ |
| build   | 构建或重建服务依赖的镜像                                     |
| images  | 列出容器使用的镜像                                           |
| events  | 监控服务下容器的事件                                         |
| logs    | 显示容器的输出内容 相当于 `docker logs`                      |
| port    | 打印绑定的开放端口                                           |
| ps      | 显示当前项目下的容器，加-p参数指定项目名 相当于 `docker ps`  |
| help    | 命令帮助                                                     |
| pull    | 拉取服务用到的镜像 相当于 `docker pull`                      |
| up      | 项目下创建服务并启动容器，如果指定了项目名，其他操作也要带上项目名参数。容器名格式：`[项目名]\_[服务名]\_[序号]` |
| down    | 移除 `up` 命令创建的容器、网络、挂载点、镜像 ,停止并删除     |
| pause   | 暂停服务下所的容器                                           |
| unpause | 恢复服务下所有暂停的容器                                     |
| rm      | 删除服务下停止的容器                                         |
| exec    | 在服务下启动的容器中运行命令 相当于 `docker exec`            |
| run     | 服务下创建并运行容器 相当于 `docker run` ,与 `up` 命令的区别在于端口要另外映射，且不受start/stop/restart/kill等命令影响，容器名格式：`[项目名]\_[服务名]\_run\_[序号]` |
| scale   | 设置服务的容器数目,多增少删                                  |
| start   | 开启服务(up命令创建的所有容器) 相当于 `docker start`         |
| stop    | 停止服务(up命令创建的所有容器) 相当于 `docker stop`          |
| restart | 重启服务(up命令创建的所有容器) 相当于 `docker restart`       |
| kill    | 像服务发送信号(up命令创建的所有容器) 相当于 `docker kill`    |


