## 命令
![系统性能监控](img/系统性能监控.jpg)


## 查看指定进程的cpu和内存的占用情况
首先找到进程id，然后使用top命令进行查看
[root@hk_crm_edm_02 ~]# jps -lm
38757 sun.tools.jps.Jps -lm
53726 net.edmauto.agent.AgentApp
[root@hk_crm_edm_02 ~]# top -p 53726
top - 11:54:59 up 672 days,  2:43,  1 user,  load average: 0.04, 0.04, 0.00
Tasks:   1 total,   0 running,   1 sleeping,   0 stopped,   0 zombie
Cpu(s):  0.0%us,  0.0%sy,  0.0%ni, 99.9%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Mem:  32872664k total, 31658132k used,  1214532k free,  3051596k buffers
Swap: 20840440k total,   104304k used, 20736136k free, 26337608k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND                                                                              
53726 root      20   0 13.2g 346m  12m S  0.0  1.1 532:15.65 java  

## 查看指定进程的带宽占用情况
使用nethogs工具即可查看，安装命令：yum -y install nethogs  
nethogs 网卡   即可查看带宽的占用情况
PS：nethogs命令无法根据pid来查看带宽


## 查看指定进程的磁盘io读写情况
使用pidstat命令即可查看，安装命令：yum -y install sysstat
pidstat -d 1 -p ${pid}