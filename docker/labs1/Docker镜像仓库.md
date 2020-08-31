## 镜像仓库
> 总体来看Docker 仓库可以分为两大类：
> + 公共仓库：最经典的公共仓库就是Docker Hub（https://hub.docker.com）。当Docker装好后，其默认的镜像源头就是这个功能仓库。当运行Docker run或者Docker pull等命令时系统会自动从Docker Hub下载现有镜像> 到本地。除了Docker Hub之外还有一些第三方的公共仓库，对外提供服务，比如Quay、阿里云等。
> + 私有仓库：私有仓库是互联网企业的生产中心的实际操作中的主流选择。不采用公共仓库通常出于以下两个原因：
>    + 公共仓库通常建于海外，下载速度受限，对于大量节点频繁更新的互联网应用场景不太友好。
>    + 公共仓库位于外网，直接将生产中心的应用和外网相连，存在明显安全隐患。黑客等容易通过网络漏洞渗透到企业内网；并且公共仓库内的容器镜像未通过企业内部的静态文件扫描，无法保证镜像中所采用的运行时和依赖库> 的安全性。


### 搭建私有仓库
搭建私有仓库最简单的方法是在容器管理节点（物理机或者虚拟机）上搭建registry容器，并将其作为企业内部的私有仓库，存放所有需要部署的容器镜像。
```
# 192.168.95.133 registry
docker run -it -d -p 5000:5000 -v /root/registry:/var/lib/registry --restart=always --name registry registry:latest
docker ps
```
> 在容器启动时通过-d定义为daemon后台运行；通过-it表明可以用户交互；通过-p 5000:5000指定将容器的应用端口5000映射为主机TCP端口5000，对外提供访问；通过-v /root/registry:/var/lib/registry指定了主机> 中的/root/registry目录mount到容器的/var/lib/registry目录，用于容器镜像的持久化保存；通过--restart=always确保容器故障时可以自动重启；通过-name registry指定容器的名称；通过registry:latest完成> 从公有仓库的最新registry镜像的下载。

```
# registry需要修配置
vi /lib/systemd/system/docker.service
# 原文
...
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
...
# 将其修改为
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --insecure-registry 192.168.95.133:5000
```


### 上传镜像
```
# 上面registry修改了配置，需要执行命令
systemctl daemon-reload
systemctl restart docker
# 现在整个仓库里空空如也，我们尝试从另一台机器192.168.95.132上传镜像到registry仓库里
docker pull hello-world
docker images 
# 然后重新给这个镜像打标签。这一步是每次镜像上传之前的必须操作。本环境中（192.168.95.133）为registry仓库所在
docker tag hello-world 192.168.95.133:5000/newhello
docker images
# 可以看到新的镜像的换成了192.168.95.133:5000/newhello，暗含这个容器对应192.168.95.133仓库的5000端口的newhello镜像。但是当前还只是存在192.168.95.132主机的本地。
# 下一步，指定该镜像的完整新名称，正式进行上传操作
docker push 192.168.95.133:5000/newhello
# 发起http请求去产看一下仓库主机的实际镜像存储情况
curl -X GET http://192.168.95.133:5000/v2/_catalog 
```
> 可以看到Registry仓库里已经存有最新上传的镜像newhello了。
> 注：为了实现对于仓库的http连接，对于不同的Docker daemon的部署情况下，修改的Dockerd配置文件略有不同，可能是/etc/sysconfig/docker或/etc/init/docker或/etc/dafault/docker等配置文件的OPTIONS字段> 等。

### 下载镜像
> 从私有仓库下载镜像。这也是容器部署过程中，最反复发生的操作。当各个应用新版本制作完成后，将打包成新的镜像传输到生产的Registry中。生产的各个主机节点将并发地从Registry仓库下载容器。还是以192.168.95.> 132节 点为例，首先删除主机中现有的镜像缓存

```
docker images
docker rmi 192.168.95.133:5000/newhello hello-world
docker pull 192.168.95.133:5000/newhello
docker images 
```
> 可以看到，镜像已经成功下载，我们可以以这个镜像的完整名称 192.168.95.133:5000/newhello用docker run命令启动容器，也可以用docker tag命令尝试简化镜像名称后，再启动容器。