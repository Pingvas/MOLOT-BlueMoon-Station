/datum/asset/json/spawnpanel
	name = "spawnpanel_atom_data"

/datum/asset/json/spawnpanel/generate()
	var/list/data = list()
	var/list/atoms = list()

	for(var/obj_type in typesof(/obj))
		atoms["[obj_type]"] = list(
			"name" = "[initial(obj_type:name)]",
			"description" = "[initial(obj_type:desc)]",
			"type" = "Objects"
		)

	for(var/turf_type in typesof(/turf))
		atoms["[turf_type]"] = list(
			"name" = "[initial(turf_type:name)]",
			"description" = "[initial(turf_type:desc)]",
			"type" = "Turfs"
		)

	for(var/mob_type in typesof(/mob))
		atoms["[mob_type]"] = list(
			"name" = "[initial(mob_type:name)]",
			"description" = "[initial(mob_type:desc)]",
			"type" = "Mobs"
		)

	data["atoms"] = atoms
	return data