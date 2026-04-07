/**
 * TGui-based Character Setup UI
 * Replaces the legacy HTML-based ShowChoices() interface
 */

/datum/character_setup_ui
	/// The client that owns this UI
	var/client/owner
	/// Reference to the preferences datum
	var/datum/preferences/prefs
	/// Native character preview (map_view screen object)
	// REMOVED — теперь используем getFlatIcon() + кэш base64 через prefs.preview_dir_b64_cache
	// (character_preview_view удалён — не нужно выделять map-зону на сервере для каждого игрока)
	/// Cached character slot data (tainted_character_profiles pattern from SPLURT)
	var/list/cached_slots
	/// Whether slot cache needs rebuilding
	var/tainted_slots = TRUE
	/// Barkbox spawned for preview_bark — stored so it can be cleaned up on close
	var/atom/movable/preview_barkbox

/datum/character_setup_ui/New(client/C)
	if(!C)
		qdel(src)
		return
	owner = C
	prefs = C.prefs

/datum/character_setup_ui/Destroy()
	QDEL_NULL(preview_barkbox)
	if(owner)
		owner.character_setup = null
	owner = null
	prefs = null
	return ..()

/datum/character_setup_ui/ui_state(mob/user)
	// Only accessible from lobby (new_player mob) or by admins — prevents editing character mid-round
	return GLOB.new_player_state

/datum/character_setup_ui/ui_close(mob/user)
	prefs?.save_character()
	prefs?.save_preferences()
	QDEL_NULL(preview_barkbox)
	// Персистентный манекен и кэш остаются до следующего открытия меню

/datum/character_setup_ui/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/chat),
		get_asset_datum(/datum/asset/spritesheet/loadout_items),
	)

/datum/character_setup_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CharacterSetup")
		ui.set_autoupdate(FALSE)
		ui.open()
		// Запускаем асинхронную генерацию превью при первом открытии
		if(prefs && !LAZYLEN(prefs.preview_dir_b64_cache))
			prefs.update_preview_icon()

/// Find a gear datum by its type path string (e.g. "/datum/gear/accessory/tie")
/datum/character_setup_ui/proc/find_gear_by_type(gear_type_path)
	for(var/cat in GLOB.loadout_items)
		for(var/subcat in GLOB.loadout_items[cat])
			for(var/item_name in GLOB.loadout_items[cat][subcat])
				var/datum/gear/G = GLOB.loadout_items[cat][subcat][item_name]
				if("[G.type]" == gear_type_path)
					return G
	return null

/datum/character_setup_ui/ui_static_data(mob/user)
	var/list/data = list()

	// Species list
	var/list/species_list = list()
	for(var/species_id in GLOB.roundstart_races)
		if(!species_id || !ispath(species_id))
			continue
		try
			var/datum/species/S = new species_id()
			species_list += list(list(
				"id" = S.id,
				"name" = S.name,
				"sexes" = S.sexes,
				"use_skintones" = S.use_skintones,
			))
			qdel(S)
		catch
			continue
	data["species_list"] = species_list

	// Hair styles
	var/list/hair_styles = list()
	for(var/style in GLOB.hair_styles_list)
		hair_styles += style
	data["hair_styles"] = hair_styles

	// Facial hair styles
	var/list/facial_hair_styles = list()
	for(var/style in GLOB.facial_hair_styles_list)
		facial_hair_styles += style
	data["facial_hair_styles"] = facial_hair_styles

	// Gradient styles
	var/list/grad_styles = list()
	for(var/style in GLOB.hair_gradients_list)
		grad_styles += style
	data["grad_styles"] = grad_styles

	// Underwear
	var/list/underwear_list = list()
	for(var/underwear in GLOB.underwear_list)
		underwear_list += underwear
	data["underwear_list"] = underwear_list

	// Undershirt
	var/list/undershirt_list = list()
	for(var/undershirt in GLOB.undershirt_list)
		undershirt_list += undershirt
	data["undershirt_list"] = undershirt_list

	// Socks
	var/list/socks_list = list()
	for(var/socks in GLOB.socks_list)
		socks_list += socks
	data["socks_list"] = socks_list

	// Background states
	var/list/bg_list = list()
	for(var/bg in list("000", "midgrey", "FFF", "white", "steel", "techmaint", "dark", "plating", "reinforced"))
		bg_list += bg
	data["bg_list"] = bg_list

	// Custom names
	var/list/custom_name_types = list()
	for(var/custom_name_id in GLOB.preferences_custom_names)
		var/namedata = GLOB.preferences_custom_names[custom_name_id]
		custom_name_types += list(list(
			"id" = custom_name_id,
			"label" = namedata["pref_name"],
			"group" = namedata["group"],
		))
	data["custom_name_types"] = custom_name_types

	// Eye types
	var/list/eye_types = list()
	for(var/eye in GLOB.eye_types)
		eye_types += eye
	data["eye_types"] = eye_types

	// Mutant parts
	var/list/mutant_parts_data = list()
	for(var/part in GLOB.all_mutant_parts)
		if(part == "mam_body_markings")
			continue
		var/list/styles = list()
		var/ref_list = GLOB.mutant_reference_list[part]
		if(ref_list)
			for(var/style_name in ref_list)
				styles += style_name
		mutant_parts_data += list(list(
			"id" = part,
			"label" = GLOB.all_mutant_parts[part],
			"styles" = styles,
			"color_type" = GLOB.colored_mutant_parts[part],
		))
	data["mutant_parts"] = mutant_parts_data

	// Bark sounds
	var/list/bark_list = list()
	for(var/bark in GLOB.bark_random_list)
		bark_list += bark
	data["bark_list"] = bark_list

	// Max save slots
	data["max_save_slots"] = prefs.max_save_slots

	// Config flags
	data["roundstart_traits"] = CONFIG_GET(flag/roundstart_traits)
	data["allow_silicon_choosing_laws"] = CONFIG_GET(flag/allow_silicon_choosing_laws)

	// === QUIRKS INFO (static) ===
	var/list/quirks_info = list()
	for(var/qname in SSquirks.quirks)
		var/datum/quirk/Q = SSquirks.quirks[qname]
		var/qpath = Q
		if(ispath(qpath))
			Q = new qpath()
		var/qpoints = SSquirks.quirk_points[qname]
		var/qcategory = "Neutral"
		if(qpoints > 0)
			qcategory = "Positive"
		else if(qpoints < 0)
			qcategory = "Negative"
		var/list/conflicts = list()
		for(var/list/conflict_pair in SSquirks.quirk_blacklist)
			if(qname in conflict_pair)
				for(var/cname in conflict_pair)
					if(cname != qname)
						conflicts += cname
		quirks_info += list(list(
			"name" = qname,
			"description" = Q.desc,
			"value" = qpoints,
			"category" = qcategory,
			"conflicts" = conflicts,
		))
		if(ispath(qpath))
			qdel(Q)
	data["quirks_info"] = quirks_info

	// === LOADOUT CATEGORIES (static) ===
	var/list/loadout_categories = list()
	for(var/cat in GLOB.loadout_items)
		var/list/subcats = list()
		for(var/subcat in GLOB.loadout_items[cat])
			subcats += subcat
		loadout_categories += list(list(
			"name" = cat,
			"subcategories" = subcats,
		))
	data["loadout_categories"] = loadout_categories

	// === KEYBINDING CATEGORIES (static) ===
	var/list/kb_categories = list()
	for(var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
		if(!kb_categories[kb.category])
			kb_categories[kb.category] = list()
		kb_categories[kb.category] += list(list(
			"name" = kb.name,
			"full_name" = kb.full_name,
			"description" = kb.description,
			"default_keys" = prefs.hotkeys ? kb.hotkey_keys : kb.classic_keys,
		))
	data["keybinding_categories"] = kb_categories

	// === AVAILABLE MARKINGS (static) ===
	var/list/available_markings = list()
	var/list/body_zones = list("Head", "Chest", "Left Arm", "Right Arm", "Left Leg", "Right Leg")
	for(var/marking_name in GLOB.mam_body_markings_list)
		var/datum/sprite_accessory/mam_body_markings/marking = GLOB.mam_body_markings_list[marking_name]
		if(!istype(marking))
			continue
		var/list/covered = list()
		for(var/limb_name in marking.covered_limbs)
			covered += limb_name
		// Determine number of usable color channels based on matrix types
		var/list/color_channels = list()
		for(var/limb_name in marking.covered_limbs)
			var/matrix_type = marking.covered_limbs[limb_name]
			switch(matrix_type)
				if(MATRIX_RED)
					color_channels |= list(1)
				if(MATRIX_GREEN)
					color_channels |= list(2)
				if(MATRIX_BLUE)
					color_channels |= list(3)
				if(MATRIX_RED_GREEN)
					color_channels |= list(1, 2)
				if(MATRIX_RED_BLUE)
					color_channels |= list(1, 3)
				if(MATRIX_GREEN_BLUE)
					color_channels |= list(2, 3)
				if(MATRIX_ALL)
					color_channels |= list(1, 2, 3)
		available_markings += list(list(
			"name" = marking.name,
			"covered_limbs" = covered,
			"color_channels" = color_channels,
			"ckeys_allowed" = marking.ckeys_allowed,
		))
	data["available_markings"] = available_markings
	data["body_zones"] = body_zones

	// === AVAILABLE INTERACTIONS (для пикера избранных) ===
	if(SSinteractions?.interactions)
		var/list/sent_interactions = list()
		for(var/interaction_key in SSinteractions.interactions)
			var/datum/interaction/I = SSinteractions.interactions[interaction_key]
			if(!I.description || (I.interaction_flags & INTERACTION_FLAG_HIDE_IN_PANEL))
				continue
			sent_interactions += list(list(
				"key" = interaction_key,
				"desc" = I.description,
			))
		data["available_interactions"] = sent_interactions

	return data

/datum/character_setup_ui/ui_data(mob/user)
	var/list/data = list()
	if(!prefs)
		return data

	// Current tab state
	data["current_tab"] = prefs.current_tab
	data["character_settings_tab"] = prefs.character_settings_tab
	data["preferences_tab"] = prefs.preferences_tab
	data["preview_pref"] = prefs.preview_pref

	// Character preview — base64 data URL from getFlatIcon() cache (no map_view overhead)
	if(prefs.preview_dir_b64_cache)
		data["preview_icon"] = prefs.preview_dir_b64_cache["[prefs.preview_direction]"]
	data["preview_generating"] = prefs.preview_generating
	data["preview_direction"] = prefs.preview_direction
	data["preview_zoom"] = prefs.preview_zoom

	// Character slots (cached — only rebuilt when tainted)
	if(tainted_slots || !cached_slots)
		var/list/slots = list()
		if(prefs.path)
			var/savefile/S = new /savefile(prefs.path)
			if(S)
				for(var/i = 1, i <= prefs.max_save_slots, i++)
					var/slot_name = null
					S.cd = "/character[i]"
					S["real_name"] >> slot_name
					slots += list(list(
						"index" = i,
						"name" = slot_name || "Character[i]",
						"is_empty" = !slot_name,
					))
		cached_slots = slots
		tainted_slots = FALSE
	data["slots"] = cached_slots
	data["active_slot"] = prefs.default_slot
	data["collapse_empty_slots"] = prefs.collapse_empty_character_slots
	data["has_offer"] = !QDELETED(prefs.offer)
	data["offer_code"] = !QDELETED(prefs.offer) ? prefs.offer.redemption_code : null

	// === GENERAL TAB DATA ===
	data["real_name"] = prefs.real_name
	data["gender"] = prefs.gender
	data["age"] = prefs.age
	data["be_random_name"] = prefs.be_random_name
	data["be_random_body"] = prefs.be_random_body
	data["nameless"] = prefs.nameless
	data["hide_ckey"] = prefs.hide_ckey
	data["custom_blood_color"] = prefs.custom_blood_color
	data["blood_color"] = prefs.blood_color

	// Custom names
	var/list/custom_names = list()
	for(var/custom_name_id in GLOB.preferences_custom_names)
		custom_names[custom_name_id] = prefs.custom_names[custom_name_id]
	data["custom_names"] = custom_names

	// Species
	data["species_name"] = prefs.pref_species?.name
	data["species_id"] = prefs.pref_species?.id
	data["custom_species"] = prefs.custom_species
	data["species_has_sexes"] = prefs.pref_species?.sexes

	// Silicon/AI
	data["preferred_ai_core_display"] = prefs.preferred_ai_core_display
	data["silicon_lawset"] = prefs.silicon_lawset
	data["prefered_security_department"] = prefs.prefered_security_department

	// PDA
	data["pda_color"] = prefs.pda_color
	data["pda_style"] = prefs.pda_style
	data["pda_skin"] = prefs.pda_skin
	data["pda_ringtone"] = prefs.pda_ringtone

	// Hardsuit
	data["hardsuit_with_tail"] = prefs.features["hardsuit_with_tail"]

	// === APPEARANCE TAB DATA ===
	data["body_model"] = prefs.features["body_model"]
	data["body_size"] = prefs.features["body_size"]
	data["normalized_size"] = prefs.features["normalized_size"]
	data["body_weight"] = prefs.body_weight
	data["color_scheme"] = prefs.features["color_scheme"]
	data["show_mismatched_markings"] = prefs.show_mismatched_markings
	data["fuzzy"] = prefs.fuzzy
	data["bgstate"] = prefs.bgstate

	// Skin tone
	data["skin_tone"] = prefs.skin_tone
	data["use_custom_skin_tone"] = prefs.use_custom_skin_tone
	data["use_skintones"] = prefs.pref_species?.use_skintones

	// Body colors
	data["mcolor"] = prefs.features["mcolor"]
	data["mcolor2"] = prefs.features["mcolor2"]
	data["mcolor3"] = prefs.features["mcolor3"]
	data["has_mutcolors"] = (MUTCOLORS in prefs.pref_species?.species_traits) || (MUTCOLORS_PARTSONLY in prefs.pref_species?.species_traits)
	data["genitals_use_skintone"] = prefs.features["genitals_use_skintone"]

	// Eyes
	data["eye_type"] = prefs.eye_type
	data["left_eye_color"] = prefs.left_eye_color
	data["right_eye_color"] = prefs.right_eye_color
	data["split_eye_colors"] = prefs.split_eye_colors
	data["has_eyes"] = !(NOEYES in prefs.pref_species?.species_traits)
	data["has_eyecolor"] = (EYECOLOR in prefs.pref_species?.species_traits)

	// Hair
	data["hair_style"] = prefs.hair_style
	data["hair_color"] = prefs.hair_color
	data["facial_hair_style"] = prefs.facial_hair_style
	data["facial_hair_color"] = prefs.facial_hair_color
	data["grad_style"] = prefs.grad_style
	data["grad_color"] = prefs.grad_color
	data["has_hair"] = (HAIR in prefs.pref_species?.species_traits)

	// Underwear
	data["underwear"] = prefs.underwear
	data["undie_color"] = prefs.undie_color
	data["undershirt"] = prefs.undershirt
	data["shirt_color"] = prefs.shirt_color
	data["socks"] = prefs.socks
	data["socks_color"] = prefs.socks_color

	// Equipment/outfit
	data["backbag"] = prefs.backbag
	data["jumpsuit_style"] = prefs.jumpsuit_style
	data["persistent_scars"] = prefs.persistent_scars
	data["uplink_spawn_loc"] = prefs.uplink_spawn_loc

	// Mutant parts — current values
	var/list/mutant_values = list()
	var/list/mutant_colors_data = list()
	for(var/part in GLOB.all_mutant_parts)
		if(part == "mam_body_markings")
			continue
		mutant_values[part] = prefs.features[part]
		var/color_type = GLOB.colored_mutant_parts[part]
		if(color_type)
			mutant_colors_data[color_type] = prefs.features[color_type]
	data["mutant_values"] = mutant_values
	data["mutant_colors"] = mutant_colors_data

	// Which mutant parts can this species have
	var/list/available_mutant_parts = list()
	if(prefs.parent)
		for(var/part in GLOB.all_mutant_parts)
			if(part == "mam_body_markings")
				continue
			if(prefs.parent.can_have_part(part))
				available_mutant_parts += part
	data["available_mutant_parts"] = available_mutant_parts

	// Limb modifications
	var/list/limb_mods = list()
	if(prefs.modified_limbs)
		for(var/limb in prefs.modified_limbs)
			var/list/mod_data = prefs.modified_limbs[limb]
			limb_mods += list(list(
				"limb" = limb,
				"type" = mod_data[1],
				"detail" = mod_data.len > 1 ? mod_data[2] : null,
			))
	data["modified_limbs"] = limb_mods

	// === BACKGROUND TAB DATA ===
	data["flavor_text"] = prefs.features["flavor_text"]
	data["naked_flavor_text"] = prefs.features["naked_flavor_text"]
	data["custom_deathgasp"] = prefs.features["custom_deathgasp"]
	data["custom_deathsound"] = prefs.features["custom_deathsound"]
	data["silicon_flavor_text"] = prefs.features["silicon_flavor_text"]
	data["custom_species_lore"] = prefs.features["custom_species_lore"]
	data["ooc_notes"] = prefs.features["ooc_notes"]
	data["security_records"] = prefs.security_records
	data["medical_records"] = prefs.medical_records

	// Headshots
	data["headshot_link"] = prefs.features["headshot_link"]
	data["headshot_link1"] = prefs.features["headshot_link1"]
	data["headshot_link2"] = prefs.features["headshot_link2"]
	data["headshot_naked_link"] = prefs.features["headshot_naked_link"]
	data["headshot_naked_link1"] = prefs.features["headshot_naked_link1"]
	data["headshot_naked_link2"] = prefs.features["headshot_naked_link2"]

	// === SPEECH TAB DATA ===
	data["speech_verb"] = prefs.features["speech_verb"]
	data["custom_tongue"] = prefs.custom_tongue
	data["custom_laugh"] = prefs.custom_laugh
	data["languages"] = prefs.language
	data["enable_personal_chat_color"] = prefs.enable_personal_chat_color
	data["personal_chat_color"] = prefs.personal_chat_color
	data["bark_id"] = prefs.bark_id
	data["bark_pitch"] = prefs.bark_pitch
	data["bark_speed"] = prefs.bark_speed

	// === LANGUAGE DATA ===
	var/max_languages = CONFIG_GET(number/max_languages)
	data["max_languages"] = max_languages
	var/list/available_languages = list()
	// Russian translations for language descriptions
	var/static/list/lang_desc_ru = list(
		"Rachnidian" = "Язык, использующий тонкие танцевальные движения конечностей арахнидов для общения. Движения достаточно быстры и резки, чтобы издавать слышимые звуки, различимые по радио.",
		"Beachtongue" = "Древний язык с далёкой Пляжной Планеты. Люди магическим образом начинают говорить на нём под воздействием космических наркотиков.",
		"Draconic" = "Общий язык ящеролюдов, состоящий из шипящих звуков и трещоток.",
		"Dwarvish" = "Язык дварфов.",
		"Encoded Audio Language" = "Эффективный язык кодированных тонов, разработанный синтетиками и киборгами.",
		"Chimpanzee" = "Ук ук ук.",
		"Mushroom" = "Язык, состоящий из периодических порывов воздуха, наполненного спорами.",
		"Neo-Kanji" = "Смесь множества старых земных азиатских диалектов. Известен как официальный язык клана пауков.",
		"Space Sign Language" = "Те, кто не может говорить, могут выучить этот язык жестов.",
		"Slime" = "Мелодичный и сложный язык слаймов. Некоторые ноты неслышимы для людей.",
		"Sylvan" = "Сложный древний язык, на котором говорят растительные существа.",
		"Siiktajr" = "Традиционный язык Адомая, состоящий из выразительных завываний и щебетаний. Родной для таджаран.",
		"Voltaic" = "Искрящийся язык, создаваемый путём управления электрическими разрядами.",
		"Canilunzt" = "Гортанный язык обитателей системы Ваззенд, состоящий из рычания, лая и активного использования ушей и хвоста. Вульпканины говорят на нём с лёгкостью.",
		"Xenomorph" = "Общий язык ксеноморфов.",
		"Galactic Common" = "Общегалактический язык.",
		"Felinid" = "Естественный язык фелинидов. Полон мягкого мяуканья, мурлыканья и шипения. Ня~",
		"Buggy" = "Едва понятный язык, на котором говорят существа, похожие на насекомых.",
		"Calcic" = "Отрывистый язык плазмаменов. Также понятен скелетам.",
		LANGUAGE_SERGAL = "Доминирующий язык родного мира сергалов — Тал. Состоит из агрессивного низкого шипения и горлового рычания.",
		"Avian" = "Набор птичьих пений и криков, в основном приятных для человеческого слуха.",
		"Skrellian" = "Мелодичный и сложный язык скреллов с Керрбалака. Некоторые ноты неслышимы для людей.",
		LANGUAGE_ACRATARIAN = "Основной язык по всему Акратару, планете Акрадоров в системе Триос.",
		LANGUAGE_CETRIA = "Редкий язык всех каткринов. Схож с немецким и латинским, с примесью шипения, мурлыканья и рычания.",
		"Katzenjammer" = "Модернизированная версия немецкого языка с различными диалектами. Обычно используется жителями Земли.",
		LANGUAGE_DEMONIC = "Родной язык многих потусторонних существ. Часто можно услышать от тех, кого люди назвали бы демонами.",
	)
	if(SSlanguage?.languages_by_name?.len)
		var/static/list/lang_icons_b64 = list()
		for(var/V in SSlanguage.languages_by_name)
			var/datum/language/L = SSlanguage.languages_by_name[V]
			if(!L)
				continue
			var/restricted = L.restricted
			if(restricted && !(L.name in prefs.pref_species?.languagewhitelist))
				var/quirklanguagefound = FALSE
				for(var/qname in prefs.all_quirks)
					var/datum/quirk/Q = SSquirks.quirks[qname]
					if(Q && (L.name in Q.languagewhitelist))
						quirklanguagefound = TRUE
						break
				if(!quirklanguagefound)
					continue
			var/desc_text = lang_desc_ru[L.name] || L.desc
			if(!lang_icons_b64[L.name])
				var/icon/lang_icon = icon(L.icon, L.icon_state)
				lang_icons_b64[L.name] = "data:image/png;base64,[icon2base64(lang_icon)]"
			available_languages += list(list(
				"name" = L.name,
				"desc" = desc_text,
				"icon_b64" = lang_icons_b64[L.name],
				"selected" = (L.name in prefs.language),
			))
	data["available_languages"] = available_languages
	data["bark_variance"] = prefs.bark_variance

	// === QUIRKS (dynamic only — static info is in ui_static_data) ===
	data["all_quirks"] = prefs.all_quirks
	data["quirk_balance"] = prefs.GetQuirkBalance(user)

	// === GAME PREFERENCES TAB ===
	data["UI_style"] = prefs.UI_style
	data["outline_enabled"] = prefs.outline_enabled
	data["outline_color"] = prefs.outline_color
	data["screentip_pref"] = prefs.screentip_pref
	data["screentip_color"] = prefs.screentip_color
	data["screentip_images"] = prefs.screentip_images
	data["hotkeys"] = prefs.hotkeys
	data["tgui_fancy"] = prefs.tgui_fancy
	data["tgui_lock"] = prefs.tgui_lock
	data["chat_on_map"] = prefs.chat_on_map
	data["max_chat_length"] = prefs.max_chat_length
	data["see_chat_non_mob"] = prefs.see_chat_non_mob
	data["see_rc_emotes"] = prefs.see_rc_emotes
	data["clientfps"] = prefs.clientfps
	data["toggles"] = prefs.toggles
	data["widescreenpref"] = prefs.widescreenpref
	data["fullscreen"] = prefs.fullscreen
	data["long_strip_menu"] = prefs.long_strip_menu
	data["autostand"] = prefs.autostand
	data["auto_ooc"] = prefs.auto_ooc
	data["auto_capitalize_enabled"] = prefs.auto_capitalize_enabled
	data["no_tetris_storage"] = prefs.no_tetris_storage
	data["screenshake"] = prefs.screenshake
	data["damagescreenshake"] = prefs.damagescreenshake
	data["recoil_screenshake"] = prefs.recoil_screenshake
	data["parallax"] = prefs.parallax
	data["ambientocclusion"] = prefs.ambientocclusion
	data["auto_fit_viewport"] = prefs.auto_fit_viewport
	data["hud_toggle_flash"] = prefs.hud_toggle_flash
	data["hud_toggle_color"] = prefs.hud_toggle_color
	data["view_pixelshift"] = prefs.view_pixelshift
	data["disable_combat_cursor"] = prefs.disable_combat_cursor
	data["disable_combat_mouse_lock"] = prefs.disable_combat_mouse_lock
	data["be_victim"] = prefs.be_victim

	// === JOB PREFERENCES DATA ===
	data["job_preferences"] = prefs.job_preferences
	data["joblessrole"] = prefs.joblessrole
	data["overflow_role"] = SSjob.overflow_role
	var/list/job_bans = list()
	var/list/job_days_left = list()
	var/list/job_exp_left = list()
	var/list/job_species_blocked = list()
	var/list/ui_jobs_data = list()
	for(var/datum/job/J in SSjob.occupations)
		if(!J.title)
			continue
		if(jobban_isbanned(user, J.title))
			job_bans += J.title
		if(J.minimal_player_age && CONFIG_GET(flag/use_age_restriction_for_jobs))
			var/player_age = user.client ? user.client.player_age : 0
			if(player_age < J.minimal_player_age)
				job_days_left[J.title] = J.minimal_player_age - player_age
		if(J.exp_requirements && J.exp_type)
			var/req_remaining = J.required_playtime_remaining(user.client)
			if(req_remaining > 0)
				job_exp_left[J.title] = round(req_remaining / 60, 0.1)
		if(J.is_species_blacklisted(user.client))
			job_species_blocked += J.title
		var/dept_name = "Other"
		if(J.departments & DEPARTMENT_BITFLAG_COMMAND)
			dept_name = "Command"
		else if(J.departments & DEPARTMENT_BITFLAG_SECURITY)
			dept_name = "Security"
		else if(J.departments & DEPARTMENT_BITFLAG_ENGINEERING)
			dept_name = "Engineering"
		else if(J.departments & DEPARTMENT_BITFLAG_SCIENCE)
			dept_name = "Science"
		else if(J.departments & DEPARTMENT_BITFLAG_MEDICAL)
			dept_name = "Medical"
		else if(J.departments & DEPARTMENT_BITFLAG_SUPPLY)
			dept_name = "Supply"
		else if(J.departments & DEPARTMENT_BITFLAG_SERVICE)
			dept_name = "Service"
		else if(J.departments & DEPARTMENT_BITFLAG_SILICON)
			dept_name = "Silicon"
		else if(J.departments & DEPARTMENT_BITFLAG_LAW)
			dept_name = "Law"
		ui_jobs_data += list(list(
			"title" = J.title,
			"department" = dept_name,
			"selection_color" = J.selection_color,
			"display_order" = J.display_order,
			"alt_titles" = (J.alt_titles ? J.alt_titles.Copy() : list()),
			"is_head" = !!(J.departments & DEPARTMENT_BITFLAG_COMMAND),
		))
	data["jobs_info"] = ui_jobs_data
	data["job_bans"] = job_bans
	data["job_days_left"] = job_days_left
	data["job_exp_left"] = job_exp_left
	data["job_species_blocked"] = job_species_blocked
	data["alt_titles_preferences"] = prefs.alt_titles_preferences

	// === ANTAG ROLES DATA ===
	var/list/antag_roles_data = list()
	var/antag_banned = jobban_isbanned(user, ROLE_INTEQ)
	data["antag_banned"] = antag_banned

	var/static/list/antag_icons_b64 = list()
	// Maps role name to antag datum type for preview icon generation
	var/static/list/antag_datum_map = list(
		"traitor" = /datum/antagonist/traitor,
		"blood brother" = /datum/antagonist/brother,
		"operative" = /datum/antagonist/nukeop,
		"changeling" = /datum/antagonist/changeling,
		"Changeling (Meteor)" = /datum/antagonist/changeling/space,
		"wizard" = /datum/antagonist/wizard,
		"revolutionary" = /datum/antagonist/rev,
		"xenomorph" = /datum/antagonist/xeno,
		"cultist" = /datum/antagonist/cult,
		"blob" = /datum/antagonist/blob,
		"space ninja" = /datum/antagonist/ninja,
		"revenant" = /datum/antagonist/revenant,
		"abductor" = /datum/antagonist/abductor,
		"Heretic" = /datum/antagonist/heretic,
		"bloodsucker" = /datum/antagonist/bloodsucker,
		"family boss" = /datum/antagonist/gang,
		"Space Dragon" = /datum/antagonist/space_dragon,
		"Terror Spider" = /datum/antagonist/terror_spiders,
	)
	// Fallback HUD icons for roles without antag datums
	var/static/list/antag_icon_fallback = list(
		"Slaver" = "slaver",
		"pAI" = "intruder",
		"monkey" = "intruder",
		"devil" = "devil",
		"servant of Ratvar" = "clockwork",
		"syndicate mutineer" = "synd",
		"internal affairs agent" = "traitor",
		"sentience potion spawn" = "intruder",
		"Syndicate" = "synd",
	)
	// Special large icons for non-datum roles
	var/static/list/antag_icon_special = list(
		"malf AI" = list("file" = 'icons/mob/ai.dmi', "state" = "ai"),
	)

	if(!antag_banned)
		for(var/role_name in GLOB.special_roles)
			var/list/role_entry = list()
			role_entry["name"] = role_name
			// Generate icon via get_preview_icon() or fallback to HUD icons
			if(!antag_icons_b64[role_name])
				var/antag_type = antag_datum_map[role_name]
				if(antag_type)
					try
						var/datum/antagonist/temp_antag = new antag_type()
						var/icon/preview = temp_antag.get_preview_icon()
						if(preview)
							antag_icons_b64[role_name] = "data:image/png;base64,[icon2base64(preview)]"
						qdel(temp_antag)
					catch
						// Silently ignore qdel warnings for ownerless antag datums
				if(!antag_icons_b64[role_name])
					var/list/special = antag_icon_special[role_name]
					if(special)
						var/icon/special_icon = icon(special["file"], special["state"])
						special_icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)
						antag_icons_b64[role_name] = "data:image/png;base64,[icon2base64(special_icon)]"
				if(!antag_icons_b64[role_name])
					var/fallback_state = antag_icon_fallback[role_name]
					if(fallback_state)
						var/icon/fallback_icon = icon('icons/mob/hud.dmi', fallback_state)
						fallback_icon.Scale(48, 48)
						antag_icons_b64[role_name] = "data:image/png;base64,[icon2base64(fallback_icon)]"
			role_entry["icon_b64"] = antag_icons_b64[role_name]
			if(jobban_isbanned(user, role_name))
				role_entry["status"] = "banned"
			else
				var/days_remaining = null
				if(ispath(GLOB.special_roles[role_name]) && CONFIG_GET(flag/use_age_restriction_for_jobs))
					var/mode_path = GLOB.special_roles[role_name]
					var/datum/game_mode/temp_mode = new mode_path
					days_remaining = temp_mode.get_remaining_days(user.client)
				if(days_remaining)
					role_entry["status"] = "locked"
					role_entry["days"] = days_remaining
				else if(role_name in prefs.be_special)
					if(prefs.be_special[role_name] >= 1)
						role_entry["status"] = "enabled"
					else
						role_entry["status"] = "low"
				else
					role_entry["status"] = "disabled"
			antag_roles_data += list(role_entry)
	data["antag_roles"] = antag_roles_data

	// === OOC PREFERENCES TAB ===
	data["ooccolor"] = prefs.ooccolor
	data["aooccolor"] = prefs.aooccolor
	data["chat_toggles"] = prefs.chat_toggles
	data["custom_colors"] = prefs.custom_colors
	data["windowflashing"] = prefs.windowflashing
	data["windownoise"] = prefs.windownoise
	data["ghost_form"] = prefs.ghost_form
	data["ghost_orbit"] = prefs.ghost_orbit
	data["ghost_accs"] = prefs.ghost_accs
	data["ghost_others"] = prefs.ghost_others

	// === CONTENT PREFERENCES TAB ===
	data["erppref"] = prefs.erppref
	data["nonconpref"] = prefs.nonconpref
	data["vorepref"] = prefs.vorepref
	data["extremepref"] = prefs.extremepref
	data["unholypref"] = prefs.unholypref
	data["mobsexpref"] = prefs.mobsexpref
	data["hornyantagspref"] = prefs.hornyantagspref
	data["tattoopref"] = prefs.tattoopref
	data["extremeharm"] = prefs.extremeharm
	data["cit_toggles"] = prefs.cit_toggles
	data["arousable"] = prefs.arousable
	data["sexknotting"] = prefs.sexknotting
	data["lust_tolerance"] = prefs.lust_tolerance
	data["sexual_potency"] = prefs.sexual_potency
	data["use_arousal_multiplier"] = prefs.use_arousal_multiplier
	data["arousal_multiplier"] = prefs.arousal_multiplier
	data["use_moaning_multiplier"] = prefs.use_moaning_multiplier
	data["moaning_multiplier"] = prefs.moaning_multiplier
	data["favorite_interactions"] = SANITIZE_LIST(prefs.favorite_interactions)
	var/list/markings_data = list()
	var/list/markings_raw = prefs.features["mam_body_markings"]
	if(islist(markings_raw))
		for(var/i = 1, i <= length(markings_raw), i++)
			var/list/entry = markings_raw[i]
			if(!islist(entry) || length(entry) < 2)
				continue
			var/limb_value = entry[1]
			var/marking_name = entry[2]
			var/list/colors = list("#FFFFFF", "#FFFFFF", "#FFFFFF")
			if(length(entry) >= 3 && islist(entry[3]))
				colors = entry[3]
			var/limb_name = GLOB.bodypart_names[num2text(limb_value)]
			// Get number of active color channels for this specific limb
			var/active_colors = 3
			var/datum/sprite_accessory/mam_body_markings/marking_datum = GLOB.mam_body_markings_list[marking_name]
			if(istype(marking_datum) && limb_name && marking_datum.covered_limbs[limb_name])
				var/matrix_type = marking_datum.covered_limbs[limb_name]
				switch(matrix_type)
					if(MATRIX_RED, MATRIX_GREEN, MATRIX_BLUE)
						active_colors = 1
					if(MATRIX_RED_GREEN, MATRIX_RED_BLUE, MATRIX_GREEN_BLUE)
						active_colors = 2
					if(MATRIX_ALL)
						active_colors = 3
					if(MATRIX_NONE)
						active_colors = 0
			markings_data += list(list(
				"index" = i,
				"limb_value" = limb_value,
				"limb_name" = limb_name,
				"marking_name" = marking_name,
				"colors" = colors,
				"active_colors" = active_colors,
			))
	data["markings"] = markings_data

	// === LOADOUT DATA ===
	data["loadout_slot"] = prefs.loadout_slot
	data["loadout_enabled"] = prefs.loadout_enabled

	// Validate and auto-init gear category/subcategory
	if(!prefs.gear_category || !GLOB.loadout_items[prefs.gear_category])
		prefs.gear_category = null
		for(var/cat in GLOB.loadout_items)
			prefs.gear_category = cat
			break
	if(prefs.gear_category)
		if(!prefs.gear_subcategory || !GLOB.loadout_items[prefs.gear_category][prefs.gear_subcategory])
			prefs.gear_subcategory = null
			for(var/sc in GLOB.loadout_items[prefs.gear_category])
				prefs.gear_subcategory = sc
				break

	data["gear_category"] = prefs.gear_category
	data["gear_subcategory"] = prefs.gear_subcategory

	// Calculate gear points
	var/total_gear_points = CONFIG_GET(number/initial_gear_points)
	if(user.client)
		if(IS_CKEY_DONATOR_GROUP(user.ckey, DONATOR_GROUP_TIER_1))
			total_gear_points += CONFIG_GET(number/subscriber_extra_gear_points)
		if(IS_CKEY_DONATOR_GROUP(user.ckey, DONATOR_GROUP_TIER_2))
			total_gear_points += CONFIG_GET(number/sponsor_extra_gear_points)
	var/list/chosen_gear = prefs.loadout_data["SAVE_[prefs.loadout_slot]"]
	if(islist(chosen_gear))
		for(var/list/loadout_entry in chosen_gear)
			var/loadout_item_path = loadout_entry[LOADOUT_ITEM]
			if(loadout_item_path)
				var/datum/gear/loadout_gear_type = text2path(loadout_item_path)
				if(loadout_gear_type)
					total_gear_points -= initial(loadout_gear_type.cost)
	data["gear_points"] = total_gear_points

	// Current loadout items (selected in current slot)
	var/list/loadout_items = list()
	if(prefs.loadout_data && prefs.loadout_data["SAVE_[prefs.loadout_slot]"])
		var/list/slot_data = prefs.loadout_data["SAVE_[prefs.loadout_slot]"]
		for(var/list/entry in slot_data)
			var/gear_path = entry[LOADOUT_ITEM]
			if(!gear_path)
				continue
			var/datum/gear/G = find_gear_by_type(gear_path)
			loadout_items += list(list(
				"path" = gear_path,
				"name" = entry[LOADOUT_CUSTOM_NAME] || (G ? G.name : gear_path),
				"color" = entry[LOADOUT_COLOR],
				"is_heirloom" = !!entry[LOADOUT_IS_HEIRLOOM],
			))
	data["loadout_items"] = loadout_items

	// Items in current category/subcategory
	var/list/category_items = list()
	if(prefs.gear_category && prefs.gear_subcategory && GLOB.loadout_items[prefs.gear_category])
		var/list/subcat_items = GLOB.loadout_items[prefs.gear_category][prefs.gear_subcategory]
		if(length(subcat_items))
			for(var/gear_name in subcat_items)
				var/datum/gear/G = subcat_items[gear_name]
				if(!istype(G))
					continue
				var/has_gear = prefs.has_loadout_gear(prefs.loadout_slot, "[G.type]")
				category_items += list(list(
					"name" = gear_name,
					"path" = "[G.type]",
					"sprite_id" = replacetext("[G.type]", "/", "_"),
					"cost" = G.cost,
					"description" = (G.description ? G.description : ""),
					"selected" = (has_gear ? 1 : 0),
					"can_color" = ((G.loadout_flags & LOADOUT_CAN_COLOR_POLYCHROMIC) ? 1 : 0),
					"can_name" = ((G.loadout_flags & LOADOUT_CAN_NAME) ? 1 : 0),
				))
	data["category_items"] = category_items

	// === KEYBINDINGS DATA (dynamic only — categories are in ui_static_data) ===
	var/list/user_binds = list()
	var/list/user_modless_binds = list()
	for(var/key in prefs.key_bindings)
		for(var/kb_name in prefs.key_bindings[key])
			user_binds[kb_name] += list(key)
	for(var/key in prefs.modless_key_bindings)
		user_modless_binds[prefs.modless_key_bindings[key]] = key

	data["user_bindings"] = user_binds
	data["user_modless_bindings"] = user_modless_binds

	return data

/// Запустить асинхронную генерацию превью (персистентный манекен + getFlatIcon + кэш base64 по 4 направлениям)
/datum/character_setup_ui/proc/update_preview()
	if(!prefs)
		return
	prefs.update_preview_icon()

/// Данный тип удалён — больше не нужна map_view. Превью рендерится через getFlatIcon() в preferences_setup.dm.
// /atom/movable/screen/map_view/character_preview_screen — REMOVED

/datum/character_setup_ui/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	if(!prefs || !owner)
		return

	. = handle_ui_action(action, params, ui)

	// Auto-update preview — с подсказками для инкрементальных обновлений
	if(.)
		if(action in list("set_hair_style", "set_facial_hair_style", "set_grad_style", "set_hair_color", "set_facial_hair_color", "set_grad_color"))
			prefs.preview_change_hint = PREVIEW_HINT_HAIR
			prefs.update_preview_icon()
		else if(action in list("set_species", "set_body_model", "set_gender"))
			prefs.invalidate_preview_mannequin()
			prefs.update_preview_icon()
		else if(action == "set_mutant_part")
			prefs.preview_change_hint = PREVIEW_HINT_MUTANT_BODYPARTS
			prefs.update_preview_icon()
		else if(action in list("set_skin_tone", "set_mutant_color", "set_eye_color", "set_eye_type", "toggle_split_eyes", "set_body_size", "set_body_weight", "toggle_custom_skin_tone", "toggle_color_scheme", "toggle_fuzzy", "set_mutant_part_color", "marking_add", "marking_remove", "marking_color", "marking_up", "marking_down", "markings_clear_limb", "markings_remove_all", "modify_limbs"))
			prefs.preview_change_hint = PREVIEW_HINT_BODY
			prefs.update_preview_icon()
		else if(action in list(
			"set_underwear", "set_undershirt", "set_socks",
			"toggle_mismatched_markings",
			"toggle_loadout_enabled", "toggle_gear", "clear_loadout",
			"toggle_arousable", "open_genital_config",
			"set_custom_blood_color", "toggle_custom_blood_color",
			"toggle_hardsuit_tail",
			"set_backbag", "toggle_jumpsuit_style",
			"change_slot", "import_slot", "retrieve_slot", "delete_slot"
		))
			prefs.update_preview_icon()

/datum/character_setup_ui/proc/handle_ui_action(action, list/params, datum/tgui/ui)
	var/mob/user = ui.user

	switch(action)
		// === TAB SWITCHING ===
		if("set_tab")
			var/tab = text2num(params["tab"])
			if(!isnull(tab))
				prefs.current_tab = tab
			return TRUE

		if("set_character_tab")
			var/tab = text2num(params["tab"])
			if(!isnull(tab))
				prefs.character_settings_tab = tab
			return TRUE

		if("set_preferences_tab")
			var/tab = text2num(params["tab"])
			if(!isnull(tab))
				prefs.preferences_tab = tab
			return TRUE

		if("set_preview_pref")
			var/pref = params["pref"]
			if(pref in list(PREVIEW_PREF_JOB, PREVIEW_PREF_LOADOUT, PREVIEW_PREF_NAKED, PREVIEW_PREF_NAKED_AROUSED))
				prefs.preview_pref = pref
				update_preview()
			return TRUE

		// === CHARACTER SLOTS ===
		if("change_slot")
			var/num = text2num(params["slot"])
			if(num && num >= 1 && num <= prefs.max_save_slots)
				if(prefs.char_queue)
					deltimer(prefs.char_queue)
				prefs.save_character(bypass_cooldown = TRUE)
				if(!prefs.load_character(num, bypass_cooldown = TRUE))
					prefs.random_character()
					prefs.real_name = random_unique_name(prefs.gender)
					prefs.save_character(bypass_cooldown = TRUE)
				if(ui.user.client?.prefs)
					var/list/payload = ui.user.client.prefs.custom_emote_panel
					ui.user.client.tgui_panel?.window.send_message("emotes/setList", payload)
				tainted_slots = TRUE
				update_preview()
			return TRUE

		if("toggle_empty_slots")
			prefs.collapse_empty_character_slots = !prefs.collapse_empty_character_slots
			return TRUE

		if("export_slot")
			var/savefile/S = prefs.save_character(export = TRUE)
			if(istype(S, /savefile))
				usr.client?.Export(S)
				tgui_alert_async(usr, "Слот успешно экспортирован.")
			else
				tgui_alert_async(usr, "Ошибка экспорта слота.")
			return TRUE

		if("import_slot")
			var/savefile/S = new(usr.client?.Import())
			if(istype(S, /savefile))
				if(prefs.load_character(provided = S))
					tgui_alert_async(usr, "Слот успешно импортирован.")
					prefs.save_character(bypass_cooldown = TRUE)
					tainted_slots = TRUE
					update_preview()
				else
					tgui_alert_async(usr, "Ошибка загрузки слота.")
			else
				tgui_alert_async(usr, "Нет сохранённого локального слота.")
			return TRUE

		if("delete_local_copy")
			usr.client?.clear_export()
			tgui_alert_async(usr, "Локальная копия удалена.")
			return TRUE

		if("give_slot")
			if(!QDELETED(prefs.offer))
				// Cancel existing offer
				var/datum/character_offer_instance/offer_datum = LAZYACCESS(GLOB.character_offers, prefs.offer.redemption_code)
				if(offer_datum)
					qdel(offer_datum)
				prefs.offer = null
			else
				// Create new offer
				var/savefile/S = prefs.save_character(export = TRUE)
				if(istype(S, /savefile))
					var/datum/character_offer_instance/offer_datum = new(usr.ckey, S)
					if(QDELETED(offer_datum))
						tgui_alert_async(usr, "Не удалось создать предложение, попробуйте позже.")
						return TRUE
					offer_datum.RegisterSignal(usr, COMSIG_MOB_CLIENT_LOGOUT, TYPE_PROC_REF(/datum/character_offer_instance, on_quit))
					prefs.offer = offer_datum
					tgui_alert_async(usr, "Код для получения: [offer_datum.redemption_code]")
			return TRUE

		if("retrieve_slot")
			if(!LAZYLEN(GLOB.character_offers))
				tgui_alert_async(usr, "Нет активных предложений.")
				return TRUE
			var/retrieve_code = tgui_input_text(usr, "Введите 5-значный код получения", "Получение слота")
			if(!retrieve_code)
				return TRUE
			if(!text2num(retrieve_code))
				tgui_alert_async(usr, "Допускаются только цифры.")
				return TRUE
			if(length(retrieve_code) != 5)
				tgui_alert_async(usr, "Код должен содержать ровно 5 цифр.")
				return TRUE
			var/datum/character_offer_instance/offer_datum = LAZYACCESS(GLOB.character_offers, retrieve_code)
			if(!offer_datum)
				tgui_alert_async(usr, "Неверный код!")
				return TRUE
			if(prefs.offer == offer_datum)
				tgui_alert_async(usr, "Вы не можете принять своё собственное предложение.")
				return TRUE
			var/savefile/savefile = offer_datum.character_savefile
			var/mob/living/the_owner = get_mob_by_ckey(offer_datum.owner_ckey)
			if(prefs.savefile_needs_update(savefile) == -2)
				tgui_alert_async(usr, "Сейвфайл повреждён.")
				to_chat(the_owner, span_boldwarning("Что-то пошло не так с обменом, он отменён."))
				qdel(offer_datum)
				return TRUE
			var/character_name
			savefile["real_name"] >> character_name
			var/confirm = tgui_alert(usr, "Вы перезапишете текущий слот персонажем [character_name]. Вы уверены?", "Подтверждение", list("Да", "Нет"))
			if(confirm != "Да")
				return TRUE
			if(QDELETED(offer_datum))
				tgui_alert_async(usr, "Персонаж больше не доступен.")
				return TRUE
			to_chat(the_owner, span_boldwarning("[usr.key] забрал вашего персонажа [character_name]!"))
			if(!prefs.load_character(provided = savefile))
				tgui_alert_async(usr, "Ошибка загрузки сейвфайла!")
				to_chat(the_owner, span_boldwarning("Ошибка при финальном шаге обмена."))
				qdel(offer_datum)
				return TRUE
			tgui_alert_async(usr, "Вы успешно получили [character_name]!")
			prefs.save_character(bypass_cooldown = TRUE)
			qdel(offer_datum)
			tainted_slots = TRUE
			update_preview()
			return TRUE

		if("delete_slot")
			var/num = text2num(params["slot"])
			if(!num)
				return TRUE
			// Count occupied slots
			var/occupied_count = 0
			if(prefs.path)
				var/savefile/S = new /savefile(prefs.path)
				if(S)
					for(var/i in 1 to prefs.max_save_slots)
						S.cd = "/character[i]"
						var/check_name
						S["real_name"] >> check_name
						if(check_name)
							occupied_count++
			if(occupied_count <= 1)
				tgui_alert_async(usr, "Нельзя удалить единственного персонажа!")
				return TRUE
			var/confirm = tgui_alert(usr, "Вы уверены, что хотите удалить этого персонажа? Это действие необратимо!", "Удаление", list("Да", "Нет"))
			if(confirm != "Да")
				return TRUE
			if(prefs.delete_character(num))
				tgui_alert_async(usr, "Персонаж удалён.")
				tainted_slots = TRUE
				update_preview()
			else
				tgui_alert_async(usr, "Ошибка удаления.")
			return TRUE

		// === GENERAL TAB ACTIONS ===
		if("set_name")
			var/new_name = sanitize_name(params["name"])
			if(new_name)
				prefs.real_name = new_name
				tainted_slots = TRUE
			return TRUE

		if("random_name")
			prefs.real_name = random_unique_name(prefs.gender)
			tainted_slots = TRUE
			return TRUE

		if("set_age")
			var/new_age = text2num(params["age"])
			if(new_age)
				prefs.age = clamp(new_age, AGE_MIN, AGE_MAX)
			return TRUE

		if("set_gender")
			var/new_gender = params["gender"]
			if(new_gender in list(MALE, FEMALE, PLURAL, NEUTER))
				prefs.gender = new_gender
			return TRUE

		if("toggle_nameless")
			prefs.nameless = !prefs.nameless
			return TRUE

		if("toggle_random_name")
			prefs.be_random_name = !prefs.be_random_name
			return TRUE

		if("toggle_random_body")
			prefs.be_random_body = !prefs.be_random_body
			return TRUE

		if("toggle_hide_ckey")
			prefs.hide_ckey = !prefs.hide_ckey
			return TRUE

		if("toggle_hardsuit_tail")
			prefs.features["hardsuit_with_tail"] = !prefs.features["hardsuit_with_tail"]
			return TRUE

		if("toggle_custom_blood_color")
			prefs.custom_blood_color = !prefs.custom_blood_color
			return TRUE

		// === APPEARANCE TAB ACTIONS ===
		if("set_body_model")
			var/new_model = params["model"]
			if(new_model in list(MALE, FEMALE))
				prefs.features["body_model"] = new_model
			return TRUE

		if("set_species")
			var/result = tgui_input_list(user, "Выберите расу", "Выбор расы", GLOB.roundstart_race_names)
			if(result)
				var/newtype = GLOB.species_list[GLOB.roundstart_race_names[result]]
				prefs.pref_species = new newtype()
				prefs.custom_species = null
				if(!owner?.can_have_part("mam_body_markings"))
					prefs.features["mam_body_markings"] = list()
				if(owner?.can_have_part("mam_body_markings"))
					if(prefs.features["mam_body_markings"] == "None")
						prefs.features["mam_body_markings"] = list()
				if(owner?.can_have_part("tail_lizard"))
					prefs.features["tail_lizard"] = "Smooth"
				if(prefs.pref_species.id == "felinid")
					prefs.features["mam_tail"] = "Cat"
					prefs.features["mam_ears"] = "Cat"
				var/temp_hsv = RGBtoHSV(prefs.features["mcolor"])
				if(prefs.features["mcolor"] == "#000000" || (!(MUTCOLORS_PARTSONLY in prefs.pref_species.species_traits) && ReadHSV(temp_hsv)[3] < ReadHSV("#202020")[3]))
					prefs.features["mcolor"] = prefs.pref_species.default_color
				if(prefs.features["mcolor2"] == "#000000" || (!(MUTCOLORS_PARTSONLY in prefs.pref_species.species_traits) && ReadHSV(temp_hsv)[3] < ReadHSV("#202020")[3]))
					prefs.features["mcolor2"] = prefs.pref_species.default_color
				if(prefs.features["mcolor3"] == "#000000" || (!(MUTCOLORS_PARTSONLY in prefs.pref_species.species_traits) && ReadHSV(temp_hsv)[3] < ReadHSV("#202020")[3]))
					prefs.features["mcolor3"] = prefs.pref_species.default_color
				prefs.eye_type = prefs.pref_species.eye_type
			return TRUE

		if("set_hair_style")
			var/new_style = params["style"]
			if(new_style in GLOB.hair_styles_list)
				prefs.hair_style = new_style
			return TRUE

		if("set_facial_hair_style")
			var/new_style = params["style"]
			if(new_style in GLOB.facial_hair_styles_list)
				prefs.facial_hair_style = new_style
			return TRUE

		if("set_grad_style")
			var/new_style = params["style"]
			if(new_style in GLOB.hair_gradients_list)
				prefs.grad_style = new_style
			return TRUE

		if("set_hair_color")
			var/new_color = params["color"]
			if(new_color)
				prefs.hair_color = sanitize_hexcolor(new_color)
			return TRUE

		if("set_facial_hair_color")
			var/new_color = params["color"]
			if(new_color)
				prefs.facial_hair_color = sanitize_hexcolor(new_color)
			return TRUE

		if("set_grad_color")
			var/new_color = params["color"]
			if(new_color)
				prefs.grad_color = sanitize_hexcolor(new_color)
			return TRUE

		if("set_eye_color")
			var/new_color = params["color"]
			var/side = params["side"]
			if(new_color)
				var/sanitized = sanitize_hexcolor(new_color)
				if(side == "left")
					prefs.left_eye_color = sanitized
				else if(side == "right")
					prefs.right_eye_color = sanitized
				else
					prefs.left_eye_color = sanitized
					prefs.right_eye_color = sanitized
			return TRUE

		if("toggle_split_eyes")
			prefs.split_eye_colors = !prefs.split_eye_colors
			if(!prefs.split_eye_colors)
				prefs.right_eye_color = prefs.left_eye_color
			return TRUE

		if("set_eye_type")
			var/new_type = params["type"]
			if(new_type in GLOB.eye_types)
				prefs.eye_type = new_type
			return TRUE

		if("set_skin_tone")
			var/list/choices = GLOB.skin_tones - GLOB.nonstandard_skin_tones
			if(CONFIG_GET(flag/allow_custom_skintones))
				choices += "custom"
			var/new_s_tone = tgui_input_list(user, "Выберите тон кожи персонажа:", "Тон Кожи", choices)
			if(new_s_tone)
				if(new_s_tone == "custom")
					var/default = prefs.use_custom_skin_tone ? prefs.skin_tone : null
					var/custom_tone = input(user, "Выберите свой тон кожи:", "Тон Кожи", default) as color|null
					if(custom_tone)
						var/temp_hsv = RGBtoHSV(custom_tone)
						if(ReadHSV(temp_hsv)[3] < ReadHSV("#333333")[3] && CONFIG_GET(flag/character_color_limits))
							to_chat(user, span_danger("Недопустимый цвет. Ваш цвет слишком тёмный."))
						else
							prefs.use_custom_skin_tone = TRUE
							prefs.skin_tone = custom_tone
				else
					prefs.use_custom_skin_tone = FALSE
					prefs.skin_tone = new_s_tone
			return TRUE

		if("set_mutant_color")
			var/which = params["which"]
			var/new_color = params["color"]
			if(new_color && which)
				var/sanitized = sanitize_hexcolor(new_color)
				switch(which)
					if("primary")
						prefs.features["mcolor"] = sanitized
					if("secondary")
						prefs.features["mcolor2"] = sanitized
					if("tertiary")
						prefs.features["mcolor3"] = sanitized
			return TRUE

		if("set_body_size")
			var/new_body_size = input(user, "Выберите размер спрайта: ([CONFIG_GET(number/body_size_min)*100]-[CONFIG_GET(number/body_size_max)*100]%)\nВнимание: размер влияет на скорость и максимальное здоровье.", "Размер Тела", prefs.features["body_size"]*100) as num|null
			if(new_body_size)
				prefs.features["body_size"] = clamp(new_body_size * 0.01, CONFIG_GET(number/body_size_min), CONFIG_GET(number/body_size_max))
			return TRUE

		if("set_mutant_part")
			var/part = params["part"]
			var/style = params["style"]
			if(part && style)
				var/ref_list = GLOB.mutant_reference_list[part]
				if(ref_list && (style in ref_list))
					prefs.features[part] = style
			return TRUE

		if("set_mutant_part_color")
			var/color_type = params["color_type"]
			var/new_color = params["color"]
			if(color_type && new_color)
				prefs.features[color_type] = sanitize_hexcolor(new_color)
			return TRUE

		if("set_underwear")
			var/new_underwear = params["value"]
			if(new_underwear in GLOB.underwear_list)
				prefs.underwear = new_underwear
			return TRUE

		if("set_undershirt")
			var/new_undershirt = params["value"]
			if(new_undershirt in GLOB.undershirt_list)
				prefs.undershirt = new_undershirt
			return TRUE

		if("set_socks")
			var/new_socks = params["value"]
			if(new_socks in GLOB.socks_list)
				prefs.socks = new_socks
			return TRUE

		if("set_bgstate")
			var/new_bg = params["value"]
			if(new_bg in list("000", "midgrey", "FFF", "white", "steel", "techmaint", "dark", "plating", "reinforced"))
				prefs.bgstate = new_bg
			return TRUE

		if("toggle_color_scheme")
			if(prefs.features["color_scheme"] == ADVANCED_CHARACTER_COLORING)
				prefs.features["color_scheme"] = OLD_CHARACTER_COLORING
			else
				prefs.features["color_scheme"] = ADVANCED_CHARACTER_COLORING
			return TRUE

		if("toggle_mismatched_markings")
			prefs.show_mismatched_markings = !prefs.show_mismatched_markings
			return TRUE

		if("toggle_fuzzy")
			prefs.fuzzy = !prefs.fuzzy
			return TRUE

		if("modify_limbs")
			var/limb_type = tgui_input_list(user, "Выберите конечность для модификации:", "Модификация Конечностей", LOADOUT_ALLOWED_LIMB_TARGETS)
			if(limb_type)
				var/modification_type = tgui_input_list(user, "Выберите тип модификации:", "Модификация Конечностей", LOADOUT_LIMBS)
				if(modification_type)
					if(modification_type == LOADOUT_LIMB_PROSTHETIC)
						var/prosthetic_type = tgui_input_list(user, "Выберите тип протеза:", "Модификация Конечностей", (list("prosthetic") + GLOB.prosthetic_limb_types))
						if(prosthetic_type)
							var/number_of_prosthetics = 0
							for(var/modified_limb in prefs.modified_limbs)
								if(prefs.modified_limbs[modified_limb][1] == LOADOUT_LIMB_PROSTHETIC && modified_limb != limb_type)
									number_of_prosthetics += 1
							if(number_of_prosthetics == MAXIMUM_LOADOUT_PROSTHETICS)
								to_chat(user, span_danger("Максимум [MAXIMUM_LOADOUT_PROSTHETICS] протеза!"))
							else
								prefs.modified_limbs[limb_type] = list(modification_type, prosthetic_type)
					else if(modification_type == LOADOUT_LIMB_NORMAL)
						prefs.modified_limbs -= limb_type
					else
						prefs.modified_limbs[limb_type] = list(modification_type)
			return TRUE

		// === APPEARANCE: Equipment handlers ===
		if("set_backbag")
			var/new_backbag = tgui_input_list(user, "Выберите стиль сумки персонажа:", "Стиль Сумки", GLOB.backbaglist)
			if(new_backbag)
				prefs.backbag = new_backbag
			return TRUE

		if("toggle_jumpsuit_style")
			if(prefs.jumpsuit_style == PREF_SUIT)
				prefs.jumpsuit_style = PREF_SKIRT
			else
				prefs.jumpsuit_style = PREF_SUIT
			return TRUE

		if("toggle_persistent_scars")
			prefs.persistent_scars = !prefs.persistent_scars
			return TRUE

		if("set_uplink_loc")
			var/new_loc = tgui_input_list(user, "Выберите место появления аплинка предателя:", "Расположение Аплинка", GLOB.uplink_spawn_loc_list)
			if(new_loc)
				prefs.uplink_spawn_loc = new_loc
			return TRUE

		// === BACKGROUND TAB ACTIONS ===
		if("set_flavor_text")
			var/msg = input(user, "Задайте внешнее описание вашего персонажа.", "Описание Внешности", prefs.features["flavor_text"]) as message|null
			if(!isnull(msg))
				prefs.features["flavor_text"] = strip_html_simple(msg, MAX_FLAVOR_LEN, TRUE)
			return TRUE

		if("set_naked_flavor_text")
			var/msg = input(user, "Задайте описание вашего персонажа без одежды.", "Описание Голого Персонажа", prefs.features["naked_flavor_text"]) as message|null
			if(!isnull(msg))
				prefs.features["naked_flavor_text"] = strip_html_simple(msg, MAX_FLAVOR_LEN, TRUE)
			return TRUE

		if("set_ooc_notes")
			var/msg = stripped_multiline_input(user, "Установите OOC-заметки, связанные с вашими предпочтениями.", "ООС-Заметки", html_decode(prefs.features["ooc_notes"]), MAX_FLAVOR_LEN, TRUE)
			if(!isnull(msg))
				prefs.features["ooc_notes"] = msg
			return TRUE

		if("set_custom_species_lore")
			var/msg = input(user, "Задайте особую предысторию расы своего персонажа.", "Предыстория Расы", prefs.features["custom_species_lore"]) as message|null
			if(!isnull(msg))
				prefs.features["custom_species_lore"] = strip_html_simple(msg, MAX_FLAVOR_LEN, TRUE)
			return TRUE

		if("set_security_records")
			var/rec = stripped_multiline_input(user, "Напишите заметки службы безопасности о вашем персонаже.", "Заметки СБ", html_decode(prefs.security_records), MAX_FLAVOR_LEN, TRUE)
			if(!isnull(rec))
				prefs.security_records = rec
			return TRUE

		if("set_medical_records")
			var/rec = stripped_multiline_input(user, "Напишите медицинские заметки о вашем персонаже.", "Мед. Заметки", html_decode(prefs.medical_records), MAX_FLAVOR_LEN, TRUE)
			if(!isnull(rec))
				prefs.medical_records = rec
			return TRUE

		if("set_custom_deathgasp")
			var/msg = input(user, "Задайте эмоцию смерти вашего персонажа.", "Сообщение О Смерти", prefs.features["custom_deathgasp"]) as message|null
			if(!isnull(msg))
				prefs.features["custom_deathgasp"] = strip_html_simple(msg, MAX_DEATHGASP_LEN, TRUE)
			return TRUE

		if("set_custom_deathsound")
			var/sound_name = tgui_input_list(user, "Выберите звук смерти персонажа:", "Звук Смерти", GLOB.deathgasp_sounds)
			if(sound_name)
				prefs.features["custom_deathsound"] = sound_name
			return TRUE

		if("set_silicon_flavor_text")
			var/msg = input(user, "Задайте особые признаки своего синтетического персонажа.", "Описание Борга", prefs.features["silicon_flavor_text"]) as message|null
			if(!isnull(msg))
				prefs.features["silicon_flavor_text"] = strip_html_simple(msg, MAX_FLAVOR_LEN, TRUE)
			return TRUE

		if("set_headshot")
			var/slot = params["slot"]
			prefs.set_headshot_link(user, "headshot_link[slot]")
			return TRUE

		if("set_naked_headshot")
			var/slot = params["slot"]
			prefs.set_headshot_link(user, "headshot_naked_link[slot]")
			return TRUE

		// === SPEECH TAB ACTIONS ===
		if("set_speech_verb")
			var/selected = tgui_input_list(user, "Выберите глагол речи (none = глагол вашей расы):", "Глагол Речи", GLOB.speech_verbs)
			if(selected)
				prefs.custom_speech_verb = selected
			return TRUE

		if("set_bark_sound")
			var/new_bark = params["bark"]
			if(new_bark in GLOB.bark_random_list)
				prefs.bark_id = new_bark
			return TRUE

		if("set_bark_pitch")
			var/new_pitch = text2num(params["value"])
			if(!isnull(new_pitch))
				prefs.bark_pitch = clamp(new_pitch, 0.5, 2)
			return TRUE

		if("set_bark_speed")
			var/new_speed = text2num(params["value"])
			if(!isnull(new_speed))
				prefs.bark_speed = clamp(new_speed, 1, 10)
			return TRUE

		if("set_bark_variance")
			var/new_variance = text2num(params["value"])
			if(!isnull(new_variance))
				prefs.bark_variance = clamp(new_variance, 0, 100)
			return TRUE

		if("preview_bark")
			if(SSticker.current_state == GAME_STATE_STARTUP)
				to_chat(user, span_warning("Предпрослушивание недоступно во время загрузки!"))
				return TRUE
			if(!COOLDOWN_FINISHED(prefs, bark_previewing))
				return TRUE
			if(!user)
				return TRUE
			COOLDOWN_START(prefs, bark_previewing, (5 SECONDS))
			QDEL_NULL(preview_barkbox)
			var/atom/movable/barkbox = new(get_turf(user))
			preview_barkbox = barkbox
			barkbox.set_bark(prefs.bark_id)
			var/total_delay
			for(var/i in 1 to (round((32 / prefs.bark_speed)) + 1))
				addtimer(CALLBACK(barkbox, TYPE_PROC_REF(/atom/movable, bark), list(user), 7, 70, BARK_DO_VARY(prefs.bark_pitch, prefs.bark_variance)), total_delay)
				total_delay += rand(DS2TICKS(prefs.bark_speed/4), DS2TICKS(prefs.bark_speed/4) + DS2TICKS(prefs.bark_speed/4)) TICKS
			QDEL_IN(barkbox, total_delay)
			return TRUE

		// === SPEECH: New handlers ===
		if("set_custom_tongue")
			var/selected = tgui_input_list(user, "Выберите язык (none = язык вашей расы):", "Язык", GLOB.roundstart_tongues)
			if(selected)
				prefs.custom_tongue = selected
			return TRUE

		if("set_custom_laugh")
			var/selected = tgui_input_list(user, "Выберите смех персонажа:", "Смех", GLOB.mob_laughs)
			if(selected)
				prefs.custom_laugh = selected
			return TRUE

		if("preview_laugh")
			if(SSticker.current_state == GAME_STATE_STARTUP)
				to_chat(user, span_warning("Предпрослушивание недоступно во время загрузки!"))
				return TRUE
			if(!COOLDOWN_FINISHED(prefs, laugh_preview))
				return TRUE
			if(!user || prefs.custom_laugh == "Default")
				return TRUE
			COOLDOWN_START(prefs, laugh_preview, (3 SECONDS))
			user.playsound_local(user, pick(get_laugh_sound(prefs.custom_laugh, FALSE)), 50)
			return TRUE

		if("toggle_language")
			var/lang_name = params["language_name"]
			if(!lang_name || !SSlanguage.languages_by_name[lang_name])
				return TRUE
			if(!prefs.toggle_language(lang_name))
				return TRUE
			prefs.language = sort_list(prefs.language)
			return TRUE

		if("reset_languages")
			prefs.language = list()
			return TRUE

		if("toggle_personal_chat_color")
			prefs.enable_personal_chat_color = !prefs.enable_personal_chat_color
			return TRUE

		if("set_personal_chat_color")
			var/new_chat_color = input(user, "Выберите цвет чата персонажа:", "Цвет Чата", prefs.personal_chat_color) as color|null
			if(new_chat_color)
				if(color_hex2num(new_chat_color) > 200)
					prefs.personal_chat_color = sanitize_hexcolor(new_chat_color, 6, TRUE)
				else
					to_chat(user, span_danger("Недопустимый цвет. Слишком тёмный."))
			return TRUE

		// === GENERAL TAB DELEGATION ===
		if("set_blood_color")
			var/picked = input(user, "Выбирайте цвет крови своего персонажа.", "Настройка персонажа", prefs.blood_color) as color|null
			if(picked)
				prefs.blood_color = sanitize_hexcolor(picked, 6, 1, initial(prefs.blood_color))
				if(!prefs.custom_blood_color)
					prefs.custom_blood_color = TRUE
			return TRUE

		if("set_custom_name")
			var/name_id = params["name_id"]
			var/value = params["value"]
			if(name_id && (name_id in GLOB.preferences_custom_names))
				prefs.custom_names[name_id] = sanitize_name(value)
			return TRUE

		if("set_security_dept")
			var/department = tgui_input_list(user, "Выберите предпочитаемый отдел охраны:", "Отделы безопасности", GLOB.security_depts_prefs)
			if(department)
				prefs.prefered_security_department = department
			return TRUE

		if("set_ai_core_display")
			var/ai_core_icon = tgui_input_list(user, "Выберите предпочитаемый экран ИИ:", "Экран ИИ-ядра", GLOB.ai_core_display_screens)
			if(ai_core_icon)
				prefs.preferred_ai_core_display = ai_core_icon
			return TRUE

		if("set_pda_color")
			var/picked = input(user, "Выбирайте цвет интерфейса своего КПК.", "Настройка персонажа", prefs.pda_color) as color|null
			if(picked)
				prefs.pda_color = picked
			return TRUE

		if("set_pda_style")
			var/picked = tgui_input_list(user, "Выбирайте стиль своего КПК.", "Настройка персонажа", GLOB.pda_styles, prefs.pda_style)
			if(picked)
				prefs.pda_style = picked
			return TRUE

		if("set_pda_skin")
			var/picked = tgui_input_list(user, "Выбирайте модель своего КПК.", "Настройка персонажа", GLOB.pda_reskins, prefs.pda_skin)
			if(picked)
				prefs.pda_skin = picked
			return TRUE

		if("set_pda_ringtone")
			var/picked = reject_bad_name(input(user, "Выбирайте рингтон своего КПК.", "Настройка персонажа", prefs.pda_ringtone) as null|text, TRUE)
			if(picked)
				prefs.pda_ringtone = picked
			return TRUE

		if("set_silicon_lawset")
			var/picked = tgui_input_list(user, "Выбирайте предпочитаемый список законов", "Настройка силикона", list("Нет") + CONFIG_GET(keyed_list/choosable_laws), prefs.silicon_lawset)
			if(picked)
				if(picked == "Нет")
					picked = null
				prefs.silicon_lawset = picked
			return TRUE

		if("set_body_weight")
			var/new_weight = tgui_input_number(user, "Введите вес тела (50–600 фунтов):", "Вес тела", prefs.body_weight, 600, 50)
			if(!isnull(new_weight))
				prefs.body_weight = clamp(new_weight, 50, 600)
			return TRUE

		if("refresh_preview")
			prefs.preview_dir_b64_cache = null
			prefs.invalidate_preview_mannequin()
			prefs.update_preview_icon()
			return TRUE

		if("rotate_preview")
			var/backwards = params["backwards"]
			prefs.preview_direction = turn(prefs.preview_direction, backwards ? 90 : -90)
			// Кэш уже есть — поворот мгновенный, регенерация не нужна
			if(prefs.preview_dir_b64_cache?["[prefs.preview_direction]"])
				SStgui.update_user_uis(user, /datum/character_setup_ui)
			else
				prefs.update_preview_icon()
			return TRUE

		if("set_preview_zoom")
			var/zoom = text2num(params["zoom"])
			if(!isnull(zoom))
				prefs.preview_zoom = clamp(round(zoom, 10), 50, 200)
				SStgui.update_user_uis(user, /datum/character_setup_ui)
			return TRUE

		// === JOB PREFERENCE HANDLERS ===
		if("set_job_priority")
			var/job_title = params["job_title"]
			var/level = text2num(params["level"])
			var/datum/job/J = SSjob.GetJob(job_title)
			if(!J)
				return FALSE
			if(jobban_isbanned(user, J.title))
				to_chat(user, span_danger("Вам запрещено играть на этой должности."))
				return FALSE
			if(J.is_species_blacklisted(user.client))
				to_chat(user, span_danger("Ваш вид не может занимать эту должность."))
				return FALSE
			if(level == 0)
				prefs.SetJobPreferenceLevel(J, null)
			else
				prefs.SetJobPreferenceLevel(J, level)
			prefs.save_preferences(user)
			return TRUE

		if("reset_jobs")
			prefs.ResetJobs()
			prefs.save_preferences(user)
			return TRUE

		if("set_jobless_role")
			var/role = text2num(params["role"])
			if(role in list(BEOVERFLOW, BERANDOMJOB, RETURNTOLOBBY))
				if(role == BEOVERFLOW && jobban_isbanned(user, SSjob.overflow_role))
					to_chat(user, span_danger("Вам запрещено играть на этой должности."))
					return FALSE
				prefs.joblessrole = role
				prefs.save_preferences(user)
			return TRUE

		if("set_alt_title")
			var/job_title = params["job_title"]
			var/alt_title = params["alt_title"]
			var/datum/job/J = SSjob.GetJob(job_title)
			if(!J)
				return FALSE
			if(alt_title == job_title || !alt_title)
				prefs.alt_titles_preferences -= job_title
			else if(alt_title in J.alt_titles)
				prefs.alt_titles_preferences[job_title] = alt_title
			prefs.save_preferences(user)
			return TRUE

		// === PREFERENCES TAB SWITCHING ===
		if("set_prefs_tab")
			var/tab = text2num(params["tab"])
			if(!isnull(tab))
				prefs.preferences_tab = tab
			return TRUE

		// === CONTENT PREFERENCES ACTIONS ===
		if("set_content_pref")
			var/pref = params["pref"]
			var/value = params["value"]
			if(!(value in list("Yes", "Ask", "No")))
				return
			switch(pref)
				if("erp_pref")
					prefs.erppref = value
				if("noncon_pref")
					prefs.nonconpref = value
					if(isliving(user?.mind?.current))
						var/mob/living/C = user.mind.current
						message_admins("[user.ckey]/[C.real_name] [ADMIN_FLW(C)][C.stat == DEAD ? " (DEAD)" : ""] меняет Non-Con на [value].")
						log_admin("[user.ckey]/[C.real_name][C.stat == DEAD ? " (DEAD)" : ""] меняет Non-Con на [value].")
				if("vore_pref")
					prefs.vorepref = value
				if("extreme_pref")
					prefs.extremepref = value
				if("unholy_pref")
					prefs.unholypref = value
				if("tattoo_pref")
					switch(prefs.tattoopref)
						if("Yes")
							prefs.tattoopref = "Ask"
						if("Ask")
							prefs.tattoopref = "No"
						if("No")
							prefs.tattoopref = "Yes"
					return TRUE
				if("extremeharm")
					switch(prefs.extremeharm)
						if("Yes")
							prefs.extremeharm = "No"
						if("No")
							prefs.extremeharm = "Yes"
					if(prefs.extremepref == "No")
						prefs.extremeharm = "No"
					return TRUE
				if("mobsex_pref")
					switch(prefs.mobsexpref)
						if("Yes")
							prefs.mobsexpref = "No"
						if("No")
							prefs.mobsexpref = "Yes"
					return TRUE
				if("hornyantags_pref")
					switch(prefs.hornyantagspref)
						if("Yes")
							prefs.hornyantagspref = "No"
						if("No")
							prefs.hornyantagspref = "Yes"
					return TRUE
			return TRUE

		if("toggle_arousable")
			prefs.arousable = !prefs.arousable
			return TRUE

		if("toggle_knotting")
			prefs.sexknotting = !prefs.sexknotting
			return TRUE

		if("toggle_cit")
			var/flag = params["flag"]
			switch(flag)
				if("genital_examine")
					prefs.cit_toggles ^= GENITAL_EXAMINE
				if("vore_examine")
					prefs.cit_toggles ^= VORE_EXAMINE
				if("hound_sleeper")
					prefs.cit_toggles ^= MEDIHOUND_SLEEPER
				if("toggleeatingnoise")
					prefs.cit_toggles ^= EATING_NOISES
				if("toggledigestionnoise")
					prefs.cit_toggles ^= DIGESTION_NOISES
				if("toggleforcefeedtrash")
					prefs.cit_toggles ^= TRASH_FORCEFEED
				if("breast_enlargement")
					prefs.cit_toggles ^= BREAST_ENLARGEMENT
				if("penis_enlargement")
					prefs.cit_toggles ^= PENIS_ENLARGEMENT
				if("butt_enlargement")
					prefs.cit_toggles ^= BUTT_ENLARGEMENT
				if("belly_inflation")
					prefs.cit_toggles ^= BELLY_INFLATION
				if("feminization")
					prefs.cit_toggles ^= FORCED_FEM
				if("masculinization")
					prefs.cit_toggles ^= FORCED_MASC
				if("hypno")
					prefs.cit_toggles ^= HYPNO
				if("never_hypno")
					prefs.cit_toggles ^= NEVER_HYPNO
				if("aphro")
					prefs.cit_toggles ^= NO_APHRO
				if("ass_slap")
					prefs.cit_toggles ^= NO_ASS_SLAP
				if("bimbo")
					prefs.cit_toggles ^= BIMBOFICATION
				if("auto_wag")
					prefs.cit_toggles ^= NO_AUTO_WAG
				if("disco_dance")
					prefs.cit_toggles ^= NO_DISCO_DANCE
				if("sex_jitter")
					prefs.cit_toggles ^= SEX_JITTER
				if("chastitypref")
					prefs.cit_toggles ^= CHASTITY
				if("stimulationpref")
					prefs.cit_toggles ^= STIMULATION
				if("edgingpref")
					prefs.cit_toggles ^= EDGING
				if("cumontopref")
					prefs.cit_toggles ^= CUM_ONTO
			return TRUE

		if("toggle_flag")
			var/flag = params["flag"]
			switch(flag)
				// toggles ^= CONSTANT
				if("hear_adminhelps")
					prefs.toggles ^= SOUND_ADMINHELP
				if("announce_login")
					prefs.toggles ^= ANNOUNCE_LOGIN
				if("combohud_lighting")
					prefs.toggles ^= COMBOHUD_LIGHTING
				if("disable_antag")
					prefs.toggles ^= NO_ANTAG
				if("hear_midis")
					prefs.toggles ^= SOUND_MIDI
				if("verb_consent")
					prefs.toggles ^= VERB_CONSENT
				if("ranged_verb_consent")
					prefs.toggles ^= RANGED_VERBS_CONSENT
				if("lewd_verb_sounds")
					prefs.toggles ^= LEWD_VERB_SOUNDS
				if("lobby_music")
					prefs.toggles ^= SOUND_LOBBY
				if("allow_midround_antag")
					prefs.toggles ^= MIDROUND_ANTAG
				if("member_public")
					prefs.toggles ^= MEMBER_PUBLIC
				if("hear_instruments")
					prefs.toggles ^= SOUND_INSTRUMENTS
				if("hear_announcements")
					prefs.toggles ^= SOUND_ANNOUNCEMENTS
				if("hear_jukeboxes")
					prefs.toggles ^= SOUND_JUKEBOXES
				// Simple bool toggles
				if("winflash")
					prefs.windowflashing = !prefs.windowflashing
				if("winnoise")
					prefs.windownoise = !prefs.windownoise
				// chat_toggles ^= CONSTANT
				if("ghost_ears")
					prefs.chat_toggles ^= CHAT_GHOSTEARS
				if("ghost_sight")
					prefs.chat_toggles ^= CHAT_GHOSTSIGHT
				if("ghost_whispers")
					prefs.chat_toggles ^= CHAT_GHOSTWHISPER
				if("ghost_radio")
					prefs.chat_toggles ^= CHAT_GHOSTRADIO
				if("ghost_pda")
					prefs.chat_toggles ^= CHAT_GHOSTPDA
				if("income_pings")
					prefs.chat_toggles ^= CHAT_BANKCARD
				if("pull_requests")
					prefs.chat_toggles ^= CHAT_PULLR
				// custom_colors ^= CONSTANT
				if("custom_color_ooc")
					prefs.custom_colors ^= CUSTOM_OOC
				if("custom_color_aooc")
					prefs.custom_colors ^= CUSTOM_AOOC
				// Ghost accessory cycling
				if("ghost_accs")
					var/new_ghost_accs = tgui_input_list(user, "Выберите режим аксессуаров призрака:", "Аксессуары Призрака", list(GHOST_ACCS_FULL_NAME, GHOST_ACCS_DIR_NAME, GHOST_ACCS_NONE_NAME))
					switch(new_ghost_accs)
						if(GHOST_ACCS_FULL_NAME)
							prefs.ghost_accs = GHOST_ACCS_FULL
						if(GHOST_ACCS_DIR_NAME)
							prefs.ghost_accs = GHOST_ACCS_DIR
						if(GHOST_ACCS_NONE_NAME)
							prefs.ghost_accs = GHOST_ACCS_NONE
				if("ghost_others")
					var/new_ghost_others = tgui_input_list(user, "Как показывать призраков других игроков?", "Другие Призраки", list(GHOST_OTHERS_THEIR_SETTING_NAME, GHOST_OTHERS_DEFAULT_SPRITE_NAME, GHOST_OTHERS_SIMPLE_NAME))
					switch(new_ghost_others)
						if(GHOST_OTHERS_THEIR_SETTING_NAME)
							prefs.ghost_others = GHOST_OTHERS_THEIR_SETTING
						if(GHOST_OTHERS_DEFAULT_SPRITE_NAME)
							prefs.ghost_others = GHOST_OTHERS_DEFAULT_SPRITE
						if(GHOST_OTHERS_SIMPLE_NAME)
							prefs.ghost_others = GHOST_OTHERS_SIMPLE
			return TRUE

		if("open_genital_config")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "genitals", "task" = "input"))
			return TRUE

		// === CONTENT: New handlers ===
		if("set_lust_tolerance")
			var/lust_tol = params["value"]
			if(!isnull(lust_tol))
				prefs.lust_tolerance = clamp(text2num(lust_tol), 25, 200)
			return TRUE

		if("set_sexual_potency")
			var/sexual_pot = params["value"]
			if(!isnull(sexual_pot))
				prefs.sexual_potency = clamp(text2num(sexual_pot), -1, 25)
			return TRUE

		if("toggle_arousal_multiplier")
			prefs.use_arousal_multiplier = !prefs.use_arousal_multiplier
			return TRUE

		if("set_arousal_multiplier")
			var/val = params["value"]
			if(!isnull(val))
				prefs.arousal_multiplier = clamp(text2num(val), 0, 300)
			return TRUE

		if("toggle_moaning_multiplier")
			prefs.use_moaning_multiplier = !prefs.use_moaning_multiplier
			return TRUE

		if("set_moaning_multiplier")
			var/val = params["value"]
			if(!isnull(val))
				prefs.moaning_multiplier = clamp(text2num(val), 0, 100)
			return TRUE

		if("toggle_favorite_interaction")
			var/key = params["key"]
			if(!key || !SSinteractions?.interactions[key])
				return TRUE
			var/datum/interaction/I = SSinteractions.interactions[key]
			if(I.type in prefs.favorite_interactions)
				LAZYREMOVE(prefs.favorite_interactions, I.type)
			else
				LAZYADD(prefs.favorite_interactions, I.type)
			prefs.save_preferences(bypass_cooldown = TRUE, silent = TRUE)
			return TRUE

		if("set_gfluid_blacklist")
			var/list/datum/reagent/fluid_list = GLOB.genital_fluids_list.Copy()
			var/list/blacklisted = list()
			for(var/r in prefs.gfluid_blacklist)
				LAZYADD(blacklisted, find_reagent_object_from_type(r))
			LAZYREMOVE(fluid_list, GLOB.default_genital_fluids + blacklisted)
			var/datum/reagent/selected = tgui_input_list(user, "Добавить жидкость в чёрный список:", "Чёрный Список Жидкостей", fluid_list)
			if(selected)
				LAZYADD(prefs.gfluid_blacklist, selected.type)
			return TRUE

		// === GAME PREFERENCES ACTIONS ===
		if("set_ui_style")
			var/pickedui = tgui_input_list(user, "Выберите стиль интерфейса:", "Стиль UI", GLOB.available_ui_styles, prefs.UI_style)
			if(pickedui)
				prefs.UI_style = pickedui
				if(owner?.mob?.hud_used)
					QDEL_NULL(owner.mob.hud_used)
					owner.mob.create_mob_hud()
					owner.mob.hud_used.show_hud(1, owner.mob)
			return TRUE

		if("toggle_outline")
			prefs.outline_enabled = !prefs.outline_enabled
			return TRUE

		if("set_outline_color")
			var/picked = input(user, "Выберите цвет контура:", "Цвет Контура", prefs.outline_color) as color|null
			if(picked != prefs.outline_color)
				prefs.outline_color = picked
			return TRUE

		if("set_screentip_pref")
			var/choice = tgui_input_list(user, "Выберите режим подсказок:", "Подсказки", GLOB.screentip_pref_options, prefs.screentip_pref)
			if(choice)
				prefs.screentip_pref = choice
			return TRUE

		if("set_screentip_color")
			var/picked = input(user, "Выберите цвет подсказок:", "Цвет Подсказок", prefs.screentip_color) as color|null
			if(picked)
				prefs.screentip_color = picked
			return TRUE

		if("toggle_screentip_images")
			prefs.screentip_images = !prefs.screentip_images
			return TRUE

		if("toggle_hotkeys")
			prefs.hotkeys = !prefs.hotkeys
			if(owner)
				owner.ensure_keys_set(prefs)
			return TRUE

		if("toggle_tgui_fancy")
			prefs.tgui_fancy = !prefs.tgui_fancy
			return TRUE

		if("toggle_tgui_lock")
			prefs.tgui_lock = !prefs.tgui_lock
			return TRUE

		if("toggle_chat_on_map")
			prefs.chat_on_map = !prefs.chat_on_map
			return TRUE

		if("set_max_chat_length")
			var/new_length = text2num(params["value"])
			if(!isnull(new_length))
				prefs.max_chat_length = clamp(new_length, 1, CHAT_MESSAGE_MAX_LENGTH)
			return TRUE

		if("toggle_see_chat_non_mob")
			prefs.see_chat_non_mob = !prefs.see_chat_non_mob
			return TRUE

		if("toggle_see_rc_emotes")
			prefs.see_rc_emotes = !prefs.see_rc_emotes
			return TRUE

		if("set_clientfps")
			var/new_fps = text2num(params["value"])
			if(!isnull(new_fps))
				prefs.clientfps = clamp(new_fps, 0, 240)
				if(owner)
					owner.fps = prefs.clientfps
			return TRUE

		if("toggle_antag_role")
			var/role_name = params["role"]
			if(!role_name || !(role_name in GLOB.special_roles))
				return
			if(jobban_isbanned(user, ROLE_INTEQ) || jobban_isbanned(user, role_name))
				return
			if(role_name in prefs.be_special)
				if(prefs.be_special[role_name] >= 1)
					prefs.be_special -= role_name
				else
					prefs.be_special[role_name] = 1
			else
				prefs.be_special += role_name
				prefs.be_special[role_name] = 0
			return TRUE

		// === GAME PREFS: New toggles ===
		if("toggle_widescreenpref")
			prefs.widescreenpref = !prefs.widescreenpref
			if(owner)
				owner.view_size.setDefault(getScreenSize(prefs.widescreenpref))
			return TRUE

		if("toggle_fullscreen")
			prefs.fullscreen = !prefs.fullscreen
			if(owner)
				owner.ToggleFullscreen()
			return TRUE

		if("toggle_long_strip_menu")
			prefs.long_strip_menu = !prefs.long_strip_menu
			return TRUE

		if("toggle_autostand")
			prefs.autostand = !prefs.autostand
			return TRUE

		if("toggle_auto_ooc")
			prefs.auto_ooc = !prefs.auto_ooc
			return TRUE

		if("toggle_auto_capitalize")
			prefs.auto_capitalize_enabled = !prefs.auto_capitalize_enabled
			return TRUE

		if("toggle_no_tetris")
			prefs.no_tetris_storage = !prefs.no_tetris_storage
			return TRUE

		if("set_screenshake")
			var/desiredshake = input(user, "Задайте силу тряски экрана (0 = выкл, 100 = макс):", "Тряска Экрана", prefs.screenshake) as null|num
			if(!isnull(desiredshake))
				prefs.screenshake = desiredshake
			return TRUE

		if("set_damagescreenshake")
			switch(prefs.damagescreenshake)
				if(0)
					prefs.damagescreenshake = 1
				if(1)
					prefs.damagescreenshake = 2
				if(2)
					prefs.damagescreenshake = 0
				else
					prefs.damagescreenshake = 1
			return TRUE

		if("set_recoil_screenshake")
			var/desiredshake = input(user, "Задайте силу тряски отдачи (0 = выкл, 100 = макс):", "Отдача", prefs.recoil_screenshake) as null|num
			if(!isnull(desiredshake))
				prefs.recoil_screenshake = desiredshake
			return TRUE

		if("set_parallax")
			prefs.parallax = WRAP(prefs.parallax + 1, PARALLAX_DISABLE, PARALLAX_INSANE + 1)
			if(owner?.parallax_holder)
				owner.parallax_holder.Reset()
			return TRUE

		if("toggle_ambientocclusion")
			prefs.ambientocclusion = !prefs.ambientocclusion
			if(owner?.mob?.hud_used)
				var/atom/movable/screen/plane_master/game_world/G = owner.mob.hud_used.plane_masters["[GAME_PLANE]"]
				var/atom/movable/screen/plane_master/above_wall/A = owner.mob.hud_used.plane_masters["[ABOVE_WALL_PLANE]"]
				var/atom/movable/screen/plane_master/wall/W = owner.mob.hud_used.plane_masters["[WALL_PLANE]"]
				G?.backdrop(owner.mob)
				A?.backdrop(owner.mob)
				W?.backdrop(owner.mob)
			return TRUE

		if("toggle_auto_fit_viewport")
			prefs.auto_fit_viewport = !prefs.auto_fit_viewport
			if(prefs.auto_fit_viewport && owner)
				owner.fit_viewport()
			return TRUE

		if("toggle_hud_flash")
			prefs.hud_toggle_flash = !prefs.hud_toggle_flash
			return TRUE

		if("set_hud_color")
			var/picked = input(user, "Выберите цвет мигания HUD:", "Цвет HUD", prefs.hud_toggle_color) as color|null
			if(picked)
				prefs.hud_toggle_color = picked
			return TRUE

		if("toggle_view_pixelshift")
			prefs.view_pixelshift = !prefs.view_pixelshift
			return TRUE

		if("toggle_combat_cursor")
			prefs.disable_combat_cursor = !prefs.disable_combat_cursor
			return TRUE

		if("toggle_combat_mouse_lock")
			prefs.disable_combat_mouse_lock = !prefs.disable_combat_mouse_lock
			return TRUE

		if("set_be_victim")
			var/picked = tgui_input_list(user, "Готовы ли вы к взаимодействию с антагонистами?", "Согласие Жертвы", list(BEVICTIM_NO, BEVICTIM_ASK, BEVICTIM_YES))
			if(picked)
				prefs.be_victim = picked
			return TRUE

		// === OOC PREFERENCES ACTIONS ===
		if("set_ooccolor")
			var/new_ooccolor = input(user, "Выберите цвет OOC:", "Цвет OOC", prefs.ooccolor) as color|null
			if(new_ooccolor)
				prefs.ooccolor = sanitize_ooccolor(new_ooccolor)
			return TRUE

		if("set_aooccolor")
			var/new_aooccolor = input(user, "Выберите цвет AOOC:", "Цвет AOOC", prefs.aooccolor) as color|null
			if(new_aooccolor)
				prefs.aooccolor = sanitize_ooccolor(new_aooccolor)
			return TRUE

		if("set_ghost_form")
			var/new_form = tgui_input_list(user, "Выберите форму призрака:", "Форма Призрака", GLOB.ghost_forms)
			if(new_form)
				prefs.ghost_form = new_form
			return TRUE

		if("set_ghost_orbit")
			var/new_orbit = tgui_input_list(user, "Выберите орбиту призрака:", "Орбита Призрака", GLOB.ghost_orbits)
			if(new_orbit)
				prefs.ghost_orbit = new_orbit
			return TRUE

		if("toggle_chat_flag")
			var/flag = params["flag"]
			if(flag)
				switch(flag)
					if("ghost_ears")
						prefs.chat_toggles ^= CHAT_GHOSTEARS
					if("ghost_sight")
						prefs.chat_toggles ^= CHAT_GHOSTSIGHT
					if("ghost_whispers")
						prefs.chat_toggles ^= CHAT_GHOSTWHISPER
					if("ghost_radio")
						prefs.chat_toggles ^= CHAT_GHOSTRADIO
					if("ghost_pda")
						prefs.chat_toggles ^= CHAT_GHOSTPDA
					if("income_pings")
						prefs.chat_toggles ^= CHAT_BANKCARD
					if("pull_requests")
						prefs.chat_toggles ^= CHAT_PULLR
			return TRUE

		// === MARKINGS ACTIONS ===
		if("marking_add")
			var/limb_name = params["limb"]
			var/marking_name = params["marking"]
			if(!limb_name || !marking_name)
				return TRUE
			var/datum/sprite_accessory/mam_body_markings/marking = GLOB.mam_body_markings_list[marking_name]
			if(!istype(marking))
				return TRUE
			// ckey check
			if(marking.ckeys_allowed && !marking.ckeys_allowed.Find(user.client?.ckey))
				return TRUE
			var/list/L = prefs.features["mam_body_markings"]
			if(!islist(L))
				L = list()
				prefs.features["mam_body_markings"] = L
			if(limb_name == "All")
				for(var/limb in marking.covered_limbs)
					var/limb_value = text2num(GLOB.bodypart_values[limb])
					L += list(list(limb_value, marking_name))
			else
				if(!(limb_name in marking.covered_limbs))
					return TRUE
				var/limb_value = text2num(GLOB.bodypart_values[limb_name])
				L += list(list(limb_value, marking_name))
			return TRUE

		if("marking_remove")
			var/index = text2num(params["index"])
			var/list/L = prefs.features["mam_body_markings"]
			if(index && islist(L) && index >= 1 && index <= length(L))
				L.Cut(index, index + 1)
			return TRUE

		if("marking_up")
			var/index = text2num(params["index"])
			var/list/L = prefs.features["mam_body_markings"]
			if(index && islist(L) && index > 1 && index <= length(L))
				L.Swap(index, index - 1)
			return TRUE

		if("marking_down")
			var/index = text2num(params["index"])
			var/list/L = prefs.features["mam_body_markings"]
			if(index && islist(L) && index >= 1 && index < length(L))
				L.Swap(index, index + 1)
			return TRUE

		if("marking_color")
			var/index = text2num(params["index"])
			var/color_number = text2num(params["color_num"])
			if(!index || !color_number)
				return TRUE
			var/list/L = prefs.features["mam_body_markings"]
			if(!islist(L) || index < 1 || index > length(L))
				return TRUE
			var/list/marking_entry = L[index]
			if(!islist(marking_entry) || length(marking_entry) < 2)
				return TRUE
			// Ensure colors list exists
			if(length(marking_entry) < 3 || !islist(marking_entry[3]))
				marking_entry.len = 3
				marking_entry[3] = list("#FFFFFF", "#FFFFFF", "#FFFFFF")
			// MATRIX color remapping
			var/datum/sprite_accessory/mam_body_markings/S = GLOB.mam_body_markings_list[marking_entry[2]]
			if(istype(S))
				var/limb_name = GLOB.bodypart_names[num2text(marking_entry[1])]
				var/matrixed_sections = S.covered_limbs[limb_name]
				if(color_number == 1)
					switch(matrixed_sections)
						if(MATRIX_GREEN)
							color_number = 2
						if(MATRIX_BLUE)
							color_number = 3
				else if(color_number == 2)
					switch(matrixed_sections)
						if(MATRIX_RED_BLUE)
							color_number = 3
						if(MATRIX_GREEN_BLUE)
							color_number = 3
			var/list/color_list = marking_entry[3]
			if(color_number < 1 || color_number > length(color_list))
				return TRUE
			// Use provided color or open color picker
			var/new_color = params["color"]
			if(!new_color)
				new_color = input(user, "Выберите цвет маркинга:", "Цвет маркинга", color_list[color_number]) as color|null
			if(!new_color)
				return TRUE
			// Validate color brightness
			var/sanitized = "#[sanitize_hexcolor(new_color, 6)]"
			var/temp_hsv = RGBtoHSV(sanitized)
			if(prefs.pref_species && !((MUTCOLORS_PARTSONLY in prefs.pref_species.species_traits) || ReadHSV(temp_hsv)[3] >= ReadHSV(MINIMUM_MUTANT_COLOR)[3] || !CONFIG_GET(flag/character_color_limits)))
				to_chat(user, span_danger("Недопустимый цвет. Цвет недостаточно яркий."))
				return TRUE
			color_list[color_number] = sanitized
			return TRUE

		if("markings_clear_limb")
			var/limb_name = params["limb"]
			if(!limb_name)
				return TRUE
			var/list/L = prefs.features["mam_body_markings"]
			if(!islist(L))
				return TRUE
			if(limb_name == "All")
				clearlist(L)
			else
				var/limb_value = text2num(GLOB.bodypart_values[limb_name])
				for(var/i = length(L), i >= 1, i--)
					var/list/entry = L[i]
					if(islist(entry) && entry[1] == limb_value)
						L.Cut(i, i + 1)
			return TRUE

		if("markings_remove_all")
			clearlist(prefs.features["mam_body_markings"])
			return TRUE

		if("open_tattoo_manager")
			user.client?.open_tattoo_manager()
			return TRUE

		// === LOADOUT ACTIONS ===
		if("select_loadout_slot")
			var/slot = text2num(params["slot"])
			if(slot && slot >= 1 && slot <= MAXIMUM_LOADOUT_SAVES)
				prefs.loadout_slot = slot
			return TRUE

		if("toggle_loadout_enabled")
			prefs.loadout_enabled = !prefs.loadout_enabled
			return TRUE

		if("select_loadout_category")
			var/cat = params["category"]
			if(cat && GLOB.loadout_items[cat])
				prefs.gear_category = cat
				// Auto-select first subcategory
				for(var/sc in GLOB.loadout_items[cat])
					prefs.gear_subcategory = sc
					break
			return TRUE

		if("select_loadout_subcategory")
			var/subcat = params["subcategory"]
			if(subcat && prefs.gear_category && GLOB.loadout_items[prefs.gear_category] && GLOB.loadout_items[prefs.gear_category][subcat])
				prefs.gear_subcategory = subcat
			return TRUE

		if("toggle_gear")
			var/gear_type_path = params["name"]
			var/toggle = text2num(params["toggle"])
			if(!gear_type_path)
				return FALSE
			if(!toggle && prefs.has_loadout_gear(prefs.loadout_slot, gear_type_path))
				// Remove gear
				var/gear = prefs.has_loadout_gear(prefs.loadout_slot, gear_type_path)
				if(gear[LOADOUT_IS_HEIRLOOM])
					gear[LOADOUT_IS_HEIRLOOM] = FALSE
				prefs.remove_gear_from_loadout(prefs.loadout_slot, gear_type_path)
			else if(toggle && !prefs.has_loadout_gear(prefs.loadout_slot, gear_type_path))
				// Add gear — find the datum by type path
				var/datum/gear/G = find_gear_by_type(gear_type_path)
				if(!G)
					return FALSE
				if(G.donoritem && !G.donator_ckey_check(user.ckey))
					to_chat(user, span_danger("Этот предмет доступен только донатерам."))
					return FALSE
				if(istype(G, /datum/gear/unlockable) && !prefs.can_use_unlockable(G))
					to_chat(user, span_danger("Вы не выполнили требования для этого предмета."))
					return FALSE
				if(prefs.gear_points >= initial(G.cost))
					var/list/new_loadout_data = list(LOADOUT_ITEM = gear_type_path)
					if(length(G.loadout_initial_colors))
						new_loadout_data[LOADOUT_COLOR] = G.loadout_initial_colors.Copy()
					else
						new_loadout_data[LOADOUT_COLOR] = list("#FFFFFF")
					LAZYINITLIST(prefs.loadout_data["SAVE_[prefs.loadout_slot]"])
					prefs.loadout_data["SAVE_[prefs.loadout_slot]"] += list(new_loadout_data)
				else
					to_chat(user, span_danger("Недостаточно очков экипировки."))
					return FALSE
			prefs.save_preferences(user)
			return TRUE

		if("loadout_color")
			var/gear_type_path = params["name"]
			if(!gear_type_path)
				return FALSE
			var/user_gear = prefs.has_loadout_gear(prefs.loadout_slot, gear_type_path)
			if(!user_gear)
				return FALSE
			var/datum/gear/G = find_gear_by_type(gear_type_path)
			if(!G)
				return FALSE
			if(G.loadout_flags & LOADOUT_CAN_COLOR_POLYCHROMIC)
				// Polychromic — let user pick color index
				if(!length(user_gear[LOADOUT_COLOR]))
					user_gear[LOADOUT_COLOR] = list("#FFFFFF")
				var/list/color_options = list()
				for(var/i in 1 to length(user_gear[LOADOUT_COLOR]))
					color_options += "Цвет [i]"
				var/choice = tgui_input_list(user, "Какой цвет изменить?", "Полихромный цвет", color_options)
				if(!choice)
					return FALSE
				var/color_index = text2num(copytext(choice, 6))
				if(!color_index || color_index < 1 || color_index > length(user_gear[LOADOUT_COLOR]))
					return FALSE
				var/current_color = user_gear[LOADOUT_COLOR][color_index]
				var/new_color = input(user, "Выберите цвет:", "Цвет снаряжения", current_color) as color|null
				if(new_color)
					user_gear[LOADOUT_COLOR][color_index] = sanitize_hexcolor(new_color, 6, TRUE, current_color)
			else
				// Mono color
				if(!length(user_gear[LOADOUT_COLOR]))
					user_gear[LOADOUT_COLOR] = list("#FFFFFF")
				var/current_color = user_gear[LOADOUT_COLOR][1]
				var/new_color = input(user, "Выберите цвет:", "Цвет снаряжения", current_color) as color|null
				if(new_color)
					user_gear[LOADOUT_COLOR][1] = sanitize_hexcolor(new_color, 6, TRUE, current_color)
			prefs.save_preferences(user)
			return TRUE

		if("loadout_rename")
			var/gear_type_path = params["name"]
			if(!gear_type_path)
				return FALSE
			var/user_gear = prefs.has_loadout_gear(prefs.loadout_slot, gear_type_path)
			if(!user_gear)
				return FALSE
			var/datum/gear/G = find_gear_by_type(gear_type_path)
			if(!G || !(G.loadout_flags & LOADOUT_CAN_NAME))
				return FALSE
			var/new_name = stripped_input(user, "Введите новое название:", "Переименование", user_gear[LOADOUT_CUSTOM_NAME], MAX_NAME_LEN)
			if(new_name)
				user_gear[LOADOUT_CUSTOM_NAME] = new_name
				prefs.save_preferences(user)
			return TRUE

		if("loadout_heirloom")
			var/gear_type_path = params["name"]
			if(!gear_type_path)
				return FALSE
			var/user_gear = prefs.has_loadout_gear(prefs.loadout_slot, gear_type_path)
			if(!user_gear)
				return FALSE
			if(user_gear[LOADOUT_IS_HEIRLOOM])
				// Remove heirloom
				user_gear[LOADOUT_IS_HEIRLOOM] = FALSE
			else
				// Check if already have an heirloom
				var/existing = prefs.find_gear_with_property(prefs.loadout_slot, LOADOUT_IS_HEIRLOOM, TRUE)
				if(existing)
					to_chat(user, span_danger("У вас уже есть реликвия в этом слоте."))
					return FALSE
				// Check if item is allowed as heirloom
				var/resolved_path = text2path(gear_type_path)
				if(!ispath(resolved_path))
					return FALSE
				var/datum/gear/temp_gear = new resolved_path()
				var/forbidden = ispath_in_list(temp_gear.path, LOADOUT_IS_DISALLOWED_HEIRLOOM)
				qdel(temp_gear)
				if(forbidden)
					to_chat(user, span_danger("Этот предмет не может быть реликвией."))
					return FALSE
				user_gear[LOADOUT_IS_HEIRLOOM] = TRUE
			prefs.save_preferences(user)
			return TRUE

		if("clear_loadout")
			prefs.loadout_data["SAVE_[prefs.loadout_slot]"] = list()
			prefs.save_preferences(user)
			return TRUE

		// === QUIRKS ACTIONS ===
		if("toggle_quirk")
			var/qname = params["name"]
			if(qname)
				if(qname in prefs.all_quirks)
					prefs.all_quirks -= qname
				else
					prefs.all_quirks += qname
			return TRUE

		if("reset_quirks")
			prefs.all_quirks = list()
			return TRUE

		if("change_shriek_option")
			var/new_shriek_type = tgui_input_list(user, "Выберите тип крика персонажа:", "Тип крика", GLOB.shriek_types, prefs.shriek_type)
			if(new_shriek_type)
				prefs.shriek_type = new_shriek_type
			return TRUE

		if("set_summon_nickname")
			var/new_nickname = input(user, "Задайте прозвище при призыве персонажа:", "Прозвище призыва", prefs.summon_nickname) as text|null
			if(new_nickname)
				new_nickname = reject_bad_name(new_nickname, allow_numbers = TRUE)
				if(new_nickname)
					prefs.summon_nickname = new_nickname
				else
					to_chat(user, span_warning("Недопустимое прозвище. Минимум 2, максимум [MAX_NAME_LEN] символов. Допускаются: A-Z, a-z, А-Я, а-я, -, ', ."))
			return TRUE

		// === KEYBINDINGS ACTIONS ===
		if("capture_keybinding")
			var/kb_name = params["keybinding"]
			var/old_key = params["old_key"]
			var/independent = params["independent"]
			var/datum/keybinding/kb = GLOB.keybindings_by_name[kb_name]
			if(kb)
				prefs.CaptureKeybinding(user, kb, old_key, text2num(independent), kb.special || kb.clientside)
			return TRUE

		if("reset_keybinds")
			prefs.key_bindings = deepCopyList(GLOB.hotkey_keybinding_list_by_key)
			prefs.modless_key_bindings = list()
			if(owner)
				owner.ensure_keys_set(prefs)
			return TRUE

		if("select_kb_category")
			// Just store locally, handled by frontend
			return TRUE

		// === SAVE / LOAD ===
		if("save")
			prefs.save_character()
			prefs.save_preferences()
			tainted_slots = TRUE
			return TRUE

		if("load")
			if(prefs.char_queue)
				deltimer(prefs.char_queue)
			prefs.load_preferences()
			prefs.load_character()
			tainted_slots = TRUE
			update_preview()
			return TRUE

		if("randomize_all")
			prefs.random_character()
			tainted_slots = TRUE
			update_preview()
			return TRUE

	// After any action, re-save and update preview
	if(.)
		prefs.save_character()
		// Update preview for appearance-affecting actions

/client
	var/datum/character_setup_ui/character_setup

/// Open the TGui CharacterSetup for a client
/client/proc/open_character_setup_tgui()
	if(!character_setup)
		character_setup = new(src)
	character_setup.ui_interact(mob)

/// Verb to open the new TGui character setup
/client/verb/character_setup_tgui()
	set name = "Character Setup (TGui)"
	set category = "Preferences.Game"
	set desc = "Open TGui Character Setup"
	open_character_setup_tgui()
