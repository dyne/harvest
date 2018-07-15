PREFIX ?= /usr/local

all:
	make -C file-extension-list/render

install:
	install -d $(PREFIX)/share/harvest/file-extension-list/render/
	install -p file-extension-list/render/file-extension-parser.zsh \
      $(PREFIX)/share/harvest/file-extension-list/render/file-extension-parser.zsh
	install -d $(PREFIX)/share/harvest/zuper/
	install -p zuper/zuper      $(PREFIX)/share/harvest/zuper/zuper
	install -p zuper/zuper.init $(PREFIX)/share/harvest/zuper/zuper.init
	install -p harvest             $(PREFIX)/bin/harvest

