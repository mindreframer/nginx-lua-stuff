MODNAME= httpclient

INSTALL ?= install

.PHONY: all test install

all: ;

install:
	$(INSTALL) lib/resty/$(MODNAME).lua $< `lua installpath.lua $(MODNAME).lua`

