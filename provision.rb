%w[ build-essential libpcre3-dev git-core cpanminus libssl-dev redis-server ].each do |p|
  package p
end

execute "cpanm install Test::Nginx" do
  not_if "perl -mTest::Nginx -e'1'"
end

openresty_version = "1.2.8.6"

remote_file "/home/vagrant/ngx_openresty-#{openresty_version}.tar.gz" do
  source "http://openresty.org/download/ngx_openresty-#{openresty_version}.tar.gz"
  notifies :run, "execute[install openresty]"
end

execute "install openresty" do
  cwd "/home/vagrant"
  command <<EOF
 tar -zxvf ngx_openresty-#{openresty_version}.tar.gz
cd ngx_openresty-#{openresty_version}
./configure --with-luajit --prefix=/usr/local --sbin-path=/usr/local/sbin/nginx
make
make install
EOF
  action :nothing
end
