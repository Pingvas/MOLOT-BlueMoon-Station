// Кэшируем иконки base64 в css класс
/datum/asset/spritesheet/loadout_icons
	name = "loadout_icons"

/datum/asset/spritesheet/loadout_icons/register()
	for(var/gear_type in subtypesof(/datum/gear))
		var/datum/gear/G = gear_type
		if(!initial(G.name))
			continue
		var/atom/item_path = initial(G.path)
		if(!ispath(item_path, /atom))
			continue
		var/icon_file = initial(G.item_icon) || initial(item_path.icon)
		var/icon_state = initial(G.item_icon_state) || initial(item_path.icon_state)
		if(!icon_file || !icon_state)
			continue
		if(!(icon_state in icon_states(icon_file)))
			continue
		var/sprite_name = replacetext("[gear_type]", "/", "_")
		if(sprites[sprite_name])
			continue
		Insert(sprite_name, icon_file, icon_state)
	return ..()
