PREFIX ?= /usr/local
ARCH=$(shell uname -m)

CC ?= gcc
AR ?= ar
CFLAGS ?= -O3 --fast-math

LUA_VERSION ?= luajit-2.1
INCLUDE ?= -I /usr/include/$(LUA_VERSION)
LDADD ?= /usr/lib/x86_64-linux-gnu/libluajit-5.1.a -lm -ldl

MUSL_LDADD ?= /usr/lib/${ARCH}-linux-musl/libc.a

all: devuan-luajit-shared

luajit:
	make -C src/luajit CC=$(CC) CFLAGS="$(CFLAGS)"


luajit-win:
	make -C src/luajit HOST_CC=gcc CC=$(CC) CFLAGS="$(CFLAGS)" TARGET_SYS=Windows

luastatic:
	CC=$(CC) AR=$(AR) INCLUDE="$(INCLUDE)" LDADD="$(LDADD)" CFLAGS="$(CFLAGS)" make -C src

devuan-luajit-shared: luastatic
	$(CC) -o harvest $(CFLAGS) $(INCLUDE) src/harvest.luastatic.c src/lfs.a $(LDADD)

devuan-luajit-static: LDADD = src/luajit/src/libluajit.a /usr/lib/${ARCH}-linux-musl/libc.a
devuan-luajit-static: INCLUDE = -I luajit/src
devuan-luajit-static: CC = musl-gcc
devuan-luajit-static: CFLAGS = -Os -static
devuan-luajit-static: luastatic luajit
	$(CC) -static -o harvest $(CFLAGS) -I src/luajit/src src/harvest.luastatic.c src/lfs.a $(LDADD) -lm

mingw32-luajit-static: CC=x86_64-w64-mingw32-gcc
mingw32-luajit-static: AR=x86_64-w64-mingw32-ar
mingw32-luajit-static: INCLUDE = -I luajit/src
mingw32-luajit-static: LDADD = src/luajit/src/libluajit.a
mingw32-luajit-static: LDLIBS=-lm
mingw32-luajit-static: luastatic luajit-win
	$(CC) -static -o harvest.exe $(CFLAGS) $(INCLUDE) src/harvest.luastatic.c src/lfs.a $(LDADD)

win32: mingw32-luajit-static

install:
	install -p harvest $(DESTDIR)$(PREFIX)/bin/harvest

clean-luajit:
	make -C src/luajit clean

clean:
	rm -f src/*.o src/*.a
	rm -f src/harvest.luastatic.c

# install:
# 	install -d $(PREFIX)/share/harvest/file-extension-list/render/
# 	install -p file-extension-list/render/file-extension-parser.zsh \
#       $(PREFIX)/share/harvest/file-extension-list/render/file-extension-parser.zsh
# 	install -d $(PREFIX)/share/harvest/zuper/
# 	install -p zuper/zuper      $(PREFIX)/share/harvest/zuper/zuper
# 	install -p zuper/zuper.init $(PREFIX)/share/harvest/zuper/zuper.init
# 	install -p harvest             $(PREFIX)/bin/harvest

