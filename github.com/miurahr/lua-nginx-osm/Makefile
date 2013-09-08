PREFIX ?=          /usr/local
LUA_INCLUDE_DIR ?= $(PREFIX)/include
LUA_LIB_DIR ?=     $(PREFIX)/lib/lua/$(LUA_VERSION)
INSTALL ?= install

.PHONY: all install

all: ;

install: all
	$(INSTALL) -d $(DESTDIR)/$(LUA_LIB_DIR)/osm
	$(INSTALL) -d $(DESTDIR)/$(LUA_LIB_DIR)/osm/data
	$(INSTALL) osm/*.lua $(DESTDIR)/$(LUA_LIB_DIR)/osm
	$(INSTALL) osm/data/*.lua $(DESTDIR)/$(LUA_LIB_DIR)/osm/data

