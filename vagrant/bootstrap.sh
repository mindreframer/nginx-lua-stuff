#!/usr/bin/env bash

apt-get update

# add osmjapan PPA repository
apt-get install -y python-software-properties
apt-add-repository -y ppa:osmjapan/ppa
apt-add-repository -y ppa:miurahr/openresty
apt-add-repository -y ppa:osmjapan/testing
apt-get update

# install nginx/openresty
apt-get install -y nginx-openresty
#apt-get install -y nginx-extras # > 1.4.1-0ppa1


# install mapnik
apt-get install -y libmapnik-dev
apt-get install -y ttf-unifont ttf-dejavu ttf-dejavu-core ttf-dejavu-extra

# install postgis
apt-get install -y postgresql-9.1 postgresql-contrib-9.1 postgresql-9.1-postgis

# install Tirex
apt-get install -y tirex-core tirex-backend-mapnik tirex-example-map

# install Lua OSM library
apt-get install -y geoip-database lua5.1 lua-bitop
apt-get install -y lua-nginx-osm

# install osm2pgsql
apt-get install -y osm2pgsql

# install osmosis
apt-get install -y openjdk-7-jre
cd /vagrant
wget http://bretth.dev.openstreetmap.org/osmosis-build/osmosis-latest.tgz
mkdir -p /opt/osmosis
cd /opt/osmosis;tar zxf /vagrant/osmosis-latest.tgz
mkdir -p /var/opt/osmosis
chown vagrant /var/opt/osmosis

# install tileman package
apt-get install -y tileman

# development dependencies
apt-get install -y devscripts debhelper dh-autoreconf build-essential git
apt-get install -y libfreexl-dev libgdal-dev python-gdal gdal-bin
apt-get install -y libxml2-dev python-libxml2 libsvg

# install Redis-server
apt-get install -y redis-server

# setup postgis database
su postgres -c /usr/bin/tileman-create
