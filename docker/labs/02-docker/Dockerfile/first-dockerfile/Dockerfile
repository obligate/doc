FROM ubuntu:14.04
LABEL maintainer="Peter Huang <peterhlycf@gmail.com>"
RUN apt-get update && apt-get install -y redis-server
EXPOSE 6379
ENTRYPOINT [ "/usr/bin/redis-server" ]
