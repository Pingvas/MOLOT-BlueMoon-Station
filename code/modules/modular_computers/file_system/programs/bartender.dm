/**
 * Bartender - PDA cartridge program
 *
 * Drink recipes and reagent reference for bartenders.
 */
/datum/computer_file/program/bartender
	filename = "booze"
	filedesc = "Booze Reference"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "This program provides drink recipes and reagent information for bartenders."
	requires_ntnet = FALSE
	transfer_access = null
	usage_flags = PROGRAM_PDA
	size = 4
	tgui_id = "NtosBartender"
	program_icon = "wine-glass-alt"

/datum/computer_file/program/bartender/ui_data(mob/user)
	var/list/data = get_header_data()

	var/list/drinks = list()
	for(var/datum/reagent/consumable/ethanol/E in subtypesof(/datum/reagent/consumable/ethanol))
		drinks += list(list(
			"name" = initial(E.name),
			"description" = initial(E.description),
			"strength" = initial(E.boozepwr),
		))

	data["drinks"] = drinks
	return data
