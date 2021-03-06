## Minikube快速搭建K8S单节点环境
### requirement
- kubectl
- macOS
    + Hyperkit driver, xhyve driver, VirtualBox, or VMware Fusion
- Linux
	+ VirtualBox or KVM
	+ NOTE: Minikube also supports a –vm-driver=none option that runs the Kubernetes components on the host and not in a VM. Docker is required to use this driver but no hypervisor.
- Windows
	- VirtualBox or Hyper-V
- VT-x/AMD-v virtualization must be enabled in BIOS
- Internet connection on first run
### 1.centos 安装
#### 安装kubectl
```
# wget https://storage.googleapis.com/kubernetes-release/release/v1.9.0/bin/linux/amd64/kubectl
# curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
# install kubectl /usr/local/bin/
# kubectl cluster-info
```
#### 设置shell命令补全
```
# yum install -y bash-completion
# source /usr/share/bash-completion/bash_completion
# echo "source <(kubectl completion bash)" >> ~/.bashrc
# kubectl
```
#### 安装Hypervisor(KVM) 或者install virtualbox
```
# yum install qemu-kvm libvirt libvirt-python libguestfs-tools virt-install
# systemctl enable libvirtd && systemctl start libvirtd
# wget https://github.com/dhiltgen/docker-machine-kvm/releases/download/v0.10.0/docker-machine-driver-kvm-centos7
# install docker-machine-driver-kvm-centos7 /usr/local/bin/docker-machine-driver-kvm
# usermod -a -G libvirt $(whoami)
# newgrp libvirt
```
#### 安装minikube
```
# wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
# install minikube-linux-amd64 /usr/local/bin/minikube
# minikube config set WantReportErrorPrompt false
# minikube start --vm-driver=kvm
# kubectl version
# kubectl cluster-info
# kubectl get all
```
#### 测试
```
kubectl get nodes
kubectl get pods
minikube stop
```
### 2. windows 安装
+ requirement
	+ Download the minikube-windows-amd64.exe file, rename it to minikube.exe and add it to your path
	+ kubectl,下载，添加到环境变量
	+ virtualbox
+ 验证安装
```
minikube version
kubectl version
```


### 3. 从阿里云的镜像地址在centos安装minikube
```
curl -Lo minikube http://kubernetes.oss-cn-hangzhou.aliyuncs.com/minikube/releases/v0.28.1/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
minikube start --registry-mirror=https://registry.docker-cn.com  # 缺省Minikube使用VirtualBox驱动来创建Kubernetes本地环境
minikube dashboard    # 打开Kubernetes控制台
```


## Kops install Kubernetes cluster on Amazon AWS
### 安装kops 和 awscli
```
# install some tools
sudo yum install -y vim telnet bind-utils wget
# install kops
wget https://github.com/kubernetes/kops/releases/download/1.10.0/kops-linux-amd64
mv kops-linux-amd64 kops
sudo mv kops /usr/local/bin/
sudo chmod +x /usr/local/bin/kops
# install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
# install python pip
wget https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py
rm -rf get-pip.py
# install aws cli
sudo pip install awscli
```
### aws 准备和设置
```
1. 先创建一个组,kops-group,使用adminxx
2. 先创建一个用户，kops，使用program访问，使用kops-group,现在access key 和secret key
3. aws configure
4. 配置dns，进入route53，注册一个domain，例如： 360pf.net
5. 域名验证
	1. dig +short 360pf.net ns
	2. dig +short 360pf.net soa
6. 创建hosted zones
	1. 创建subdomain   k8s.360pf.net   type: public hosted zone
	2. 在主域名下面创建子域名的 ns记录，类型ns，值就是subdomain的ns记录
	3. 子域名验证
		1. dig +short k8s.360pf.net ns
		2. dig +short k8s.360pf.net soa
7. 创建s3 bucket
	1. bucket name: kops.k8s.360pf.net

```
### 创建
```
1. 创建一个ssh key: tlz_cluster 
2. 创建一个集群的配置，保存到s3
kops create cluster --name=k8s.360pf.net --ssh-public-key=~/.ssh/tlz_cluster.pub --state=s3://kops.k8s.360pf.net --zones=us-west-1a  --node-count=2 --node-size=t2.medium --master-size=t2.medium --dns-zone=k8s.360pf.net
kops create cluster --name=k8s.360pf.net  --state=s3://kops.k8s.360pf.net --zones=us-west-1a  --node-count=2 --node-size=t2.medium --master-size=t2.medium --dns-zone=k8s.360pf.net
### 如果配置信息有问题，可以先删除，然后创建
kops delete cluster --name=k8s.360pf.net  --state=s3://kops.k8s.360pf.net          -- 确认删除配置信息
kops delete cluster --name=k8s.360pf.net  --state=s3://kops.k8s.360pf.net --yes    -- 删除集群
### 真正的创建虚机
kops update cluster k8s.360pf.net --yes   --state=s3://kops.k8s.360pf.net  
## 验证状态
ssh -i ~/.ssh/id_rsa admin@api.k8s.360pf.net                                  # ssh to the master
kubectl get nodes --show-labels                                               # list nodes
kops validate cluster --state=s3://kops.k8s.360pf.net                         # 验证cluster的状态
```
```
systemctl status etcd kube-apiserver kube-controller-manager kube-scheduler | grep "(running)" | wc -l
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo firewall-cmd --state
sudo systemctl status firewalld
```


### 本地访问
[install](https://kubernetes.io/zh/docs/tasks/tools/install-kubectl/#%e5%9c%a8-windows-%e4%b8%8a%e7%94%a8-chocolatey-%e5%ae%89%e8%a3%85-kubectl)
+ 创建一个config`~/.kube/config`
+ 本地访问
```
kubectl version               # 查看版本
kubectl cluster-info          # 显示集群信息
kubectl get nodes             # 查看集群中有几个node
kubectl run my-nignx --image=nginx --replicas=2 --port=80   # 运行一个镜像
kubectl get pods
kubectl describe pod my-nginx-3333        # 查看服务详情
kubectl delete pod my-nginx-3333          # 删除pod
kubectl get deployments       # 查看已部署
kubectl delete deployment my-nginx                          # 删除部署的my-nginx服务，彻底删除pod
kubectl config view
kubectl config current-context                         							# 显示当前的上下文                     
kubectl config get-contexts
kubectl config use-context  k8s-bj                     							# 切换上下文，当前的上下文切换到k8s-bj
kubectl config set-context --current --namespace test  							# 切换当前上下文的命名空间为test
kubectl config set-context $(kubectl config current-context)  --namespace test  # 切换命名空间，将当前上下文的命名空间切换为test
kubectl config get-contexts --no-headers | grep '*' | grep -Eo '\S+$'                    # 获取当前的namespace
kubectl config get-contexts | sed -n "2p" | awk "{print \$5}";                           # 获取当前的namespace
kubectl get all                                        # 获取所有的
kubectl get deployment tlz-cloud-app  -o yaml          # 查看某个deployment的yaml文件
kubectl exec -it podName  -c  containerName -n namespace -- shell comand
kubectl get pods  --all-namespaces -o=name       # 获取所有namespace下面的pod，输出name，慎用
kubectl get pods -n meshop-dev03
kubectl describe  pod meshop-mysql-57975fddc4-r2q8x  -n meshop-dev03
kubectl exec -it meshop-mysql-57975fddc4-r2q8x  -n meshop-dev03 -- sh     # 通过bash获得 pod 中某个容器的TTY，相当于登录容器
# 需要删除ns和ingress
kubectl get ingress -o custom-columns=namespace:.metadata.namespace,name:.metadata.name  --all-namespaces    # 自定义输出列，获取所有namespace的ingress
kubectl get ingress -n meshop-dev07
kubectl delete ingress meshop-dev07 -n meshop-dev07
kubectl get ns
kubectl delete ns meshop-dev07
## 
kubectl get node --show-labels      # 查看节点 labels
kubectl cp  -n ingress-nginx nginx-ingress-controller-4gpxv:nginx.conf ./nginx.conf    # 从pod拷贝文件到宿主机nginx-ingress-controller-4gpxv:nginx.conf 为pod的当前目录下的nginx
# 创建alias
$  alias kubectl='_kubectl_custom(){ if [[ "$1" == "project" && "$2" != "" ]]; then kubectl config set-context --current --namespace=$2; elif [[ "$1" == "projects" && "$2" == "" ]]; then kubectl get ns; elif [[ "$1" == "project" && "$2" == "" ]]; then kubectl config get-contexts | sed -n "2p" | awk "{print \$5}";  else kubectl $*; fi;}; _kubectl_custom'
$ alias oc='kubectl'
# alias 验证
kubectl project test
kubectl get pod
```


## k8s 环境搭建
### 软件安装
```
master  172.31.5.246
node1   172.31.13.91
node2   172.31.5.102
docker    # 每个节点都需要安装
kubelet   # k8s的核心，不管是master还是node，都需要安装，进行容器的管理
kubeadm   # k8s的集群管理的核心,每个节点都需要安装，node1,node2也需要用这个命令加入集群
kubectl   # kube命令的管理，每个节点需要安装
## 3台机器都需要安装k8s
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/  
# kubernetes.repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
```
> 关闭Selinux  
```
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```
> 安装Kubernetes安装包  
```
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet
systemctl restart kubelet
```
### 创建集群
```
# master执行
kubeadm init --apiserver-advertise-address=172.31.5.246 --pod-network-cidr=10.244.0.0/16

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:
# master执行
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at: 
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

# master执行
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

Then you can join any number of worker nodes by running the following on each as root:


# node1，node2执行
kubeadm join 172.31.5.246:6443 --token 80ag2v.bypypfsg39vltspg \
    --discovery-token-ca-cert-hash sha256:e2eccf68f5467011a9b45a552e813b5ce4df1ad00161b435386add78aa0fb4fa 



```

#### error
```
[root@master mnt]# kubeadm init --apiserver-advertise-address=172.31.5.246 --pod-network-cidr=10.244.0.0/16
W0830 03:15:49.745333   25160 configset.go:348] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
[init] Using Kubernetes version: v1.19.0
[preflight] Running pre-flight checks
        [WARNING Service-Docker]: docker service is not enabled, please run 'systemctl enable docker.service'
        [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
        [WARNING Hostname]: hostname "master" could not be reached
        [WARNING Hostname]: hostname "master": lookup master on 172.31.0.2:53: no such host
error execution phase preflight: [preflight] Some fatal errors occurred:
        [ERROR FileContent--proc-sys-net-bridge-bridge-nf-call-iptables]: /proc/sys/net/bridge/bridge-nf-call-iptables contents are not set to 1
[preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
To see the stack trace of this error execute with --v=5 or higher
```
> 解决方法 `echo "1" >/proc/sys/net/bridge/bridge-nf-call-iptables`



### 测试集群
#### pod
```
[root@master ~]# vim mynginx-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: mynginx
spec:
  containers:
  - name: nginx
    image: nginx:1.7.9
```
```
[root@master ~]# kubectl apply -f mynginx-pod.yaml
[root@master ~]# kubectl describe pod mynginx
[root@master ~]# kubectl get pod -o wide
[root@master ~]# kubectl exec mynginx -- ls /              # 非交互式执行命令
[root@master ~]# kubectl exec -it mynginx -- sh            # 交互式进入pod中的容器
[root@master ~]# kubectl exec -it mynginx -- /bin/bash
```
#### depolyment
注：部分小伙伴的Kubernetes版本较新的可以采用apiVersion: apps/v1或者apiVersion: apps/v1beta1来部署Deployment。  
```
[root@master ~]# cat mynginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 5
  selector:
    matchLabels:
      app: web_server
  template:
    metadata:
      labels:
        app: web_server
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
```
```
[root@master ~]# kubectl apply -f mynginx-deployment.yaml
[root@master ~]# kubectl get deployment
[root@master ~]# kubectl describe deployment nginx-deployment
[root@master ~]# kubectl get pods
[root@master ~]# kubectl get pods -o wide
# 通过edit修改动态文件,replicas: 4
[root@master ~]# kubectl edit deployment nginx-deployment
[root@master ~]# kubectl get deployment
[root@master ~]# kubectl describe deployment nginx-deployment
# 通过vi修改静态文件 replicas: 3
[root@master ~]#  vim mynginx-deployment.yaml
[root@master ~]#  kubectl apply -f mynginx-deployment.yaml
# 通过deployment的scale命令实现pod的stop
[root@master ~]#  kubectl scale  --replicas=0 deployment/nginx-deployment
# deployment -> replicaset -> pod
# 通过describe命令查看他们之间的关系
[root@master ~]#  kubectl get deployment
[root@master ~]#  kubectl scale  --replicas=5 deployment/nginx-deployment
[root@master ~]#  kubectl get deployment
[root@master ~]#  kubectl get replicaset
```
#### nodeSelector来选择指定的node
> 给指定的node添加label,通过nodeSelector来选择指定的node
> 1.给指定的node添加label
```
[root@master ~]#  kubectl get node --show-labels
[root@master ~]#  Kubectl label node node1 disktype=ssd   # 给node1机器添加label，disktype=ssd
```
> 2.修改mynginx-pod-selector.yaml文件，添加：  
```
      nodeSelector:
        disktype: ssd
```
>3.再执行命令：  
```
kubectl delete pod mynginx
kubectl apply -f mynginx-pod-selector.yaml
kubectl get pod -o wide
```

