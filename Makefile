PREFIX ?= /usr/local

all:
	make -C file-extension-list/render

install:
	install -D -p file-extension-list/render/file-extension-parser.zsh \
      $(PREFIX)/share/harvest/file-extension-list/render/file-extension-parser.zsh
	install -D -p zuper/zuper      $(PREFIX)/share/harvest/zuper/zuper
	install -D -p zuper/zuper.init $(PREFIX)/share/harvest/zuper/zuper.init
	install -p harvest             $(PREFIX)/bin/harvest

