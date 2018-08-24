## pip 安装
```
yum -y install epel-release                 						   # 需要先安装企业版linux附加包（epel)
yum -y install python-pip                                              # 安装pip
pip install --upgrade pip                                              # 更新pip
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple  --upgrade pip # 国内原加速
pip install -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com  --upgrade pip
```

## pip 使用
```
# pip install docker-compose                                               # 安装docker-compose 
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple  docker-compose    # 国内原加速
pip show docker-compose                                                    # 显示这个包的信息，包括安装地址
pip show --files docker-compose                                            # 查看已安装的包（包括安装路径等详细信息）
pip list --outdated                                                        # 检查哪些包需要更新
pip install --upgrade docker-compose									   # 升级包
pip uninstall  docker-compose                                              # 卸载包
pip list                                                                   # 列出已安装包
pip search  docker-compose                                                 # 搜索包，类似yum里的search
pip freeze                                                                 # 按着一定格式输出已安装包列表
pip freeze > requirement                                                   # 把已安装的包导出到requirement文件
pip install -r requirement                                                 # 从requirement安装包
```