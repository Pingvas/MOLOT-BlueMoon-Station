/**
 * TGui-based Character Setup UI
 * Replaces the legacy HTML-based ShowChoices() interface
 */

/datum/character_setup_ui
	/// The client that owns this UI
	var/client/owner
	/// Reference to the preferences datum
	var/datum/preferences/prefs
	/// Native BYOND map view for character preview
	var/atom/movable/screen/map_view/char_preview/character_preview_view
	/// Cached character slot data (tainted_character_profiles pattern from SPLURT)
	var/list/cached_slots
	/// Whether slot cache needs rebuilding
	var/tainted_slots = TRUE

/datum/character_setup_ui/New(client/C)
	if(!C)
		qdel(src)
		return
	owner = C
	prefs = C.prefs

/datum/character_setup_ui/Destroy()
	QDEL_NULL(character_preview_view)
	if(owner)
		owner.character_setup = null
	owner = null
	prefs = null
	return ..()

/datum/character_setup_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/character_setup_ui/ui_close(mob/user)
	prefs?.save_character()
	prefs?.save_preferences()
	QDEL_NULL(character_preview_view)

/datum/character_setup_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		if(!character_preview_view)
			create_character_preview_view(user)
		ui = new(user, src, "CharacterSetup")
		ui.set_autoupdate(FALSE)
		ui.open()
		character_preview_view.display_to(user, ui.window)

/datum/character_setup_ui/ui_static_data(mob/user)
	var/list/data = list()

	// Species list
	var/list/species_list = list()
	for(var/species_id in GLOB.roundstart_races)
		var/datum/species/S = new species_id()
		species_list += list(list(
			"id" = S.id,
			"name" = S.name,
			"sexes" = S.sexes,
			"use_skintones" = S.use_skintones,
		))
		qdel(S)
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

	// Character preview map view ID
	if(character_preview_view)
		data["character_preview_view"] = character_preview_view.assigned_map

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

	// === MARKINGS DATA ===
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
			markings_data += list(list(
				"index" = i,
				"limb_value" = limb_value,
				"limb_name" = limb_name,
				"marking_name" = marking_name,
				"colors" = colors,
			))
	data["markings"] = markings_data

	// === LOADOUT DATA ===
	data["loadout_slot"] = prefs.loadout_slot
	data["loadout_enabled"] = prefs.loadout_enabled
	data["gear_points"] = prefs.gear_points
	data["gear_category"] = prefs.gear_category
	data["gear_subcategory"] = prefs.gear_subcategory

	// Current loadout items
	var/list/loadout_items = list()
	if(prefs.loadout_data && prefs.loadout_data["[prefs.loadout_slot]"])
		var/list/slot_data = prefs.loadout_data["[prefs.loadout_slot]"]
		for(var/gear_path in slot_data)
			var/list/item_data = slot_data[gear_path]
			loadout_items += list(list(
				"path" = gear_path,
				"name" = item_data[LOADOUT_CUSTOM_NAME] || gear_path,
				"color" = item_data[LOADOUT_COLOR],
				"is_heirloom" = item_data[LOADOUT_IS_HEIRLOOM],
			))
	data["loadout_items"] = loadout_items

	// Items in current category
	var/list/category_items = list()
	if(prefs.gear_category && GLOB.loadout_items[prefs.gear_category])
		var/curr_subcat = prefs.gear_subcategory
		if(!curr_subcat || !GLOB.loadout_items[prefs.gear_category][curr_subcat])
			for(var/sc in GLOB.loadout_items[prefs.gear_category])
				curr_subcat = sc
				break
		if(curr_subcat && GLOB.loadout_items[prefs.gear_category][curr_subcat])
			for(var/item_name in GLOB.loadout_items[prefs.gear_category][curr_subcat])
				var/datum/gear/G = GLOB.loadout_items[prefs.gear_category][curr_subcat][item_name]
				if(!G)
					continue
				var/is_selected = !!prefs.has_loadout_gear(prefs.loadout_slot, "[G.type]")
				category_items += list(list(
					"name" = item_name,
					"path" = "[G.type]",
					"cost" = G.cost,
					"description" = G.description,
					"selected" = is_selected,
					"can_color" = !!(G.loadout_flags & LOADOUT_CAN_COLOR_POLYCHROMIC),
					"can_name" = !!(G.loadout_flags & LOADOUT_CAN_NAME),
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

/// Create the native BYOND map view for character preview
/datum/character_setup_ui/proc/create_character_preview_view(mob/user)
	QDEL_NULL(character_preview_view)
	character_preview_view = new(null, prefs)
	character_preview_view.generate_view("char_preview_[REF(character_preview_view)]")
	character_preview_view.update_body()
	return character_preview_view

/// Native BYOND character preview using map_view
/atom/movable/screen/map_view/char_preview
	name = "character_preview"
	icon = 'modular_citadel/icons/ui/backgrounds.dmi'
	icon_state = "000"
	/// The body that is displayed
	var/mob/living/carbon/human/dummy/body
	/// The preferences this refers to
	var/datum/preferences/preferences

/atom/movable/screen/map_view/char_preview/Initialize(mapload, datum/preferences/preferences)
	. = ..()
	src.preferences = preferences
	if(preferences?.bgstate)
		icon_state = preferences.bgstate

/atom/movable/screen/map_view/char_preview/Destroy()
	QDEL_NULL(body)
	preferences = null
	return ..()

/// Updates the displayed preview body
/atom/movable/screen/map_view/char_preview/proc/update_body()
	if(isnull(body))
		create_body()
	else
		body.wipe_state()

	cut_overlays()

	// Update background
	icon_state = preferences?.bgstate || "000"

	var/datum/job/preview_job = preferences.get_highest_job()

	// Handle silicon previews
	if(preview_job)
		if(istype(preview_job, /datum/job/ai))
			var/mutable_appearance/ai_ma = mutable_appearance('icons/mob/ai.dmi', icon_state = resolve_ai_icon(preferences.preferred_ai_core_display))
			ai_ma.setDir(SOUTH)
			ai_ma.transform = matrix()
			ai_ma.pixel_x = 0
			ai_ma.pixel_y = 0
			add_overlay(ai_ma)
			return
		if(istype(preview_job, /datum/job/cyborg))
			var/mutable_appearance/borg_ma = mutable_appearance('icons/mob/robots.dmi', icon_state = "robot")
			borg_ma.setDir(SOUTH)
			borg_ma.transform = matrix()
			borg_ma.pixel_x = 0
			borg_ma.pixel_y = 0
			add_overlay(borg_ma)
			return

	preferences.copy_to(body, initial_spawn = TRUE)

	switch(preferences.preview_pref)
		if(PREVIEW_PREF_JOB)
			if(preview_job)
				body.job = preview_job.title
				preview_job.equip(body, TRUE, preference_source = preferences.parent)
		if(PREVIEW_PREF_LOADOUT)
			if(preferences.parent)
				SSjob.equip_loadout(preferences.parent.mob, body, bypass_prereqs = TRUE, can_drop = FALSE, is_dummy = TRUE)
				SSjob.post_equip_loadout(preferences.parent.mob, body, bypass_prereqs = TRUE, can_drop = FALSE, is_dummy = TRUE)
		if(PREVIEW_PREF_NAKED_AROUSED)
			for(var/obj/item/organ/genital/genital in body.internal_organs)
				if(CHECK_BITFIELD(genital.genital_flags, GENITAL_CAN_AROUSE))
					genital.set_aroused_state(TRUE, null)

	body.regenerate_icons()

	var/mutable_appearance/body_ma = new(body)
	body_ma.setDir(body.dir)
	body_ma.transform = matrix()
	body_ma.pixel_x = 0
	body_ma.pixel_y = 0
	add_overlay(body_ma)

/atom/movable/screen/map_view/char_preview/proc/create_body()
	QDEL_NULL(body)
	body = new

/// Set direction of the preview
/atom/movable/screen/map_view/char_preview/proc/set_preview_dir(new_dir)
	if(body)
		body.setDir(new_dir)
		update_body()

/datum/character_setup_ui/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	if(!prefs || !owner)
		return

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
				if(character_preview_view)
					character_preview_view.update_body()
			return TRUE

		// === CHARACTER SLOTS ===
		if("change_slot")
			var/num = text2num(params["slot"])
			if(num && num >= 1 && num <= prefs.max_save_slots)
				prefs.default_slot = num
				prefs.load_character()
				tainted_slots = TRUE
				if(character_preview_view)
					character_preview_view.update_body()
			return TRUE

		if("toggle_empty_slots")
			prefs.collapse_empty_character_slots = !prefs.collapse_empty_character_slots
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
			// Delegate to existing process_link behavior
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "species", "task" = "input"))
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
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "s_tone", "task" = "input"))
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
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "body_size", "task" = "input"))
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
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "modify_limbs", "task" = "input"))
			return TRUE

		// === APPEARANCE: Equipment handlers ===
		if("set_backbag")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "bag", "task" = "input"))
			return TRUE

		if("toggle_jumpsuit_style")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "suit"))
			return TRUE

		if("toggle_persistent_scars")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "persistent_scars"))
			return TRUE

		if("set_uplink_loc")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "uplink_loc", "task" = "input"))
			return TRUE

		// === BACKGROUND TAB ACTIONS ===
		if("set_flavor_text")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "flavor_text", "task" = "input"))
			return TRUE

		if("set_naked_flavor_text")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "naked_flavor_text", "task" = "input"))
			return TRUE

		if("set_ooc_notes")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "ooc_notes", "task" = "input"))
			return TRUE

		if("set_custom_species_lore")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "custom_species_lore", "task" = "input"))
			return TRUE

		if("set_security_records")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "security_records", "task" = "input"))
			return TRUE

		if("set_medical_records")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "medical_records", "task" = "input"))
			return TRUE

		if("set_custom_deathgasp")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "custom_deathgasp", "task" = "input"))
			return TRUE

		if("set_custom_deathsound")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "custom_deathsound", "task" = "input"))
			return TRUE

		if("set_silicon_flavor_text")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "silicon_flavor_text", "task" = "input"))
			return TRUE

		if("set_headshot")
			var/slot = params["slot"]
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "headshot[slot]"))
			return TRUE

		if("set_naked_headshot")
			var/slot = params["slot"]
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "headshot_naked[slot]"))
			return TRUE

		// === SPEECH TAB ACTIONS ===
		if("set_speech_verb")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "speech_verb", "task" = "input"))
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
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "barkpreview"))
			return TRUE

		// === SPEECH: New handlers ===
		if("set_custom_tongue")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "tongue", "task" = "input"))
			return TRUE

		if("set_custom_laugh")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "laugh", "task" = "input"))
			return TRUE

		if("preview_laugh")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "laughpreview"))
			return TRUE

		if("set_languages")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "language", "task" = "menu"))
			return TRUE

		if("toggle_personal_chat_color")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "enable_personal_chat_color"))
			return TRUE

		if("set_personal_chat_color")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "personal_chat_color", "task" = "input"))
			return TRUE

		// === GENERAL TAB DELEGATION ===
		if("set_blood_color")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "blood_color", "task" = "input"))
			return TRUE

		if("set_custom_name")
			var/name_id = params["name_id"]
			var/value = params["value"]
			if(name_id && (name_id in GLOB.preferences_custom_names))
				prefs.custom_names[name_id] = sanitize_name(value)
			return TRUE

		if("set_security_dept")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "sec_dept", "task" = "input"))
			return TRUE

		if("set_ai_core_display")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "ai_core_icon", "task" = "input"))
			return TRUE

		if("set_pda_color")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "pda_color", "task" = "input"))
			return TRUE

		if("set_pda_style")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "pda_style", "task" = "input"))
			return TRUE

		if("set_pda_skin")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "pda_skin", "task" = "input"))
			return TRUE

		if("set_pda_ringtone")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "pda_ringtone", "task" = "input"))
			return TRUE

		if("set_silicon_lawset")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "silicon_lawset", "task" = "input"))
			return TRUE

		if("set_body_weight")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "body_weight", "task" = "input"))
			return TRUE

		if("refresh_preview")
			if(character_preview_view)
				character_preview_view.update_body()
			return TRUE

		if("rotate_preview")
			if(character_preview_view)
				var/backwards = params["backwards"]
				var/new_dir = turn(character_preview_view.body?.dir || SOUTH, backwards ? 90 : -90)
				character_preview_view.set_preview_dir(new_dir)
			return TRUE

		// === JOB / QUIRK DELEGATION ===
		if("open_job_menu")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "job", "task" = "menu"))
			return TRUE

		if("open_quirk_menu")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "trait", "task" = "menu"))
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
					prefs.process_link(user, list("_src_" = "prefs", "preference" = "tattoo_pref"))
					return TRUE
				if("extremeharm")
					prefs.process_link(user, list("_src_" = "prefs", "preference" = "extremeharm"))
					return TRUE
				if("mobsex_pref")
					prefs.process_link(user, list("_src_" = "prefs", "preference" = "mobsex_pref"))
					return TRUE
				if("hornyantags_pref")
					prefs.process_link(user, list("_src_" = "prefs", "preference" = "hornyantags_pref"))
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
			prefs.process_link(user, list("_src_" = "prefs", "preference" = flag))
			return TRUE

		if("toggle_flag")
			var/flag = params["flag"]
			prefs.process_link(user, list("_src_" = "prefs", "preference" = flag))
			return TRUE

		if("open_genital_config")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "genitals", "task" = "input"))
			return TRUE

		// === CONTENT: New handlers ===
		if("set_lust_tolerance")
			var/new_val = text2num(params["value"])
			if(!isnull(new_val))
				prefs.process_link(user, list("_src_" = "prefs", "preference" = "lust_tolerance"))
			return TRUE

		if("set_sexual_potency")
			var/new_val = text2num(params["value"])
			if(!isnull(new_val))
				prefs.process_link(user, list("_src_" = "prefs", "preference" = "sexual_potency"))
			return TRUE

		if("set_gfluid_blacklist")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "gfluid_black", "task" = "input"))
			return TRUE

		// === GAME PREFERENCES ACTIONS ===
		if("set_ui_style")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "ui", "task" = "input"))
			return TRUE

		if("toggle_outline")
			prefs.outline_enabled = !prefs.outline_enabled
			return TRUE

		if("set_outline_color")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "outline_color"))
			return TRUE

		if("set_screentip_pref")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "screentip_pref"))
			return TRUE

		if("set_screentip_color")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "screentip_color"))
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

		if("open_antag_prefs")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "be_special", "task" = "input"))
			return TRUE

		// === GAME PREFS: New toggles ===
		if("toggle_widescreenpref")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "widescreenpref"))
			return TRUE

		if("toggle_fullscreen")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "fullscreen"))
			return TRUE

		if("toggle_long_strip_menu")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "long_strip_menu"))
			return TRUE

		if("toggle_autostand")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "autostand"))
			return TRUE

		if("toggle_auto_ooc")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "auto_ooc"))
			return TRUE

		if("toggle_auto_capitalize")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "auto_capitalize_enabled"))
			return TRUE

		if("toggle_no_tetris")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "no_tetris_storage"))
			return TRUE

		if("set_screenshake")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "screenshake"))
			return TRUE

		if("set_damagescreenshake")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "damagescreenshake"))
			return TRUE

		if("set_recoil_screenshake")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "recoil_screenshake"))
			return TRUE

		if("set_parallax")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "parallax"))
			return TRUE

		if("toggle_ambientocclusion")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "ambientocclusion"))
			return TRUE

		if("toggle_auto_fit_viewport")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "auto_fit_viewport"))
			return TRUE

		if("toggle_hud_flash")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "hud_toggle_flash"))
			return TRUE

		if("set_hud_color")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "hud_toggle_color"))
			return TRUE

		if("toggle_view_pixelshift")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "view_pixelshift"))
			return TRUE

		if("toggle_combat_cursor")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "disable_combat_cursor"))
			return TRUE

		if("toggle_combat_mouse_lock")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "disable_combat_mouse_lock"))
			return TRUE

		if("set_be_victim")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "be_victim"))
			return TRUE

		// === OOC PREFERENCES ACTIONS ===
		if("set_ooccolor")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "ooccolor"))
			return TRUE

		if("set_aooccolor")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "aooccolor"))
			return TRUE

		if("set_ghost_form")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "ghost_form"))
			return TRUE

		if("set_ghost_orbit")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "ghost_orbit"))
			return TRUE

		if("toggle_chat_flag")
			var/flag = params["flag"]
			if(flag)
				prefs.process_link(user, list("_src_" = "prefs", "preference" = flag))
			return TRUE

		// === MARKINGS ACTIONS ===
		if("marking_add")
			var/limb = params["limb"]
			var/list/href = list("_src_" = "prefs", "preference" = "marking_add", "marking_type" = "mam_body_markings", "task" = "input")
			if(limb)
				href["limb"] = limb
			prefs.process_link(user, href)
			return TRUE

		if("marking_remove")
			var/index = params["index"]
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "marking_remove", "marking_type" = "mam_body_markings", "marking_index" = index, "task" = "input"))
			return TRUE

		if("marking_up")
			var/index = params["index"]
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "marking_up", "marking_type" = "mam_body_markings", "marking_index" = index, "task" = "input"))
			return TRUE

		if("marking_down")
			var/index = params["index"]
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "marking_down", "marking_type" = "mam_body_markings", "marking_index" = index, "task" = "input"))
			return TRUE

		if("marking_color")
			var/index = params["index"]
			var/color_num = params["color_num"]
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "marking_color_specific", "marking_type" = "mam_body_markings", "marking_index" = index, "number_color" = color_num, "task" = "input"))
			return TRUE

		if("markings_clear_limb")
			var/limb = params["limb"]
			var/list/href = list("_src_" = "prefs", "preference" = "markings_clear_limb", "marking_type" = "mam_body_markings", "task" = "input")
			if(limb)
				href["limb"] = limb
			prefs.process_link(user, href)
			return TRUE

		if("markings_remove_all")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "markings_remove", "task" = "input"))
			return TRUE

		if("open_tattoo_manager")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "open_tattoo_manager"))
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
			var/name = params["name"]
			var/toggle = text2num(params["toggle"])
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "gear", "toggle_gear_path" = name, "toggle_gear" = "[toggle]"))
			return TRUE

		if("loadout_color")
			var/gear_name = params["name"]
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "gear", "loadout_color" = "1", "loadout_gear_name" = gear_name))
			return TRUE

		if("loadout_rename")
			var/gear_name = params["name"]
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "gear", "loadout_rename" = "1", "loadout_gear_name" = gear_name))
			return TRUE

		if("loadout_heirloom")
			var/gear_name = params["name"]
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "gear", "loadout_addheirloom" = "1", "loadout_gear_name" = gear_name))
			return TRUE

		if("clear_loadout")
			prefs.process_link(user, list("_src_" = "prefs", "preference" = "gear", "clear_loadout" = "1"))
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
			prefs.load_character()
			prefs.load_preferences()
			tainted_slots = TRUE
			if(character_preview_view)
				character_preview_view.update_body()
			return TRUE

		if("randomize_all")
			prefs.random_character()
			tainted_slots = TRUE
			if(character_preview_view)
				character_preview_view.update_body()
			return TRUE

	// After any action, re-save and update preview
	if(.)
		prefs.save_character()

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
