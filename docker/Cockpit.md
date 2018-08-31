## install
```
sudo yum install cockpit                                                  # Install cockpit
sudo systemctl enable --now cockpit.socket                                # Enable cockpit
sudo firewall-cmd --permanent --zone=public --add-service=cockpit         # Open the firewall if necessary
sudo firewall-cmd --reload
```
## 结合k8s 
### 在k8s 的master 上
```
yum install -y cockpit cockpit-ws cockpit-kubernetes cockpit-bridge cockpit-dashboard cockpit-pcp cockpit-storaged
systemctl restart cockpit.socket
systemctl enable cockpit.socket
https://hostip:9090
master 机器用户账户密码
```


## 使用
If you already have Cockpit on your server, point your web browser to: https://ip-address-of-machine:9090
Use your system user account and password to log in. See the guide for more info.




## Refer
[cockpit](https://cockpit-project.org/)