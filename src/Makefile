
all:
	luajit -b harvest.lua harvest.luac
	CC="" luastatic harvest.luac cliargs.lua cliargs/*.lua cliargs/utils/*.lua lfs.a 
	rm harvest.luac
