FROM ubuntu
RUN apt-get update && apt-get install -y stress
ENTRYPOINT ["/usr/bin/stress"]
CMD []


# CMD [] 作用： 接受docker run传递的参数
# ENTRYPOINT + CMD []                                                   ## 为了传递参数,这是典型的处理方式
########################################### 使用 ################################
# stress --vm 2 --verbose                                               ## 启动2个worker，默认一个worker内存是256M
# stress --vm 1 --vm-bytes 500000M --verbose                            ## 启动一个worker，自动启动的内存500000M,测试失败，受限于容器本身或者docker host
# top 查看当前docker host的内存总量
#####################################    build ###################################
# docker build -t peterhly/ubuntu-stree . 
# docker image ls
# docker run -it  peterhly/ubuntu-stree                                 ## 类似于执行了stress命令的help信息
# docker run -it  peterhly/ubuntu-stree --vm 1  --verbose               ## 类似于执行了stress命令的传入参数--vm 1 --verbose