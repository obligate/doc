## kubernetes常用命令
+ `kubectl get no`                              查询节点，nodes or node or no           
+ `kubectl get cs`                              查询组件状态，componentstatuses or cs    
+ `kubectl get ns`                              查询名命空间，namespaces or ns           

缺省defalut名命空间，-n 指定名命空间，指定全部名命空间 --all-namespaces

+ `kubectl get pod -n kube-system`               查询pod，pods or pod or po               
+ `kubectl get pod -n kube-system -o wide`       加参数 -o wide 可显示运行节点             
+ `kubectl  get service --all-namespaces`        查询service，services or service or svc  
+ `kubectl  get deployments --all-namespaces`    kind分类查询，replicationcontrollers or rc , deployments or deploy, daemonsets or ds
+ `kubectl  get all --all-namespaces`            查询所有 all