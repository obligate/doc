## nginx 配置
```
user nginx;
worker_processes 4;
pid /var/run/nginx.pid;

events {
	worker_connections 768;
	# multi_accept on;
}

http {

    ##
    # Basic Settings
    ##

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;   #关闭显示nginx版本

    server_names_hash_bucket_size 64;
    
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    ##
    # SSL Settings
    ##

    ssl_protocols TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384:TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA:TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256:TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
    ssl_ecdh_curve secp384r1; # Requires nginx >= 1.1.0
    ssl_session_cache shared:SSL:10m;
    ssl_session_tickets off; # Requires nginx >= 1.5.9
    ssl_stapling_verify on; # Requires nginx => 1.3.7

    ##
    # Logging Settings
    ##

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                '$status $body_bytes_sent "$http_referer" '
                '"$http_user_agent" "$http_x_forwarded_for"';
    access_log /data/log/nginx/nginx.log;
    error_log /data/log/nginx/error.log;

    ##
    # Gzip Settings
    ##

    gzip on;
    gzip_vary on;
    gzip_min_length 1k;
    gzip_buffers 4 32k;
    gzip_disable "msie6";
    gzip_disable "MSIE [1-6].";
    gzip_http_version 1.1;
    gzip_comp_level 3;
    gzip_types text/plain application/x-javascript text/css application/xml text/javascript application/javascript application/json;
    ##
    # Proxy Headers
    ##
    include /etc/nginx/proxy.conf;   #设置代理头信息

    ##
    # filter ip
    ##
    include /etc/nginx/blocksip.conf;  #过滤IP地址

    ##
    # Virtual Host Configs
    ##

   # include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*.conf;  #配置各个站点的信息
}
```



## 动态监控流量ip进行deny和allow
```
*/15 * * * * root /data/filterip.sh
```
```
vim /data/filterip.sh
#!/bin/bash
acc_log=/data/log/nginx/nginx.log
blockip=/etc/nginx/blocksip.conf
tail -n20000 ${acc_log} | awk -vFPAT='"[^"]+"|[^ ]+' '{print $1,$7,$10}' | grep -i -v -E "google|facebook|bing|addthis|criteo|403|bot|android|iphone|ipad|ios|okhttp" | awk '{print $1}' | sort | uniq -c | sort -rn | awk '{if($1>1300)print "deny "$2";"}' >> ${blockip}
/usr/sbin/nginx -t && /usr/sbin/nginx -s reload
```