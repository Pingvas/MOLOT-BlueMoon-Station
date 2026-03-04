/datum/controller/subsystem/title_bm/proc/_on_enter_pregame()
	SIGNAL_HANDLER
	change_image(null)
	deltimer(lobby_tick_timer)
	lobby_tick_count = 0
	last_online_count = -1
	last_ready_count = -1
	lobby_tick_timer = addtimer(CALLBACK(src, PROC_REF(_lobby_tick)), 5 SECONDS, TIMER_LOOP | TIMER_STOPPABLE)

/datum/controller/subsystem/title_bm/proc/_lobby_tick()
	if(!length(GLOB.new_player_list))
		return
	lobby_tick_count++
	update_player_counts_all()
	if(lobby_tick_count % 9 == 0)
		if(!current_image && !current_video_payload && (LAZYLEN(sfw_images) || LAZYLEN(nsfw_images)))
			for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
				if(player.spawning || player.new_character || !player.bm_lobby_ready || !player.client)
					continue
				INVOKE_ASYNC(player, TYPE_PROC_REF(/mob/dead/new_player, bm_push_background))

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

