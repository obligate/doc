

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


### 3. 卸载
```
docker container stop $(docker container ls -a -q) && docker system prune --all --force --volumes
docker volume rm $(docker volume ls -q)
docker image rm $(docker image ls -q)
rm -rf /etc/ceph \
       /etc/cni \
       /etc/kubernetes \
       /opt/cni \
       /opt/rke \
       /run/secrets/kubernetes.io \
       /run/calico \
       /run/flannel \
       /var/lib/calico \
       /var/lib/etcd \
       /var/lib/cni \
       /var/lib/kubelet \
       /var/lib/rancher/rke/log \
       /var/log/containers \
       /var/log/pods \
       /var/run/calico

```

### 4. ceph
```
https://www.cnblogs.com/huchong/p/12435957.html
https://developer.aliyun.com/article/604372
```
+ 配置yum源(三台机器都需要)
```
wget -qO /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
wget -qO /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

[root@node1 ~]# cat /etc/yum.repos.d/ceph.repo
[Ceph]
name=Ceph packages for $basearch
baseurl=https://mirrors.aliyun.com/ceph/rpm-nautilus/el7/$basearch
enabled=1
gpgcheck=0
type=rpm-md
gpgkey=https://mirrors.aliyun.com/ceph/keys/release.asc
priority=1

[Ceph-noarch]
name=Ceph noarch packages
baseurl=https://mirrors.aliyun.com/ceph/rpm-nautilus/el7/noarch
enabled=1
gpgcheck=0
type=rpm-md
gpgkey=https://mirrors.aliyun.com/ceph/keys/release.asc
priority=1

[ceph-source]
name=Ceph source packages
baseurl=https://mirrors.aliyun.com/ceph/rpm-nautilus/el7/SRPMS
enabled=1
gpgcheck=0
type=rpm-md
gpgkey=https://mirrors.aliyun.com/ceph/keys/release.asc
priority=1
```
```
yum clean all
ceph-deploy purge   node01 node02 node03
ceph-deploy purgedata   node01 node02 node03    # 清空
ceph-deploy forgetkeys
mkdir my-cluster
cd my-cluster
ceph-deploy new  node02 node03
ceph-deploy install --no-adjust-repos  node01 node02 node03
ceph-deploy --overwrite-conf mon create node01 node02 node03
ceph-deploy admin node01 node02 node03

ceph-deploy --overwrite-conf config push node01 node02 node03
timedatectl list-timezones 或者 tzselect
timedatectl set-timezone "Asia/Shanghai"
```
+ 部署ceph-mgr(在node1)

```
ceph-deploy mgr create node01 
```
+ 创建osd(在node1)

```
ceph-deploy osd create --data /dev/sdb1 node01      # /dev/sdb1不要mount
ceph-deploy osd create --data /dev/sdb1 node02
ceph-deploy osd create --data /dev/sdb1 node03
```
+ 检查osd
```
sudo ceph health
sudo ceph -s
sudo ceph osd tree
```
+ 开启MGR监控模块(root用户)
  ```
  ceph mgr module enable dashboard   
  ceph dashboard create-self-signed-cert             # 要快速启动并运行仪表板，可以使用以下内置命令生成并安装自签名证书
  ceph dashboard set-login-credentials admin admin   # 创建具有管理员角色的用户:
  ceph mgr services                                  # 查看ceph-mgr服务 https://node1:8443/   https://192.168.195.134:8443/
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