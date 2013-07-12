#!/bin/bash

source ./bin/generate_nginx_conf.sh

PWD=`pwd`
NGINX_FILES=$PWD"/nginx_runtime"
$OPENRESTY_HOME/nginx/sbin/nginx -p $NGINX_FILES/ -c conf/nginx.conf

echo "nginx started!"

