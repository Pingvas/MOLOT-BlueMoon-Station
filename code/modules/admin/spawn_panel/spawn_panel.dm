// Spawn location where-targets - must match TGUI constants.ts strings
#define WHERE_FLOOR_BELOW_MOB        "Current location"
#define WHERE_SUPPLY_BELOW_MOB       "Current location (droppod)"
#define WHERE_MOB_HAND               "In own mob's hand"
#define WHERE_MARKED_OBJECT          "At a marked object"
#define WHERE_IN_MARKED_OBJECT       "In the marked object"
#define WHERE_TARGETED_LOCATION      "Targeted location"
#define WHERE_TARGETED_LOCATION_POD  "Targeted location (droppod)"
#define WHERE_TARGETED_MOB_HAND      "In targeted mob's hand"

// Precise mode states
#define PRECISE_MODE_OFF    "Off"
#define PRECISE_MODE_TARGET "Target"
#define PRECISE_MODE_COPY   "Copy"

// Offset types
#define OFFSET_ABSOLUTE "Absolute offset"
#define OFFSET_RELATIVE "Relative offset"

/datum/spawnpanel
	var/where_target_type = WHERE_FLOOR_BELOW_MOB
	var/selected_atom = null
	var/selected_icon = null // base64 of current atom icon, generated on selection
	var/atom_amount = 1
	var/atom_name = null
	var/atom_dir = 2
	var/list/offset
	var/offset_type = OFFSET_RELATIVE
	var/precise_mode = PRECISE_MODE_OFF

/datum/spawnpanel/New()
	. = ..()
	offset = list("X" = 0, "Y" = 0, "Z" = 0)

/datum/spawnpanel/Destroy()
	if(precise_mode != PRECISE_MODE_OFF)
		toggle_precise_mode(PRECISE_MODE_OFF)
	. = ..()

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
	return list(
		get_asset_datum(/datum/asset/spritesheet/spawnpanel),
		get_asset_datum(/datum/asset/json/spawnpanel),
	)

/datum/spawnpanel/ui_data(mob/user)
	return list(
		"selected_object" = selected_atom,
		"selected_icon" = selected_icon,
		"where_target_type" = where_target_type,
		"atom_amount" = atom_amount,
		"atom_name" = atom_name,
		"atom_dir" = atom_dir,
		"offset" = list(offset["X"], offset["Y"], offset["Z"]),
		"offset_type" = offset_type,
		"precise_mode" = precise_mode,
	)

/datum/spawnpanel/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(!check_rights_for(ui.user.client, R_SPAWN))
		return FALSE

	switch(action)
		if("selected-atom-changed")
			selected_atom = params["newObj"]
			selected_icon = null
			if(selected_atom)
				var/path = text2path(selected_atom)
				if(path)
					var/atom_icon = initial(path:icon)
					var/atom_state = initial(path:icon_state)
					if(atom_icon)
						if(isnull(atom_state) || atom_state == "")
							var/list/states = icon_states(atom_icon)
							if(!("" in states) && length(states))
								atom_state = states[1]
						var/icon/I = icon(atom_icon, atom_state, SOUTH, 1)
						selected_icon = "data:image/png;base64,[icon2base64(I)]"
			return TRUE

		if("update-settings")
			if(!isnull(params["where_target_type"]))
				where_target_type = params["where_target_type"]
			if(!isnull(params["atom_amount"]))
				atom_amount = clamp(text2num(params["atom_amount"]) || 1, 1, ADMIN_SPAWN_CAP)
			if(!isnull(params["atom_name"]))
				atom_name = sanitize(params["atom_name"]) || null
			if(!isnull(params["atom_dir"]))
				atom_dir = text2num(params["atom_dir"])
			if(!isnull(params["offset"]))
				var/list/off = params["offset"]
				if(length(off) >= 3)
					offset["X"] = text2num(off[1]) || 0
					offset["Y"] = text2num(off[2]) || 0
					offset["Z"] = text2num(off[3]) || 0
			if(!isnull(params["offset_type"]))
				offset_type = params["offset_type"]
			return TRUE

		if("create-atom-action")
			var/use_atom = params["selected_atom"] || selected_atom
			if(!use_atom)
				return FALSE
			if(!isnull(params["where_target_type"]))
				where_target_type = params["where_target_type"]
			if(!isnull(params["atom_amount"]))
				atom_amount = clamp(text2num(params["atom_amount"]) || 1, 1, ADMIN_SPAWN_CAP)
			if(!isnull(params["atom_name"]))
				atom_name = sanitize(params["atom_name"]) || null
			if(!isnull(params["atom_dir"]))
				atom_dir = text2num(params["atom_dir"])
			if(!isnull(params["offset"]))
				var/list/off2 = params["offset"]
				if(length(off2) >= 3)
					offset["X"] = text2num(off2[1]) || 0
					offset["Y"] = text2num(off2[2]) || 0
					offset["Z"] = text2num(off2[3]) || 0
			if(!isnull(params["offset_type"]))
				offset_type = params["offset_type"]
			var/list/spawn_params = list(
				"type" = use_atom,
				"amount" = atom_amount,
				"atom_name" = atom_name,
				"atom_dir" = atom_dir,
				"where" = where_target_type,
				"offsetX" = offset["X"],
				"offsetY" = offset["Y"],
				"offsetZ" = offset["Z"],
				"offset_type" = offset_type,
			)
			spawn_atom(spawn_params, ui.user)
			return TRUE

		if("toggle-precise-mode")
			var/new_mode = params["newPreciseType"] || PRECISE_MODE_OFF
			toggle_precise_mode(new_mode)
			return TRUE

	return FALSE

/datum/spawnpanel/proc/toggle_precise_mode(new_mode)
	if(!selected_atom && new_mode != PRECISE_MODE_OFF)
		to_chat(usr, span_warning("SpawnPanel: select an atom first."))
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
				"type" = selected_atom,
				"amount" = atom_amount,
				"atom_name" = atom_name,
				"atom_dir" = atom_dir,
				"where" = WHERE_TARGETED_LOCATION,
				"targetTurf" = get_turf(target),
				"offsetX" = 0,
				"offsetY" = 0,
				"offsetZ" = 0,
				"offset_type" = OFFSET_RELATIVE,
			)
			spawn_atom(spawn_params, clicker)
		if(PRECISE_MODE_COPY)
			selected_atom = "[target.type]"
			toggle_precise_mode(PRECISE_MODE_OFF)
			SStgui.update_uis(src)
	return TRUE
