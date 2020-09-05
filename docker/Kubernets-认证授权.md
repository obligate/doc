## 认证和授权
> 1.确认k8s群集的rbac是否开启
```
[root@master mnt]# cat /etc/kubernetes/manifests/kube-apiserver.yaml |grep auth
    - --authorization-mode=Node,RBAC
    - --enable-bootstrap-token-auth=true
```
> 2.创建`mysa.yaml`
```
[root@master mnt]#  cat mysa.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: mysa
--- 
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: mysa-role
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: mysa-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: mysa-role
subjects:
- kind: ServiceAccount
  name: mysa
```
> 3.操作` mysa.yaml`
```
[root@master mnt]# kubectl apply -f mysa.yaml     # 此时在默认namespace创建
serviceaccount/mysa created
role.rbac.authorization.k8s.io/mysa-role created
rolebinding.rbac.authorization.k8s.io/mysa-rolebinding created
[root@master mnt]# kubectl get sa
NAME      SECRETS   AGE
default   1         37h
mysa      1         74s
[root@master mnt]#  kubectl get secret
NAME                  TYPE                                  DATA   AGE
default-token-rjdbg   kubernetes.io/service-account-token   3      37h
mysa-token-h2dnz      kubernetes.io/service-account-token   3      3m16s        # 生成一个sa的token
mysecret              Opaque                                2      70m
[root@master mnt]# kubectl describe secret mysa-token-h2dnz                     # 通过describe来获取sa的token，就可以通过这个token去访问k8s集群，权限就是mysa-role定义的可以访问pod
Name:         mysa-token-h2dnz
Namespace:    default
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: mysa
              kubernetes.io/service-account.uid: 06753b07-9d96-40cd-8f83-3001fb5b6d96
Type:  kubernetes.io/service-account-token
Data
====
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6ImpVTHhzTXpEbEx2Wlp4Z2VYUDQtbFUzRFludmQ0ZGZtY0dEaWlwdDZOdGMifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im15c2EtdG9rZW4taDJkbnoiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoibXlzYSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjA2NzUzYjA3LTlkOTYtNDBjZC04ZjgzLTMwMDFmYjViNmQ5NiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0Om15c2EifQ.N5AmNfAAJWxZBovIw3-crQPM1IaMvsyYljy4pJNrnhc-2wrhvpegyOjpOxhoLYjGDsgki-k9UFJ9yOWuqUCqnCEkZ_ioT2S7lb7n_ZTKW798cYPU5lhBhcHaSSCuyLM7q1GLBhThrxQqkPx_fLrQkyTih1wbh2642KaUbEGXwCTb9bNKFLdhRw6MrU1tvSRNw2Ola4Id5PStv4TN7eRfwdyIr2GqrH-d9ohBaqKLROQP3JkzCDsEDYfeZ-YdiiSwslqFE3SCbYwmjq7nt6ifTlsdeLLrNHjxC8mzMNk6q9M2Cp9a6PDclOgeljrmnaL9AKrzKiefNWOALYUwYRVW2w
ca.crt:     1066 bytes
namespace:  7 bytes
```