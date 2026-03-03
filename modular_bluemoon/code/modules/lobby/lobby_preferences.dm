/datum/preferences
	var/bm_lobby_show_nsfw = FALSE
	var/bm_lobby_button_style = BM_BUTTON_STYLE_BM

/datum/preferences/save_preferences(bypass_cooldown = FALSE, silent = FALSE)
	. = ..()
	if(!istype(., /savefile))
		return FALSE
	WRITE_FILE(.["bm_lobby_show_nsfw"], bm_lobby_show_nsfw)
	WRITE_FILE(.["bm_lobby_button_style"], bm_lobby_button_style)

/datum/preferences/load_preferences(bypass_cooldown = FALSE)
	. = ..()
	if(!istype(., /savefile))
		return FALSE
	.["bm_lobby_show_nsfw"] >> bm_lobby_show_nsfw
	.["bm_lobby_button_style"] >> bm_lobby_button_style
	if(isnull(bm_lobby_show_nsfw))
		bm_lobby_show_nsfw = FALSE
	if(!bm_lobby_button_style || !(bm_lobby_button_style in list(BM_BUTTON_STYLE_TG, BM_BUTTON_STYLE_BM)))
		bm_lobby_button_style = BM_BUTTON_STYLE_BM
