How to configure custom style

# Original rendering configutaion
  
1. Install Dependencies

  ```
  sudo apt-get install python-mapnik
  ```
  
2. Get OpenStreetMap Japan mapnik style.

  ```
  git clone https://github.com/osmfj/mapnik-stylesheets.git
  ```
  
3. fork it for your own style.

  ```
  git checkout -b <new-cool-style-for-my-map> master
  ```

   please replace <new-cool-style-for-my-map> with your favorite branch name
   
4. get coast line

  ```
  cd ~/mapnik-stylesheets # or whatever directory you put the project in
  get_coastline.sh
  ```
  
5. Edit style in XML

 (1) Modify template for local language

  Now tweaking the Mapnik rules to render the tiles in a local language. For this all we need to do is point Mapnik to the right font. You can quickly follow the steps briefed by Richard.

  You can run
  
  ```
    python
    >>> from mapnik import *
    >>> for face in FontEngine.face_names(): print face
    … [Enter]

    DejaVu Sans Bold
    DejaVu Sans Bold Oblique
    DejaVu Sans Book
    DejaVu Sans Condensed
    DejaVu Sans Condensed Bold
    DejaVu Sans Condensed Bold Oblique
    DejaVu Sans Condensed Oblique
    DejaVu Sans ExtraLight
    DejaVu Sans Mono Bold
    DejaVu Sans Mono Oblique

    ……………………………………..

    >>> Ctrl-d
  ```
  
  to see what fonts are currently being recognized by Mapnik. The second task is to install the local language unicode font to Mapnik’s default font directory. If you have already installed Mapnik, you can run strace -ff, and search for font to see which directory is used by Mapnik. In my case it was the default directory at /usr/share/fonts/
  
  Next, you need to copy the required fonts to the above directory.

  edit the Mapnik template file: inc/fontset-settings.xml.inc.template, as described below.  The file begins with something like this.

  ```
    <FontSet name=”bold-fonts”>
    <Font face_name=”DejaVu Sans Bold”></Font>
    </FontSet>
    <FontSet name=”book-fonts”>
    <Font face_name=”DejaVu Sans Book”></Font>
    </FontSet>
    <FontSet name=”oblique-fonts”>
    <Font face_name=”DejaVu Sans Oblique”></Font>
    </FontSet>
  ```
  
  Change the face_name to the font name we just copied to the fonts directory.  In my case, it would look like this.
  ```
    <FontSet name=”bold-fonts”>
    <Font face_name=”Rachana Regular”></Font>
    </FontSet>
    <FontSet name=”book-fonts”>
    <Font face_name=”Rachana Regular”></Font>
    </FontSet>
    <FontSet name=”oblique-fonts”>
    <Font face_name=”Rachana Regular”></Font>
    </FontSet>
  ```

 (2)

  TBD


6. Generate your custom mapnik rules

  ```
  ./generate_xml.py --host localhost --port 5432 --user osm --password '' --dbname gis --symbols ./symbols/ --world_boundaries ./world_boundaries/ osm.xml > custom.xml
  ```
  
7. Now we copy the file to proper place
  ```
  cp custom.xml /opt/tileserver/share
  ```

8. add tirex configuration

  ```
  vi /etc/tirex/render/mapnik/custom.conf
  ##
  #  Configuration for Mapnik custom map.
  #  /etc/tirex/renderer/mapnik/custom.conf
  ##
  #  symbolic name of this map
  name=custom
  
  #  tile directory
  tiledir=/var/lib/tirex/tiles/custom

  #  zoom level allowed
  minz=0
  maxz=19
  
  mapfile=/opt/tileserver/share/custom.xml
  ```

9. restart tirex-backend-manager and test!


