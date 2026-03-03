/datum/controller/subsystem/title_bm/proc/_on_enter_pregame()
	SIGNAL_HANDLER
	addtimer(CALLBACK(src, PROC_REF(change_image)), 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(_auto_rotate_backgrounds)), 45 SECONDS, TIMER_LOOP)
	addtimer(CALLBACK(src, PROC_REF(update_player_counts_all)), 5 SECONDS, TIMER_LOOP)

/datum/controller/subsystem/title_bm/proc/_auto_rotate_backgrounds()
	if(current_image)
		return
	if(!LAZYLEN(sfw_images) && !LAZYLEN(nsfw_images))
		return
	for(var/mob/dead/new_player/player in GLOB.new_player_list)
		if(player.spawning || player.new_character || !player.bm_lobby_ready || !player.client)
			continue
		INVOKE_ASYNC(player, TYPE_PROC_REF(/mob/dead/new_player, bm_push_background))

/datum/controller/subsystem/title_bm/proc/_on_enter_setting_up()
	SIGNAL_HANDLER
	addtimer(CALLBACK(src, PROC_REF(_refresh_all_lobby_html)), 0.5 SECONDS)

/datum/controller/subsystem/title_bm/proc/_refresh_all_lobby_html()
	for(var/mob/dead/new_player/player in GLOB.new_player_list)
		if(player.spawning || player.new_character)
			continue
		if(!player.client)
			continue
		INVOKE_ASYNC(player, TYPE_PROC_REF(/mob/dead/new_player, bm_update_lobby_html))

