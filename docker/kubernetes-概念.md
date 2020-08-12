### port、NodePort、ContainerPort和targetPort
- port在service上，负责处理对内的通信，clusterIP:port
- NodePort在node上，负责对外通信，NodeIP:NodePort
- ContainerPort在容器上，用于被pod绑定
- targetPort在pod上、负责与kube-proxy代理的port和Nodeport数据进行通信

### k8s 权限控制
Secret、ServiceAccount 的权限受限于 Role/ClusterRole。一提到权限就整 RABC，其实就是 Role-Based Access Control
权限在 role 上，通过 rolebinding 将 user 和 role 串起来
user 可以是 serviceaccout(基于某个 namespace)、users(没有试验过)
role 可以是 role(基于某个 namespace)、clusterRole(全局)
rolebinding 可以是 rolebinding(基于某个 namespace)、clusterrolebinding(全局)
+ Role 代表权限，本质上说就是对某种资源的什么操作是允许的
APIGroups + Resources + ResourceNames 是表征资源
[Verbs](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#determine-the-request-verb) 是表征操作
+ RoleBinding 是 role 与 user 的桥梁