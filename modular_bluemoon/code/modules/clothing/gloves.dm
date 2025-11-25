/obj/item/clothing/gloves/cbrn/mopp
	icon = 'modular_bluemoon/icons/obj/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_bluemoon/icons/mob/clothing/hands.dmi'
	icon_state = "mopp"
	item_state = "mopp"

/obj/item/clothing/gloves/cbrn/engineer
	icon = 'modular_bluemoon/icons/obj/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_bluemoon/icons/mob/clothing/hands.dmi'
	icon_state = "cbrn_engi"
	item_state = "cbrn_engi"

//////////////////////////////////////////////////////////////////////
/obj/item/clothing/gloves/cbrn/medical
	name = "medical CBRN gloves"
	desc = "Chemical, Biological, Radiological and Nuclear. Thick black gloves design for working in hazardous environments and seems to have a thin layer of nitrile for better grasps."
	icon = 'modular_bluemoon/icons/obj/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_bluemoon/icons/mob/clothing/hands.dmi'
	icon_state = "cbrn_med"
	item_state = "cbrn_med"
	var/carrytrait = TRAIT_QUICK_CARRY

/obj/item/clothing/gloves/cbrn/medical/equipped(mob/user, slot)
	..()
	if(slot == ITEM_SLOT_GLOVES)
		ADD_TRAIT(user, carrytrait, GLOVE_TRAIT)

/obj/item/clothing/gloves/cbrn/medical/dropped(mob/user)
	..()
	REMOVE_TRAIT(user, carrytrait, GLOVE_TRAIT)

// research nod
/datum/design/cbrn/cbrnglovesmed
	name = "Medical CBRN Gloves"
	desc = "A pair of medical CBRN gloves."
	id = "cbrn_glovesmed"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 400, /datum/material/uranium = 55, /datum/material/iron = 200)
	build_path = /obj/item/clothing/gloves/cbrn/medical
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

//////////////////////////////////////////////////////////////////////
// Начало перчатки крашли

/obj/item/clothing/gloves/combat/maid/inteq
	icon = 'modular_bluemoon/icons/obj/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_bluemoon/icons/mob/clothing/gloves.dmi'
	icon_state = "inteqmaid_arms"
	item_state = "inteqmaid_arms"

/obj/item/clothing/gloves/color/latex/nitrile/plaguedoc_new
	name = "plague doctor gloves"
	desc = "They look extremely unhygienic... They just look, right..?"
	icon = 'modular_bluemoon/icons/obj/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_bluemoon/icons/mob/clothing/gloves.dmi'
	icon_state = "plaguedoc_gloves"
	item_state = "plaguedoc_gloves"

// Конец перчатки крашли

/obj/item/clothing/gloves/poly_evening
	name = "polychromic evening gloves"
	desc = "Thin, pretty polychromic gloves intended for use in regal feminine attire."
	icon = 'modular_bluemoon/icons/clothing/object/gloves.dmi'
	mob_overlay_icon = 'modular_bluemoon/icons/clothing/worn/hands.dmi'
	icon_state = "poly_evening"
	item_state = "poly_evening"
	transfer_prints = TRUE
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = COAT_MAX_TEMP_PROTECT
	strip_mod = 0.9

/obj/item/clothing/gloves/poly_evening/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/polychromic, list("#FEFEFE"), 1)

/obj/item/clothing/gloves/transparent
	name = "transparent bracers"
	desc = "A pair of transparent bracers, they look fancy."
	icon = 'modular_bluemoon/icons/clothing/object/gloves.dmi'
	mob_overlay_icon = 'modular_bluemoon/icons/clothing/worn/hands.dmi'
	icon_state = "transparent_bracers"
	item_state = "transparent_bracers"
	transfer_prints = TRUE
