/**
 * Reagent Scanner - PDA cartridge program
 *
 * Allows scanning of held containers to identify their chemical contents.
 * Replicates the legacy PDA reagent scan functionality.
 */
/datum/computer_file/program/reagentscanner
	filename = "reagscan"
	filedesc = "Reagent Scanner"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "This program allows scanning of containers to identify chemical reagents within."
	requires_ntnet = FALSE
	transfer_access = null
	usage_flags = PROGRAM_PDA
	size = 4
	tgui_id = "NtosReagentScanner"
	program_icon = "flask"

/datum/computer_file/program/reagentscanner/ui_data(mob/user)
	var/list/data = get_header_data()

	var/mob/living/carbon/human/human_user = user
	if(istype(human_user))
		var/obj/item/held = human_user.get_active_held_item()
		if(held)
			data["scanned_item"] = held.name
			if(held.reagents && held.reagents.reagent_list.len)
				var/list/reagent_data = list()
				for(var/datum/reagent/R in held.reagents.reagent_list)
					reagent_data += list(list(
						"name" = R.name,
						"volume" = round(R.volume, 0.01),
						"description" = R.description,
					))
				data["reagents"] = reagent_data
				data["total_volume"] = held.reagents.total_volume
				data["max_volume"] = held.reagents.maximum_volume
			else
				data["reagents"] = list()
				data["total_volume"] = 0
				data["max_volume"] = 0
		else
			data["scanned_item"] = null
	else
		data["scanned_item"] = null

	return data

/datum/computer_file/program/reagentscanner/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("scan")
			return TRUE
