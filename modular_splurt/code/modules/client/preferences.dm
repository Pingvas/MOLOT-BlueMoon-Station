
/datum/preferences
	max_save_slots = DEFAULT_SAVE_SLOTS
	var/unholypref = "No" //Goin 2 hell fo dis one
//	var/stomppref = TRUE // Please step on me.
	var/list/gfluid_blacklist = list() //Stuff you don't want people to cum into you
	var/fuzzy = FALSE			//Fuzzy scaling

/datum/preferences/New(client/C)
	// Check if readable fluids list exists
	// Please move this check a better location if possible
	if(!GLOB.genital_fluids_list)
		// Build list
		build_genital_fluids_list()

	//Extra saves for donators
	max_save_slots = CONFIG_GET(number/base_save_slots)
	if(istype(C))
		var/extra_slots = 0
		if(IS_CKEY_DONATOR_GROUP(C.key, DONATOR_GROUP_TIER_3))
			extra_slots = 30
		else if(IS_CKEY_DONATOR_GROUP(C.key, DONATOR_GROUP_TIER_2))
			extra_slots = 20
		else if(IS_CKEY_DONATOR_GROUP(C.key, DONATOR_GROUP_TIER_1))
			extra_slots = 10
		max_save_slots = max_save_slots + extra_slots

	. = ..()

/datum/preferences/copy_to(mob/living/carbon/human/character, icon_updates, roundstart_checks, initial_spawn)
	character.fuzzy = fuzzy
	. = ..()

