## 网络
### 防火墙
+ 关闭firewall
```
systemctl stop firewalld.service #停止firewall
systemctl disable firewalld.service #禁止firewall开机启动
```
+ 安装iptables防火墙
```
#安装
yum install iptables-services 
```
+ 编辑防火墙配置文件
```
vi /etc/sysconfig/iptables
```
+ 重启
```
systemctl restart iptables.service #最后重启防火墙使配置生效
systemctl enable iptables.service #设置防火墙开机启动
```