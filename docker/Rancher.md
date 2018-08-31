

## Rancher
更方便的进行docker的部署和管理
### 1.[Rancher Server install](https://rancher.com/quick-start/)
+ 1.centos7.3以上，先安装docker
+ 2.安装`sudo docker run -d --restart=unless-stopped -p 8080:8080   rancher/server:stable`
+ `docker stop <container_name_of_original_server>`

### 2.配置agent和agent的安装
通过浏览器访问 http://192.168.0.11:8080
+ 添加主机，如果失败可以把`vim /etc/sysconfig/selinux `关闭
+ 讲命令在配置的agent执行，例如
```
sudo docker run -e CATTLE_AGENT_IP="192.168.7.234"  --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher rancher/agent:v1.2.11 http://192.168.0.11:8080/v1/scripts/86B03898C1DD98F3D2A5:1514678400000:VBXzclg9mDZtjg9Lm3B0M6xnD2k
```

## 镜像加速
vim /etc/docker/daemon.json
```
{
  "registry-mirrors": ["https://fy707np5.mirror.aliyuncs.com"]
}
```
```
systemctl daemon-reload
systemctl restart docker
```
## Refer
+ [Rancher官网](https://rancher.com/)
+ [Rancher CN](https://www.cnrancher.com/)