@test "Scan test folders" {
	./harvest scan > harvested
}

@test "Test that 2 video folders are found" {
	[ `grep ';audio;' harvested | wc -l` == "2" ]
}
@test "Test that 1 code folder is found" {
	[ `grep ';code;' harvested  | wc -l` == "1" ]
}
@test "Test that 1 video folder is found" {
	[ `grep ';video;' harvested  | wc -l` == "1" ]
}
@test "Test that 1 text folder is found" {
	[ `grep ';text;' harvested  | wc -l` == "1" ]
}
