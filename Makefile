PREFIX ?= /usr/local
ARCH=$(shell uname -m)

CC ?= gcc
AR ?= ar
CFLAGS ?= -O3 --fast-math
INCLUDE ?= -I src/luajit/src
LDADD = -lm -ldl

LUA_VERSION ?= luajit-2.1
LUA_INCLUDE ?= -I /usr/include/$(LUA_VERSION)
LUA_LDADD ?= /usr/lib/x86_64-linux-gnu/libluajit-5.1.a

MUSL_LDADD ?= /usr/lib/${ARCH}-linux-musl/libc.a

all: devuan-luajit-shared

luajit:
	make -C src/luajit CC=$(CC) CFLAGS="$(CFLAGS)"


luajit-win:
	make -C src/luajit HOST_CC=gcc CC=$(CC) CFLAGS="$(CFLAGS)" TARGET_SYS=Windows

luastatic:
	make -C src

# luajit -b src/harvest.lua src/harvest.luac
# CC="" luastatic src/harvest.luac src/cliargs/*.lua src/lfs.a src/cliargs.lua 
# rm src/harvest.luac

lfs:
	$(CC) -c $(LUA_INCLUDE) -O3 --fast-math src/lfs.c -o src/lfs.o
	$(AR) rcs src/lfs.a src/lfs.o

devuan-luajit-shared: lfs luastatic
	$(CC) -o harvest $(CFLAGS) $(LUA_INCLUDE) src/harvest.luac.c src/lfs.a $(LUA_LDADD) $(LDADD)

devuan-luajit-static: LUA_LDADD = src/luajit/src/libluajit.a
devuan-luajit-static: LUA_INCLUDE = -Isrc/luajit/src
devuan-luajit-static: CC = musl-gcc
devuan-luajit-static: CFLAGS = -Os -static
devuan-luajit-static: lfs luastatic luajit
	$(CC) -static -o harvest $(CFLAGS) $(LUA_INCLUDE) src/harvest.luac.c src/lfs.a $(LUA_LDADD) $(MUSL_LDADD) -static -lm

mingw32-luajit-static: CC=x86_64-w64-mingw32-gcc
mingw32-luajit-static: AR=x86_64-w64-mingw32-ar
mingw32-luajit-static: LUA_INCLUDE = -I src/luajit/src
mingw32-luajit-static: LUA_LDADD = src/luajit/src/libluajit.a
mingw32-luajit-static: LDLIBS=-lm
mingw32-luajit-static: lfs luastatic luajit-win
	$(CC) -static -o harvest.exe $(CFLAGS) $(LUA_INCLUDE) src/harvest.luac.c src/lfs.a $(LUA_LDADD)

win32: mingw32-luajit-static

install:
	install -p harvest $(DESTDIR)$(PREFIX)/bin/harvest

clean-luajit:
	make -C src/luajit clean

clean:
	rm src/*.o src/*.a

# install:
# 	install -d $(PREFIX)/share/harvest/file-extension-list/render/
# 	install -p file-extension-list/render/file-extension-parser.zsh \
#       $(PREFIX)/share/harvest/file-extension-list/render/file-extension-parser.zsh
# 	install -d $(PREFIX)/share/harvest/zuper/
# 	install -p zuper/zuper      $(PREFIX)/share/harvest/zuper/zuper
# 	install -p zuper/zuper.init $(PREFIX)/share/harvest/zuper/zuper.init
# 	install -p harvest             $(PREFIX)/bin/harvest

