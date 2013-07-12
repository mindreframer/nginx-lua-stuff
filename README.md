# Introduction

I started porting the Sinatra framework using Lua on top of Openresty.
Currently using capybara-webkit with Ruby to test as I have not come up
with a good pattern to mock nginx through Lua. Trying to abstract
Request and Response, so most of the app can be tested against using
MockRequest and MockResponse objects.

# Test

Assuming that you already have OpenResty installed and available via
PATH.

```sh
bundle
pkill nginx; nginx -p `pwd`/examples/ -c nginx.conf; bundle exec rspec spec/
busted -p spec.lua
```
