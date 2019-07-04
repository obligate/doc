## namespace

namespace 是 Linux 内核用来隔离内核资源的方式。通过 namespace 可以让一些进程只能看到与自己相关的一部分资源，而另外一些进程也只能看到与它们自己相关的资源，这两拨进程根本就感觉不到对方的存在。具体的实现方式是把一个或多个进程的相关资源指定在同一个 namespace 中。其中PID,IPC,Network等系统资源不再是全局性的，而是属于特定的Namespace。Linux Namespace机制为实现基于容器的虚拟化技术提供了很好的基础，LXC（Linux containers）就是利用这一特性实现了资源的隔离。不同Container内的进程属于不同的Namespace，彼此透明，互不干扰，改变一个namespace中的系统资源只会影响当前namespace里的进程，对其他namespace中的进程没有影响

Linux namespaces 是对全局系统资源的一种封装隔离，使得处于不同 namespace 的进程拥有独立的全局系统资源，改变一个 namespace 中的系统资源只会影响当前 namespace 里的进程，对其他 namespace 中的进程没有影响。

Namespace是Linux内核对系统资源进行隔离和虚拟化的特性，这些系统资源包括进程ID、主机名、用户ID、网络访问、进程间通讯和文件系统等。Linux 3.8内核中包括了6种命名空间：Mount (mnt)、Process ID (process)、Network (net)、InterProcess Communication (ipc)、UTS、User ID (user)；此外，还有cgroup namespace。在Namespace中，每一个进程都绑定在特定命名空间中，且只能查看和操作绑定在此名字空间的资源

namespace是一种隔离机制，一个独立的namespace看上去拥有所有linux主机的资源，也拥有自己的0号进程（即系统初始化的进程）。一个namespace可以产生多个子namespace，通过设置clone系统调用的flag可以实现。事实上namespace是为了支持linux container（即linux容器）出现的，运用kernel中的namespace机制和cgroup机制（kernel的配额管理机制）可以实现轻量级的虚拟，即多个虚拟主机（容器）公用宿主机的kernel，彼此之间资源隔离。docker的部分技术也依赖于此


```
Linux提供了如下几种Namespace
Namespace   变量               隔离资源
Cgroup      CLONE_NEWCGROUP   Cgroup 根目录(since Linux 4.6)
IPC         CLONE_NEWIPC      System V IPC, POSIX 消息队列等(since Linux 2.6.19)【Interprocess Communication】
Network     CLONE_NEWNET      网络设备，协议栈、端口等(since Linux 2.6.24)
Mount       CLONE_NEWNS       挂载点(since Linux 2.4.19)
PID         CLONE_NEWPID      进程ID(since Linux 2.6.24)
User        CLONE_NEWUSER     用户和group ID(started in Linux 2.6.23 and completed in Linux 3.8)
UTS         CLONE_NEWUTS      Hostname和NIS域名(since Linux 2.6.19)【UNIX Time-sharing System】
```
> 通过`uname -r 可以查看内核版本`
其实从代码角度理解是最容易的。在进程的struct里面加多了几个变量用来区分uts,ipc等等，比如两个进程管理uts的变量一样，那么就共享hostname 和 NIS信息，如果不一样就各自玩各种的。IPC，如果一样的话，一个进程创建的 消息队列，另一个进程也能看到。不一样的话就看不到。


Namespace API提供了三种系统调用接口
+ clone()：创建新的进程
+ setns()：允许指定进程加入特定的namespace
+ unshare()：将指定进程移除指定的namespace


查看进程所属的 namespace ,从版本号为 3.8 的内核开始，`/proc/[pid]/ns `目录下会包含进程所属的 namespace 信息，使用命令`ll /proc/$$/ns`可以查看当前进程所属的 namespace 信息
