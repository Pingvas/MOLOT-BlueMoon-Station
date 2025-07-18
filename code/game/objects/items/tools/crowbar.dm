/obj/item/crowbar
	name = "pocket crowbar"
	desc = "A small crowbar. This handy tool is useful for lots of things, such as prying floor tiles or opening unpowered doors."
	icon = 'icons/obj/tools.dmi'
	icon_state = "crowbar"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	usesound = 'sound/items/crowbar.ogg'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	item_flags = SURGICAL_TOOL
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron=50)
	drop_sound = 'sound/items/handling/crowbar_drop.ogg'
	pickup_sound = 'sound/items/handling/crowbar_pickup.ogg'

	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
	tool_behaviour = TOOL_CROWBAR
	toolspeed = 1
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 30)

	wound_bonus = 7
	bare_wound_bonus = 8

/obj/item/crowbar/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is beating themself to death with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/weapons/genhit.ogg', 50, 1, -1)
	return (BRUTELOSS)

/obj/item/crowbar/red
	icon_state = "crowbar_red"
	force = 8

/obj/item/crowbar/red/sec
	icon_state = "crowbar_sec"
	item_state = "crowbar_sec"

/obj/item/crowbar/brass
	name = "brass crowbar"
	desc = "A brass crowbar. It feels faintly warm to the touch."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon_state = "crowbar_clock"
	toolspeed = 0.5

/obj/item/crowbar/brass/family
	toolspeed = 1

/obj/item/crowbar/ashwalker
	name = "bone crowbar"
	desc = "A rudimentary crowbar made of bones."
	icon = 'icons/obj/mining.dmi'
	icon_state = "crowbar_bone"
	toolspeed = 0.75

/obj/item/crowbar/bronze
	name = "bronze plated crowbar"
	desc = "A bronze plated crowbar."
	icon_state = "crowbar_brass"
	toolspeed = 0.95

/obj/item/crowbar/abductor
	name = "alien crowbar"
	desc = "A hard-light crowbar. It appears to pry by itself, without any effort required."
	icon = 'icons/obj/abductor.dmi'
	usesound = 'sound/weapons/sonic_jackhammer.ogg'
	icon_state = "crowbar"
	toolspeed = 0.1

/obj/item/crowbar/large
	name = "crowbar"
	desc = "It's a big crowbar. It doesn't fit in your pockets, because it's big."
	force = 12
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 3
	custom_materials = list(/datum/material/iron=70)
	icon_state = "crowbar_large"
	item_state = "crowbar"
	toolspeed = 0.5

/obj/item/crowbar/large/heavy
	name = "heavy crowbar"
	desc = "It's a big crowbar. It doesn't fit in your pockets, because it's big. It feels oddly heavy.."
	force = 14 // BLUEMOON - HEAVY_CROWBAR_DAMAGE_CHANGE - EDIT (было 20)
	icon_state = "crowbar_powergame"

/obj/item/crowbar/cyborg
	name = "hydraulic crowbar"
	desc = "A hydraulic prying tool, compact but powerful. Designed to replace crowbar in construction cyborgs."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "crowbar_cyborg"
	usesound = 'sound/items/jaws_pry.ogg'
	force = 10
	toolspeed = 0.5

/obj/item/crowbar/power
	name = "jaws of life"
	desc = "A set of jaws of life, compressed through the magic of science. It's fitted with a prying head."
	icon_state = "jaws_pry"
	item_state = "jawsoflife"
	lefthand_file = 'modular_sand/icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'modular_sand/icons/mob/inhands/equipment/tools_righthand.dmi'
	custom_materials = list(/datum/material/iron=150,/datum/material/silver=50,/datum/material/titanium=25)

	usesound = 'sound/items/jaws_pry.ogg'
	force = 15
	toolspeed = 0.25
	can_force_powered = TRUE

/obj/item/crowbar/power/syndicate
	name = "Syndicate jaws of life"
	desc = "A pocket sized re-engineered copy of Nanotrasen's standard jaws of life. Can be used to force open airlocks in its crowbar configuration."
	icon = 'icons/obj/tools.dmi'
	icon_state = "jaws_syndie_pry"
	item_state = "jawsoflife"
	force = 20
	toolspeed = 0.20

/obj/item/crowbar/power/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is putting [user.ru_ego()] head in [src], it looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/items/jaws_pry.ogg', 50, 1, -1)
	return (BRUTELOSS)

/obj/item/crowbar/power/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_jaws.ogg', 50, 1)
	var/obj/item/wirecutters/power/cutjaws = new /obj/item/wirecutters/power(drop_location())
	cutjaws.name = name
	to_chat(user, "<span class='notice'>You attach the cutting jaws to [src].</span>")
	qdel(src)
	user.put_in_active_hand(cutjaws)

/obj/item/crowbar/advanced
	name = "advanced crowbar"
	desc = "A scientist's almost successful reproduction of an abductor's crowbar, it uses the same technology combined with a handle that can't quite hold it."
	icon = 'icons/obj/advancedtools.dmi'
	usesound = 'sound/weapons/sonic_jackhammer.ogg'
	icon_state = "crowbar"
	toolspeed = 0.2
// BLUEMOON ADD START black skin
	unique_reskin = list(
		"Carbonized" = list(
			RESKIN_ICON_STATE_FILE = 'modular_bluemoon/icons/obj/advancedtools_black.dmi',
			RESKIN_ICON_STATE = "crowbar_black",
		),
		"Titanium" = list(
			RESKIN_ICON_STATE = "crowbar",
		)
	)
// BLUEMOON ADD END
