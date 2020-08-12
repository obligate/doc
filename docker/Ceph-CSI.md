## vault
整个部署默认部署在csi-rbd 命名空间下,如果没有需要⼿动创建`kubectl create ns csi-rbd`
vault 是⼀个管理secret 并保护敏感数据

### 部署vault
```
cd ceph-csi/vault/
kubectl apply -f csi-vaulttokenreview-rbac.yaml -n csi-rbd
kubectl apply -f vault.yaml  -n csi-rbd
kubectl apply -f vault-psp.yaml -n csi-rbd
```
### CSI RBD 部署
#### 创建存储池及访问权限
```
ceph osd pool create kubernetes
rbd pool init kubernetes
ceph auth get-or-create client.kubernetes mon 'profile rbd' osd 'profile rbd pool=kubernetes' mgr 'profile rbd pool=kubernetes'
ceph auth get client.kubernetes
```
#### CSI RBD 部署
```
cd ceph-csi/rdb/
ceph auth get client.kubernetes                  # 获取kubernetes用户的key
ceph mon dump                                    # 获取Ceph 集群的fsid 和monitor 的地址列表
kubectl apply -f csi-config-map.yaml   -n csi-rbd
kubectl apply -f csi-rbd-secret.yaml   -n csi-rbd
kubectl apply -f csi-rbd-sc.yaml    -n csi-rbd
kubectl apply -f ceph-csi-encryption-kms-config.yaml   -n csi-rbd
kubectl apply -f csi-nodeplugin-rbac.yaml    -n csi-rbd
kubectl apply -f csi-provisioner-rbac.yaml   -n csi-rbd
kubectl apply -f csi-rbdplugin.yaml   -n csi-rbd
kubectl apply -f csi-rbdplugin-provisioner.yaml   -n csi-rbd
```
### CSI FS部署
```
cd ceph-csi/fs/
ceph auth get client.admin                   # 获取admin用户的key
kubectl apply -f csi-cephfs-secret.yaml  -n csi-rbd
kubectl apply -f csi-nodeplugin-rbac.yaml  -n csi-rbd
kubectl apply -f csi-provisioner-rbac.yaml -n csi-rbd
kubectl apply -f csi-cephfsplugin.yaml   -n csi-rbd
kubectl apply -f csi-cephfsplugin-provisioner.yaml  -n csi-rbd
kubectl apply -f storageclass.yaml  -n csi-rbd
```
#### 测试
```
kubectl apply -f pvc.yaml -n validsa
kubectl apply -f pod.yaml -n validsa
```