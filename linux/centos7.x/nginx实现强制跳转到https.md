## nginx实现跳转到https
当用户访问 `http://www.aa.com`的时候统一跳转到`https://www.aa.com`


## `nginx.conf`
```
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
  # underscores_in_headers on;
  real_ip_header X-Forwarded-For;
  real_ip_recursive on;
  include /etc/nginx/conf.d/*.conf;
}
```

## `/etc/nginx/conf.d/www_aa_com.conf`
```
server {

  server_name www.aa.com;
  listen 443 ssl;
  access_log /var/log/nginx/www.aa.com.access.log;


  proxy_set_header Host $http_host;
  proxy_set_header X-Forwarded-Proto $scheme;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_redirect off;

  ssl_certificate /etc/nginx/conf.d/www.aa.com.crt;
  ssl_certificate_key /etc/nginx/conf.d/www.aa.com.key;

  # keepalive + raven.js is a disaster
  keepalive_timeout 0;

  # use very aggressive timeouts
  # proxy_read_timeout 5s;
  proxy_send_timeout 5s;
  send_timeout 5s;
▽ resolver_timeout 5s;
  client_body_timeout 5s;

  # buffer larger messages
  client_max_body_size 100m;
  client_body_buffer_size 100k;

  gzip_static on;
  gzip on;
  gzip_min_length 3k;
  gzip_buffers 4 16k;
  gzip_comp_level 2;
  gzip_types text/plain application/x-javascript application/javascript text/css application/xml text/javascript application/x-httpd-php image/jpeg image/gif image/png;
  gzip_vary off;
  gzip_disable "MSIE [1-6]\.";

  include /etc/nginx/white-ip.conf;

  location / {

    proxy_pass http://10.10.10.173:8081;
    add_header Strict-Transport-Security "max-age=31536000";
  }
  location ^~ /api/ {

    proxy_pass http://10.10.10.172:9504;
    client_max_body_size 500M;
  }
  location ^~ /authentication/ {

    proxy_pass http://10.10.10.172:9504;
  }


}

server {
  server_name www.aa.com;
  listen 80;
  rewrite ^(.*) https://$server_name$1 permanent;
}
```