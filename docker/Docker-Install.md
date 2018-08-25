## Docker Centos install
```
yum install redhat-lsb-core
lsb_release -a  
```
[官网安装文档](https://docs.docker.com/install/linux/docker-ce/centos/#os-requirements)
```    
sudo yum remove docker  docker-client  docker-client-latest  docker-common  docker-latest docker-latest-logrotate docker-logrotate  docker-selinux  docker-engine-selinux  docker-engine
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager  --add-repo   https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce -y
sudo systemctl start docker
```
### 修改Docker本地镜像与容器的存储位置的方法
[容器存储](https://docs.docker.com/storage/#choose-the-right-type-of-mount)
```
sudo docker info | grep "Docker Root Dir"             # 可以通过该命令查看具体位置,默认情况下Docker的存放位置为：/var/lib/docker
systemctl stop docker
mv /var/lib/docker /mnt/data/docker
ln -s /mnt/data/docker /var/lib/docker
systemctl start docker
```
## Docker compose install
+ mac，windows docker已经默认安装 `docker-compose --version`,linux需要安装
### 官网安装方式
```
sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

### pip install docker compose
```
yum -y install epel-release                                                #需要先安装企业版linux附加包（epel)
yum -y install python-pip                   		                       #安装pip
# pip install --upgrade pip                                                #更新pip
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple  --upgrade pip     #国内原加速
# pip install docker-compose                                               #安装docker-compose 
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple  docker-compose    #国内原加速
docker-compose --version                                                   #查看docker-compose版本信息
```

## Docker windows 安装
### 1.vagrant
+ 安装准备
	+ 确保powershell在3.x版本以上 `$psversiontable`
	+ win7的powershell需要升级
		+ Windows6.1-KB2819745-x64-MultiPkg.msu
		+ dotNetFx45_Full_setup.exe
+ 下载安装[vagrant](https://www.vagrantup.com/downloads.html)
+ VirtualBox
+ 安装一个centos7的环境
```
mkdir vagrant
cd vagrant
mkdir centos7
cd centos7
vagrant init centos/7      #此时会在当前目录生成一个Vagrantfile
vagrant up
vagrant ssh 进入到创建的虚拟机 yum version
vagrant destroy 可以销毁刚才创建的虚机
vagrant plugin list
vagrant plugin install vagrant-scp 
vagrant scp xxx  虚机机名称:/home/vagrant/xxx
```
+ 开始安装，以下命令也可以放到Vagrantfile 中，这样启动的时候就会安装启动docker
```
sudo yum remove docker  docker-client  docker-client-latest  docker-common  docker-latest docker-latest-logrotate docker-logrotate  docker-selinux  docker-engine-selinux  docker-engine
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager  --add-repo   https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce
sudo systemctl start docker
```
+ 测试
```
sudo docker run hello-world
```
### 2.docker-machine
+ 对于win7及以前的系统需要下载[Docker Toolbox](https://docs.docker.com/toolbox/overview/#whats-in-the-box)
> 注意到第2个选项有添加到PATH，如果忘记勾选请安装完成之后手动添加PATH路径。
> 输入docker 输出options，说明安装成功
> 如果发现本地没有boot2docker的镜像文件，它会自动去github上下载，但是非常慢，我们事先把这个地址的镜像下载下来放本地的用户目录的docker目录下`~/.docker/machine/cache/boot2docker.iso`
+ 本地模式
```
docker-machine可以查看当前的所有命令
docker-machine create demo  创建一个带docker的虚拟机
docker-machine ls 
docker-machine ssh demo     进入demo机器
进入demo机器，运行docker version  退出exit
docker-machine start demo
docker-machine stop demo
docker-machine env demo     查看demo的环境变量，执行eval，就可以本地使用
```
+ 远程模式aws
配置credential
```
docker-machine create --driver amazonec2 --amazonec2-open-port 8000 --amazonec2-region us-west-1 aws-demo
docker-machine ls 
docker-machine ssh  aws-demo
```

### 3.docker [playgroud](https://labs.play-with-docker.com/)
+ 在[docker login](https://hub.docker.com/login/)注册一个用户
+ 在[playgroud](https://labs.play-with-docker.com/) 就可以使用docker