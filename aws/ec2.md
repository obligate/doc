## 格式化并附加到附加卷
实例选用的是`Amazon linux`， 默认的用户名  `ec2-user`, linux下自动挂载的配置文件是放在 `cat /etc/fstab`
### 在 Linux 上格式化并挂载 EBS 卷
+ `lsbl`查看挂载
使用 `lsbl` 命令可查看可用磁盘设备及其挂载点（如果适用），以帮助您确定要使用的正确设备名称。`lsblk` 的输出从完整的设备路径中去掉了 `/dev/` 前缀。
以下是基于 Nitro 的实例的示例输出，输出将 EBS 卷显示为 NVMe 块储存设备。根设备为 /dev/nvme0n1。如果尚未附加，则附加卷为 /dev/nvme1n1
```
lsblk             # 查看挂载
NAME          MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
nvme1n1       259:0    0 1000G  0 disk 
nvme0n1       259:1    0   20G  0 disk 
├─nvme0n1p1   259:2    0   20G  0 part /
└─nvme0n1p128 259:3    0    1M  0 part 
```
+ 确定卷上是否存在文件系统
确定卷上是否存在文件系统。新卷为原始的块储存设备，您必须先在这种设备上创建文件系统，然后才能够挂载并使用它们。从快照还原的卷可能已经含有文件系统；如果您在现有的文件系统上创建新的文件系统，则该操作将覆盖您的数据。
使用 file -s 命令获取设备信息，例如其文件系统类型。如果输出仅显示 data（如以下示例输出），则说明设备上没有文件系统，您必须创建一个文件系统
```
[root@ip-172-31-21-158 ~]# file -s /dev/nvme1n1
/dev/nvme1n1: data
```
如果设备有文件系统，该命令会显示有关文件系统类型的信息。例如，以下示例输出显示具有 XFS 文件系统的根设备
```
[root@ip-172-31-21-158 ~]# file -s /dev/nvme1n1
/dev/nvme1n1: SGI XFS filesystem data (blksz 4096, inosz 512, v2 dirs)
```
+ `mkfs -t` 命令在该卷上创建一个文件系统
```
[root@ip-172-31-21-158 ~]# mkfs -t xfs /dev/nvme1n1
meta-data=/dev/nvme1n1           isize=512    agcount=4, agsize=65536000 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=0
data     =                       bsize=4096   blocks=262144000, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=128000, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
```
> 如果出现“找不到 mkfs.xfs”错误，请使用命令 `sudo yum install xfsprogs` 安装 XFS 工具，然后重复上一命令
实例选用的是`Amazon linux`， 默认的用户名  `ec2-user`, linux下自动挂载的配置文件是放在 `cat /etc/fstab`
+ 创建挂载点和挂载
```
sudo mkdir /data
sudo mount /dev//dev/nvme1n1 /data
umount /data     # 释放挂载点
```
> 重启实例后，挂载点不会自动保留。

### 重启后自动附加附加卷
要在每次系统重启时附加附加的 EBS 卷，可在 /etc/fstab 文件中为该设备添加一个条目
+ 备份`/etc/fstab`,`cp /etc/fstab /etc/fstab.orig`
+ 使用 blkid 命令查找设备的 UUID,以`/dev/nvme1n1`为例
```
[root@ip-172-31-21-158 ~]# blkid
/dev/nvme0n1p1: LABEL="/" UUID="add39d87-732e-4e76-9ad7-40a00dbb04e5" TYPE="xfs" PARTLABEL="Linux" PARTUUID="47de1259-f7c2-470b-b49b-5e054f378a95"
/dev/nvme1n1: UUID="015ca16e-df02-460e-a531-b3fcf2180777" TYPE="xfs"
/dev/nvme0n1: PTUUID="33e98a7e-ccdf-4af7-8a35-da18e704cdd4" PTTYPE="gpt"
/dev/nvme0n1p128: PARTLABEL="BIOS Boot Partition" PARTUUID="430fb5f4-e6d9-4c53-b89f-117c8989b982"
```
+ `vim /etc/fstab`,将以下条目添加到 /etc/fstab 以在指定的挂载点挂载设备
```
UUID=015ca16e-df02-460e-a531-b3fcf2180777     /mnt        xfs    defaults,noatime  1   1
```
+ 要检查条目是否有效，请在 /etc/fstab 中运行以下命令以卸载设备，然后挂载所有文件系统。如果未产生错误，则说明 /etc/fstab 文件正常，您的文件系统会在重启后自动挂载。
```
[root@ip-172-31-21-158 ~]#sudo umount /data
[root@ip-172-31-21-158 ~]#sudo mount -a
```