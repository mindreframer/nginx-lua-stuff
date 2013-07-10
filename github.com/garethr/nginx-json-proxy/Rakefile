require 'bundler'
Bundler.setup(:default)

require 'open3'
require 'ansi/code'

OPENRESTY_VERSION = "1.2.8.6"
OPENRESTY_NAME = "ngx_openresty-#{OPENRESTY_VERSION}"
OPENRESTY_TARBALL = "#{OPENRESTY_NAME}.tar.gz"

DEBUG = 0
INFO = 1
ERROR = 2
NONE = 3

LOG_LEVEL = ENV['LOG_LEVEL'].to_i || INFO

ROOT = File.expand_path(File.dirname(__FILE__))

def r(cmd, log_level = LOG_LEVEL)
  puts ANSI.on_blue { ANSI.bold { cmd } }
  Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
    stdout.each { |line| print ANSI.green { line } if log_level <= DEBUG }
    stderr.each { |line| print ANSI.red { line } if log_level <= ERROR }
    exit_status = wait_thr.value
  end
end

namespace :openresty do
  desc "Remove ngx_openresty files from vendor and tmp"
  task :clobber do
    r "rm -rf #{ROOT}/tmp/ngx_*"
    r "rm -rf #{ROOT}/vendor/openresty"
  end

  desc "Download ngx_openresty tarball and install it into ./vendor"
  task :install, [:force] do |t, args|
    if forced = (args[:force] || "") =~ /^f/
      Rake::Task["openresty:clobber"].invoke
    else
      if File.exists?("#{ROOT}/vendor/openresty/nginx/sbin/nginx") && r("#{ROOT}/vendor/openresty/nginx/sbin/nginx -V", NONE).success?
        puts ANSI.yellow { "openresty is already installed: rake openresty:install[force] to reinstall" }
        exit
      end
    end

    FileUtils.cd("tmp")
    r("wget http://openresty.org/download/#{OPENRESTY_TARBALL}", NONE) unless File.exists?(OPENRESTY_TARBALL)
    r("tar xzvf #{OPENRESTY_TARBALL}") unless Dir.exists?(OPENRESTY_NAME)

    FileUtils.cd(OPENRESTY_NAME)
    r "./configure --prefix=#{ROOT}/vendor/openresty --with-luajit --with-http_ssl_module --with-http_gzip_static_module"
    r "make && make install"

    puts ANSI.reverse { ANSI.green { "#{OPENRESTY_NAME} installed to ./vendor/#{OPENRESTY_NAME}. Cool beans." } }
  end
end
