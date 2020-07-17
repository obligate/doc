

## Rancher
### 需要每个节点都安装docker（https://docs.docker.com/engine/install/centos/）
```
sudo yum remove docker docker-client   docker-client-latest    docker-common   docker-latest   docker-latest-logrotate  docker-logrotate  docker-engine
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo  https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io
sudo systemctl start docker     # 启动docker
sudo systemctl enable docker    # 随机启动
sudo docker run hello-world     # 测试
```
### 关闭防火墙及selinux（各rancher节点及nginx服务器）
```
systemctl stop firewalld.service
systemctl disable firewalld.service
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
```
更方便的进行docker的部署和管理
### 1.[Rancher Server install](https://rancher.com/quick-start/)
+ 1.centos7.3以上，先安装docker
+ 2.安装

  ```
    mkdir -p /mnt/docker_volume/rancher
    mkdir -p /mnt/docker_volume/auditlog
    docker run -d --restart=unless-stopped -p 80:80 -p 443:443 -v /mnt/docker_volume/rancher:/var/lib/rancher -v /mnt/docker_volume/auditlog:/var/log/auditlog --name rancher rancher/rancher 
  ```
+ `docker stop <container_name_of_original_server>`

### 2.配置agent和agent的安装
通过浏览器访问 http://192.168.195.133
+ 添加主机，如果失败可以把`vim /etc/sysconfig/selinux `关闭
+ 讲命令在配置的agent执行，例如
```
sudo docker run -d --privileged --restart=unless-stopped --net=host -v /etc/kubernetes:/etc/kubernetes -v /var/run:/var/run rancher/rancher-agent:v2.4.5 --server https://192.168.195.133 --token zfpf5lrdxrffd8l8wvrg9zsqxgd4pbh6mwqlzj6xzz8q9rzr864k9q --ca-checksum c02dbac16c3003c0d5c94c1047a15c879eb3ef32e2ca068c7478165733914b64 --etcd --controlplane --worker
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