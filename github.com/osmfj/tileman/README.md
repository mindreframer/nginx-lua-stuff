TileMan
=========

Author: Hiroshi Miura, OpenStreetMap Foundation Japan <miurahr@osmf.jp>


Here is a project to maintain tile.openstreetmap.jp tile cache/tile server.
It uses following technologies.

- Nginx Web server (tested on nginx v1.4.1 + lua-module 0.8.1)
  we provide PPA for ubuntu user. You need to select nginx-extras package.
   (need lua module > 0.8.1)

- Tirex, rendering backend 0.4.1

- PostGIS 2.0/postgresql 9.1

- osm2pgsql

- osmosis (recommend v0.40 or later)

It is intended to run on Ubuntu 12.04.2(x86_64) server but it may be
useful for other platform and who want to run osm tile server.


Version
----

Ver 1.3
Release: 8, Sept. 2013


Install
----

Please see INSTALL.md for up-to-date install instructions.

Also you can try it with Vagrant.
[Setup development environment using Vagrant](https://github.com/osmfj/tileman/wiki/Setup-development-environment-using-Vagrant)

License
-- 

TileMan is distributed under GPLv3 license.

Maintainer
--

It is maintained by OpenStreetMap Foundation Japan.

Core developer: Hiroshi Miura
Developers:     Hal Seki

Design
==

Nginx serves tile proxy. It returns disk cache and escalate to upstream
tile.openstreetmap.org servers when needed.
Lua script included by Nginx controls local rendering.
It is an asumption that postgis server has limited osm data in region.

Lua script retrive x/y/z parameter and check an existence of 
tile data. If it is out of area where the server provided, it goes upstream.

We need another script to maintain tile generation control.
We can get expire.list as "Tile expire method" explaines when importing diff.osm.
http://wiki.openstreetmap.org/wiki/Tile_expire_methods

Here is a typical configuration 
![configration diagram](https://dl.dropboxusercontent.com/u/90779460/typical_configuration.png)

planet import
---

The directory updatedb has an incremental update script and primary load script
for osm data.
It is now defaults geofabrik data and also supposed to use planet.osm.org data. 


Data
====

This distribution includes several tile images.

It can be used to replace some tiles,  where some country law request to 
display specific name.

There are several places where multiple laws in countries requires incoherent 
rules, such as administration claims.

A nginx configuration, statictile provides a solution for these case.
For details, please refer doc/statictile.ja.txt


