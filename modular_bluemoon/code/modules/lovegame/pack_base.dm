// Base love card datum with required fields

/datum/love_card
	var/name = "Card"
	var/desc = "A card."
	var/icon = null
	var/icon_state = "card"
	var/pack = null

/datum/love_card/truths
	name = "Truth Card"
	desc = "A truth question"
	icon_state = "vopros"
	pack = 'icons/obj/lovecard/pack_1.dmi'
	var/cardname = "vopros"

/datum/love_card/kinks
	name = "Kink Card"
	desc = "A flirty prompt"
	icon_state = "kink"
	pack = 'icons/obj/lovecard/pack_1.dmi'
	var/cardname = "kink"

/datum/love_card/actions
	name = "Action Card"
	desc = "An action to perform"
	icon_state = "deystvie"
	pack = 'icons/obj/lovecard/pack_1.dmi'
	var/cardname = "deystvie"
