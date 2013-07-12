CC      := gcc
LD      := ld
CFLAGS  := -fPIC
LIB		:= -I/usr/local/luajit/include/luajit-2.0i -liconv
LDFLAGS := -Wall -O2 -shared 
SOURCE  := $(wildcard *.c)
OBJS    := $(patsubst %.c,%.o,$(SOURCE))
TARGET_LIB := ipquery.so

all:$(OBJS)
	@echo $(OBJS)
	$(LD) $(LDFLAGS) $(LIB) -o $(TARGET_LIB) $(OBJS) 
	@rm *.o -rf

%.o:%.c
	@echo Compiling $< ...
	@$(CC) $(LDFLAGS) $(CFLAGS) ip.c ip_lua_bingding.c -o ipquery.so

.PHONY: clean

clean:
	rm *.so *.o -rf
