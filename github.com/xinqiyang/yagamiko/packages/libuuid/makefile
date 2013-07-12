CC      := gcc
LD      := ld
CFLAGS  := -fPIC -fno-stack-protector
LIB		:= -luuid
LDFLAGS := -shared 
SOURCE  := $(wildcard *.c)
OBJS    := $(patsubst %.c,%.o,$(SOURCE))
TARGET_LIB := libuuidx.so

all:$(OBJS)
	@echo $(OBJS)
	$(LD) $(LDFLAGS) $(LIB) -o $(TARGET_LIB) $(OBJS) 
	@rm *.o -rf

%.o:%.c
	@echo Compiling $< ...
	@$(CC) -c $(CFLAGS)  $< -o $*.o

.PHONY: clean

clean:
	rm *.so *.o -rf
