## 镜像发布
### 1. `docker image push ` 发布，不推荐，可能产生不信任，例如包含病毒
#### 配置环境
+ 1.生成`/etc/docker/daemon.json`
```
touch daemon.json
内容
{
 "registry-mirrors": [
    "https://registry.docker-cn.com"
  ],
 "selinux-enabled": false,
 "insecure-registries":[
    "192.168.7.234:5000"
  ]
}
cp daemon.json /etc/docker/daemon.json
```
+ 2.`vim /lib/systemd/system/docker.service`
```
文件中在ExecReload=/bin/kill -s HUP $MAINPID 之前需要添加一行
EnvironmentFile=-/etc/docker/daemon.json
```
+ 3.重启服务
```
sudo systemctl daemon-reload
sudo systemctl restart docker
```
#### 注册用户
+ 需要在[docker hub](https://hub.docker.com)注册一个用户 或者[网易云](https://c.163yun.com/hub)
+ `docker login`
+ `docker push`
+ docker hub的push
```
docker login 要求输入用户和密码，成功之后会保存到~/.docker/config.json 文件中
docker image push  peterhly/hello-world:latest  
docker push peterhly/hello-world:latest  
docker image rm  peterhly/hello-world   #删除本地的image
docker pull peterhly/hello-world        #如果本地没有，从hub拉取
```
+ 网易云的push
```
docker login -u {你的网易云邮箱账号或手机号码} -p {你的网易云密码} hub.c.163.com   ## 登录网易云镜像仓库
docker tag {镜像名或ID} hub.c.163.com/{你的用户名}/{标签名}                      ## 标记本地镜像
你的网易云镜像仓库推送地址为 hub.c.163.com/{你的用户名}/{标签名}
Attention: 此处为你的用户名，不是你的邮箱帐号或者手机号码 登录网易云控制台，页面右上角头像右侧即为「用户名」
docker push hub.c.163.com/{你的用户名}/{标签名}                                 ## 推送至网易云镜像仓库
默认为私有镜像仓库，推送成功后即可在控制台的「镜像仓库」查看
Attention
如果你的镜像仓库数量达到配额限制（默认为 10 个），则无法推送本地镜像到镜像仓库，推送时将出现错误提示：「request failed with status: 403 Forbidden」。
镜像过大，当 PUSH 时间超过 15 分钟会导致认证失败，提示 [unauthorized: authentication required`]
```
```
docker pull centos
docker run -it centos 进入安装 yum -y install vim ，退出
docker ps -a      找到centos的容器实例c0ae5840d44f
docker commit c0ae5840d44f hub.c.163.com/peterhly/centos-vim
docker push hub.c.163.com/peterhly/centos-vim
```
### 2.  通过在github发布dockerfile
+ [参考](https://github.com/docker-library)
### 3.  搭建私有的docker registry
```
docker pull registry      
docker run -d -p 5000:5000 --restart always --name registry registry:2 
docker build -t 192.168.7.234:5000/helloworld .   其中192.168.7.234是我们自己的docker registry服务器
docker push 192.168.7.234:5000/helloworld   push会报错
验证是否push 成功，因为私有的docker register 没有界面， 需要使用 docker register api 
api文档：https://docs.docker.com/registry/spec/api/
http://192.168.7.234:5000/v2/_catalog   测试镜像仓库中所有的镜像
curl http://192.168.7.234:5000/v2/_catalog   ##测试镜像仓库中所有的镜像
docker pull 192.168.7.234:5000/helloworld
```
```
docker pull hub.c.163.com/peterhly/centos-vim:latest
docker tag hub.c.163.com/peterhly/centos-vim  192.168.7.234:5000/centos-vim    # 重新打一个tag，指向自己的registry
docker push 192.168.7.234:5000/centos-vim
curl http://192.168.7.234:5000/v2/_catalog 
```
## Refer
+ [gravatar](https://en.gravatar.com)
```
https://hub.docker.com/u/<namespace>/dashboard/settings/   修改头像，使用https://en.gravatar.com/的email
```
+ [registry Api](https://docs.docker.com/registry/spec/api/#catalog)