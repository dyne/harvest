
all:
	$(CC) -c $(INCLUDE) $(CFLAGS) --fast-math lfs.c -o lfs.o
	$(AR) rcs lfs.a lfs.o
	CC="" luastatic harvest.lua cliargs.lua cliargs/*.lua cliargs/utils/*.lua lfs.a 
