## Volume
> 其实volume和Docker的数据卷Data Volume的概念是一脉相承的。
> 就是通过将系统的特定目录以Volume的形式mount到Kubernetes的Pod中。
> 分成5种形式
+ emptyDir
+ hostPath
+ storage provider
+ PersistentVolume -> PersistentVolumeClaim
+ StorageClass   -> PersistentVolumeClaim

> emptyDir就是靶场射击模式的Docker Volumes,完全由系统管理分配资源，将一个系统目录以指定的读写形式mount到容器指定目录。数据将保留到POD消失为止。缺点就是pod消亡，目录也会消亡
> hostPath就是狩猎模式的Docker Bind Mounts，将用户指定的主机系统目录mount到容器内。 数据将始终在物理节点上保留。 缺点是和节点的目录有紧耦合的限制，使用较少。
> storage provider是将公有云或分布式存储(ceph等)上的物理卷映射给容器，具体的配置方式可以参见各云平台文档。因为是脱离于服务器的物理卷，所以数据不会因为Pod和服务器节点的故障而销毁。


### emptyDir
```
[root@master mnt]# vim mynginx-pod-emptydir.yaml
apiVersion: v1
kind: Pod
metadata:
  name: mynginx
spec:
  containers:
  - name: nginx
    image: nginx:1.7.9
    volumeMounts:
      - mountPath: /mymount
        name: mount-volume
  volumes:
  - name: mount-volume
    emptyDir: {}
```
> 操作
```
[root@master mnt]# kubectl delete pod mynginx
[root@master mnt]# kubectl apply -f mynginx-pod-emptydir.yaml
[root@master mnt]# kubectl get pod mynginx
NAME      READY   STATUS    RESTARTS   AGE
mynginx   1/1     Running   0          48s
[root@master mnt]#  kubectl exec mynginx  -- mount|grep mymount                # 进入容器mynignx，执行命令mount，看一下容器mymount挂载点情况
/dev/xvda1 on /mymount type xfs (rw,relatime,seclabel,attr2,inode64,noquota)   # 系统分配了/dev/xvda1 挂载到容器的目录 mymount
# 如果pod中有多个容器，都会挂载到/mymount点，实现pod间容器目录的共享，缺点是，pod消亡，目录也会消亡
```

### PersistentVolume
#### 搭建NFS
> 在node1节点搭建nfs的pv存储
> node1  172.31.13.91
```
[root@node1 ~]# sudo yum -y install nfs-utils rpcbind
[root@node1 ~]# sudo systemctl enable rpcbind
[root@node1 ~]# sudo systemctl start rpcbind
[root@node1 ~]# sudo systemctl enable nfs-server
[root@node1 ~]# sudo systemctl start nfs-server
[root@node1 ~]# vim /etc/exports
/mnt	172.31.13.0/24(rw,sync,no_root_squash)   #rw可读写,sync可更新，no_root_squash就是root用户也可以进行远端操作
[root@node1 ~]# sudo systemctl restart nfs-server
[root@node1 ~]# showmount -e                  # 查看配置是否正确
Export list for node1:
/mnt 172.31.13.0/24
```

#### pvc
> 172.31.13.91的/mnt目录对外提供服务，申请了1G的空间
```
[root@master mnt]# cat mypv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mypv
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: nfs
  nfs:
    path: /mnt
    server: 172.31.13.91
```
> 操作
```
[root@master mnt]# kubectl apply -f mypv.yaml 
persistentvolume/mypv created
[root@master mnt]# kubectl get pv
NAME   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
mypv   1Gi        RWO            Recycle          Available           nfs                     4s
```
#### pvc 
```
[root@master mnt]# cat mypvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc
spec:
  accessModes:
  - ReadWriteOnce      
  resources:
    requests:
      storage: 1Gi
  storageClassName: nfs
```
> 操作
```
[root@master mnt]# kubectl apply -f mypvc.yaml 
persistentvolumeclaim/mypvc created
[root@master mnt]# kubectl get pvc
NAME    STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mypvc   Bound    mypv     1Gi        RWO            nfs            5s
```
#### pod使用pvc
```
[root@master mnt]# vim mynginx-pod-pv-pvc.yaml
apiVersion: v1
kind: Pod
metadata:
  name: mynginx
spec:
  containers:
  - name: nginx
    image: nginx:1.7.9
    volumeMounts:
      - mountPath: /mymount
        name: mount-volume
  volumes:
  - name: mount-volume
    persistentVolumeClaim:
        claimName: mypvc
```
> 操作
```
[root@master mnt]# kubectl delete pod mynginx
pod "mynginx" deleted
[root@master mnt]# kubectl apply -f mynginx-pod-pv-pvc.yaml
pod/mynginx created
# 在nfs的节点node1上，切换到mnt目录，创建一个文件test-pvc,看进入到mynignx的pod的 /mymount 是否有test-pvc存在
[root@node1 mnt]# cd /mnt
[root@node1 mnt]# touch test-pvc
# master节点
[root@master mnt]# kubectl exec -it mynginx -- /bin/bash
root@mynginx:/# ls /mymount
get-docker.sh  test-pvc                       # 发现在我们的pod节点的 /mymount 有我们的test-pvc存在
root@mynginx:/# 
```

### ConfigMap & Secret
> ConfigMap & Secret 创建方式有4种，推荐用`YAML`
+ `--from-literal`
+ `--from-file`
+ `--from-env-file`
+ `YAML`
> ConfigMap & Secret 传递方式有两种。 
+ volumes 
+ env
> 演示用volumes方式传递
```
[root@master mnt]# echo -n aaa|base64
YWFh
[root@master mnt]# echo -n bbb|base64
YmJi
[root@master mnt]# cat mysecret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
data:
  username: YWFh
  password: YmJi
```
> 操作mysecret.yaml
```
[root@master mnt]# kubectl apply -f mysecret.yaml 
secret/mysecret created
[root@master mnt]# kubectl get secret
NAME                  TYPE                                  DATA   AGE
default-token-rjdbg   kubernetes.io/service-account-token   3      36h
mysecret              Opaque                                2      6s
```
> `mynginx-pod-secret.yaml`
```
[root@master mnt]# cat mynginx-pod-secret.yaml
apiVersion: v1
kind: Pod
metadata:
  name: mynginx
spec:
  containers:
  - name: nginx
    image: nginx:1.7.9
    volumeMounts:
    - mountPath: /mymount
      name: mount-volume
  volumes:
  - name: mount-volume
    secret:
      secretName: mysecret
```
> 操作mynginx-pod-secret.yaml
```
[root@master mnt]# kubectl apply -f mynginx-pod-secret.yaml 
pod/mynginx created
[root@master mnt]# kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
mynginx                            1/1     Running   0          12s
# 进入mynginx容器验证一下,在mymount挂载点生成了两个文件username,password
[root@master mnt]# kubectl exec -it mynginx -- /bin/bash
root@mynginx:/# cd /mymount
root@mynginx:/mymount# ls
password  username
root@mynginx:/mymount# cat username
aaa
root@mynginx:/mymount# cat password
bbb
root@mynginx:/mymount# exit
```
> 修改一下mysecret.yaml中的password为ccc
```
[root@master mnt]# echo -n ccc|base64
Y2Nj
[root@master mnt]# cat mysecret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
data:
  username: YWFh
  password: Y2Nj
```
> 更新secret
```
[root@master mnt]# kubectl apply -f mysecret.yaml 
secret/mysecret configured
# 进入mynginx容器验证一下,在mymount挂载点生成了两个文件username,password
[root@master mnt]# kubectl exec -it mynginx -- /bin/bash
root@mynginx:/# cd /mymount
root@mynginx:/mymount# ls
password  username
root@mynginx:/mymount# cat password
ccc
root@mynginx:/mymount# exit
```