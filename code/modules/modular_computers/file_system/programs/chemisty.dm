/**
 * Chemistry - PDA cartridge program
 *
 * Chemical reference and dispenser interface for chemists.
 */
/datum/computer_file/program/chemisty
	filename = "chemref"
	filedesc = "Chem Reference"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "This program provides chemical reference information and reagent scanning for chemists."
	requires_ntnet = FALSE
	transfer_access = null
	usage_flags = PROGRAM_PDA
	size = 4
	tgui_id = "NtosChemistry"
	program_icon = "prescription-bottle"

/datum/computer_file/program/chemisty/ui_data(mob/user)
	var/list/data = get_header_data()

	var/list/chems = list()
	for(var/datum/reagent/R in subtypesof(/datum/reagent))
		if(istype(R, /datum/reagent/consumable))
			continue
		chems += list(list(
			"name" = initial(R.name),
			"description" = initial(R.description),
		))

	data["chems"] = chems
	return data
