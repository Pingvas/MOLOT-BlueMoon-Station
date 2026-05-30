/datum/asset/spritesheet/loadout_icons
	name = "loadout_icons"

/datum/asset/spritesheet/loadout_icons/register()
	var/list/icon_state_cache = list()
	for(var/category in GLOB.loadout_items)
		for(var/subcategory in GLOB.loadout_items[category])
			for(var/name in GLOB.loadout_items[category][subcategory])
				var/datum/gear/gear = GLOB.loadout_items[category][subcategory][name]
				if(!gear)
					continue
				var/obj/item/item_type = gear.path
				if(!ispath(item_type, /obj))
					continue
				var/icon_file = initial(item_type.icon)
				var/icon_state = initial(item_type.icon_state)
				if(!icon_file || !icon_state)
					continue
				// Validate icon_state actually exists in the file to avoid BYOND falling back to a random frame
				var/list/valid_states = icon_state_cache[icon_file]
				if(isnull(valid_states))
					valid_states = icon_states(icon_file)
					icon_state_cache[icon_file] = valid_states
				if(!(icon_state in valid_states))
					continue
				var/icon/I = icon(icon_file, icon_state, SOUTH)
				if(!I)
					continue
				var/c = initial(item_type.color)
				if(!isnull(c) && c != "#FFFFFF")
					I.Blend(c, ICON_MULTIPLY)
				var/imgid = replacetext("[gear.type]", "/", "_")
				Insert(imgid, I)
	return ..()
