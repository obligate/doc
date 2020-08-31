## 实战
### 1. helloworld
```
docker ps                      # 查看本地正在运行的container
docker images                  # 查看本地的image
docker run hello-world         # 运行hello-world,运行就结束
docker ps -a                   # 查看运行中和运行结束的容器，发现此时hello-world容器对应的状态是exited
```

### 2. redis
```
docker run -d redis:3.2 redis-server                # 后台运行redis:3.2 版本的redis，并执行命令redis-server
docker ps 
docker exec -it containerId  redis-cli              # 通过containerid进入后台运行的容器，并执行redis-cli命令
docker exec -it containerId  sh                     # 通过containerid进入后台运行的容器，并执行sh命令
```

### 3. nginx
```
docker run -d -p 80:80 nginx                       # 后台运行一个nginx，没有指定版本，默认是latest，-p [宿主机端口]:[容器端口]
curl http://192.168.195.132                        # 访问容器宿主机ip
```
