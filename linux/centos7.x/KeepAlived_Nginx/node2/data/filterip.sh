#!/bin/bash
acc_log=/data/log/nginx/nginx.log
blockip=/etc/nginx/blocksip.conf
tail -n20000 ${acc_log} | awk -vFPAT='"[^"]+"|[^ ]+' '{print $1,$7,$10}' | grep -i -v -E "google|facebook|bing|addthis|criteo|403|bot|android|iphone|ipad|ios|okhttp" | awk '{print $1}' | sort | uniq -c | sort -rn | awk '{if($1>1300)print "deny "$2";"}' >> ${blockip}

/usr/sbin/nginx -t && /usr/sbin/nginx -s reload
