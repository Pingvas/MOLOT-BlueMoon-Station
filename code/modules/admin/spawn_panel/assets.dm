GLOBAL_LIST_EMPTY(spawnpanel_icon_map) // "[typepath]" → spritesheet imgid string

/datum/asset/spritesheet/spawnpanel
	name = "spawnpanel"

/datum/asset/spritesheet/spawnpanel/register()
	var/list/icon_dedup = list() // "[ifile]|[istate]" → imgid, deduplicates identical icons
	var/counter = 0

	for(var/atom_type in typesof(/obj))
		if(atom_type == /obj)
			continue
		var/ifile = initial(atom_type:icon)
		var/istate = initial(atom_type:icon_state)
		if(!ifile)
			continue
		var/cache_key = "[ifile]|[istate]"
		if(!(cache_key in icon_dedup))
			var/icon/I = icon(ifile, istate, SOUTH)
			var/imgid = "sp[counter]"
			counter++
			Insert(imgid, I)
			icon_dedup[cache_key] = imgid
		GLOB.spawnpanel_icon_map["[atom_type]"] = icon_dedup[cache_key]

	for(var/turf_type in typesof(/turf))
		if(turf_type == /turf)
			continue
		var/ifile2 = initial(turf_type:icon)
		var/istate2 = initial(turf_type:icon_state)
		if(!ifile2)
			continue
		var/cache_key2 = "[ifile2]|[istate2]"
		if(!(cache_key2 in icon_dedup))
			var/icon/I2 = icon(ifile2, istate2, SOUTH)
			var/imgid2 = "sp[counter]"
			counter++
			Insert(imgid2, I2)
			icon_dedup[cache_key2] = imgid2
		GLOB.spawnpanel_icon_map["[turf_type]"] = icon_dedup[cache_key2]

	for(var/mob_type in typesof(/mob))
		if(mob_type == /mob)
			continue
		var/ifile3 = initial(mob_type:icon)
		var/istate3 = initial(mob_type:icon_state)
		if(!ifile3)
			continue
		var/cache_key3 = "[ifile3]|[istate3]"
		if(!(cache_key3 in icon_dedup))
			var/icon/I3 = icon(ifile3, istate3, SOUTH)
			var/imgid3 = "sp[counter]"
			counter++
			Insert(imgid3, I3)
			icon_dedup[cache_key3] = imgid3
		GLOB.spawnpanel_icon_map["[mob_type]"] = icon_dedup[cache_key3]

	return ..()

/datum/asset/json/spawnpanel
	name = "spawnpanel_atom_data"

/datum/asset/json/spawnpanel/generate()
	var/list/data = list()
	var/list/atoms = list()

	for(var/obj_type in typesof(/obj))
		if(obj_type == /obj)
			continue
		atoms["[obj_type]"] = list(
			"name" = "[initial(obj_type:name)]",
			"description" = "[initial(obj_type:desc)]",
			"type" = "Objects",
			"iconid" = GLOB.spawnpanel_icon_map["[obj_type]"]
		)

	for(var/turf_type in typesof(/turf))
		if(turf_type == /turf)
			continue
		atoms["[turf_type]"] = list(
			"name" = "[initial(turf_type:name)]",
			"description" = "[initial(turf_type:desc)]",
			"type" = "Turfs",
			"iconid" = GLOB.spawnpanel_icon_map["[turf_type]"]
		)

	for(var/mob_type in typesof(/mob))
		if(mob_type == /mob)
			continue
		atoms["[mob_type]"] = list(
			"name" = "[initial(mob_type:name)]",
			"description" = "[initial(mob_type:desc)]",
			"type" = "Mobs",
			"iconid" = GLOB.spawnpanel_icon_map["[mob_type]"]
		)

	data["atoms"] = atoms
	return data
