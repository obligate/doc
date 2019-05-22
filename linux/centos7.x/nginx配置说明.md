## 配置文件结构
![配置文件结构](img/nginx_config_struct.png)
```
# 全局块
...              
# events块
events {         
   ...
}
# http块
http      
{
    # http全局块
    ...   
    # 虚拟主机server块
    server        
    { 
        # server全局块
        ...       
        # location块
        location [PATTERN]   
        {
            ...
        }
        location [PATTERN] 
        {
            ...
        }
    }
    server
    {
      ...
    }
    # http全局块
    ...     
}
```
在上述配置中我们可以看出，Nginx配置文件由以下几个部分构成
+ 全局块
+ events块
+ http块
  + server块
    + location块
  
### 全局块
配置影响nginx全局的指令。一般有运行nginx服务器的用户组，nginx进程pid存放路径，日志存放路径，配置文件引入，允许生成worker process数等
```
#运行用户
user www-data;    
#启动进程,通常设置成和cpu的数量相等,也可以设置为auto
#在配置文件的顶级main部分，worker角色的工作进程的个数，master进程是接收并分配请求给worker处理。这个数值简单一点可以设置为cpu的核数grep ^processor /proc/cpuinfo | wc -l，也是 auto 值，如果开启了ssl和gzip更应该设置成与逻辑CPU数量一样甚至为2倍，可以减少I/O操作。如果nginx服务器还有其它服务，可以考虑适当减少
worker_processes  1;

#全局错误日志及PID文件
error_log  /var/log/nginx/error.log;
pid        /var/run/nginx.pid;
```
### events块
配置影响nginx服务器或与用户的网络连接。有每个进程的最大连接数，选取哪种事件驱动模型处理连接请求，是否允许同时接受多个网路连接，开启多个网络连接序列化等
```
#工作模式及连接数上限
events {
    # 写在events部分。在Linux操作系统下，nginx默认使用epoll事件模型，得益于此，nginx在Linux操作系统下效率相当高。同时Nginx在OpenBSD或FreeBSD操作系统上采用类似于epoll的高效事件模型kqueue。在操作系统不支持这些高效模型时才使用select
    use   epoll;             #epoll是多路复用IO(I/O Multiplexing)中的一种方式,但是仅用于linux2.6以上内核,可以大大提高nginx的性能
    worker_connections  1024;#单个后台worker process进程的最大并发链接数
    #一个worker可以接受多个请求，如果一下来了几百个请求，是否允许一个worker全接受。
	#如果该参数被设为OFF，那么一个worker process进程一次只接收一个请求，如果是ON，则一次接收所有请求
	#设置为on显然就快的多，如果是off，则还需要master进程额外调度。默认是off。
    # multi_accept on; 
}
```
### http块
可以嵌套多个server，配置代理，缓存，日志定义等绝大多数功能和第三方模块的配置。如文件引入，mime-type定义，日志自定义，是否使用sendfile传输文件，连接超时时间，单连接请求数等。
```
#http配置段，用于定义web服务的一些重要属性，代理、缓存、日志以及其他HTTP有关的特性等
http {
     #设定mime类型,类型由mime.type文件定义
    include       /etc/nginx/mime.types;
    #默认文件类型
    default_type  application/octet-stream;

    log_format detaile  '[$time_local] [$http_x_forwarded_for] [$http_x_via]'
                        '[$http_x_hm_trace_id] [$cookie_x_hm_tuid] [$http_x_hm_tuid] [$sent_http_x_damai_lk] [nginx] [$host] '
                        '[$server_addr] [$request_method] [$http_referer] [http://$host$uri] [$args] [$status] '
                        '[$body_bytes_sent] [$request_time] [$upstream_addr] [$upstream_status] [$upstream_response_time] '
                        '[$http_user_agent] [$http_rule_name]';
	#以下为主要变量说明
	# $http_x_forwarded_for：保存的就是X-Forwarded-For信息
	# $host：客户端请求的Host头域值
	# $server_add：服务器IP地址
	# $request_method：请求方法
	# $http_referer：表示从哪个链接跳转过来
	# $status：服务器响应代码
	# $request_time：从接受用户请求的第一个字节到发送完响应数据的实际，包括接受请求数据的实际、程序响应时间、输出数据时间
	# $upstream_add：后端被代理服务器的地址
	# $upstream_response_time：表示Nginx向被代理服务器建立连接开始到接收完数据然后断开连接的时间，这个时间肯定比$request_time的时间短


   	#这个访问日志如果在编译时指定则这里会被禁用，同时不会显示实际路径，为了便于识别
	#在保持禁用的同时你修改为实际路径。这个访问日志格式使用的是上面定义的main格式。
    access_log  /var/log/nginx/access.log  detaile;
	#下面这个加了一个 buffer 参数，含义是日志先同步到缓存中，这样提升性能，避免每产生
	#一条日志都立即写入磁盘文件。
	#access_log /var/log/nginx/access.log  main buffer=32k


    #sendfile 指令指定 nginx 是否调用 sendfile 函数（zero copy 方式）来输出文件，对于普通应用，
    #必须设为 on,如果用来进行下载等应用磁盘IO重负载应用，可设置为 off，以平衡磁盘与网络I/O处理速度，降低系统的uptime.
    sendfile        on;
    #tcp_nopush     on;

    #连接超时时间
    #keepalive_timeout  0;
    keepalive_timeout  65;
    tcp_nodelay        on;
    
    #开启gzip压缩
    gzip  on;
    gzip_disable "MSIE [1-6]\.(?!.*SV1)";

    #设定请求缓冲
    client_header_buffer_size    1k;
    large_client_header_buffers  4 4k;

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;

    #设定负载均衡的服务器列表
     upstream mysvr {
    #weigth参数表示权值，权值越高被分配到的几率越大
    #本机上的Squid开启3128端口
    server 192.168.8.1:3128 weight=5;
    server 192.168.8.2:80  weight=1;
    server 192.168.8.3:80  weight=6;
    }


   server {
    #侦听80端口
        listen       80;
        #定义使用www.xx.com访问
        #域名可以有多个，用空格隔开
        server_name  www.xx.com;

        #设定本虚拟主机的访问日志
        access_log  logs/www.xx.com.access.log  main;

    #默认请求
    location / {
          root   /root;      #定义服务器的默认网站根目录位置
          index index.php index.html index.htm;   #定义首页索引文件的名称

          fastcgi_pass  www.xx.com;
         fastcgi_param  SCRIPT_FILENAME  $document_root/$fastcgi_script_name; 
          include /etc/nginx/fastcgi_params;
        }

    # 定义错误提示页面
    error_page   500 502 503 504 /50x.html;  
        location = /50x.html {
        root   /root;
    }

    #静态文件，nginx自己处理
    location ~ ^/(images|javascript|js|css|flash|media|static)/ {
        root /var/www/virtual/htdocs;
        #过期30天，静态文件不怎么更新，过期可以设大一点，如果频繁更新，则可以设置得小一点。
        expires 30d;
    }
    #PHP 脚本请求全部转发到 FastCGI处理. 使用FastCGI默认配置.
    location ~ \.php$ {
        root /root;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME /home/www/www$fastcgi_script_name;
        include fastcgi_params;
    }
    #设定查看Nginx状态的地址
    location /NginxStatus {
        stub_status            on;
        access_log              on;
        auth_basic              "NginxStatus";
        auth_basic_user_file  conf/htpasswd;
    }
    #禁止访问 .htxxx 文件
    location ~ /\.ht {
        deny all;
    }
     
     }
}
```
### server块
配置虚拟主机的相关参数，一个http中可以有多个server

### location块
配置请求的路由，以及各种页面的处理情况


## 启动关闭nginx
```
## 检查配置文件是否正确
# /usr/local/nginx-1.6/sbin/nginx -t 
# ./sbin/nginx -V     # 可以看到编译选项

## 启动、关闭
# ./sbin/nginx        # 默认配置文件 conf/nginx.conf，-c 指定
# ./sbin/nginx -s stop
或 pkill nginx

## 重启，不会改变启动时指定的配置文件
# ./sbin/nginx -s reload
或 kill -HUP `cat /usr/local/nginx-1.6/logs/nginx.pid`
```



## refer
[nginx.conf配置文件说明](https://blog.51cto.com/littledevil/1901390)