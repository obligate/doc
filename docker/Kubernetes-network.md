## 切换网络协议栈  
```
# master、node1、node2执行
kubeadm reset
# master执行
kubeadm init --apiserver-advertise-address=172.31.5.246 --pod-network-cidr=10.244.0.0/16
# master执行
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
> 参考: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
```
# master执行
kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/canal.yaml
# node1，node2执行
kubeadm join 172.31.5.246:6443 --token lohqsx.plp3hrjvanx2q1db \
    --discovery-token-ca-cert-hash sha256:abf77ba7bf76a98ecf9b5c739848edf2cd4059a94cc4ead4647666077ff96872
# 查看网络是否启动
kubectl get daemonset -n kube-system -o wide
kubectl get pods -n kube-system -o wide|grep canal
```

## Kubernetes网络配置和测试
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
> `kubectl apply -f mynginx-deployment.yaml`
```
[root@master ~]# cat service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
spec:
  type: NodePort
  selector:
    app: web_server
  ports:
  - protocol: TCP
    nodePort: 30000  # 外部访问的端口，节点的节点，可以用任意节点的ip：30000端口就可以通过浏览器访问
    port: 8080       # service对外提供访问的port
    targetPort: 80   # 容器的port
```
> 操作
```
[root@master mnt]# kubectl apply -f service.yaml
[root@master mnt]# kubectl get service -o wide
[root@master mnt]# kubectl get service      
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP          53m
nginx-svc    NodePort    10.103.17.169   <none>        8080:31278/TCP   5m2s
[root@master mnt]# curl clusterip:port
[root@master mnt]# curl 10.103.17.169:8080
# 启动一个pod，pod间的服务发现的方式：服务名.namespace名:端口
[root@master mnt]# kubectl run busybox --rm -it --image=busybox -- /bin/sh
/# wget 10.103.17.169:8080
/# wget nginx-svc.default:8080
```
> `policy.yml`
```
[root@master ~]# cat policy.yml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: access-nginx
spec:
  podSelector:
    matchLabels:
      app: web_server
  ingress:
  - from:
    - podSelector:             # 只允许label=access: "true" pod访问才生效
        matchLabels:
          access: "true"
    ports:                     # 访问podSelector.matchLabels.app=web_server中的pod的80端口
    - protocol: TCP
      port: 80
```
```
kubectl apply -f policy.yml
# 启动一个pod
kubectl run busybox --rm -it --image=busybox -- /bin/sh
/# wget 10.103.17.169:8080      # 发现不能访问
kubectl run busybox --rm -it --labels="access=true" --image=busybox -- /bin/sh
/# wget 10.103.17.169:8080      # 可以访问，busybox因为添加了label="access=true"，可以改pod可以访问service
/# wget nginx-svc.default:8080
[root@master mnt]# curl 10.103.17.169:8080    # 访问失败，因为没有设置ipBlock
```
> 添加ipBlock
```
[root@master ~]# cat policy.yml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: access-nginx
spec:
  podSelector:
    matchLabels:
      app: web_server
  ingress:
  - from:
    - podSelector:             # 只允许label=access: "true" pod访问才生效
        matchLabels:
          access: "true"
    - ipBlock:                 # 添加部分允许10.244.0.0/16可以访问service
        cidr: 10.244.0.0/16
    ports:                     # 访问podSelector.matchLabels.app=web_server中的pod的80端口
    - protocol: TCP
      port: 80
```

```
kubectl apply -f policy.yml
# 启动一个pod
kubectl run busybox --rm -it --image=busybox -- /bin/sh
/# wget 10.103.17.169:8080     # 可以访问，因为ipBlock
kubectl run busybox --rm -it --labels="access=true" --image=busybox -- /bin/sh
/# wget 10.103.17.169:8080      # 可以访问，busybox因为添加了label="access=true"，可以改pod可以访问service
/# wget nginx-svc.default:8080
[root@master mnt]# curl 10.103.17.169:8080    # 可以访问，设置了ipBlock的cidr的地址段，如果不设置，则访问失败
```