FROM python:2.7
LABEL maintaner="Peter Huang<peterhlycf@gmail.com>"
COPY . /app
WORKDIR /app
RUN pip install flask redis
EXPOSE 5000
CMD [ "python", "app.py" ]



# 场景 ----  python flask 访问redis
# 1. 启动redis
# 2. 根据Dockerfile构建一个flask-redis的image
# 3. 根据flask-redis，启动一个容器flask-redis，做一个单向的绑定 --link redis
# 4. 测试：
# 	1. 进入flask-redis容器内部，执行ping redis 和 curl http://127.0.0.1:5000(可以执行多次）
# 	2. 在dockerhost访问curl http://127.0.0.1:5000,结果不能访问，因为没有portmap
# 5. 删除flask-redis的容器，添加portmap
# 6. 测试：
# 	在docker host上访问curl http://127.0.0.1:5000，可以访问
# #################### 命令#########################################
# docker\labs\03-docker-network\flask-redis
# sudo docker run -d --name redis redis    # 启动一个redis的container
# sudo docker build -t peterhly/flask-redis .
# sudo docker image ls
# ## -d 后台运行，--link和redis做一个单向绑定，在flask-redis容器内可以通过这个link访问redis
# ## -e 在当前的容器设置一个环境变量REDIS_HOST=redis,进入容器内部使用env可以看到设置的环境变量
# sudo docker run -d --link redis --name flask-redis -e REDIS_HOST=redis  peterhly/flask-redis
# sudo docker exec -it flask-redis /bin/bash
# env   
# ping redis
# curl http://127.0.0.1:5000
# curl http://127.0.0.1:5000
# curl http://127.0.0.1:5000  执行多次
# exit
# 此时外面无法访问curl http://127.0.0.1:5000，没有port map
# sudo docker stop flask-redis
# sudo docker rm flask-redis
# sudo docker run -d -p 5000:5000 --link redis --name flask-redis -e REDIS_HOST=redis  peterhly/flask-redis
# 此时本地就可以访问 curl http://127.0.0.1:5000