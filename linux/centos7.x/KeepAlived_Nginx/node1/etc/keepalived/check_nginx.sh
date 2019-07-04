#!/bin/bash
if [ $(ps -C nginx --no-header | wc -l) -eq 0 ]; then
        systemctl start nginx.service
fi
sleep 2
if [ $(ps -C nginx --no-header | wc -l) -eq 0 ]; then
       systemctl stop keepalived.service
fi

