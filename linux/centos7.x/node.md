## 1.node安装-->二进制包安装nodejs
+ 1.下载[node](https://nodejs.org/dist/v10.13.0/node-v10.13.0-linux-x64.tar.xz)对应的二进制包
`wget https://nodejs.org/dist/v10.13.0/node-v10.13.0-linux-x64.tar.xz`
+ 2.解压
```
xz -d node-v10.13.0-linux-x64.tar.xz
tar -xvf node-v10.13.0-linux-x64.tar
mkdir /usr/local/node
mv node-v10.13.0-linux-x64/* /usr/local/node/
```
+ 3.环境变量配置
```
vi /etc/profile
export NODE_HOME=/usr/local/node
export PATH=$NODE_HOME/bin:$PATH
source /etc/profile
node -v
npm -v
echo $PATH
```
## 2.cnpm 
`npm install -g cnpm --registry=https://registry.npm.taobao.org`
## 3.pm2 
PM2 是开源的基于Nodejs 的进程管理器，包括守护进程，监控，日志的一整套完整的功能
### 安装
`cnpm install -g pm2`
### 常用命令
```
pm2 start app.js --name www_aa_com
pm2 start app.js -i 3 --name www_aa_com 3                  # 启动3 个进程（自带负载均衡）
pm2 start all                                              # 启动所有
pm2 list                                                   # 显示所有进程状态
pm2 logs                                                   # 显示所有进程状态
pm2 logs www_aa_com                                        # 显示一个进程的日志
pm2 stop 0                                                 # 停止id=0的进程
pm2 stop www_aa_com                                        # 按照名称停止进程 
pm2 stop all                                               # 停止所有进程
pm2 restart 0                                              # 重启id=0进程                       
pm2 restart www_aa_com                                     # 按照名称重启进程 
pm2 restart all                                            # 重启所有进程
pm2 reload all                                             # 0 秒停机重载进程(用于NETWORKED 进程)
pm2 delete 0                                               # 杀死id=0的进程
pm2 delete www_aa_com                                      # 按照名称杀死进程
pm2 delete all                                             # 杀死全部进程
pm2 show www_aa_com                                        # 显示总体信息
```
## Refer
+ [Node](https://nodejs.org/en/)