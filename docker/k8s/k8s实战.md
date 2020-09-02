> 实验环境k8s版本： v1.19.0
### 创建pod
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
### depolyment
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
```
### nodeSelector来选择指定的node
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
> 修改后的文件
```
apiVersion: v1
kind: Pod
metadata:
  name: mynginx
spec:
  containers:
  - name: nginx
    image: nginx:1.7.9
  nodeSelector:
    disktype: ssd
```
>3.再执行命令：  
```
kubectl delete pod mynginx
kubectl apply -f mynginx-pod-selector.yaml
kubectl get pod -o wide
```
