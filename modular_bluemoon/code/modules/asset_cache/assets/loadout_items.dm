/// Spritesheet for loadout item icons (same pattern as research_designs)
/datum/asset/spritesheet/loadout_items
	name = "loadout"

/datum/asset/spritesheet/loadout_items/register()
	for(var/cat in GLOB.loadout_items)
		for(var/subcat in GLOB.loadout_items[cat])
			for(var/gear_name in GLOB.loadout_items[cat][subcat])
				var/datum/gear/G = GLOB.loadout_items[cat][subcat][gear_name]
				if(!istype(G))
					continue
				var/sprite_name = replacetext("[G.type]", "/", "_")
				var/init_icon = G.item_icon ? G.item_icon : initial(G.path.icon)
				var/init_icon_state = G.item_icon_state ? G.item_icon_state : initial(G.path.icon_state)
				if(!init_icon || !init_icon_state)
					continue
				if(!(init_icon_state in icon_states(init_icon)))
					continue
				try
					Insert(sprite_name, icon(init_icon, init_icon_state, SOUTH, 1, FALSE))
				catch
					continue
	return ..()
