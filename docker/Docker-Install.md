## Docker install
[官网安装文档](https://docs.docker.com/install/linux/docker-ce/centos/#os-requirements)
```
sudo yum remove docker  docker-client  docker-client-latest  docker-common  docker-latest docker-latest-logrotate docker-logrotate  docker-selinux  docker-engine-selinux  docker-engine
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager  --add-repo   https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce
sudo systemctl start docker
```

## Docker compose install
### 官网安装方式
```
sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

### pip install docker compose
```
yum -y install epel-release                                              #需要先安装企业版linux附加包（epel)
yum -y install python-pip                   		                     #安装pip
# pip install --upgrade pip                                                #更新pip
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple  --upgrade pip   #国内原加速
# pip install docker-compose                                               #安装docker-compose 
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple  docker-compose  #国内原加速
docker-compose --version                                                 #查看docker-compose版本信息
```