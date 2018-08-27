FROM python:2.7
LABEL maintainer="Peter Huang<peterhlycf@gmail.com>"
# RUN pip  install -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com  flask 
RUN pip  install  flask 
COPY app.py /app/
WORKDIR /app
EXPOSE 5000
CMD ["python", "app.py"]

# 可以手动的方式执行安装python，然后运行 python app.py,访问结果，如果访问不了，需要配置一下防火墙的策略

# docker build -t peterhly/flask-hello-world .
# 如果报错，可以通过以下方式调试
# docker run -it 报错临时生成的imageid /bin/bash   #通过报错临时生成的imageid使用bash进入
# =============
# docker run peterhly/flask-hello-world         ##启动container
# docker run -d peterhly/flask-hello-world      ##后台运行container，使用-d
# docker ps
# docker inspect 容器id，获取一下ip地址为： 172.17.0.2
# docker exec -it 容器id  ip a
# 在docker host机器通过curl http://172.17.0.2:5000  就可以进行访问， 此时其他机器访问不了？