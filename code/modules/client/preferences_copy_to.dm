/datum/preferences/proc/copy_to(mob/living/carbon/human/character, icon_updates = 1, roundstart_checks = TRUE, initial_spawn = FALSE)
	if(be_random_name)
		real_name = pref_species.random_name(gender)

	if(be_random_body)
		random_character(gender)

	if(roundstart_checks)
		if(CONFIG_GET(flag/humans_need_surnames) && (pref_species.id == "human"))
			var/firstspace = findtext(real_name, " ")
			var/name_length = length(real_name)
			if(!firstspace)	//we need a surname
				real_name += " [pick(GLOB.last_names)]"
			else if(firstspace == name_length)
				real_name += "[pick(GLOB.last_names)]"

	character.mob_weight = mob_size_name_to_num(body_weight) //BLUEMOON ADD записываем вес персонажа как цифру
	character.laugh_override = custom_laugh != "Default" ? custom_laugh : null //BLUEMOON ADD записываем вес персонажа как цифру

	//reset size if applicable
	if(character.dna.features["body_size"])
		var/initial_old_size = character.dna.features["body_size"]
		character.update_size(RESIZE_DEFAULT_SIZE, initial_old_size)

	character.real_name = nameless ? "[real_name] #[rand(10000, 99999)]" : real_name
	character.name = character.real_name
	character.nameless = nameless
	character.custom_species = custom_species

	character.gender = gender
	character.age = age

	character.fuzzy = fuzzy

	character.update_weight(character.mob_weight)
	character.left_eye_color = left_eye_color
	character.right_eye_color = right_eye_color
	var/obj/item/organ/eyes/organ_eyes = character.getorgan(/obj/item/organ/eyes)
	if(organ_eyes)
		if(!initial(organ_eyes.left_eye_color))
			organ_eyes.left_eye_color = left_eye_color
			organ_eyes.right_eye_color = right_eye_color
		organ_eyes.old_left_eye_color = left_eye_color
		organ_eyes.old_right_eye_color = right_eye_color
	character.hair_color = hair_color
	character.facial_hair_color = facial_hair_color
	character.skin_tone = skin_tone
	character.dna.skin_tone_override = use_custom_skin_tone ? skin_tone : null
	character.hair_style = hair_style
	character.facial_hair_style = facial_hair_style
	character.grad_style = grad_style
	character.grad_color = grad_color
	/* skyrat edit
	character.underwear = underwear

	character.saved_underwear = underwear
	character.undershirt = undershirt
	character.saved_undershirt = undershirt
	character.socks = socks
	character.saved_socks = socks
	*/
	character.undie_color = undie_color
	character.shirt_color = shirt_color
	character.socks_color = socks_color

	var/datum/species/chosen_species
	if(!roundstart_checks || (pref_species.id in GLOB.roundstart_races))
		chosen_species = pref_species.type
	else
		chosen_species = /datum/species/human
		pref_species = new /datum/species/human
		save_character()

	character.dna.features = features.Copy()

	character.set_species(chosen_species, icon_update = FALSE, pref_load = TRUE)
	character.dna.species.eye_type = eye_type
	if(chosen_limb_id && (chosen_limb_id in character.dna.species.allowed_limb_ids))
		character.dna.species.mutant_bodyparts["limbs_id"] = chosen_limb_id
	character.dna.real_name = character.real_name
	character.dna.nameless = character.nameless
	// BLUEMOON EDIT START - привязка флавора и лора кастомных рас к ДНК
	character.dna.custom_species = character.custom_species
	character.dna.custom_species_lore = features["custom_species_lore"]
	character.dna.flavor_text = features["flavor_text"]
	character.dna.naked_flavor_text = features["naked_flavor_text"]
	character.dna.headshot_links.Cut()
	if (features["headshot_link"])
		character.dna.headshot_links.Add(features["headshot_link"])
	if (features["headshot_link1"])
		character.dna.headshot_links.Add(features["headshot_link1"])
	if (features["headshot_link2"])
		character.dna.headshot_links.Add(features["headshot_link2"])
	// BLUEMOON ADD START
	character.dna.headshot_naked_links.Cut()
	if (features["headshot_naked_link"])
		character.dna.headshot_naked_links.Add(features["headshot_naked_link"])
	if (features["headshot_naked_link1"])
		character.dna.headshot_naked_links.Add(features["headshot_naked_link1"])
	if (features["headshot_naked_link2"])
		character.dna.headshot_naked_links.Add(features["headshot_naked_link2"])
	// BLUEMOON ADD END
	character.dna.ooc_notes = features["ooc_notes"]
	if(custom_blood_color)
		character.dna.species.exotic_blood_color = blood_color //а раньше эта строчка была немного выше и всё ломалось, думайте, когда делаете врезки
	// BLUEMOON EDIT END

	var/old_size = RESIZE_DEFAULT_SIZE
	if(isdwarf(character))
		character.dna.features["body_size"] = RESIZE_DEFAULT_SIZE

	if(parent?.can_have_part("meat_type") || pref_species.mutant_bodyparts["meat_type"])
		character.type_of_meat = GLOB.meat_types[features["meat_type"]]

	if((parent?.can_have_part("legs") || pref_species.mutant_bodyparts["legs"])  && (character.dna.features["legs"] == "Digitigrade" || character.dna.features["legs"] == "Avian"))
		pref_species.species_traits |= DIGITIGRADE
	else if(character.dna.species.mutant_bodyparts["limbs_id"] == "sergal")
		pref_species.species_traits |= DIGITIGRADE
	else
		pref_species.species_traits -= DIGITIGRADE

	if(DIGITIGRADE in pref_species.species_traits)
		character.Digitigrade_Leg_Swap(FALSE)
	else
		character.Digitigrade_Leg_Swap(TRUE)

	character.dna.features["lust_tolerance"] = lust_tolerance
	character.dna.features["sexual_potency"] = sexual_potency

	if(features["anus_accessible"])
		character.toggle_anus_always_accessible(TRUE)

	character.give_genitals(TRUE) //character.update_genitals() is already called on genital.update_appearance()

	character.update_size(get_size(character), old_size)

	//speech stuff
	if(custom_tongue != "default")
		var/new_tongue = GLOB.roundstart_tongues[custom_tongue]
		if(new_tongue)
			character.dna.species.mutanttongue = new_tongue //this means we get our tongue when we clone
			var/obj/item/organ/tongue/T = character.getorganslot(ORGAN_SLOT_TONGUE)
			if(T)
				qdel(T)
			var/obj/item/organ/tongue/new_custom_tongue = new new_tongue
			new_custom_tongue.Insert(character)
	if(custom_speech_verb != "default")
		character.dna.species.say_mod = custom_speech_verb

	character.set_bark(bark_id)
	character.vocal_speed = bark_speed
	character.vocal_pitch = bark_pitch
	character.vocal_pitch_range = bark_variance

	//limb stuff, only done when initially spawning in
	if(initial_spawn)
		//delete any existing prosthetic limbs to make sure no remnant prosthetics are left over - But DO NOT delete those that are species-related
		for(var/obj/item/bodypart/part in character.bodyparts)
			if(part.is_robotic_limb(FALSE))
				qdel(part)
		character.regenerate_limbs() //regenerate limbs so now you only have normal limbs
		for(var/modified_limb in modified_limbs)
			var/modification = modified_limbs[modified_limb][1]
			var/obj/item/bodypart/old_part = character.get_bodypart(modified_limb)
			if(modification == LOADOUT_LIMB_PROSTHETIC)
				var/obj/item/bodypart/new_limb
				switch(modified_limb)
					if(BODY_ZONE_L_ARM)
						new_limb = new/obj/item/bodypart/l_arm/robot/surplus(character)
					if(BODY_ZONE_R_ARM)
						new_limb = new/obj/item/bodypart/r_arm/robot/surplus(character)
					if(BODY_ZONE_L_LEG)
						new_limb = new/obj/item/bodypart/l_leg/robot/surplus(character)
					if(BODY_ZONE_R_LEG)
						new_limb = new/obj/item/bodypart/r_leg/robot/surplus(character)
				var/prosthetic_type = modified_limbs[modified_limb][2]
				if(prosthetic_type != "prosthetic") //lets just leave the old sprites as they are
					new_limb.icon = file("icons/mob/augmentation/cosmetic_prosthetic/[prosthetic_type].dmi")
				new_limb.replace_limb(character)
			qdel(old_part)

	SEND_SIGNAL(character, COMSIG_HUMAN_PREFS_COPIED_TO, src, icon_updates, roundstart_checks)

	//let's be sure the character updates
	if(icon_updates)
		character.update_body()
		character.update_hair()

/datum/preferences/proc/post_copy_to(mob/living/carbon/human/character)
	//if no legs, and not a paraplegic or a slime, give them a free wheelchair
	var/list/left_leg = modified_limbs[BODY_ZONE_L_LEG]
	var/list/right_leg = modified_limbs[BODY_ZONE_R_LEG]
	if(left_leg && left_leg[1] == LOADOUT_LIMB_AMPUTATED && right_leg && right_leg[1] == LOADOUT_LIMB_AMPUTATED && !character.has_quirk(/datum/quirk/paraplegic) && !isjellyperson(character))
		if(character.buckled)
			character.buckled.unbuckle_mob(character)
		var/turf/T = get_turf(character)
		var/obj/structure/chair/spawn_chair = locate(/obj/structure/chair) in T
		var/obj/vehicle/ridden/wheelchair/wheels = new(T)
		if(spawn_chair) // Makes spawning on the arrivals shuttle more consistent looking
			wheels.setDir(spawn_chair.dir)
		wheels.buckle_mob(character)

/datum/preferences/proc/get_default_name(name_id)
	switch(name_id)
		if("human")
			return random_unique_name()
		if("ai")
			return pick(GLOB.ai_names)
		if("cyborg")
			return DEFAULT_CYBORG_NAME
		if("clown")
			return pick(GLOB.clown_names)
		if("mime")
			return pick(GLOB.mime_names)
	return random_unique_name()

/datum/preferences/proc/ask_for_custom_name(mob/user,name_id)
	var/namedata = GLOB.preferences_custom_names[name_id]
	if(!namedata)
		return

	var/raw_name = input(user, "Choose your character's [namedata["qdesc"]]:","Character Preference") as text|null
	if(!raw_name)
		if(namedata["allow_null"])
			custom_names[name_id] = get_default_name(name_id)
		else
			return
	else
		var/sanitized_name = reject_bad_name(raw_name,namedata["allow_numbers"])
		if(!sanitized_name)
			to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z,[namedata["allow_numbers"] ? ",0-9," : ""] -, ' and .</font>")
			return
		else
			custom_names[name_id] = sanitized_name

/datum/preferences/proc/get_filtered_holoform(filter_type)
	if(!custom_holoform_icon)
		return
	LAZYINITLIST(cached_holoform_icons)
	if(!cached_holoform_icons[filter_type])
		cached_holoform_icons[filter_type] = process_holoform_icon_filter(custom_holoform_icon, filter_type)
	return cached_holoform_icons[filter_type]

/// Resets the client's keybindings. Asks them for which
/datum/preferences/proc/force_reset_keybindings()
	var/choice = tgalert(parent.mob, "Your basic keybindings need to be reset, emotes will remain as before. Would you prefer 'hotkey' or 'classic' mode?", "Reset keybindings", "Hotkey", "Classic")
	hotkeys = (choice != "Classic")
	force_reset_keybindings_direct(hotkeys)

/// Does the actual reset
/datum/preferences/proc/force_reset_keybindings_direct(hotkeys = TRUE)
	var/list/oldkeys = key_bindings
	key_bindings = (hotkeys) ? deepCopyList(GLOB.hotkey_keybinding_list_by_key) : deepCopyList(GLOB.classic_keybinding_list_by_key)

	for(var/key in oldkeys)
		if(!key_bindings[key])
			key_bindings[key] = oldkeys[key]
	parent?.ensure_keys_set(src)

/datum/preferences/proc/is_loadout_slot_available(slot)
	return TRUE // No category limits - loadout points handle balance

// BLUEMOON ADD START - выбор вещей из лодаута как семейной реликвии
///Searching for loadout item which `property` ([LOADOUT_ITEM], [LOADOUT_COLOR], etc) equals to `value`; returns this items, or FALSE if no gear matched conditions
/datum/preferences/proc/find_gear_with_property(save_slot, property, value)
	var/list/gear_list = loadout_data["SAVE_[save_slot]"]
	for(var/loadout_gear in gear_list)
		if(loadout_gear[property] == value)
			return loadout_gear
	return FALSE

/datum/preferences/proc/has_loadout_gear(save_slot, gear_type)
	var/list/gear_list = loadout_data["SAVE_[save_slot]"]
	for(var/loadout_gear in gear_list)
		if(loadout_gear[LOADOUT_ITEM] == gear_type)
			return loadout_gear
	return FALSE

/datum/preferences/proc/remove_gear_from_loadout(save_slot, gear_type)
	var/find_gear = has_loadout_gear(save_slot, gear_type)
	if(find_gear)
		loadout_data["SAVE_[save_slot]"] -= list(find_gear)

/datum/preferences/proc/can_use_unlockable(datum/gear/unlockable/unlockable_gear)
	if(unlockable_loadout_data[unlockable_gear.progress_key] >= unlockable_gear.progress_required)
		return TRUE
	return FALSE

/**
 * Get the given client's chat toggle prefs.
 *
 * Getter function for prefs.chat_toggles which guards against null client and null prefs.
 * The client object is fickle and can go null at times, so use this instead of directly accessing the var
 * if you want to ensure no runtimes.
 *
 * returns client.prefs.chat_toggles or FALSE if something went wrong.
 *
 * Arguments:
 * * client/prefs_holder - the client to get the chat_toggles pref from.
 */
/proc/get_chat_toggles(client/prefs_holder)
	if(!prefs_holder)
		return FALSE
	if(prefs_holder && !prefs_holder?.prefs)
		stack_trace("[prefs_holder?.mob] ([prefs_holder?.ckey]) had null prefs, which shouldn't be possible!")
		return FALSE

	return prefs_holder?.prefs.chat_toggles


// ========== BlueMoon: mob size helpers ==========
/datum/preferences/proc/mob_size_name_to_num(body_weight_name)
	switch(body_weight_name)
		if(NAME_WEIGHT_LIGHT)
			return MOB_WEIGHT_LIGHT
		if(NAME_WEIGHT_NORMAL)
			return MOB_WEIGHT_NORMAL
		if(NAME_WEIGHT_HEAVY)
			return MOB_WEIGHT_HEAVY
		if(NAME_WEIGHT_HEAVY_SUPER)
			return MOB_WEIGHT_HEAVY_SUPER
		else
			return MOB_WEIGHT_NORMAL

/datum/preferences/proc/mob_size_name_to_quirk_cost(body_weight_name)
	switch(body_weight_name)
		if(NAME_WEIGHT_HEAVY)
			return 1
		if(NAME_WEIGHT_HEAVY_SUPER)
			return 2
		else
			return 0
