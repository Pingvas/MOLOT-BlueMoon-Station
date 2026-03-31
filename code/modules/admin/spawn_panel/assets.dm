/datum/asset/json/spawnpanel
	name = "spawnpanel_atom_data"

/datum/asset/json/spawnpanel/proc/atom_icon_b64(icon/ico, state)
	if(!ico)
		return ""
	var/icon/render = icon(ico, state, SOUTH, 1, 0)
	var/b64 = icon2base64(render)
	return b64 ? "data:image/png;base64,[b64]" : ""

/datum/asset/json/spawnpanel/generate()
	var/list/data = list()
	data["atoms"] = list()

	for(var/obj/each_obj as anything in typesof(/obj))
		var/icon_file = initial(each_obj:icon)
		var/icon_state = initial(each_obj:icon_state)
		data["atoms"]["[each_obj]"] = list(
			"icon"        = atom_icon_b64(icon_file, icon_state),
			"name"        = "[initial(each_obj:name)]",
			"description" = "[initial(each_obj:desc)]",
			"type"        = "Objects"
		)

	for(var/turf/each_turf as anything in typesof(/turf))
		var/icon_file = initial(each_turf:icon)
		var/icon_state = initial(each_turf:icon_state)
		data["atoms"]["[each_turf]"] = list(
			"icon"        = atom_icon_b64(icon_file, icon_state),
			"name"        = "[initial(each_turf:name)]",
			"description" = "[initial(each_turf:desc)]",
			"type"        = "Turfs"
		)

	for(var/mob/each_mob as anything in typesof(/mob))
		var/icon_file = initial(each_mob:icon)
		var/icon_state = initial(each_mob:icon_state)
		data["atoms"]["[each_mob]"] = list(
			"icon"        = atom_icon_b64(icon_file, icon_state),
			"name"        = "[initial(each_mob:name)]",
			"description" = "[initial(each_mob:desc)]",
			"type"        = "Mobs"
		)

	return data
