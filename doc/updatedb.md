Tileman utilities
===================

tileman-create
--------------

tileman-load
-------------







tileman-update
==========

Here is utility to keep PostGIS tracking planet
using Osmosis and osm2pgsql.
You can run it with cron scheduler to make up-to-date your PostGIS db
with OSM planet changes data.

Options
---

tileman-update can take additional option.

  * '-b': clwan-up out-of-bounding-box ways
 
  * '-c': compact size of PostGIS.

  * '-d': show debug messages

  * '-v': show version 

Configurations
----

You can configure a behavior with /etc/tileman.conf
and a file 'config.txt' in an Osmosis working directory.

Please refer osmosis manual and page how to configure it.
http://wiki.openstreetmap.org/wiki/JA:Osmosis
