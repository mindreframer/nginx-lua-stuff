#!/bin/bash

# set global variables   project name and path
export YGM_APP_NAME=yagamiko
export OPENRESTY_HOME=/usr/local
export YAGAMI_HOME=/source/freeflare/server/yagami

#echo $OPENRESTY_HOME
#echo $YAGAMI_HOME

PWD=`pwd`

NGINX_FILES=$PWD"/nginx_runtime"

mkdir -p $NGINX_FILES"/conf"
mkdir -p $NGINX_FILES"/logs"

rm -rf $NGINX_FILES"/conf/*"
cp -r $PWD"/conf" $NGINX_FILES


sed -e "s|__YAGAMI_HOME_VALUE__|$YAGAMI_HOME|" \
    -e "s|__YAGAMI_APP_PATH_VALUE__|$PWD|" \
    -e "s|__YAGAMI_APPNAME_VALUE__|$YGM_APP_NAME|" \
    $PWD/conf/vhosts/$YGM_APP_NAME.conf > $NGINX_FILES/conf/vhosts/$YGM_APP_NAME.conf
