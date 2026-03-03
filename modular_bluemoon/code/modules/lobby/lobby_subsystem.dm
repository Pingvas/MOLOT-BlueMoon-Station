SUBSYSTEM_DEF(title_bm)
	name = "BlueMoon Title Screen"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_TITLE - 1

	var/current_image
	var/list/sfw_images = list()
	var/list/nsfw_images = list()
	var/lobby_html = ""
	var/current_notice
	var/loading_image = BM_LOBBY_LOADING_GIF
	var/average_completion_time = BM_LOBBY_DEFAULT_MAP_LOADTIME
	var/progress_reference_time = 0
	var/list/progress_json = list()
	var/rotate_bg_timer
	var/player_count_timer
	var/current_video_payload

/datum/controller/subsystem/title_bm/Initialize()
	if(fexists(BM_LOBBY_HTML_FILE))
		var/full_html = file2text(BM_LOBBY_HTML_FILE)
		var/body_pos = findtext(full_html, "<body")
		if(body_pos)
			var/tag_end = findtext(full_html, ">", body_pos)
			lobby_html = tag_end ? copytext(full_html, 1, tag_end + 1) : full_html
		else
			lobby_html = full_html
	else
		log_game("[name]: Файл [BM_LOBBY_HTML_FILE] не найден! Используется встроенный фолбэк.")
		lobby_html = BM_DEFAULT_LOBBY_HTML_PREAMBLE

	_load_title_images()

	if(fexists(loading_image))
		loading_image = fcopy_rsc(loading_image)
	current_image = loading_image

	_check_progress_reference_time()
	_load_progress_json()

	RegisterSignal(SSticker, COMSIG_TICKER_ENTER_PREGAME, PROC_REF(_on_enter_pregame))
	RegisterSignal(SSticker, COMSIG_TICKER_ENTER_SETTING_UP, PROC_REF(_on_enter_setting_up))

	addtimer(CALLBACK(src, PROC_REF(_refresh_all_lobby_html)), 0.5 SECONDS)

	return SS_INIT_SUCCESS

/datum/controller/subsystem/title_bm/Recover()
	current_image         = SStitle_bm.current_image
	loading_image         = SStitle_bm.loading_image
	sfw_images            = SStitle_bm.sfw_images
	nsfw_images           = SStitle_bm.nsfw_images
	lobby_html            = SStitle_bm.lobby_html
	current_notice        = SStitle_bm.current_notice
	average_completion_time = SStitle_bm.average_completion_time
	progress_reference_time = SStitle_bm.progress_reference_time
	progress_json           = SStitle_bm.progress_json
	current_video_payload = SStitle_bm.current_video_payload

/datum/controller/subsystem/title_bm/proc/_check_progress_reference_time()
	if(!progress_reference_time)
		progress_reference_time = world.timeofday

/datum/controller/subsystem/title_bm/proc/_load_progress_json()
	if(!fexists(BM_LOBBY_PROGRESS_CACHE))
		return
	var/json_text = file2text(BM_LOBBY_PROGRESS_CACHE)
	progress_json = json_decode(json_text)
	if(!islist(progress_json) || progress_json["_version"] != BM_LOBBY_PROGRESS_VERSION)
		progress_json = list()
		return
	var/map_key = SSmapping.config?.map_name || "default"
	var/list/map_info = progress_json[map_key]
	if(!islist(map_info))
		return
	average_completion_time = map_info["total"] || BM_LOBBY_DEFAULT_MAP_LOADTIME

/datum/controller/subsystem/title_bm/proc/_save_progress_json()
	progress_json["_version"] = BM_LOBBY_PROGRESS_VERSION
	var/map_key = SSmapping.config?.map_name || "default"
	var/list/map_info = list()
	if(progress_json[map_key])
		map_info["total"] = 0.75 * average_completion_time + 0.25 * (world.timeofday - progress_reference_time)
	else
		map_info["total"] = world.timeofday - progress_reference_time
	progress_json[map_key] = map_info
	var/F = file(BM_LOBBY_PROGRESS_CACHE)
	fdel(F)
	WRITE_FILE(F, json_encode(progress_json))
	progress_json = null

/datum/controller/subsystem/title_bm/proc/_load_title_images()
	var/list/sfw_files = flist(BM_LOBBY_IMAGES_SFW)
	if(islist(sfw_files))
		for(var/filename in sfw_files)
			if(filename == "exclude" || filename == "blank.png")
				continue
			if(copytext(filename, length(filename)) == "/")
				continue
			var/lower = lowertext(filename)
			if(!findtext(lower, ".png") && !findtext(lower, ".jpg") && !findtext(lower, ".jpeg") && !findtext(lower, ".gif") && !findtext(lower, ".dmi"))
				continue
			var/full_path = "[BM_LOBBY_IMAGES_SFW][filename]"
			if(!fexists(full_path))
				continue
			sfw_images += fcopy_rsc(full_path)

	if(fexists(BM_LOBBY_IMAGES_NSFW))
		var/list/nsfw_files = flist(BM_LOBBY_IMAGES_NSFW)
		if(islist(nsfw_files))
			for(var/filename in nsfw_files)
				if(filename == "exclude" || filename == "blank.png")
					continue
				if(copytext(filename, length(filename)) == "/")
					continue
				var/lower = lowertext(filename)
				if(!findtext(lower, ".png") && !findtext(lower, ".jpg") && !findtext(lower, ".jpeg") && !findtext(lower, ".gif") && !findtext(lower, ".dmi"))
					continue
				var/full_path = "[BM_LOBBY_IMAGES_NSFW][filename]"
				if(!fexists(full_path))
					continue
				nsfw_images += fcopy_rsc(full_path)

/datum/controller/subsystem/title_bm/proc/get_image_for_player(show_nsfw = FALSE)
	if(current_image == loading_image)
		return loading_image
	if(current_image)
		return current_image
	var/list/pool = sfw_images
	if(show_nsfw && LAZYLEN(nsfw_images))
		pool = nsfw_images
	if(!LAZYLEN(pool))
		return BM_LOBBY_DEFAULT_IMAGE
	return pick(pool)

/datum/controller/subsystem/title_bm/proc/set_video(payload)
	current_video_payload = payload
	current_image = null
	for(var/mob/dead/new_player/player in GLOB.new_player_list)
		if(!player.bm_lobby_ready || !player.client)
			continue
		player.client << output(payload, "bm_lobby_browser:bm_set_background")

/datum/controller/subsystem/title_bm/proc/change_image(file_or_icon)
	current_video_payload = null
	if(file_or_icon)
		current_image = file_or_icon
	else
		current_image = null

	if(progress_json && SSticker?.current_state == GAME_STATE_PREGAME)
		_save_progress_json()

	// Готовым — только меняем картинку через JS (без перезагрузки HTML → музыка не прерывается)
	// Не готовым — полный показ лобби с нуля
	for(var/mob/dead/new_player/player in GLOB.new_player_list)
		if(player.spawning || player.new_character)
			continue
		if(player.bm_lobby_ready)
			INVOKE_ASYNC(player, TYPE_PROC_REF(/mob/dead/new_player, bm_push_background))
		else
			INVOKE_ASYNC(player, TYPE_PROC_REF(/mob/dead/new_player, bm_show_lobby))

/datum/controller/subsystem/title_bm/proc/show_to_all()
	for(var/mob/dead/new_player/player in GLOB.new_player_list)
		if(player.spawning || player.new_character)
			continue
		INVOKE_ASYNC(player, TYPE_PROC_REF(/mob/dead/new_player, bm_show_lobby))

/datum/controller/subsystem/title_bm/proc/set_notice(notice_text)
	current_notice = notice_text ? sanitize_text(notice_text) : null
	var/safe_notice = current_notice ? replacetext(current_notice, "'", "\\'") : ""
	var/toast_type = current_notice ? "'error'" : "'info'"
	for(var/mob/dead/new_player/player in GLOB.new_player_list)
		if(!player.bm_lobby_ready || !player.client)
			continue
		player.client << output("'[safe_notice]',[toast_type]", "bm_lobby_browser:bm_show_notice")

/datum/controller/subsystem/title_bm/proc/update_character_name(mob/dead/new_player/user, name)
	if(!(istype(user) && user.bm_lobby_ready && user.client))
		return
	user.client << output(name, "bm_lobby_browser:bm_update_character")

/datum/controller/subsystem/title_bm/proc/push_player_count_to(mob/dead/new_player/player)
	if(!(istype(player) && player.bm_lobby_ready && player.client))
		return
	var/online = length(GLOB.new_player_list)
	var/ready = 0
	for(var/mob/dead/new_player/p in GLOB.new_player_list)
		if(p.ready)
			ready++
	player.client << output("[online],[ready]", "bm_lobby_browser:bm_update_counts")

/datum/controller/subsystem/title_bm/proc/update_player_counts_all()
	var/online = length(GLOB.new_player_list)
	var/ready = 0
	for(var/mob/dead/new_player/p in GLOB.new_player_list)
		if(p.ready)
			ready++
	for(var/mob/dead/new_player/player in GLOB.new_player_list)
		if(!player.bm_lobby_ready || !player.client)
			continue
		player.client << output("[online],[ready]", "bm_lobby_browser:bm_update_counts")
