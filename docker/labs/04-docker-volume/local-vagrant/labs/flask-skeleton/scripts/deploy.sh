#!/usr/bin/env bash

docker ps -a | grep peter_skeleton | awk '{print$1}' | xargs docker stop
docker ps -a | grep peter_skeleton | awk '{print$1}' | xargs docker rm
docker run -d -p 80:5000 --name peter_skeleton skeleton
