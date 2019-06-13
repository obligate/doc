## Docker 
### 配置docker镜像仓库源
+ 您可以配置 Docker 守护进程默认使用 Docker 官方镜像加速。这样您可以默认通过官方镜像加速拉取镜像，而无需在每次拉取时指定 registry.docker-cn.com,您可以在 Docker 守护进程启动时传入 --registry-mirror 参数 `docker --registry-mirror=https://registry.docker-cn.com daemon`
+ 为了永久性保留更改，您可以修改 /etc/docker/daemon.json 文件并添加上 registry-mirrors 键值,修改保存后重启 Docker 以使配置生效`sudo systemctl restart docker`
```
{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}
```