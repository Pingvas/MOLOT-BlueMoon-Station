/datum/controller/subsystem/title_bm/proc/_on_enter_pregame()
	SIGNAL_HANDLER
	_rotate_current_images()  // выбираем случайную картинку один раз при старте прегейма
	change_image(null)
	deltimer(lobby_tick_timer)
	last_online_count = -1
	last_ready_count = -1
	lobby_tick_timer = addtimer(CALLBACK(src, PROC_REF(_lobby_tick)), 15 SECONDS, TIMER_LOOP | TIMER_STOPPABLE)

/datum/controller/subsystem/title_bm/proc/_lobby_tick()
	if(!length(GLOB.new_player_list))
		return
	update_player_counts_all()

/datum/controller/subsystem/title_bm/proc/_on_enter_setting_up()
	SIGNAL_HANDLER
	addtimer(CALLBACK(src, PROC_REF(_refresh_all_lobby_html)), 0.5 SECONDS)

/datum/controller/subsystem/title_bm/proc/_refresh_all_lobby_html()
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(player.spawning || player.new_character)
			continue
		if(!player.client)
			continue
		INVOKE_ASYNC(player, TYPE_PROC_REF(/mob/dead/new_player, bm_update_lobby_html))

