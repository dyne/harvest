CFLAGS += $(shell pkg-config luajit --cflags)

SOURCES = harvest.lua \
	cliargs.lua cliargs/*.lua cliargs/utils/*.lua \
	align.lua

all:
	$(CC) -c $(INCLUDE) $(CFLAGS) lfs.c -o lfs.o
	$(AR) rcs lfs.a lfs.o
	CC="" luastatic $(SOURCES) lfs.a
	$(CC) -c $(INCLUDE) $(CFLAGS) harvest.luastatic.c


static:
	$(CC) -c $(INCLUDE) $(CFLAGS) lfs.c -o lfs.o
	$(AR) rcs lfs.a lfs.o
	-CC="" luastatic $(SOURCES) lfs.a -static $(INCLUDES)
	$(CC) -c $(INCLUDE) $(CFLAGS) harvest.luastatic.c
