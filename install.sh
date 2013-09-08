#!/bin/bash

DISTRO=debian #ubuntu/debian
#DISTRO=redhat #redhat/centos/fedora

PREFIX=/opt/tileman

DESTDIR=${PREFIX}/bin/
HTMLDIR=${PREFIX}/html/
CACHEDIR=${PREFIX}/cache/
STATICDIR=${PREFIX}/tiles/

CONFDIR=/etc/
NGINX=${CONFDIR}/nginx

OSMOSIS_WORK=/var/opt/osmosis

mkdir -p ${DESTDIR}
mkdir -p ${OSMOSIS_WORK}
mkdir -p ${HTMLDIR}

echo "make ${CACHEDIR} directory for tile cache"
mkdir -p ${CACHEDIR}
chmod 777 ${CACHEDIR}

echo "Locating example static tile on ${STATICDIR}..."
mkdir -p ${STATICDIR}
bzcat data/Liancourt_Rocks_lang_ja_tiles.tar.bz2 |(cd ${STATICDIR};tar xf -)

echo "Install nginx configurations..."
install nginx/tileproxy_params $NGINX/
install nginx/common_location_params $NGINX/
install nginx/ssl_params $NGINX/

if [ "${DISTRO}" = "debian" ]; then
  install nginx/conf.d/* $NGINX/conf.d/
  install nginx/sites/* $NGINX/sites-available/
else
  install nginx/conf.d/tileman.conf $NGINX/conf.d/_tileman.conf
  #
  install nginx/sites/tileman-proxy $NGINX/conf.d/tileman-proxy.conf.ex
  install nginx/sites/tileman-proxy-ssl $NGINX/conf.d/tileman-proxy-ssl.conf.ex
  install nginx/sites/tileman-server $NGINX/conf.d/tileman-server.conf.ex
  install nginx/sites/tileman-server-ssl $NGINX/conf.d/tileman-server-ssl.conf.ex
  echo "Please see $NGINX/conf.d/*.conf.ex for configuration examples."
fi

# install updatedb utils
echo "Install osm/postgis utilities..."
install -c bin/* ${DESTDIR}
install -c etc/*.conf ${CONFDIR}

cp osmosis/fabrik.txt ${OSMOSIS_WORK}/configuration.txt

echo "Now you should create PostgreSQL/PostGIS database for OSM"
echo "After you set DBUSER/DBPASS and DBNAME to /etc/tileman.conf"
echo "You can use /opt/tileman/bin/tileman-create"
echo "and /opt/tileman/bin/tileman-load"

