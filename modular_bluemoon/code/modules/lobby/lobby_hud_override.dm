/mob/dead/new_player/create_mob_hud()
	return

/mob/dead/new_player/new_player_panel()
	return

/mob/dead/new_player/create_character(transfer_after)
	bm_hide_lobby()
	return ..(transfer_after)

/mob/dead/new_player/transfer_character(late_transfer)
	. = ..(late_transfer)
	if(.)
		bm_hide_lobby()

/mob/dead/new_player/close_spawn_windows()
	bm_hide_lobby()
	return ..()

/mob/dead/new_player/Logout()
	bm_hide_lobby()
	return ..()

/mob/dead/new_player/reset_menu_hud()
	set hidden = 1

/client/playtitlemusic(vol = 85)
	set waitfor = FALSE
	if(!istype(mob, /mob/dead/new_player))
		return ..()

	if(!(prefs?.toggles & SOUND_LOBBY))
		return

	var/music_deadline = world.time + 30 SECONDS
	UNTIL(SSticker?.login_music || world.time >= music_deadline)
	var/music_path = SSticker?.login_music
	if(!music_path || !fexists(music_path))
		return

	// Название трека
	var/track_name = music_path
	var/last_slash = findlasttext(track_name, "/")
	if(last_slash)
		track_name = copytext(track_name, last_slash + 1)
	var/dot_pos = findlasttext(track_name, ".")
	if(dot_pos > 1)
		track_name = copytext(track_name, 1, dot_pos)
	track_name = replacetext(replacetext(track_name, "_", " "), "-", " ")

	var/mob/dead/new_player/player = mob
	player.bm_lobby_music_path = music_path
	player.bm_lobby_track_name = track_name

	// Ждём пока HTML-лобби готово
	var/lobby_deadline = world.time + 60 SECONDS
	UNTIL(player.bm_lobby_ready || !player.client || world.time >= lobby_deadline)
	if(!player.client)
		return

	bm_push_lobby_music()

//  Отправляет текущую музыку в HTML5-плеер лобби.

/client/proc/bm_push_lobby_music()
	var/mob/dead/new_player/player = mob
	if(!istype(player))
		return
	var/music_path = player.bm_lobby_music_path
	var/track_name = player.bm_lobby_track_name
	if(!music_path)
		music_path = SSticker?.login_music
	if(!music_path || !fexists(music_path))
		return
	if(!track_name && music_path)
		track_name = music_path
		var/last_slash = findlasttext(track_name, "/")
		if(last_slash)
			track_name = copytext(track_name, last_slash + 1)
		var/dot_pos = findlasttext(track_name, ".")
		if(dot_pos > 1)
			track_name = copytext(track_name, 1, dot_pos)
		track_name = replacetext(replacetext(track_name, "_", " "), "-", " ")
	src << browse(fcopy_rsc(music_path), "file=bm_lobby_music.ogg;display=0")
	src << output("bm_lobby_music.ogg", "bm_lobby_browser:bm_load_audio")
	if(track_name)
		src << output(track_name, "bm_lobby_browser:bm_set_audio_track")
