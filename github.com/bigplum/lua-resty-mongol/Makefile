OPENRESTY_PREFIX=/usr/local/openresty

PREFIX ?= /usr/local/openresty
LUA_INCLUDE_DIR ?= $(PREFIX)/include
LUA_LIB_DIR ?= $(PREFIX)/lualib
INSTALL ?= install

.PHONY: all test install

all: ;

install: all
	$(INSTALL) -d $(LUA_LIB_DIR)/resty/mongol
	$(INSTALL) lib/resty/mongol/*.lua $(LUA_LIB_DIR)/resty/mongol


test:
	PATH=$(OPENRESTY_PREFIX)/nginx/sbin:$$PATH prove -I../test-nginx/lib -r t
