## 获取ip
`ip a |awk '{match($0,/([0-9]{1,3}\.){3}[0-9]{1,3}/,a); print a[0]}'|grep .`    


## 大小写转换
`cat /etc/passwd|cut -d ":" -f 1|head -n 5|tr [a-z] [A-Z]`


## 输出的讯息中，将冒号(:)删除
`cat /etc/passwd | tr -d ':'`


## wget
`wget --no-passive-ftp ftp://username@password:xxx`