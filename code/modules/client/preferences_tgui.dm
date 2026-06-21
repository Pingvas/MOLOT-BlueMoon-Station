/datum/preferences/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GamePreferences")
		ui.title = "Настройки"
		ui.open()

/datum/preferences/ui_status(mob/user, datum/tgui/ui)
	return UI_INTERACTIVE

/datum/preferences/ui_state(mob/user)
	return GLOB.self_state

/datum/preferences/ui_data(mob/user)
	. = list()
	.["hotkeys"] = hotkeys

	// Sound toggles
	.["sound_lobby"] = !!(toggles & SOUND_LOBBY)
	.["sound_midi"] = !!(toggles & SOUND_MIDI)
	.["sound_instruments"] = !!(toggles & SOUND_INSTRUMENTS)
	.["sound_jukeboxes"] = !!(toggles & SOUND_JUKEBOXES)
	.["sound_personal_jukeboxes"] = !!(toggles & SOUND_PERSONAL_JUKEBOXES)
	.["sound_ambience"] = !!(toggles & SOUND_AMBIENCE)
	.["sound_ship_ambience"] = !!(toggles & SOUND_SHIP_AMBIENCE)
	.["sound_announcements"] = !!(toggles & SOUND_ANNOUNCEMENTS)
	.["sound_bark"] = !!(toggles & SOUND_BARK)
	.["sound_prayers"] = !!(toggles & SOUND_PRAYERS)
	.["sound_adminhelp"] = !!(toggles & SOUND_ADMINHELP)

	// Graphics toggles
	.["parallax"] = parallax
	.["ambient_occlusion"] = ambientocclusion
	.["widescreen"] = widescreenpref
	.["fullscreen"] = fullscreen
	.["fit_viewport"] = auto_fit_viewport
	.["clientfps"] = clientfps
	.["outline_enabled"] = outline_enabled
	.["screentip_pref"] = !!(screentip_pref)
	.["screentip_images"] = screentip_images
	.["tgui_fancy"] = tgui_fancy
	.["tgui_lock"] = tgui_lock
	.["chat_on_map"] = chat_on_map
	.["chat_on_map_looc"] = chat_on_map_looc
	.["see_chat_non_mob"] = see_chat_non_mob
	.["see_rc_emotes"] = see_rc_emotes
	.["hud_button_flashes"] = hud_toggle_flash

	// Chat toggles
	.["chat_ooc"] = !!(chat_toggles & CHAT_OOC)
	.["chat_looc"] = !!(chat_toggles & CHAT_LOOC)
	.["chat_ghostears"] = !!(chat_toggles & CHAT_GHOSTEARS)
	.["chat_ghostsight"] = !!(chat_toggles & CHAT_GHOSTSIGHT)
	.["chat_ghostwhisper"] = !!(chat_toggles & CHAT_GHOSTWHISPER)
	.["chat_ghostpda"] = !!(chat_toggles & CHAT_GHOSTPDA)
	.["chat_ghostradio"] = !!(chat_toggles & CHAT_GHOSTRADIO)
	.["chat_dead"] = !!(chat_toggles & CHAT_DEAD)
	.["chat_prayer"] = !!(chat_toggles & CHAT_PRAYER)
	.["chat_radio"] = !!(chat_toggles & CHAT_RADIO)
	.["chat_pullr"] = !!(chat_toggles & CHAT_PULLR)
	.["chat_bankcard"] = !!(chat_toggles & CHAT_BANKCARD)
	.["windowflashing"] = windowflashing
	.["windownoise"] = windownoise

	// Gameplay toggles
	.["no_antag"] = !!(toggles & NO_ANTAG)
	.["midround_antag"] = !!(toggles & MIDROUND_ANTAG)
	.["deathrattle"] = !(toggles & DISABLE_DEATHRATTLE)
	.["arrivalrattle"] = !(toggles & DISABLE_ARRIVALRATTLE)
	.["intent_style"] = !!(toggles & INTENT_STYLE)
	.["action_buttons_hide"] = action_buttons_hide_on_spawn
	.["announce_login"] = !!(toggles & ANNOUNCE_LOGIN)
	.["combohud_lighting"] = !!(toggles & COMBOHUD_LIGHTING)
	.["tg_player_panel"] = !!(toggles & TG_PLAYER_PANEL)

	// Gameplay: victim & combat
	.["be_victim"] = be_victim || BEVICTIM_NO
	.["disable_combat_cursor"] = disable_combat_cursor
	.["disable_combat_mouse_lock"] = disable_combat_mouse_lock

	// Screenshake
	.["screenshake"] = screenshake
	.["damage_screenshake"] = damagescreenshake
	.["recoil_push"] = recoil_screenshake

	// Content toggles
	.["verb_consent"] = !!(toggles & VERB_CONSENT)
	.["ranged_verb_pref"] = !!(toggles & RANGED_VERBS_CONSENT)
	.["lewd_verb_sounds"] = !!(toggles & LEWD_VERB_SOUNDS)
	.["arousable"] = arousable
	.["sexknotting"] = sexknotting
	.["genital_examine"] = !!(cit_toggles & GENITAL_EXAMINE)
	.["vore_examine"] = !!(cit_toggles & VORE_EXAMINE)
	.["medihound_sleeper"] = !!(cit_toggles & MEDIHOUND_SLEEPER)
	.["eating_noises"] = !!(cit_toggles & EATING_NOISES)
	.["digestion_noises"] = !!(cit_toggles & DIGESTION_NOISES)
	.["trash_forcefeed"] = !!(cit_toggles & TRASH_FORCEFEED)
	.["forced_fem"] = !!(cit_toggles & FORCED_FEM)
	.["forced_masc"] = !!(cit_toggles & FORCED_MASC)
	.["hypno"] = !!(cit_toggles & HYPNO)
	.["bimbofication"] = !!(cit_toggles & BIMBOFICATION)
	.["breast_enlargement"] = !!(cit_toggles & BREAST_ENLARGEMENT)
	.["penis_enlargement"] = !!(cit_toggles & PENIS_ENLARGEMENT)
	.["butt_enlargement"] = !!(cit_toggles & BUTT_ENLARGEMENT)
	.["belly_inflation"] = !!(cit_toggles & BELLY_INFLATION)
	.["never_hypno"] = !!(cit_toggles & NEVER_HYPNO)
	.["no_aphro"] = !!(cit_toggles & NO_APHRO)
	.["no_ass_slap"] = !!(cit_toggles & NO_ASS_SLAP)
	.["no_auto_wag"] = !!(cit_toggles & NO_AUTO_WAG)
	.["chastity_pref"] = !!(cit_toggles & CHASTITY)
	.["stimulation_pref"] = !!(cit_toggles & STIMULATION)
	.["edging_pref"] = !!(cit_toggles & EDGING)
	.["cum_onto_pref"] = !!(cit_toggles & CUM_ONTO)
	.["sex_jitter"] = !!(cit_toggles & SEX_JITTER)
	.["dance_disco"] = !(cit_toggles & NO_DISCO_DANCE)
	.["tattoopref"] = tattoopref
	.["extremeharm"] = extremeharm
	.["unholypref"] = unholypref
	.["gfluid_blacklist"] = gfluid_blacklist

	// Keybindings
	var/list/kb_list = list()
	var/list/user_binds = list()
	var/list/user_modless_binds = list()
	for (var/key in key_bindings)
		for(var/kb_name in key_bindings[key])
			user_binds[kb_name] += list(key)
	for (var/key in modless_key_bindings)
		user_modless_binds[modless_key_bindings[key]] = key

	for (var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
		var/independent_key = user_modless_binds[kb.name] || null
		var/list/keys = user_binds[kb.name] || list()
		var/list/default_keys = list()
		var/list/dk = hotkeys ? kb.hotkey_keys : kb.classic_keys
		if(LAZYLEN(dk))
			default_keys = dk.Copy()
		kb_list += list(list(
			"name" = kb.name,
			"full_name" = kb.full_name,
			"description" = kb.description,
			"category" = kb.category,
			"keys" = keys,
			"independent_key" = independent_key,
			"default_keys" = default_keys,
			"can_independent" = !kb.special && !kb.clientside,
		))
	.["keybindings"] = kb_list

	if(kb_capture_kb_name)
		var/datum/keybinding/capture_kb = GLOB.keybindings_by_name[kb_capture_kb_name]
		.["kb_capture"] = list(
			"keybinding" = kb_capture_kb_name,
			"old_key" = kb_capture_old_key,
			"independent" = kb_capture_independent,
			"full_name" = capture_kb?.full_name || kb_capture_kb_name,
			"description" = capture_kb?.description,
			"special" = capture_kb?.special || capture_kb?.clientside,
		)
	else
		.["kb_capture"] = null

/datum/preferences/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	var/mob/user = usr
	if(!user?.client)
		return

	switch(action)
		// Sound toggles
		if("toggle_sound")
			var/flag = params["flag"]
			switch(flag)
				if("sound_lobby")
					toggles ^= SOUND_LOBBY
					if(toggles & SOUND_LOBBY)
						if(isnewplayer(user))
							user.client.playtitlemusic()
					else
						user.stop_sound_channel(CHANNEL_LOBBYMUSIC)
				if("sound_midi")
					toggles ^= SOUND_MIDI
					if(!(toggles & SOUND_MIDI))
						user.stop_sound_channel(CHANNEL_ADMIN)
						user.client?.tgui_panel?.stop_music()
				if("sound_instruments")
					toggles ^= SOUND_INSTRUMENTS
				if("sound_jukeboxes")
					toggles ^= SOUND_JUKEBOXES
				if("sound_personal_jukeboxes")
					toggles ^= SOUND_PERSONAL_JUKEBOXES
				if("sound_ambience")
					toggles ^= SOUND_AMBIENCE
					if(!(toggles & SOUND_AMBIENCE))
						SSambience.remove_ambience_client(user.client)
						user.stop_sound_channel(CHANNEL_AMBIENCE)
				if("sound_ship_ambience")
					toggles ^= SOUND_SHIP_AMBIENCE
					if(!(toggles & SOUND_SHIP_AMBIENCE))
						user.stop_sound_channel(CHANNEL_BUZZ)
						user.client.ambience_playing = 0
				if("sound_announcements")
					toggles ^= SOUND_ANNOUNCEMENTS
				if("sound_bark")
					toggles ^= SOUND_BARK
				if("sound_prayers")
					toggles ^= SOUND_PRAYERS
				if("sound_adminhelp")
					toggles ^= SOUND_ADMINHELP
			save_preferences()

		// Graphics toggles
		if("toggle_gfx")
			var/flag = params["flag"]
			switch(flag)
				if("ambient_occlusion")
					ambientocclusion = !ambientocclusion
				if("widescreen")
					widescreenpref = !widescreenpref
					user.client?.view_size.setDefault(getScreenSize(widescreenpref))
				if("fullscreen")
					fullscreen = !fullscreen
					user.client?.ToggleFullscreen()
				if("fit_viewport")
					auto_fit_viewport = !auto_fit_viewport
					user.client?.fit_viewport()
				if("outline_enabled")
					outline_enabled = !outline_enabled
				if("screentip_pref")
					screentip_pref = !screentip_pref
				if("screentip_images")
					screentip_images = !screentip_images
				if("tgui_fancy")
					tgui_fancy = !tgui_fancy
				if("tgui_lock")
					tgui_lock = !tgui_lock
				if("chat_on_map")
					chat_on_map = !chat_on_map
				if("chat_on_map_looc")
					chat_on_map_looc = !chat_on_map_looc
				if("see_chat_non_mob")
					see_chat_non_mob = !see_chat_non_mob
				if("see_rc_emotes")
					see_rc_emotes = !see_rc_emotes
				if("hud_button_flashes")
					hud_toggle_flash = !hud_toggle_flash
			save_preferences()

		if("set_parallax")
			parallax = clamp(text2num(params["value"]), PARALLAX_DISABLE, PARALLAX_INSANE)
			parent?.parallax_holder?.Reset()
			save_preferences()

		// Chat toggles
		if("toggle_chat")
			var/flag = params["flag"]
			switch(flag)
				if("chat_ooc")
					chat_toggles ^= CHAT_OOC
				if("chat_looc")
					chat_toggles ^= CHAT_LOOC
				if("chat_ghostears")
					chat_toggles ^= CHAT_GHOSTEARS
				if("chat_ghostsight")
					chat_toggles ^= CHAT_GHOSTSIGHT
				if("chat_ghostwhisper")
					chat_toggles ^= CHAT_GHOSTWHISPER
				if("chat_ghostpda")
					chat_toggles ^= CHAT_GHOSTPDA
				if("chat_ghostradio")
					chat_toggles ^= CHAT_GHOSTRADIO
				if("chat_dead")
					chat_toggles ^= CHAT_DEAD
				if("chat_prayer")
					chat_toggles ^= CHAT_PRAYER
				if("chat_radio")
					chat_toggles ^= CHAT_RADIO
				if("chat_pullr")
					chat_toggles ^= CHAT_PULLR
				if("chat_bankcard")
					chat_toggles ^= CHAT_BANKCARD
				if("windowflashing")
					windowflashing = !windowflashing
				if("windownoise")
					windownoise = !windownoise
			save_preferences()

		// Gameplay toggles
		if("toggle_gameplay")
			var/flag = params["flag"]
			switch(flag)
				if("no_antag")
					toggles ^= NO_ANTAG
				if("midround_antag")
					toggles ^= MIDROUND_ANTAG
				if("deathrattle")
					toggles ^= DISABLE_DEATHRATTLE
				if("arrivalrattle")
					toggles ^= DISABLE_ARRIVALRATTLE
				if("intent_style")
					toggles ^= INTENT_STYLE
				if("action_buttons_hide")
					action_buttons_hide_on_spawn = !action_buttons_hide_on_spawn
				if("announce_login")
					toggles ^= ANNOUNCE_LOGIN
				if("combohud_lighting")
					toggles ^= COMBOHUD_LIGHTING
				if("tg_player_panel")
					toggles ^= TG_PLAYER_PANEL
				if("disable_combat_cursor")
					disable_combat_cursor = !disable_combat_cursor
				if("disable_combat_mouse_lock")
					disable_combat_mouse_lock = !disable_combat_mouse_lock
			save_preferences()

		if("set_be_victim")
			be_victim = params["value"]
			save_preferences()

		if("set_screenshake")
			var/flag = params["flag"]
			var/value = text2num(params["value"])
			switch(flag)
				if("screenshake")
					screenshake = clamp(value, 0, 100)
				if("damage_screenshake")
					damagescreenshake = clamp(value, 0, 2)
				if("recoil_push")
					recoil_screenshake = clamp(value, 0, 100)
			save_preferences()

		// Content toggles
		if("pref")
			var/pref = params["pref"]
			switch(pref)
				if("verb_consent")
					toggles ^= VERB_CONSENT
				if("ranged_verb_pref")
					toggles ^= RANGED_VERBS_CONSENT
				if("lewd_verb_sounds")
					toggles ^= LEWD_VERB_SOUNDS
				if("arousable")
					arousable = !arousable
				if("sexknotting")
					sexknotting = !sexknotting
				if("genital_examine")
					cit_toggles ^= GENITAL_EXAMINE
				if("vore_examine")
					cit_toggles ^= VORE_EXAMINE
				if("medihound_sleeper")
					cit_toggles ^= MEDIHOUND_SLEEPER
				if("eating_noises")
					cit_toggles ^= EATING_NOISES
				if("digestion_noises")
					cit_toggles ^= DIGESTION_NOISES
				if("trash_forcefeed")
					cit_toggles ^= TRASH_FORCEFEED
				if("forced_fem")
					cit_toggles ^= FORCED_FEM
				if("forced_masc")
					cit_toggles ^= FORCED_MASC
				if("hypno")
					cit_toggles ^= HYPNO
				if("bimbofication")
					cit_toggles ^= BIMBOFICATION
				if("breast_enlargement")
					cit_toggles ^= BREAST_ENLARGEMENT
				if("penis_enlargement")
					cit_toggles ^= PENIS_ENLARGEMENT
				if("butt_enlargement")
					cit_toggles ^= BUTT_ENLARGEMENT
				if("belly_inflation")
					cit_toggles ^= BELLY_INFLATION
				if("never_hypno")
					cit_toggles ^= NEVER_HYPNO
				if("no_aphro")
					cit_toggles ^= NO_APHRO
				if("no_ass_slap")
					cit_toggles ^= NO_ASS_SLAP
				if("no_auto_wag")
					cit_toggles ^= NO_AUTO_WAG
				if("chastity_pref")
					cit_toggles ^= CHASTITY
				if("stimulation_pref")
					cit_toggles ^= STIMULATION
				if("edging_pref")
					cit_toggles ^= EDGING
				if("cum_onto_pref")
					cit_toggles ^= CUM_ONTO
				if("sex_jitter")
					cit_toggles ^= SEX_JITTER
				if("dance_disco")
					cit_toggles ^= NO_DISCO_DANCE
			save_preferences()

		if("set_consent_pref")
			var/pref = params["pref"]
			var/value = params["value"]
			switch(pref)
				if("tattoopref")
					tattoopref = value
				if("extremeharm")
					extremeharm = value
				if("unholypref")
					unholypref = value
			save_preferences()

		// Keybinding actions
		if("toggle_hotkeys")
			hotkeys = !hotkeys
			user.client.ensure_keys_set(src)
			save_preferences()

		if("keybinding_capture")
			var/datum/keybinding/kb = GLOB.keybindings_by_name[params["keybinding"]]
			if(!kb)
				return
			kb_capture_kb_name = kb.name
			kb_capture_old_key = params["old_key"] || "Unbound"
			kb_capture_independent = text2num(params["independent"])
			return

		if("keybinding_cancel")
			ClearKeybindingCapture()
			return

		if("keybindings_set")
			var/datum/keybinding/kb = GLOB.keybindings_by_name[params["keybinding"]]
			if(!kb)
				ClearKeybindingCapture()
				return
			params["special"] = kb.special || kb.clientside
			if(ApplyKeybindingSet(user, params))
				user.client.ensure_keys_set(src)
				save_preferences()
			ClearKeybindingCapture()
			return

		if("keybinding_reset")
			var/choice = tgalert(user, "Выберите стиль раскладки:", "Сброс клавиш", "Горячие клавиши", "Классика", "Отмена")
			if(choice == "Отмена")
				return
			hotkeys = (choice == "Горячие клавиши")
			key_bindings = hotkeys ? deepCopyList(GLOB.hotkey_keybinding_list_by_key) : deepCopyList(GLOB.classic_keybinding_list_by_key)
			modless_key_bindings = list()
			user.client.ensure_keys_set(src)
			save_preferences()

	. = TRUE

/datum/preferences/proc/tgui_or_html_refresh(mob/user)
	if(!user?.client)
		return
	var/datum/tgui/ui = SStgui.get_open_ui(user, src, "GamePreferences")
	if(ui)
		ui.send_update()
	else
		ShowChoices(user)
