Setup instruction of tileman

Tested on Ubuntu 12.04 LTS 64bit

# Install TileMan for using a proxy/cache server of tile.openstreetmap.jp

If you only need tile proxy/cache server, just follow this instruction.
And you can serve original local tile images placed X/Y/Z folder.

The OpenStreetMap Japan team provide Ubuntu PPA for it.


## Install dependency programs

We use git version control system and Private Package Archive.

  ```
  sudo apt-get install git python-software-properties
  ```

## clone git repository.

We use submodule feature of git.
Please follows an instructon bellow.

  ```
  git clone https://github.com/osmfj/tileman.git
  git submodule init
  git submodule update
  ```

  If you have github account, you can use a following instead;

  ```
  git://github.com/osmfj/tileman.git
  ```

If you are not developer, it is recommended to download tar.gz or zip archive
from https://github.com/osmfj/tileman/tags

## Install nginx from PPA

  ```
  sudo apt-add-repository ppa:osmjapan/ppa
  sudo apt-get update
  sudo apt-get install nginx-extras
  ```

## Install TileMan

1. Install dependencies and core libraries from Ubuntu repository and PPA

  ```
  sudo apt-get install geoip-database lua5.1 lua-bitop
  ```
  
  if you intend to be a developer, you may need following packages.
  ```
    sudo apt-get install build-essentials geoip-database dh-autoreconf lua5.1 lua-bitop
  ```

 It will be also installed so many depencent packages.
 
2. Install lua osm library

  ```
  sudo apt-get install lua-nginx-osm
  ```

3. Setup nginx configulation, cache directory and updatedb utilities, 

  ```
  cd  tileman
  sudo ./install.sh
  ```

  If you want to use TileProxy;
  ```
  sudo ln -s /etc/nginx/sites-available/tileproxy /etc/nginx/sites-enabled/tileproxy
  ```

  If you need SSL settings, enable ssl configuration;

  ```
  sudo ln -s /etc/nginx/sites-available/tileproxy-ssl /etc/nginx/sites-enabled/tileproxy-ssl
  ```

  If you want to use special configuration in order to replace static tiles in specific region.
  A details are described in StaticTile.md.(TBD)
  
  ```
  sudo ln -s /etc/nginx/sites-available/statictile /etc/nginx/sites-enabled/statictile
  ```

4. Restart nginx

  ```
  sudo service nginx restart
  ```

5. Test

  You can access to the nginx from your local machine. And VirtualHost name of the tile cache server is named 'tile' as default. So you have to add 'tile' entry on your local hosts file (not on the remote host).

  ```
  local% sudo vi /etc/hosts
  ##
  # Host Database
  #
  # localhost is used to configure the loopback interface
  # when the system is booting.  Do not change this entry.
  ##
  127.0.0.1  localhost tile
  255.255.255.255  broadcasthost
  ::1             localhost
  fe80::1%lo0  localhost
  ```

  You can see cached tiles like this, using url 'http://tile/0/0/0.png'

  ![tile image](https://dl.dropbox.com/u/442212/qiita/tilecache_image.png)

  If you are set for replacement of static tiles, hostname 'japan' is used for it.
  
  
# Install rendering system for generating original tiles.

You will need following softwares for serving original renderer.
First it shows a test case for mapnik example-map tirex rendering configuration.

## Install Dependencies

1. Mapnik rendering library

 PPA now has Mapnik 2.2.0

  ```
  sudo apt-get install python-software-properties
  sudo apt-add-repository ppa:osmjapan/ppa # if you did not add this yet
  sudo apt-get update
  sudo apt-get install libmapnik-dev unzip
  ```


2. Tirex rendering engine

  ```
  sudo apt-get install tirex-core tirex-backend-mapnik \
       tirex-example-map
  ```

  
## example-map rendering server

1. Setup nginx configuration

  ```
  sudo ln -s /etc/nginx/sites-available/tileserver /etc/nginx/sites-enabled/tileserver
  ```

 If you need SSL settings, enable ssl configuration

  ```
  sudo ln -s /etc/nginx/sites-available/tileserver_ssl /etc/nginx/sites-enabled/tileserver_ssl
  ```

2. restert nginx

  ```
  sudo service nginx restart
  ```

3. Test

  You can access to the nginx from your local machine. And VirtualHost name of the tileserver is named 'tileserver' as default. So you have to add 'tileserver' entry on your local hosts file (not on the remote host).

  ```
  local% sudo vi /etc/hosts
  ##
  # Host Database
  #
  # localhost is used to configure the loopback interface
  # when the system is booting.  Do not change this entry.
  ##
  127.0.0.1  localhost tile tileserver
  255.255.255.255  broadcasthost
  ::1             localhost
  fe80::1%lo0  localhost
  ```

  You can see rendered tile, using url 'http://tileserver/0/0/0.png'
  It will be a world coast lines in zoom 0.
  

## OpenStreetMap planet data and rendering
  
  Now you can challenge your own rendering server.
  You need to prepare PostGIS and mapnik style for its work.
  
1. PostGIS 2.0 geo-spacial DBMS

  ```
  sudo apt-get install postgresql-9.1-postgis
  ```

2. Importing tools

  ```
  # osm2pgsql
  sudo apt-get install osm2pgsql
  #  osmoisis
  sudo apt-get install openjdk-7-jre # if not installed  
  wget http://bretth.dev.openstreetmap.org/osmosis-build/osmosis-latest.tgz
  mkdir -p /opt/osmosis
  cd /opt/osmosis
  sudo tar zxf ~/osmosis-latest.tgz
  sudo mkdir -p /var/opt/osmosis
  sudo chown peter /var/opt/osmosis
  ```
  
  please change owner of /var/opt/osmosis to who run update-db script.

3. OpenStreetMap data setup

  Create db named 'gis'
  
  ```
  sudo apt-get install openstreetmap-postgis-db-setup
  ```
  You will be asked by package configuration.
  ```
  Configuring openstreetmap-postgis-db-setup
   "If you don't use the default name, you might need to adapt programs and scripts to use the new name
   Name of the database to create:"
      gis
   ok
   ```
   
   adding users who want to use osm data.
   please add you and 'osm'
   ```  
   ────┤   Configuring openstreetmap-postgis-db-setup ├───┐
   │ Please specify which users should have access to     |
   | the newly created db. You will want the user www-data| 
   | for rendering and your own user name to import data  |
   | into the db.                                         │
   │ The list of users is blank separated:                |
   | E.g. "www-data peter"                                |
   |                                                      │  
   │ Other users that should have access to the db:       |
     ──────────────────────────────────────────────────── 
     www-data peter osm                                 
   ```

4. Configure postgresql user

 Edit /opt/postgresql/9.1/main/pg_hba.conf
 Make test easy, add followings:
 ```
  # TYPE  DATABASE  ADDRESS   USER  METHOD
    local   gis               osm    trust
  ```

5. Configure postgis, role and hstore

 You can see /opt/tileman/bin/createdb.sh 
  ```
  sudo -u postgres -i
  createuser osm
  createdb -E UTF8 -O osm gis
  createlang plpgsql gis
  psql -d gis -f /usr/share/postgresql/9.1/contrib/postgis-2.0/postgis.sql 
  psql -d gis -f /usr/share/postgresql/9.1/contrib/postgis-2.0/spatial_ref_sys.sql
  psql -d gis 'ALTER TABLE geography_columns owner to osm;'
  psql -d gis 'ALTER TABLE geometry_columns  owner to osm;'
  psql -d gis 'ALTER TABLE spatial_ref_sys   owner to osm;'
  exit
  ```
  
6. configure import tool setting

  You should change at least, MEMSIZE, PROCESS_NUM, REGION, COUNTRY.
  please refer definitions 
  http://www.geofabrik.de/

  ```
  vi /etc/tileman.conf
 
  DBNAME=gis
  DBUSER=osm
  DBPASS=
  
  MEMSIZE=1024
  PROCESS_NUM=1
  
  ORIGIN=geofabrik
  #ORIGIN=planet

  # import region and country that need when origin is geofabrik
  REGION=asia
  COUNTRY=japan
  ```
  
  if you want to import world data, please change ORIGIN.
  You need to change also /var/opt/osmosis/configration.txt
  
  further detail is in tileman/updatedb/osmosis_conf/
  
8. import planet or geofabrik data

   ```
   cd $HOME
   mkdir tmp
   cd tmp
   /opt/tileman/bin/osm-loaddb 
   ```
   
9. mapnik openstreetmap style and more

  ```
  sudo apt-get install python-mapnik
  git clone git@github.com:osmfj/mapnik-stylesheets.git
    or
  git clone https://github.com/osmfj/mapnik-stylesheets.git
  ```

10. get coastlines

  ```
  cd mapnik-stylesheets
  ./get-coastlines.sh
  ```
  
11. setup xml config
  ```
  ./generate_xml.py --dbname gis --user osm --accept-none
  ./generate_xml.py osm.xml custom.xml --dbname gis --user osm  --accept-none
  ```

12. setup tirex

  you can see recommend modifications in
  ```
  doc/tirex_mapnik_conf.diff
  doc/tirex_mapnik_custom.conf
  ```

   ```
  sudo vi /etc/tirex/render/mapnik.conf
  sudo vi /etc/tirex/render/mapnik/custom.conf
   ```

  Further instruction is in doc/custom_style.md
  It shows a practical environment with PostGIS/Mapnik/Tirex combination.

