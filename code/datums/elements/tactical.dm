/datum/element/tactical
	element_flags = ELEMENT_DETACH
	var/allowed_slot
	var/list/original_names = list()
	var/static/list/hud_to_hide = list(
		HEALTH_HUD,
		STATUS_HUD,
		ID_HUD,
        WANTED_HUD,
        IMPLOYAL_HUD,
        IMPCHEM_HUD,
        IMPTRACK_HUD,
        RAD_HUD,
    )

/datum/element/tactical/Attach(datum/target, allowed_slot)
	. = ..()
	if(. == ELEMENT_INCOMPATIBLE || !isitem(target))
		return ELEMENT_INCOMPATIBLE

	src.allowed_slot = allowed_slot
	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, PROC_REF(modify))
	RegisterSignal(target, COMSIG_ITEM_DROPPED, PROC_REF(unmodify))

/datum/element/tactical/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	unmodify(target)
	original_names -= target
	return ..()

/datum/element/tactical/proc/modify(obj/item/source, mob/user, slot)
	if(allowed_slot && slot != allowed_slot)
		unmodify(source, user)
		return

	var/image/I = image(icon = source.icon, icon_state = source.icon_state, loc = user)
	I.copy_overlays(source)
	I.layer = ABOVE_MOB_LAYER
	I.override = TRUE
	if(!original_names[source])
		user.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/everyone, "sneaking_mission", I)
		if(ishuman(user))
			original_names[source] = user.name
			user.name = source.name

	set_hud_alpha(user, 100)

/datum/element/tactical/proc/unmodify(obj/item/source, mob/user)
	if(!user)
		original_names -= source
		return

	user.remove_alt_appearance("sneaking_mission")

	if(ishuman(user) && original_names[source])
		user.name = original_names[source]
	original_names -= source

	set_hud_alpha(user, 255)

/datum/element/tactical/proc/set_hud_alpha(mob/user, alpha = 255)
    for(var/hud_id in hud_to_hide)
        var/image/hud_image = user.hud_list[hud_id]
        hud_image?.alpha = alpha
