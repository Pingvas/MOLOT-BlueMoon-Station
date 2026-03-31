/**
 * Желательно тут вообще ничего не трогать.
 * Required keys in spawn_params:
 *   "type"        - text typepath of the atom to spawn
 *   "amount"      - how many to spawn (clamped to ADMIN_SPAWN_CAP)
 *   "whereTarget" - one of the WHERE_* defines from spawn_panel.dm
 *   "offsetX/Y/Z" - numeric offset
 *   "offsetType"  - OFFSET_ABSOLUTE or OFFSET_RELATIVE
 * Optional keys:
 *   "atomName"    - string name override
 *   "atomDir"     - BYOND dir int
 *   "targetTurf"  - /turf, used when whereTarget == WHERE_TARGETED_LOCATION*
 */
/datum/spawnpanel/proc/spawn_atom(list/spawn_params, mob/user)
	if(!check_rights_for(user.client, R_SPAWN))
		return

	var/path = text2path(spawn_params["type"])
	if(!path)
		to_chat(user, span_warning("SpawnPanel: invalid typepath '[spawn_params["type"]]'"))
		return
	if(!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob))
		to_chat(user, span_warning("SpawnPanel: path must be /obj, /turf, or /mob."))
		return

	var/amount   = clamp(spawn_params["amount"] || 1, 1, ADMIN_SPAWN_CAP)
	var/obj_name = spawn_params["atomName"] ? sanitize(spawn_params["atomName"]) : null
	var/obj_dir  = text2num(spawn_params["atomDir"])
	if(obj_dir && !(obj_dir in list(1,2,4,8,5,6,9,10)))
		obj_dir = null

	var/where    = spawn_params["whereTarget"] || WHERE_FLOOR_BELOW_MOB

	var/offset_x = text2num(spawn_params["offsetX"]) || 0
	var/offset_y = text2num(spawn_params["offsetY"]) || 0
	var/offset_z = text2num(spawn_params["offsetZ"]) || 0
	var/offset_type = spawn_params["offsetType"] || OFFSET_RELATIVE

	var/turf/target
	var/mob/target_mob = null

	switch(where)
		if(WHERE_FLOOR_BELOW_MOB)
			var/turf/user_turf = get_turf(user)
			if(offset_type == OFFSET_ABSOLUTE)
				target = locate(offset_x, offset_y, offset_z)
			else
				target = locate(user_turf.x + offset_x, user_turf.y + offset_y, user_turf.z + offset_z)
			if(!target)
				target = user_turf

		if(WHERE_SUPPLY_BELOW_MOB)
			var/turf/user_turf = get_turf(user)
			if(offset_type == OFFSET_ABSOLUTE)
				target = locate(offset_x, offset_y, offset_z)
			else
				target = locate(user_turf.x + offset_x, user_turf.y + offset_y, user_turf.z + offset_z)
			if(!target)
				target = user_turf

		if(WHERE_MOB_HAND)
			if(!iscarbon(user) && !iscyborg(user))
				to_chat(user, span_warning("SpawnPanel: Can only spawn in hand as a carbon or cyborg."))
				return
			target = user

		if(WHERE_MARKED_OBJECT)
			var/datum/marked = user.client.holder?.marked_datum
			if(!marked)
				to_chat(user, span_warning("SpawnPanel: No marked datum."))
				return
			if(!isatom(marked))
				to_chat(user, span_warning("SpawnPanel: Marked datum must be an /atom."))
				return
			target = get_turf(marked)

		if(WHERE_IN_MARKED_OBJECT)
			var/datum/marked = user.client.holder?.marked_datum
			if(!marked || !isatom(marked))
				to_chat(user, span_warning("SpawnPanel: No valid marked atom."))
				return
			target = marked

		if(WHERE_TARGETED_LOCATION, WHERE_TARGETED_LOCATION_POD)
			var/turf/precise = spawn_params["targetTurf"]
			if(!precise)
				to_chat(user, span_warning("SpawnPanel: No targeted location set."))
				return
			target = precise

		if(WHERE_TARGETED_MOB_HAND)
			var/mob/hand_target = spawn_params["targetMob"]
			if(!hand_target || (!iscarbon(hand_target) && !iscyborg(hand_target)))
				to_chat(user, span_warning("SpawnPanel: No valid targeted mob for hand spawn."))
				return
			target_mob = hand_target
			target = hand_target
		else
			if(!target)
				target = get_turf(user)

	var/obj/structure/closet/supplypod/centcompod/pod = null
	if(where == WHERE_SUPPLY_BELOW_MOB || where == WHERE_TARGETED_LOCATION_POD)
		pod = new

	for(var/i in 1 to amount)
		if(ispath(path, /turf))
			var/turf/T = get_turf(target)
			if(T)
				var/turf/N = T.ChangeTurf(path)
				if(N && obj_name)
					N.name = obj_name
		else
			var/atom/movable/O
			if(pod)
				O = new path(pod)
			else
				O = new path(target)
			if(!QDELETED(O))
				O.flags_1 |= ADMIN_SPAWNED_1
				if(obj_dir)
					O.setDir(obj_dir)
				if(obj_name)
					O.name = obj_name
					if(ismob(O))
						var/mob/M = O
						M.real_name = obj_name
				if((where == WHERE_MOB_HAND) && isliving(user) && isitem(O))
					var/mob/living/L = user
					var/obj/item/I = O
					L.put_in_hands(I)
					if(iscyborg(L))
						var/mob/living/silicon/robot/R = L
						if(R.module)
							R.module.add_module(I, TRUE, TRUE)
							R.activate_module(I)
				else if((where == WHERE_TARGETED_MOB_HAND) && target_mob && isliving(target_mob) && isitem(O))
					var/mob/living/LT = target_mob
					var/obj/item/IT = O
					LT.put_in_hands(IT)

	if(pod)
		new /obj/effect/pod_landingzone(get_turf(target), pod)

	if(amount == 1)
		log_admin("[key_name(user)] created a [path] at [AREACOORD(user)]")
		if(ispath(path, /mob))
			message_admins("[key_name_admin(user)] created a [path] at [AREACOORD(user)]")
	else
		log_admin("[key_name(user)] created [amount]x [path] at [AREACOORD(user)]")
		if(ispath(path, /mob))
			message_admins("[key_name_admin(user)] created [amount]x [path] at [AREACOORD(user)]")

#undef WHERE_FLOOR_BELOW_MOB
#undef WHERE_SUPPLY_BELOW_MOB
#undef WHERE_MOB_HAND
#undef WHERE_MARKED_OBJECT
#undef WHERE_IN_MARKED_OBJECT
#undef WHERE_TARGETED_LOCATION
#undef WHERE_TARGETED_LOCATION_POD
#undef WHERE_TARGETED_MOB_HAND
#undef PRECISE_MODE_OFF
#undef PRECISE_MODE_TARGET
#undef PRECISE_MODE_COPY
#undef OFFSET_ABSOLUTE
#undef OFFSET_RELATIVE
