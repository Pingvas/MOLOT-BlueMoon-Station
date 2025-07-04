/turf/open/floor/holofloor
	holodeck_compatible = TRUE
	icon_state = "floor"
	thermal_conductivity = 0
	flags_1 = NONE

/turf/open/floor/holofloor/attackby(obj/item/I, mob/living/user)
	return // HOLOFLOOR DOES NOT GIVE A FUCK

/turf/open/floor/holofloor/tool_act(mob/living/user, obj/item/I, tool_type)
	return

/turf/open/floor/holofloor/burn_tile()
	return //you can't burn a hologram!

/turf/open/floor/holofloor/break_tile()
	return //you can't break a hologram!

/turf/open/floor/holofloor/plating
	name = "holodeck projector floor"
	icon_state = "engine"

/turf/open/floor/holofloor/plating/burnmix
	name = "burn-mix floor"
	initial_gas_mix = BURNMIX_ATMOS

/turf/open/floor/holofloor/grass
	gender = PLURAL
	name = "lush grass"
	icon_state = "grass"
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/beach
	gender = PLURAL
	name = "sand"
	icon = 'modular_bluemoon/icons/turf/floors/sand.dmi'
	icon_state = "sand"
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/beach/coast_t
	gender = NEUTER
	name = "coastline"
	icon = 'modular_bluemoon/icons/turf/floors/beach.dmi'
	icon_state = "beach"

/turf/open/floor/holofloor/beach/coast_b
	gender = NEUTER
	name = "coastline"
	icon = 'modular_bluemoon/icons/turf/floors/beach.dmi'
	icon_state = "beach-corner"

/turf/open/floor/holofloor/beach/water
	name = "water"
	icon_state = "water"
	icon = 'modular_bluemoon/icons/turf/floors/beach.dmi'
	bullet_sizzle = TRUE

/turf/open/floor/holofloor/asteroid
	name = "asteroid"
	icon_state = "asteroid0"
	tiled_dirt = FALSE

/turf/open/floor/holofloor/asteroid/Initialize(mapload)
	icon_state = "asteroid[rand(0, 12)]"
	. = ..()

/turf/open/floor/holofloor/basalt
	gender = PLURAL
	name = "basalt"
	icon_state = "basalt0"
	tiled_dirt = FALSE

/turf/open/floor/holofloor/basalt/Initialize(mapload)
	. = ..()
	if(prob(15))
		icon_state = "basalt[rand(0, 12)]"
		set_basalt_light(src)

/turf/open/floor/holofloor/space
	name = "\proper space"
	icon = 'icons/turf/space.dmi'
	icon_state = "0"

/turf/open/floor/holofloor/space/Initialize(mapload)
	icon_state = SPACE_ICON_STATE // so realistic
	. = ..()

/turf/open/floor/holofloor/hyperspace
	name = "\proper hyperspace"
	icon = 'icons/turf/space.dmi'
	icon_state = "speedspace_ns_1"
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/hyperspace/Initialize(mapload)
	icon_state = "speedspace_ns_[(x + 5*y + (y%2+1)*7)%15+1]"
	. = ..()

/turf/open/floor/holofloor/hyperspace/ns/Initialize(mapload)
	. = ..()
	icon_state = "speedspace_ns_[(x + 5*y + (y%2+1)*7)%15+1]"

/turf/open/floor/holofloor/carpet
	name = "carpet"
	desc = "Electrically inviting."
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet"
	floor_tile = /obj/item/stack/tile/carpet
	smooth = SMOOTH_TRUE
	canSmoothWith = null
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/carpet/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 1)

/turf/open/floor/holofloor/carpet/update_icon()
	. = ..()
	if(intact)
		queue_smooth(src)

/turf/open/floor/holofloor/wood
	icon_state = "wood"
	tiled_dirt = FALSE

/turf/open/floor/holofloor/snow
	gender = PLURAL
	name = "snow"
	desc = "Looks cold."
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	slowdown = 2
	bullet_sizzle = TRUE
	bullet_bounce_sound = null
	tiled_dirt = FALSE
	baseturfs = /turf/open/floor/holofloor/snow

/turf/open/floor/holofloor/snow/on_attack_hand(mob/living/user, act_intent = user.a_intent, unarmed_attack_flags)
	. = ..()
	if(.)
		return
	user.visible_message("<span class='notice'>[user] scroops up some snow from [src].</span>", "<span class='notice'>You scoop up some snow from [src].</span>")
	var/obj/item/toy/snowball/S = new(get_turf(src))
	user.put_in_hands(S)

/turf/open/floor/holofloor/snow/cold
	initial_gas_mix = "nob=7500;TEMP=2.7"

/turf/open/floor/holofloor/asteroid
	gender = PLURAL
	name = "asteroid sand"
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	tiled_dirt = FALSE

/turf/open/floor/holofloor/ice
	name = "ice sheet"
	desc = "A sheet of solid ice. Looks slippery."
	icon = 'icons/turf/floors/ice_turf.dmi'
	icon_state = "unsmooth"
	baseturfs = /turf/open/floor/holofloor/ice
	slowdown = 1
	footstep = FOOTSTEP_FLOOR

/turf/open/floor/holofloor/ice/smooth
	icon_state = "smooth"
	smooth = SMOOTH_MORE | SMOOTH_BORDER
	canSmoothWith = list(/turf/open/floor/plating/ice/smooth, /turf/open/floor/plating/ice, /turf/open/floor/holofloor/ice)
	baseturfs = /turf/open/floor/holofloor/ice/smooth

/turf/open/floor/holofloor/ice/Initialize(mapload)
	. = ..()
	MakeSlippery(TURF_WET_PERMAFROST, INFINITY, 0, INFINITY, TRUE)
