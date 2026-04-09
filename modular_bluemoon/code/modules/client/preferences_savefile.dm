/datum/preferences/proc/bluemoon_character_pref_load(savefile/S) //TODO: modularize our other savefile edits... maybe?
	S["pda_style"] >> pda_style
	S["pda_color"] >> pda_color
	S["pda_skin"] >> pda_skin
	S["pda_ringtone"] >> pda_ringtone

	S["silicon_lawset"] >> silicon_lawset
	S["body_weight"] >> body_weight
	S["normalized_size"] >> features["normalized_size"]
	S["custom_laugh"] >> custom_laugh

	pda_style = sanitize_inlist(pda_style, GLOB.pda_styles, initial(pda_style))
	pda_color = sanitize_hexcolor(pda_color, 6, 1, initial(pda_color))
	pda_skin = sanitize_inlist(pda_skin, GLOB.pda_reskins, PDA_SKIN_ALT)
	pda_ringtone = sanitize_inlist(pda_ringtone, GLOB.pda_ringtone_list, "beep")

	silicon_lawset = sanitize_inlist(silicon_lawset, CONFIG_GET(keyed_list/choosable_laws), null)
	body_weight = sanitize_inlist(body_weight, GLOB.mob_sizes, NAME_WEIGHT_NORMAL)
	features["normalized_size"] = sanitize_num_clamp(features["normalized_size"], 0.81, 1.2, 1)
	custom_laugh = sanitize_inlist(custom_laugh, GLOB.mob_laughs, "Default")

/datum/preferences/proc/bluemoon_character_pref_save(savefile/S) //TODO: modularize our other savefile edits... maybe?
	WRITE_FILE(S["pda_style"], pda_style)
	WRITE_FILE(S["pda_color"], pda_color)
	WRITE_FILE(S["pda_skin"], pda_skin)
	WRITE_FILE(S["pda_ringtone"], pda_ringtone)

	WRITE_FILE(S["silicon_lawset"], silicon_lawset)
	WRITE_FILE(S["body_weight"], body_weight)
	WRITE_FILE(S["normalized_size"], features["normalized_size"])
	WRITE_FILE(S["custom_laugh"], custom_laugh)

/obj/item/modular_computer/pda/proc/update_style(client/C)
	// Legacy compat — uses the new PDA prefs system for theme and ringtone
	update_pda_prefs(C)

/datum/preferences
	var/list/favorite_tracks = list()

	//Ключем будет имя плейлиста, а значением, лист с треками. Пример:
	//playlists = list("Первый" = list("song1", song2), "Второй" = list("song2", "song3"))
	var/list/playlists = list()
	var/list/favorite_paintings_md5 = list()

/datum/preferences/save_preferences()
	. = ..()
	if(!istype(., /savefile))
		return FALSE
	WRITE_FILE(.["favorite_tracks"], favorite_tracks)
	WRITE_FILE(.["playlists"], playlists)
	WRITE_FILE(.["favorite_paintings_md5"], favorite_paintings_md5)

/datum/preferences/load_preferences()
	. = ..()
	if(!istype(., /savefile))
		return FALSE
	.["favorite_tracks"] >> favorite_tracks
	favorite_tracks = SANITIZE_LIST(favorite_tracks)

	.["favorite_paintings_md5"] >> favorite_paintings_md5
	favorite_paintings_md5 = SANITIZE_LIST(favorite_paintings_md5)

	.["playlists"] >> playlists
	playlists = SANITIZE_LIST(playlists)

/datum/preferences/update_preferences(current_version, savefile/S)
	// Citadel added a new bitfield to toggles, we need to push our prefs forward starting from the last bit
	if(current_version < 61)
		if(CHECK_BITFIELD(toggles, VERB_CONSENT))
			ENABLE_BITFIELD(toggles, RANGED_VERBS_CONSENT)
	. = ..()
