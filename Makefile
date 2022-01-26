PREFIX ?= /usr/local
ARCH=$(shell uname -m)

CC ?= gcc
AR ?= ar
CFLAGS ?= -O3 --fast-math

LUA_VERSION ?= luajit-2.1
INCLUDE ?= -I /usr/include/$(LUA_VERSION)
LDADD ?= /usr/lib/x86_64-linux-gnu/libluajit-5.1.a -lm -ldl

MUSL_LDADD ?= /usr/lib/${ARCH}-linux-musl/libc.a

all: shared

shared:
	CC=$(CC) AR=$(AR) INCLUDE="$(INCLUDE)" LDADD="$(LDADD)" CFLAGS="$(CFLAGS)" make -C src
	$(CC) -o harvest $(CFLAGS) $(INCLUDE) src/harvest.luastatic.c src/lfs.a $(LDADD)

static: LDADD = /usr/lib/${ARCH}-linux-gnu/libluajit-5.1.a /usr/lib/${ARCH}-linux-musl/libc.a
static: CC = musl-gcc
static: CFLAGS = -O3 --fast-math -static
static:
	CC=$(CC) AR=$(AR) INCLUDE="$(INCLUDE)" LDADD="$(LDADD)" CFLAGS="$(CFLAGS)" make -C src static
	$(CC) -static -o harvest $(CFLAGS) $(INCLUDE) src/harvest.luastatic.c src/lfs.a $(LDADD) -lm

luajit-win64: CC=x86_64-w64-mingw32-gcc
luajit-win64: AR=x86_64-w64-mingw32-ar
luajit-win64:
	if ! [ -r luajit.tar.gz ]; then curl -L https://luajit.org/download/LuaJIT-2.1.0-beta3.tar.gz > luajit.tar.gz; fi
	if ! [ -d luajit ]; then mkdir -p luajit && tar -C luajit -xf luajit.tar.gz ; fi
	mkdir -p luajit/include && cp -ra luajit/*/src/*.h luajit/include/
	make -C luajit/Lua* HOST_CC=gcc CC=$(CC) CFLAGS="$(CFLAGS)" TARGET_SYS=Windows BUILDMODE=static
	cp luajit/Lua*/src/libluajit.a luajit/

win64: CC=x86_64-w64-mingw32-gcc
win64: AR=x86_64-w64-mingw32-ar
win64: INCLUDE = -I luajit/include
win64: LDADD = luajit/libluajit.a
win64: LDLIBS=-lm
win64: luajit-win64
	CC=$(CC) AR=$(AR) INCLUDE="$(INCLUDE)" LDADD="$(LDADD)" CFLAGS="$(CFLAGS)" make -C src static
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

