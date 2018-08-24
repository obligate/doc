FROM centos
ENV name Docker
ENTRYPOINT ["bin/bash","-c", "echo hello $name"]
# ENTRYPOINT ["bin/echo", "hello $name"]   ##输出hello $name

# docker build -t peterhly/centos-entrypoint-exec  .    ## 构建image
# docker run peterhly/centos-entrypoint-exec           ## 生成container并运行
