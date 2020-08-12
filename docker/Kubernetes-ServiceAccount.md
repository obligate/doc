## serviceaccount
### 概念
Service account是为了方便Pod里面的进程调用Kubernetes API或其他外部服务而设计的。它与User account不同
　　1.User account是为人设计的，而service account则是为Pod中的进程调用Kubernetes API而设计；
　　2.User account是跨namespace的，而service account则是仅局限它所在的namespace；
　　3.每个namespace都会自动创建一个default service account
　　4.Token controller检测service account的创建，并为它们创建secret
　　5.开启ServiceAccount Admission Controller后
       1.每个Pod在创建后都会自动设置spec.serviceAccount为default（除非指定了其他ServiceAccout）
　　　　2.验证Pod引用的service account已经存在，否则拒绝创建
　　　　3.如果Pod没有指定ImagePullSecrets，则把service account的ImagePullSecrets加到Pod中
　　　　4.每个container启动后都会挂载该service account的token和ca.crt到/var/run/secrets/kubernetes.io/serviceaccount/
### 验证
```
[root@node01 ~]# kubectl create ns validsa             # 创建一个名称空间
namespace/validsa created
[root@node01 ~]# kubectl get sa -n validsa             # 名称空间创建完成后会自动创建一个sa
NAME      SECRETS   AGE
default   1         67s
[root@node01 ~]# kubectl get secret -n validsa         #  同时也会自动创建一个secret
NAME                  TYPE                                  DATA   AGE
default-token-rvxp4   kubernetes.io/service-account-token   3      94s
```
### 在创建的名称空间中新建一个pod
```
[root@node01 sa-example]# cat pod_demo.yaml 
kind: Pod
apiVersion: v1
metadata:
  name: task-pv-pod
  namespace: validsa
spec:
  containers:
  - name: nginx
    image: ikubernetes/myapp:v1
    ports:
     - containerPort: 80
       name: www
```
```
[root@node01 sa-example]# kubectl apply -f pod_demo.yaml 
pod/task-pv-pod created
```
### 查看pod信息
```
[root@node01 sa-example]# kubectl get pod task-pv-pod  -n validsa
NAME          READY   STATUS              RESTARTS   AGE
task-pv-pod   0/1     ContainerCreating   0          45s
[root@node01 sa-example]# kubectl get pod task-pv-pod -o yaml  -n validsa 
......
volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: default-token-rvxp4
      readOnly: true
......
volumes:     # 挂载sa的secret
  - name: default-token-rvxp4
    secret:
      defaultMode: 420
      secretName: default-token-rvxp4
......
```
> 命名空间新建的pod如果不指定sa，会自动挂载当前名称空间中默认的sa(default)


## 创建serviceaccount(以下简称sa)
### 创建
```
[root@node01 sa-example]# kubectl create sa admin          # 会在default命名空间下，创建一个sa 名称为admin
serviceaccount/admin created
[root@node01 sa-example]# kubectl get sa
NAME      SECRETS   AGE
admin     1         58s
default   1         12d
[root@node01 sa-example]# kubectl describe sa admin         # 查看名称为admin的sa的信息，系统会自动创建一个token信息
Name:                admin
Namespace:           default
Labels:              <none>
Annotations:         <none>
Image pull secrets:  <none>
Mountable secrets:   admin-token-b6chp
Tokens:              admin-token-b6chp
Events:              <none> 
[root@node01 sa-example]# kubectl get secret                  # 会自动创建一个secret(admin-token-b6chp),用于当前sa连接至当前API server时使用的认证信息
NAME                  TYPE                                  DATA   AGE
admin-token-b6chp     kubernetes.io/service-account-token   3      3m21s
default-token-vh44b   kubernetes.io/service-account-token   3      12d
```
### 创建一个pod应用刚刚创建的sa
```
[root@node01 sa-example]# cat deploy-demon.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: sa-demo
  labels:
    app: myapp
    release: canary
spec:
  containers:
  - name: myapp
    image: ikubernetes/myapp:v2
    ports:
    - name: httpd
      containerPort: 80
  serviceAccountName: admin  #此处指令为指定sa的名称
[root@node01 sa-example]# kubectl apply -f deploy-demon.yaml 
pod/sa-demo created
[root@node01 sa-example]# kubectl describe pod sa-demo 
......
Mounts:
    /var/run/secrets/kubernetes.io/serviceaccount from admin-token-b6chp (ro)         #pod会自动挂载自己sa的证书
......
 Volumes:
  admin-token-b6chp:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  admin-token-b6chp
    Optional:    false
......
```
> 集群交互的时候少不了的是身份认证，使用 kubeconfig（即证书） 和 token 两种认证方式是最简单也最通用的认证方式，下面我使用kubeconfing来进行认证
> 使用kubeconfig文件来组织关于集群，用户，名称空间和身份验证机制的信息。使用 kubectl命令行工具对kubeconfig文件来查找选择群集并与群集的API服务器进行通信所需的信息。
> 默认情况下 kubectl使用的配置文件名称是在$HOME/.kube目录下 config文件，可以通过设置环境变量KUBECONFIG或者--kubeconfig指定其他的配置文件



## kubeconfig
###  查看kubeconfig命令行配置帮助
``` 
[root@node01 sa-example]#kubectl config --help
Modify kubeconfig files using subcommands like "kubectl config set current-context my-context" 

The loading order follows these rules: 

  1. If the --kubeconfig flag is set, then only that file is loaded.  The flag may only be set once
and no merging takes place.  
  2. If $KUBECONFIG environment variable is set, then it is used a list of paths (normal path
delimitting rules for your system).  These paths are merged.  When a value is modified, it is
modified in the file that defines the stanza.  When a value is created, it is created in the first
file that exists.  If no files in the chain exist, then it creates the last file in the list.  
  3. Otherwise, ${HOME}/.kube/config is used and no merging takes place.

Available Commands:
  current-context 显示 current_context
  delete-cluster  删除 kubeconfig 文件中指定的集群
  delete-context  删除 kubeconfig 文件中指定的 context
  get-clusters    显示 kubeconfig 文件中定义的集群
  get-contexts    描述一个或多个 contexts
  rename-context  Renames a context from the kubeconfig file.
  set             设置 kubeconfig 文件中的一个单个值
  set-cluster     设置 kubeconfig 文件中的一个集群条目
  set-context     设置 kubeconfig 文件中的一个 context 条目
  set-credentials 设置 kubeconfig 文件中的一个用户条目
  unset           取消设置 kubeconfig 文件中的一个单个值
  use-context     设置 kubeconfig 文件中的当前上下文
  view            显示合并的 kubeconfig 配置或一个指定的 kubeconfig 文件

Usage:
  kubectl config SUBCOMMAND [options]

Use "kubectl <command> --help" for more information about a given command.
Use "kubectl options" for a list of global command-line options (applies to all commands).
```
### 查看系统的kubeconfig
```
[root@node01 sa-example]# kubectl config view
apiVersion: v1
clusters:                                                 # 集群列表
- cluster:
    certificate-authority-data: DATA+OMITTED               # 认证集群的方式
    server: https://192.168.195.133/k8s/clusters/c-j5wh4   # 访问服务的APIserver的路径
  name: rk8s2020                                           #  集群的名称
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://192.168.195.134:6443
  name: rk8s2020-rancher-master01
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://192.168.195.135:6443
  name: rk8s2020-rancher-master02
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://192.168.195.136:6443
  name: rk8s2020-rancher-master03
contexts:                                                 #  上下文列表
- context:
    cluster: rk8s2020                                     #  访问rk8s2020这个集群
    user: rk8s2020                                        #  使用rk8s2020账号
  name: rk8s2020                                          #  给定一个名称
- context:
    cluster: rk8s2020-rancher-master01
    user: rk8s2020
  name: rk8s2020-rancher-master01
- context:
    cluster: rk8s2020-rancher-master02
    user: rk8s2020
  name: rk8s2020-rancher-master02
- context:
    cluster: rk8s2020-rancher-master03
    user: rk8s2020
  name: rk8s2020-rancher-master03
current-context: rk8s2020                                  # 当前上下文
kind: Config
preferences: {}
users:                                                     # 用户列表
- name: rk8s2020                                           # 用户名称
  user:
    token: kubeconfig-user-jltmp.c-j5wh4:b5scr22b7c55djv6skxg98m5zpb2n6pcrwc4xmzmf2svwxwrg2kw88
```
```
[root@node01 sa-example]# kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.43.0.1    <none>        443/TCP   12d
[root@node01 sa-example]# kubectl describe svc kubernetes
Name:              kubernetes
Namespace:         default
Labels:            component=apiserver
                   provider=kubernetes
Annotations:       <none>
Selector:          <none>
Type:              ClusterIP
IP:                10.43.0.1
Port:              https  443/TCP
TargetPort:        6443/TCP
Endpoints:         192.168.195.134:6443,192.168.195.135:6443,192.168.195.136:6443   #可以看到此处svc后端的Endpoint是当前节点的IP地址，通过svc的IP地址进行映射，以确保cluster中的pod可以通过该sa与集群内api进行通讯，仅仅是身份认证
Session Affinity:  None
Events:            <none>
```
### 创建一个cluster用户及context
#### 使用当前系统的ca证书认证一个私有证书
> 如果当前系统的ca证书没有，需要自己生成ca.crt ca.key
```
[root@node01 sa-example]# cd /etc/kubernetes/pki/
[root@node01 pki]# (umask 077;openssl genrsa -out jasper.key 2048)
Generating RSA private key, 2048 bit long modulus
..+++
...+++
e is 65537 (0x10001)
[root@node01 pki]# openssl req -new -key jasper.key -out jasper.csr -subj "/CN=jasper"     # jasper是后面我们创建的用户名称，需要保持一致
[root@node01 pki]# openssl x509 -req -in jasper.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out jasper.crt -days 3650
Signature ok
subject=/CN=jasper
Getting CA Private Key
```
#### 查看证书内容
```
[root@node01 pki]# openssl x509 -in jasper.crt -text -noout
Certificate:
    Data:
        Version: 1 (0x0)
        Serial Number:
            9a:df:5f:17:1a:37:e4:d8
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN=kubernetes                                    #由谁签署的
        Validity                                                 #证书的有效时间
            Not Before: Aug 12 04:52:23 2020 GMT
            Not After : Aug 10 04:52:23 2030 GMT
        Subject: CN=jasper                                       #证书使用的用户
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                ......
```
#### 创建一个当前集群用户
```
#--embed-certs表示是否隐藏证书路径及名称,默认不隐藏
[root@node01 pki]#  kubectl config set-credentials jasper --client-certificate=./jasper.crt --client-key=./jasper.key --embed-certs=true     
User "jasper" set.
[root@node01 pki]# kubectl config view 
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://192.168.195.133/k8s/clusters/c-j5wh4
  name: rk8s2020
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://192.168.195.134:6443
  name: rk8s2020-rancher-master01
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://192.168.195.135:6443
  name: rk8s2020-rancher-master02
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://192.168.195.136:6443
  name: rk8s2020-rancher-master03
contexts:
- context:
    cluster: rk8s2020
    user: rk8s2020
  name: rk8s2020
- context:
    cluster: rk8s2020-rancher-master01
    user: rk8s2020
  name: rk8s2020-rancher-master01
- context:
    cluster: rk8s2020-rancher-master02
    user: rk8s2020
  name: rk8s2020-rancher-master02
- context:
    cluster: rk8s2020-rancher-master03
    user: rk8s2020
  name: rk8s2020-rancher-master03
current-context: rk8s2020
kind: Config
preferences: {}
users:
- name: jasper                                         # 我们新建的用户
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
- name: rk8s2020
  user:
    token: kubeconfig-user-jltmp.c-j5wh4:b5scr22b7c55djv6skxg98m5zpb2n6pcrwc4xmzmf2svwxwrg2kw88
```
#### 为jasper用户创建一个context
```
[root@node01 pki]# kubectl config set-context  jasper@rk8s2020 --cluster=rk8s2020 --user=jasper 
Context "jasper@rk8s2020" created.
[root@node01 pki]# kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://192.168.195.133/k8s/clusters/c-j5wh4
  name: rk8s2020
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://192.168.195.134:6443
  name: rk8s2020-rancher-master01
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://192.168.195.135:6443
  name: rk8s2020-rancher-master02
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://192.168.195.136:6443
  name: rk8s2020-rancher-master03
contexts:
- context:                                                            #新创建的context
    cluster: rk8s2020
    user: jasper
  name: jasper@rk8s2020
- context:
    cluster: rk8s2020
    user: rk8s2020
  name: rk8s2020
- context:
    cluster: rk8s2020-rancher-master01
    user: rk8s2020
  name: rk8s2020-rancher-master01
- context:
    cluster: rk8s2020-rancher-master02
    user: rk8s2020
  name: rk8s2020-rancher-master02
- context:
    cluster: rk8s2020-rancher-master03
    user: rk8s2020
  name: rk8s2020-rancher-master03
current-context: rk8s2020
kind: Config
preferences: {}
users:
- name: jasper
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
- name: rk8s2020
  user:
    token: kubeconfig-user-jltmp.c-j5wh4:b5scr22b7c55djv6skxg98m5zpb2n6pcrwc4xmzmf2svwxwrg2kw88
```
#### 切换serviceaccount
```
[root@node01 pki]# kubectl config use-context  jasper@rk8s2020
Switched to context "jasper@rk8s2020".
[root@node01 pki]# kubectl get pod
Error from server (Forbidden): pods is forbidden: User "jasper" cannot list pods in the namespace "default"
```
#### 自定义一个cluster
```
[root@node01 pki]# kubectl config set-cluster  mycluster --kubeconfig=/tmp/test.conf --server="https://192.168.195.134:6443" --certificate-authority=/etc/kubernetes/pki/ca.crt --embed-certs=true
Cluster "mycluster" set.
[root@node01 pki]# kubectl config view --kubeconfig=/tmp/test.conf 
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://192.168.195.134:6443
  name: mycluster
contexts: null
current-context: ""
kind: Config
preferences: {}
users: null
```

## Refer
[RBAC](https://www.cnblogs.com/panwenbin-logs/p/10046572.html)