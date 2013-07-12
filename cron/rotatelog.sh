_prefix="/home/jsb/stat"
time=`date +%Y%m%d%H`

mv ${_prefix}/logs/ma.log ${_prefix}/logs/ma/ma-${time}.log
kill -USR1 `cat ${_prefix}/logs/nginx.pid`
