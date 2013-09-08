Developmenter note
=====================

Roadmap
============

Ver 0.8
----
* nginxサーバで、タイルキャッシュ機能を提供します。
* リクエストのx/y/z値のチェックをおこなって不正なアクセスを
  抑止します。
* tile.openstreetmap.orgの地域分散プログラム(CDN)へ参加可能な
　機能を備えます。

Ver 0.9
----
* PostGISデータベースに日本地域のOSMデータを日次で
  自動更新できるようにします。
* アクセス元が日本国内かどうかを判定して、独自タイルの配信を
   切り替えます。
* リクエストのx/y/z値をチェックして、レンダリング対象かどうかを
　判定できます。

Ver 1.0
----
* nginxサーバのLUA拡張を利用して実装します。
* タイル生成は、Tirexで行います。
* 生成されたタイル画像ファイルは、ファイルシステムに格納されます。
* nginxサーバとTirexは、UDPソケット通信でコマンドをやり取りします。


Ver 1.1
---

* TileManに名称変更
* Tirexとの通信において本バージョン以降で安定動作

Ver 1.2
---

* バックグラウンドで、リクエストされたタイルよりズームレベルの高い
　タイルを、低い優先度でリクエストします。
* Tirex-batchを使って、tile expire を処理します。
* Debianパッケージ化を進めます。
* コアロジックを lua-nginx-osmライブラリに分割し、tilemanの設定は
　容易に理解可能にします。

Ver 2.0
----

* Redis Key-Value-Storeを活用して、複数サーバのtile管理情報を管理します。
* Redis Pub/Subを利用して、複数サーバでコマンドをやり取りします。


Directories
=============

    /opt/tileman/cache ... tile cache directory for nginx, 要書き込み権限　
    /opt/tileman ... application directory
    /opt/osmosis    ... osmosisのバイナリを展開する
    /opt/tileman/bin/ lib/ share/ application bin/data
    /var/opt/osmosis ... osmosisの設定や状態　要書き込み権限 osmosisで


External Links
===============

* [*1] https://github.com/osmfj/tileman
* [*2] https://github.com/miurahr/lua-nginx-osm
* [*3] http://wiki.openstreetmap.org/wiki/Tirex
* [*4] http://nginx.org/ja/

