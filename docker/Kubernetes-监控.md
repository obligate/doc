## Helm安装部署
```
[root@master mnt]# yum install -y openssl
[root@master mnt]# curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7160  100  7160    0     0  22226      0 --:--:-- --:--:-- --:--:-- 22236
Downloading https://get.helm.sh/helm-v2.16.10-linux-amd64.tar.gz
Preparing to install helm and tiller into /usr/local/bin
helm installed into /usr/local/bin/helm
tiller installed into /usr/local/bin/tiller
Run 'helm init' to configure helm.
[root@master mnt]# helm init 
Creating /root/.helm 
Creating /root/.helm/repository 
Creating /root/.helm/repository/cache 
Creating /root/.helm/repository/local 
Creating /root/.helm/plugins 
Creating /root/.helm/starters 
Creating /root/.helm/cache/archive 
Creating /root/.helm/repository/repositories.yaml 
Adding stable repo with URL: https://kubernetes-charts.storage.googleapis.com 
Adding local repo with URL: http://127.0.0.1:8879/charts 
$HELM_HOME has been configured at /root/.helm.

Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.

Please note: by default, Tiller is deployed with an insecure 'allow unauthenticated users' policy.
To prevent this, run `helm init` with the --tiller-tls-verify flag.
For more information on securing your installation see: https://v2.helm.sh/docs/securing_installation/

[root@master mnt]# helm version
Client: &version.Version{SemVer:"v2.16.10", GitCommit:"bceca24a91639f045f22ab0f41e47589a932cf5e", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.16.10", GitCommit:"bceca24a91639f045f22ab0f41e47589a932cf5e", GitTreeState:"clean"}

[root@master mnt]# helm search mysql
NAME                                    CHART VERSION   APP VERSION     DESCRIPTION                                                 
stable/mysql                            1.6.7           5.7.30          Fast, reliable, scalable, and easy to use open-source rel...
stable/mysqldump                        2.6.1           2.4.1           A Helm chart to help backup MySQL databases using mysqldump 
stable/prometheus-mysql-exporter        0.7.0           v0.11.0         A Helm chart for prometheus mysql exporter with cloudsqlp...
stable/percona                          1.2.1           5.7.26          free, fully compatible, enhanced, open source drop-in rep...
stable/percona-xtradb-cluster           1.0.5           5.7.19          free, fully compatible, enhanced, open source drop-in rep...
stable/phpmyadmin                       4.3.5           5.0.1           DEPRECATED phpMyAdmin is an mysql administration frontend   
stable/gcloud-sqlproxy                  0.6.1           1.11            DEPRECATED Google Cloud SQL Proxy                           
stable/mariadb                          7.3.14          10.3.22         DEPRECATED Fast, reliable, scalable, and easy to use open...

# 创建sa和rolebinding
[root@master mnt]# kubectl create serviceaccount --namespace kube-system tiller
[root@master mnt]# kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
[root@master mnt]# kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
```


## Prometheus
```
[root@master mnt]# kubectl create namespace monitoring
namespace/monitoring created
# helm install prometheus之前如果报错，一定要创建sa和rolebinding
[root@master mnt]# helm install --name prometheus-operator --set rbacEnable=true --namespace=monitoring stable/prometheus-operator
==> v1beta1/ValidatingWebhookConfiguration
NAME                           WEBHOOKS  AGE
prometheus-operator-admission  1         31s

NOTES:
The Prometheus Operator has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=prometheus-operator"

Visit https://github.com/coreos/prometheus-operator for instructions on how
to create & configure Alertmanager and Prometheus instances using the Operator.
# 查看chart结构
[root@master mnt]#  ls ~/.helm/cache/archive/|grep pro                             # prometheus的chart下载之后所在的目录
prometheus-operator-9.3.1.tgz
[root@master chart-test]# cp ~/.helm/cache/archive/prometheus-operator-9.3.1.tgz  /mnt/chart-test/    # 看一下chart的结构
[root@master chart-test]# tar -zxvf prometheus-operator-9.3.1.tgz
[root@master prometheus-operator]# ls
charts  Chart.yaml  CONTRIBUTING.md  crds  README.md  requirements.lock  requirements.yaml  templates  values.yaml
# 修改service，ClusterIP -> NodePort
[root@master mnt]# kubectl get service --namespace=monitoring
NAME                                           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
alertmanager-operated                          ClusterIP   None             <none>        9093/TCP,9094/TCP,9094/UDP   10m
prometheus-operated                            ClusterIP   None             <none>        9090/TCP                     10m
prometheus-operator-alertmanager               ClusterIP   10.110.165.46    <none>        9093/TCP                     11m
prometheus-operator-grafana                    ClusterIP   10.106.167.172   <none>        80/TCP                       11m
prometheus-operator-kube-state-metrics         ClusterIP   10.104.155.235   <none>        8080/TCP                     11m
prometheus-operator-operator                   ClusterIP   10.109.176.103   <none>        8080/TCP,443/TCP             11m
prometheus-operator-prometheus                 ClusterIP   10.97.232.237    <none>        9090/TCP                     11m
prometheus-operator-prometheus-node-exporter   ClusterIP   10.106.88.234    <none>        9100/TCP                     11m
# 修改以下service，ClusterIP -> NodePort
[root@master mnt]# kubectl edit service prometheus-operator-grafana --namespace=monitoring
[root@master mnt]# kubectl edit service prometheus-operator-prometheus --namespace=monitoring
[root@master mnt]# kubectl edit service prometheus-operator-alertmanager --namespace=monitoring
# 获取grafana的初始密码
[root@master mnt]# kubectl get secret --namespace=monitoring
[root@master mnt]# kubectl edit secret prometheus-operator-grafana --namespace=monitoring
...
  admin-password: cHJvbS1vcGVyYXRvcg==
  admin-user: YWRtaW4=
...
[root@master mnt]# echo -n YWRtaW4=| base64 -d
admin
[root@master mnt]# echo -n cHJvbS1vcGVyYXRvcg== |base64 -d
prom-operator
# 获取grafana的端口，通过 https://publicip:端口，例如https://10.106.167.172:31604
[root@master mnt]# kubectl get service --namespace=monitoring
NAME                                           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
alertmanager-operated                          ClusterIP   None             <none>        9093/TCP,9094/TCP,9094/UDP   84m
prometheus-operated                            ClusterIP   None             <none>        9090/TCP                     83m
prometheus-operator-alertmanager               NodePort    10.110.165.46    <none>        9093:32107/TCP               84m
prometheus-operator-grafana                    NodePort    10.106.167.172   <none>        80:31604/TCP                 84m
prometheus-operator-kube-state-metrics         ClusterIP   10.104.155.235   <none>        8080/TCP                     84m
prometheus-operator-operator                   ClusterIP   10.109.176.103   <none>        8080/TCP,443/TCP             84m
prometheus-operator-prometheus                 NodePort    10.97.232.237    <none>        9090:32366/TCP               84m
prometheus-operator-prometheus-node-exporter   ClusterIP   10.106.88.234    <none>        9100/TCP                     84m
```
> `git clone https://github.com/coreos/prometheus-operator`

## EFK（Fluentd, Elasticsearch, Kibana）监控
> `https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/fluentd-elasticsearch`
> 需要下载Yaml文件到$download_directory
```
[root@master mnt]# mkdir efk
[root@master mnt]# cd efk/
[root@master efk]# wget https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/es-service.yaml
[root@master efk]# wget https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/es-statefulset.yaml
[root@master efk]# wget https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/fluentd-es-configmap.yaml
[root@master efk]# wget https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/fluentd-es-ds.yaml
[root@master efk]# wget https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/kibana-deployment.yaml
[root@master efk]# wget https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/fluentd-elasticsearch/kibana-service.yaml
[root@master efk]# ls
es-service.yaml  es-statefulset.yaml  fluentd-es-configmap.yaml  fluentd-es-ds.yaml  kibana-deployment.yaml  kibana-service.yaml
# 修改kibana-deployment.yaml，删除$SERVER_BASEPATH  
[root@master efk]# vim kibana-deployment.yaml
...
         - name: SERVER_NAME
            value: kibana-logging
#          - name: SERVER_BASEPATH
#            value: /api/v1/namespaces/kube-system/services/kibana-logging/proxy
...
# 修改kibana-service.yaml, 把kibana-logging service，成为NodePort类型 
[root@master efk]# vim kibana-service.yaml
 ...
 spec:
  ports:
  - port: 5601
    protocol: TCP
    targetPort: ui
  selector:
    k8s-app: kibana-logging
  type: NodePort              # 修改成NodePort类型
```
> 操作
```
[root@master efk]# kubectl apply -f /mnt/efk/    # 指定一个目录
service/elasticsearch-logging created
serviceaccount/elasticsearch-logging created
clusterrole.rbac.authorization.k8s.io/elasticsearch-logging created
clusterrolebinding.rbac.authorization.k8s.io/elasticsearch-logging created
statefulset.apps/elasticsearch-logging created
configmap/fluentd-es-config-v0.2.0 created
serviceaccount/fluentd-es created
clusterrole.rbac.authorization.k8s.io/fluentd-es created
clusterrolebinding.rbac.authorization.k8s.io/fluentd-es created
daemonset.apps/fluentd-es-v3.0.2 created
deployment.apps/kibana-logging created
service/kibana-logging created
# 获取kibana-logging 的访问端口，通过浏览器https://public_ip:端口，例如： https://10.105.113.77:30446
[root@master efk]# kubectl get service --namespace=kube-system
NAME                                          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                        AGE
elasticsearch-logging                         ClusterIP   10.109.42.230    <none>        9200/TCP                       107s
kibana-logging                                NodePort    10.105.113.77    <none>        5601:30446/TCP                 107s
```