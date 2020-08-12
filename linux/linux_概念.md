###  EPEL
Extra Packages for Enterprise Linux (or EPEL) is a Fedora Special Interest Group that creates, maintains, and manages a high quality set of additional packages for Enterprise Linux, including, but not limited to, Red Hat Enterprise Linux (RHEL), CentOS and Scientific Linux (SL), Oracle Linux (OL).
简言之，EPEL是专门为RHEL、CentOS等Linux发行版提供额外rpm包的。很多os中没有或比较旧的rpm，在epel仓库中可以找到。RHEL以及他的衍生发行版如CentOS、Scientific Linux为了稳定，官方的rpm repository提供的rpm包往往是很滞后的，而EPEL恰恰可以解决这两方面的问题。EPEL的全称叫 Extra Packages for Enterprise Linux 。EPEL是由 Fedora 社区打造，为 RHEL 及衍生发行版如 CentOS、Scientific Linux 等提供高质量软件包的项目。装上了 EPEL之后，就相当于添加了一个第三方源。在某些情况下，通过 EPEL repo 安装一些软件比其他安装方式方便很多
例如配置阿里云的epel：
`rpm -ivh https://mirrors.aliyun.com/epel/epel-release-latest-6.noarch.rpm`
`rpm -ivh https://mirrors.aliyun.com/epel/epel-release-latest-7.noarch.rpm`
```
yum -y install epel-release    # 安装
yum repolist                   # 查看结果
```

### repo
repo文件是CentOS中yum源（软件仓库）的配置文件，通常一个repo文件定义了一个或者多个软件仓库的细节内容，例如我们将从哪里下载需要安装或者升级的软件包，repo文件中的设置内容将被yum读取和应用。YUM的工作原理并不复杂，每一个 RPM软件的头（header）里面都会纪录该软件的依赖关系，那么如果可以将该头的内容纪录下来并且进行分析，可以知道每个软件在安装之前需要额外安装 哪些基础软件。也就是说，在服务器上面先以分析工具将所有的RPM档案进行分析，然后将该分析记录下来，只要在进行安装或升级时先查询该纪录的文件，就可 以知道所有相关联的软件。所以YUM的基本工作流程如下：
服务器端：在服务器上面存放了所有的RPM软件包，然后以相关的功能去分析每个RPM文件的依赖性关系，将这些数据记录成文件（形成“依赖性关系文件”）存放在服务器的某特定目录内。
客户端：如果需要安装某个软件时，先下载服务器上面记录的依赖性关系文件(可通过WWW或FTP方式)，通过对服务器端下载的纪录数据进行分析，然后取得所有相关的软件，一次全部下载下来进行安装。
```
 vim  /etc/yum.conf
 vim  /etc/yum.repo.d/xx.repo
```