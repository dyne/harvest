
setup_suite() {
	mkdir -p /tmp/harvest_test
	cp ../harvest /tmp/harvest_test
	cd  /tmp/harvest_test
	mkdir -p bob_dylan
	touch bob_dylan/desolation_row.mp3
	touch bob_dylan/blowin_in_the_wind.wav
	touch bob_dylan/hurricane.flac
	touch bob_dylan/mr_tamburine_man.mp3
	touch bob_dylan/README.nfo

	mkdir -p bob_marley
	touch bob_marley/woman_no_cry.mp3
	touch bob_marley/buffalo_soldier.ogg
	touch bob_marley/redemption_song.ogg
	touch bob_marley/get_up_stand_up.flac
	touch bob_marley/README.nfo

	mkdir -p herzog
	touch herzog/aguirre.mp4
	touch herzog/fitzcarraldo.avi
	touch herzog/invincible.divx
	touch herzog/fata_morgana.mp4

	mkdir -p nice_books
	touch nice_books/das_kapital.txt
	touch nice_books/jungle_book.pdf
	touch nice_books/versetti_satanici.docx
	touch nice_books/README.md

	mkdir -p zenroom
	touch zenroom/erlang.c
	touch zenroom/encoding.c
	touch zenroom/base58.c
	touch zenroom/zenroom_jni.c
	touch zenroom/test.c
	touch zenroom/segwit_addr.c
	touch zenroom/rmd160.c
	touch zenroom/zen_libc.c
	touch zenroom/lua_functions.c
	touch zenroom/repl.c
	touch zenroom/randombytes.c
	touch zenroom/zen_parse.c
	touch zenroom/lua_modules.c
	touch zenroom/zen_memory.c
	touch zenroom/cortex_m.c
	touch zenroom/cli.c
	touch zenroom/mutt_sprintf.c
	touch zenroom/lua_shims.c
	touch zenroom/api_hash.c
	touch zenroom/zen_random.c
	touch zenroom/zen_config.c
	touch zenroom/zenroom.c
	touch zenroom/zen_qp.c
	touch zenroom/zen_octet.c
	touch zenroom/zen_io.c
	touch zenroom/zen_fp12.c
	touch zenroom/zen_float.c
	touch zenroom/zen_error.c
	touch zenroom/zen_ed.c
	touch zenroom/zen_ecp.c
	touch zenroom/zen_ecp2.c
	touch zenroom/zen_ecdh.c
	touch zenroom/zen_big.c
	touch zenroom/zen_aes.c
	touch zenroom/zen_hash.c
	touch zenroom/zen_ecdh_factory.c
	touch zenroom/lualibs_detected.c
}

teardown_suite() {
	rm -rf /tmp/harvest_test
}
