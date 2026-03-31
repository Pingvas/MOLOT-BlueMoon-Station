#define WHERE_FLOOR_BELOW_MOB        "floor_below_mob"
#define WHERE_SUPPLY_BELOW_MOB       "supply_below_mob"
#define WHERE_MOB_HAND               "mob_hand"
#define WHERE_MARKED_OBJECT          "marked_object"
#define WHERE_IN_MARKED_OBJECT       "in_marked_object"
#define WHERE_TARGETED_LOCATION      "targeted_location"
#define WHERE_TARGETED_LOCATION_POD  "targeted_location_pod"
#define WHERE_TARGETED_MOB_HAND      "targeted_mob_hand"

#define PRECISE_MODE_OFF    "Off"
#define PRECISE_MODE_TARGET "Target"
#define PRECISE_MODE_COPY   "Copy"

#define OFFSET_ABSOLUTE "absolute"
#define OFFSET_RELATIVE "relative"

/datum/spawnpanel
	// Where the spawned atom should appear
	var/where_target_type = WHERE_FLOOR_BELOW_MOB
	// The currently-selected atom typepath (as text)
	var/selected_atom = null
	// How many atoms to spawn at once
	var/atom_amount = 1
	// Optional name override (null = use initial name)
	var/atom_name = null
	// Direction override (BYOND dir int; 1=NORTH by default)
	var/atom_dir = 1
	// Offset associative list: list("X"=0,"Y"=0,"Z"=0)
	var/list/offset
	// Whether offset is absolute or relative (one of the OFFSET_* defines)
	var/offset_type = OFFSET_RELATIVE
	// Current precise mode state (one of the PRECISE_MODE_* defines)
	var/precise_mode = PRECISE_MODE_OFF
	// Turf captured by precise-mode click (for TARGET mode)
	var/turf/precise_target = null

/datum/spawnpanel/New()
	. = ..()
	offset = list("X" = 0, "Y" = 0, "Z" = 0)

/datum/spawnpanel/Destroy()
	if(precise_mode && precise_mode != PRECISE_MODE_OFF)
		toggle_precise_mode(PRECISE_MODE_OFF)
	. = ..()

// TGUI

/datum/spawnpanel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpawnPanel")
		ui.open()

/datum/spawnpanel/ui_close(mob/user)
	. = ..()
	if(precise_mode != PRECISE_MODE_OFF)
		toggle_precise_mode(PRECISE_MODE_OFF)

/datum/spawnpanel/ui_state(mob/user)
	return GLOB.admin_state

/datum/spawnpanel/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/json/spawnpanel))

/datum/spawnpanel/ui_data(mob/user)
	return list(
		"selectedAtom"  = selected_atom,
		"whereTarget"   = where_target_type,
		"amount"        = atom_amount,
		"atomName"      = atom_name,
		"atomDir"       = atom_dir,
		"offsetX"       = offset["X"],
		"offsetY"       = offset["Y"],
		"offsetZ"       = offset["Z"],
		"offsetType"    = offset_type,
		"preciseMode"   = precise_mode,
	)

/datum/spawnpanel/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(!check_rights_for(ui.user.client, R_SPAWN))
		return FALSE

	switch(action)
		if("selected-atom-changed")
			selected_atom = params["type"]
			return TRUE

		if("update-settings")
			if(!isnull(params["whereTarget"]))
				where_target_type = params["whereTarget"]
			if(!isnull(params["amount"]))
				atom_amount = clamp(text2num(params["amount"]) || 1, 1, ADMIN_SPAWN_CAP)
			if(!isnull(params["atomName"]))
				atom_name = sanitize(params["atomName"]) || null
			if(!isnull(params["atomDir"]))
				atom_dir = text2num(params["atomDir"])
			if(!isnull(params["offsetX"]))
				offset["X"] = text2num(params["offsetX"]) || 0
			if(!isnull(params["offsetY"]))
				offset["Y"] = text2num(params["offsetY"]) || 0
			if(!isnull(params["offsetZ"]))
				offset["Z"] = text2num(params["offsetZ"]) || 0
			if(!isnull(params["offsetType"]))
				offset_type = params["offsetType"]
			return TRUE

		if("create-atom-action")
			var/list/spawn_params = list(
				"type"        = params["type"] || selected_atom,
				"amount"      = atom_amount,
				"atomName"    = atom_name,
				"atomDir"     = atom_dir,
				"whereTarget" = where_target_type,
				"offsetX"     = offset["X"],
				"offsetY"     = offset["Y"],
				"offsetZ"     = offset["Z"],
				"offsetType"  = offset_type,
			)
			spawn_atom(spawn_params, ui.user)
			return TRUE

		if("toggle-precise-mode")
			var/new_mode = params["mode"] || PRECISE_MODE_OFF
			toggle_precise_mode(new_mode)
			return TRUE

	return FALSE

// PRECISE

/datum/spawnpanel/proc/toggle_precise_mode(new_mode)
	if(!selected_atom && new_mode != PRECISE_MODE_OFF)
		return
	var/mob/user = usr
	if(!user?.client)
		return

	precise_mode = new_mode
	if(new_mode == PRECISE_MODE_OFF)
		user.client.click_intercept = null
	else
		user.client.click_intercept = src
	SStgui.update_uis(src)

/datum/spawnpanel/proc/InterceptClickOn(mob/clicker, params, atom/target)
	if(!check_rights_for(clicker.client, R_SPAWN))
		toggle_precise_mode(PRECISE_MODE_OFF)
		return TRUE

	switch(precise_mode)
		if(PRECISE_MODE_TARGET)
			var/list/spawn_params = list(
				"type"        = selected_atom,
				"amount"      = atom_amount,
				"atomName"    = atom_name,
				"atomDir"     = atom_dir,
				"whereTarget" = WHERE_TARGETED_LOCATION,
				"targetTurf"  = get_turf(target),
				"offsetX"     = 0,
				"offsetY"     = 0,
				"offsetZ"     = 0,
				"offsetType"  = OFFSET_RELATIVE,
			)
			spawn_atom(spawn_params, clicker)

		if(PRECISE_MODE_COPY)
			selected_atom = "[target.type]"
			toggle_precise_mode(PRECISE_MODE_OFF)
			SStgui.update_uis(src)

	return TRUE
