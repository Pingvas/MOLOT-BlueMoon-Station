/// The damage healed per tick while sleeping without any modifiers
#define HEALING_SLEEP_DEFAULT -0.005

//Largely negative status effects go here, even if they have small benificial effects
//STUN EFFECTS
/datum/status_effect/incapacitating
	tick_interval = 0
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	var/needs_update_stat = FALSE

/datum/status_effect/incapacitating/on_creation(mob/living/new_owner, set_duration, updating_canmove)
	if(isnum(set_duration))
		duration = set_duration
	. = ..()
	if(.)
		if(updating_canmove)
			owner.update_mobility()
			if(needs_update_stat || issilicon(owner))
				owner.update_stat()

/datum/status_effect/incapacitating/on_remove()
	. = ..()
	owner.update_mobility()
	if(needs_update_stat || issilicon(owner)) //silicons need stat updates in addition to normal canmove updates
		owner.update_stat()

//STUN
/datum/status_effect/incapacitating/stun
	id = "stun"

/datum/status_effect/incapacitating/stun/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_INCAPACITATED, id)
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, id)
	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, id)

/datum/status_effect/incapacitating/stun/on_remove()
	REMOVE_TRAIT(owner, TRAIT_INCAPACITATED, id)
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, id)
	REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, id)
	return ..()

//KNOCKDOWN
/datum/status_effect/incapacitating/knockdown
	id = "knockdown"

/datum/status_effect/incapacitating/knockdown/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_FLOORED, id)

/datum/status_effect/incapacitating/knockdown/on_remove()
	REMOVE_TRAIT(owner, TRAIT_FLOORED, id)
	return ..()

//IMMOBILIZED
/datum/status_effect/incapacitating/immobilized
	id = "immobilized"

//PARALYZED
/datum/status_effect/incapacitating/paralyzed
	id = "paralyzed"

/datum/status_effect/incapacitating/paralyzed/tick()
	if(owner.getStaminaLoss())
		owner.adjustStaminaLoss(-0.3) //reduce stamina loss by 0.3 per tick, 6 per 2 seconds

//DAZED
/datum/status_effect/incapacitating/dazed
	id = "dazed"

//UNCONSCIOUS
/datum/status_effect/incapacitating/unconscious
	id = "unconscious"
	needs_update_stat = TRUE

/datum/status_effect/incapacitating/unconscious/tick()
	if(owner.getStaminaLoss())
		owner.adjustStaminaLoss(-0.3) //reduce stamina loss by 0.3 per tick, 6 per 2 seconds

//SLEEPING
/datum/status_effect/incapacitating/sleeping
	id = "sleeping"
	alert_type = /atom/movable/screen/alert/status_effect/asleep
	needs_update_stat = TRUE
	var/mob/living/carbon/carbon_owner
	var/mob/living/carbon/human/human_owner

/datum/status_effect/incapacitating/sleeping/on_creation(mob/living/new_owner, updating_canmove)
	. = ..()
	if(.)
		if(iscarbon(owner)) //to avoid repeated istypes
			carbon_owner = owner
		if(ishuman(owner))
			human_owner = owner

/datum/status_effect/incapacitating/sleeping/Destroy()
	carbon_owner = null
	human_owner = null
	return ..()

/datum/status_effect/incapacitating/sleeping/tick()
	if(owner.maxHealth)
		var/health_ratio = owner.health / owner.maxHealth
		var/healing = HEALING_SLEEP_DEFAULT
		if((locate(/obj/structure/bed) in owner.loc))
			healing += -0.005
		else if((locate(/obj/structure/table) in owner.loc))
			healing += -0.0025
		else if((locate(/obj/structure/chair) in owner.loc))
			healing += -0.0025
		if(locate(/obj/item/bedsheet) in owner.loc)
			healing += -0.005
		if(health_ratio > 0.75) // Only heal when above 75% health
			owner.adjustBruteLoss(healing)
			owner.adjustFireLoss(healing)
			owner.adjustToxLoss(healing * 0.5, forced = TRUE)
		owner.adjustStaminaLoss(healing)
	if(human_owner && human_owner.drunkenness)
		human_owner.drunkenness *= -0.997 //reduce drunkenness by 0.3% per tick, 6% per 2 seconds
	if(carbon_owner && !carbon_owner.dreaming && prob(2))
		carbon_owner.dream()
	// 2% per second, tick interval is in deciseconds
	if(prob((tick_interval+1) * 0.2) && owner.health > owner.crit_threshold)
		if(!iscatperson(owner))
			owner.emote("snore")
		else
			owner.emote("purr") //cats can purr in their sleep

/**
 * # Transient Status Effect (basetype)
 *
 * A status effect that works off a (possibly decimal) counter before expiring, rather than a specified world.time.
 * This allows for a more precise tweaking of status durations at runtime (e.g. paralysis).
 */
/datum/status_effect/transient
	tick_interval = 0.2 SECONDS // SSfastprocess interval
	alert_type = null
	/// How much strength left before expiring? time in deciseconds.
	var/strength = 0

/datum/status_effect/transient/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		strength = set_duration
	. = ..()


/datum/status_effect/transient/tick()
	if(QDELETED(src) || QDELETED(owner))
		return FALSE
	. = TRUE
	strength += calc_decay()
	if(strength <= 0)
		qdel(src)
		return FALSE

/**
 * Returns how much strength should be adjusted per tick.
 */
/datum/status_effect/transient/proc/calc_decay()
	return -0.2 SECONDS // 1 per second by default

//SLOWED - slows down the victim for a duration and a given slowdown value.
/datum/status_effect/incapacitating/slowed
	id = "slowed"
	var/slowdown_value = 10 // defaults to this value if none is specified

/datum/status_effect/incapacitating/slowed/on_creation(mob/living/new_owner, set_duration, _slowdown_value)
	. = ..()
	if(isnum(_slowdown_value))
		slowdown_value = _slowdown_value

/datum/status_effect/transient/silence
	id = "silenced"

/datum/status_effect/transient/silence/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_MUTE, id)

/datum/status_effect/transient/silence/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_MUTE, id)

/**
 * # Confusion
 *
 * Prevents moving straight, sometimes changing movement direction at random.
 * Decays at a rate of 1 per second.
 */
/datum/status_effect/transient/confusion
	id = "confusion"
	var/image/overlay

/datum/status_effect/transient/confusion/tick()
	. = ..()
	if(!.)
		return
	if(!owner.stat) //add or remove the overlay if they are alive or unconscious/dead
		add_overlay()
	else if(overlay)
		owner.cut_overlay(overlay)
		overlay = null

/datum/status_effect/transient/confusion/proc/add_overlay()
	if(overlay)
		return
	var/matrix/M = matrix()
	M.Scale(0.6)
	overlay = image('icons/effects/effects.dmi', "confusion", pixel_y = 20)
	overlay.transform = M
	owner.add_overlay(overlay)

/datum/status_effect/transient/confusion/on_remove()
	owner.cut_overlay(overlay)
	overlay = null
	return ..()

/atom/movable/screen/alert/status_effect/asleep
	name = "Asleep"
	desc = "You've fallen asleep. Wait a bit and you should wake up. Unless you don't, considering how helpless you are."
	icon_state = "asleep"

/datum/status_effect/staggered
	id = "staggered"
	blocks_sprint = TRUE
	alert_type = null

/datum/status_effect/staggered/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	if(!CONFIG_GET(flag/sprint_enabled))
		new_owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/status_effect/stagger, TRUE, CONFIG_GET(number/sprintless_stagger_slowdown))
	return ..()

/datum/status_effect/staggered/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/stagger)
	return ..()

/datum/status_effect/off_balance
	id = "offbalance"
	blocks_sprint = TRUE
	alert_type = null

/datum/status_effect/off_balance/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	if(!CONFIG_GET(flag/sprint_enabled))
		new_owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/status_effect/off_balance, TRUE, CONFIG_GET(number/sprintless_off_balance_slowdown))
	return ..()

/datum/status_effect/off_balance/on_remove()
	var/active_item = owner.get_active_held_item()
	if(active_item)
		owner.visible_message("<span class='warning'>[owner.name] regains their grip on \the [active_item]!</span>", "<span class='warning'>You regain your grip on \the [active_item]</span>", null, COMBAT_MESSAGE_RANGE)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/off_balance)
	return ..()

/datum/status_effect/grouped/stasis
	id = "stasis"
	duration = -1
	tick_interval = 10
	alert_type = /atom/movable/screen/alert/status_effect/stasis
	var/last_dead_time

/datum/status_effect/grouped/stasis/proc/update_time_of_death()
	if(last_dead_time)
		var/delta = world.time - last_dead_time
		var/new_timeofdeath = owner.timeofdeath + delta
		owner.timeofdeath = new_timeofdeath
		owner.tod = gameTimestamp(wtime=new_timeofdeath)
		last_dead_time = null
	if(owner.stat == DEAD)
		last_dead_time = world.time

/datum/status_effect/grouped/stasis/on_creation(mob/living/new_owner, set_duration)
	. = ..()
	if(.)
		update_time_of_death()
		owner.reagents?.end_metabolization(owner, FALSE)

/datum/status_effect/grouped/stasis/on_apply()
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_LIVING_LIFE, PROC_REF(InterruptBiologicalLife))
	owner.mobility_flags &= ~(MOBILITY_USE | MOBILITY_PICKUP | MOBILITY_PULL | MOBILITY_HOLD)
	owner.update_mobility()
	owner.add_filter("stasis_status_ripple", 2, list("type" = "ripple", "flags" = WAVE_BOUNDED, "radius" = 0, "size" = 2))
	var/filter = owner.get_filter("stasis_status_ripple")
	animate(filter, radius = 32, time = 15, size = 0, loop = -1)

/datum/status_effect/grouped/stasis/proc/InterruptBiologicalLife()
	return COMPONENT_INTERRUPT_LIFE_BIOLOGICAL

/datum/status_effect/grouped/stasis/tick()
	update_time_of_death()

/datum/status_effect/grouped/stasis/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_LIFE)
	owner.mobility_flags |= MOBILITY_USE | MOBILITY_PICKUP | MOBILITY_PULL | MOBILITY_HOLD
	owner.remove_filter("stasis_status_ripple")
	update_time_of_death()
	return ..()

/atom/movable/screen/alert/status_effect/stasis
	name = "Stasis"
	desc = "Your biological functions have halted. You could live forever this way, but it's pretty boring."
	icon_state = "stasis"

/datum/status_effect/robotic_emp
	id = "emp_no_combat_mode"

/datum/status_effect/mesmerize
	id = "Mesmerize"
	alert_type = /atom/movable/screen/alert/status_effect/mesmerized

/datum/status_effect/mesmerize/on_creation(mob/living/new_owner, set_duration)
	. = ..()
	ADD_TRAIT(owner, TRAIT_MUTE, "mesmerize")
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/mesmerize)

/datum/status_effect/mesmerize/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_MUTE, "mesmerize")
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/mesmerize)

/datum/status_effect/mesmerize/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	. = ..()

/atom/movable/screen/alert/status_effect/mesmerized
	name = "Mesmerized"
	desc = "You can't tear your sight from who is in front of you... their gaze is simply too enthralling.."
	icon = 'icons/mob/actions/bloodsucker.dmi'
	icon_state = "power_mez"

/datum/status_effect/electrode
	id = "tased"
	alert_type = null
	var/movespeed_mod = /datum/movespeed_modifier/status_effect/tased
	var/stamdmg_per_ds = 1		//a 20 duration would do 20 stamdmg, disablers do 24 or something
	var/last_tick = 0			//fastprocess processing speed is a goddamn sham, don't trust it.

/datum/status_effect/electrode/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration)) //TODO, figure out how to grab from subtype
		duration = set_duration
	. = ..()
	last_tick = world.time
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.add_movespeed_modifier(movespeed_mod)

/datum/status_effect/electrode/on_remove()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.remove_movespeed_modifier(movespeed_mod)
	. = ..()

/datum/status_effect/electrode/tick()
	var/diff = world.time - last_tick
	if(owner)
		var/mob/living/carbon/C = owner
		if(HAS_TRAIT(C, TRAIT_TASED_RESISTANCE))
			qdel(src)
		else
			C.adjustStaminaLoss(max(0, stamdmg_per_ds * diff)) //if you really want to try to stamcrit someone with a taser alone, you can, but it'll take time and good timing.
	last_tick = world.time

/datum/status_effect/electrode/no_damage
	stamdmg_per_ds = 0

/datum/status_effect/electrode/no_combat_mode
	id = "tased_strong"
	movespeed_mod = /datum/movespeed_modifier/status_effect/tased/no_combat_mode
	stamdmg_per_ds = 1

/datum/status_effect/vtec_disabled
	id = "vtec_disable"
	tick = FALSE

/datum/status_effect/vtec_disabled/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	. = ..()
	if(iscyborg(owner))
		var/mob/living/silicon/robot/R = owner
		R.vtec_disabled = TRUE

/datum/status_effect/vtec_disabled/on_remove()
	if(iscyborg(owner))
		var/mob/living/silicon/robot/R = owner
		R.vtec_disabled = FALSE
	return ..()

//OTHER DEBUFFS
/datum/status_effect/his_wrath //does minor damage over time unless holding His Grace
	id = "his_wrath"
	duration = -1
	tick_interval = 4
	alert_type = /atom/movable/screen/alert/status_effect/his_wrath

/atom/movable/screen/alert/status_effect/his_wrath
	name = "His Wrath"
	desc = "You fled from His Grace instead of feeding Him, and now you suffer."
	icon_state = "his_grace"
	alerttooltipstyle = "hisgrace"

/datum/status_effect/his_wrath/tick()
	for(var/obj/item/his_grace/HG in owner.held_items)
		qdel(src)
		return
	owner.adjustBruteLoss(0.5)
	owner.adjustFireLoss(0.5)
	owner.adjustToxLoss(0.3, TRUE, TRUE)

/datum/status_effect/belligerent
	id = "belligerent"
	duration = 70
	tick_interval = 0 //tick as fast as possible
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/status_effect/belligerent
	var/leg_damage_on_toggle = 2 //damage on initial application and when the owner tries to toggle to run
	var/cultist_damage_on_toggle = 10 //damage on initial application and when the owner tries to toggle to run, but to cultists

/atom/movable/screen/alert/status_effect/belligerent
	name = "Belligerent"
	desc = "<b><font color=#880020>Kneel, her-eti'c.</font></b>"
	icon_state = "belligerent"
	alerttooltipstyle = "clockcult"

/datum/status_effect/belligerent/on_apply()
	. = ..()
	return do_movement_toggle(TRUE)

/datum/status_effect/belligerent/tick()
	if(!do_movement_toggle())
		qdel(src)

/datum/status_effect/belligerent/proc/do_movement_toggle(force_damage)
	var/number_legs = owner.get_num_legs(FALSE)
	if(iscarbon(owner) && !is_servant_of_ratvar(owner) && !owner.anti_magic_check(chargecost = 0) && number_legs)
		if(force_damage || owner.m_intent != MOVE_INTENT_WALK)
			if(GLOB.ratvar_awakens)
				owner.DefaultCombatKnockdown(20)
			if(iscultist(owner))
				owner.apply_damage(cultist_damage_on_toggle * 0.5, BURN, BODY_ZONE_L_LEG)
				owner.apply_damage(cultist_damage_on_toggle * 0.5, BURN, BODY_ZONE_R_LEG)
			else
				owner.apply_damage(leg_damage_on_toggle * 0.5, BURN, BODY_ZONE_L_LEG)
				owner.apply_damage(leg_damage_on_toggle * 0.5, BURN, BODY_ZONE_R_LEG)
		if(owner.m_intent != MOVE_INTENT_WALK)
			if(!iscultist(owner))
				to_chat(owner, "<span class='warning'>Your leg[number_legs > 1 ? "s shiver":" shivers"] with pain!</span>")
			else //Cultists take extra burn damage
				to_chat(owner, "<span class='warning'>Your leg[number_legs > 1 ? "s burn":" burns"] with pain!</span>")
			owner.toggle_move_intent()
		return TRUE
	return FALSE

/datum/status_effect/belligerent/on_remove()
	if(owner.m_intent == MOVE_INTENT_WALK)
		owner.toggle_move_intent()
	return ..()

/datum/status_effect/maniamotor
	id = "maniamotor"
	duration = -1
	tick_interval = 10
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	var/obj/structure/destructible/clockwork/powered/mania_motor/motor
	var/severity = 0 //goes up to a maximum of MAX_MANIA_SEVERITY
	var/warned_turnoff = FALSE //if we've warned that the motor is off
	var/warned_outofsight = FALSE //if we've warned that the target is out of sight of the motor
	var/static/list/mania_messages = list("Go nuts.", "Take a crack at crazy.", "Make a bid for insanity.", "Get kooky.", "Move towards mania.", "Become bewildered.", "Wax wild.", \
	"Go round the bend.", "Land in lunacy.", "Try dementia.", "Strive to get a screw loose.", "Advance forward.", "Approach the transmitter.", "Touch the antennae.", \
	"Move towards the mania motor.", "Come closer.", "Get over here already!", "Keep your eyes on the motor.")
	var/static/list/flee_messages = list("Oh, NOW you flee.", "Get back here!", "If you were smarter, you'd come back.", "Only fools run.", "You'll be back.")
	var/static/list/turnoff_messages = list("Why would they turn it-", "What are these idi-", "Fools, fools, all of-", "Are they trying to c-", "All this effort just f-")
	var/static/list/powerloss_messages = list("\"Oh, the id**ts di***t s***e en**** pow**...\"" = TRUE, "\"D*dn't **ey mak* an **te***c*i*n le**?\"" = TRUE, "\"The** f**ls for**t t* make a ***** *f-\"" = TRUE, \
	"\"No, *O, you **re so cl***-\"" = TRUE, "You hear a yell of frustration, cut off by static." = FALSE)

/datum/status_effect/maniamotor/on_creation(mob/living/new_owner, obj/structure/destructible/clockwork/powered/mania_motor/new_motor)
	. = ..()
	if(.)
		motor = new_motor

/datum/status_effect/maniamotor/Destroy()
	motor = null
	return ..()

/datum/status_effect/maniamotor/tick()
	var/is_servant = is_servant_of_ratvar(owner)
	var/span_part = severity > 50 ? "" : "_small" //let's save like one check
	if(QDELETED(motor))
		if(!is_servant)
			to_chat(owner, "<span class='sevtug[span_part]'>You feel a frustrated voice quietly fade from your mind...</span>")
		qdel(src)
		return
	if(!motor.active) //it being off makes it fall off much faster
		if(!is_servant && !warned_turnoff)
			if(can_access_clockwork_power(motor, motor.mania_cost))
				to_chat(owner, "<span class='sevtug[span_part]'>\"[text2ratvar(pick(turnoff_messages))]\"</span>")
			else
				var/pickedmessage = pick(powerloss_messages)
				to_chat(owner, "<span class='sevtug[span_part]'>[powerloss_messages[pickedmessage] ? "[text2ratvar(pickedmessage)]" : pickedmessage]</span>")
			warned_turnoff = TRUE
		severity = max(severity - 2, 0)
		if(!severity)
			qdel(src)
			return
	else
		if(prob(severity * 2))
			warned_turnoff = FALSE
		if(!(owner in viewers(7, motor))) //not being in range makes it fall off slightly faster
			if(!is_servant && !warned_outofsight)
				to_chat(owner, "<span class='sevtug[span_part]'>\"[text2ratvar(pick(flee_messages))]\"</span>")
				warned_outofsight = TRUE
			severity = max(severity - 1, 0)
			if(!severity)
				qdel(src)
				return
		else if(prob(severity * 2))
			warned_outofsight = FALSE
	if(is_servant) //heals servants of braindamage, hallucination, druggy, dizziness, and confusion
		if(owner.hallucination)
			owner.hallucination = 0
		if(owner.druggy)
			owner.adjust_drugginess(-owner.druggy)
		if(owner.dizziness)
			owner.dizziness = 0
		if(owner.confused)
			owner.confused = 0
		severity = 0
	else if(!owner.anti_magic_check(chargecost = 0) && owner.stat != DEAD && severity)
		var/static/hum = get_sfx('sound/effects/screech.ogg') //same sound for every proc call
		if(owner.getToxLoss() > MANIA_DAMAGE_TO_CONVERT)
			if(is_eligible_servant(owner))
				to_chat(owner, "<span class='sevtug[span_part]'>\"[text2ratvar("You are mine and his, now.")]\"</span>")
				if(add_servant_of_ratvar(owner))
					owner.log_message("conversion was done with a Mania Motor", LOG_ATTACK, color="#BE8700")
			owner.Unconscious(100)
		else
			if(prob(severity * 0.15))
				to_chat(owner, "<span class='sevtug[span_part]'>\"[text2ratvar(pick(mania_messages))]\"</span>")
			owner.playsound_local(get_turf(motor), hum, severity, 1)
			owner.adjust_drugginess(clamp(max(severity * 0.075, 1), 0, max(0, 50 - owner.druggy))) //7.5% of severity per second, minimum 1
			if(owner.hallucination < 50)
				owner.hallucination = min(owner.hallucination + max(severity * 0.075, 1), 50) //7.5% of severity per second, minimum 1
			if(owner.dizziness < 50)
				owner.dizziness = min(owner.dizziness + round(severity * 0.05, 1), 50) //5% of severity per second above 10 severity
			if(owner.confused < 25)
				owner.confused = min(owner.confused + round(severity * 0.025, 1), 25) //2.5% of severity per second above 20 severity
			owner.adjustToxLoss(severity * 0.02, TRUE, TRUE) //2% of severity per second
		severity--

/datum/status_effect/cultghost //is a cult ghost and can't use manifest runes
	id = "cult_ghost"
	duration = -1
	alert_type = null

/datum/status_effect/cultghost/on_apply()
	. = ..()
	owner.see_invisible = SEE_INVISIBLE_OBSERVER
	owner.see_in_dark = 2

/datum/status_effect/cultghost/tick()
	if(owner.reagents)
		owner.reagents.del_reagent(/datum/reagent/water/holywater) //can't be deconverted

/datum/status_effect/crusher_mark
	id = "crusher_mark"
	duration = 300 //if you leave for 30 seconds you lose the mark, deal with it
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	var/mutable_appearance/marked_underlay
	var/obj/item/kinetic_crusher/hammer_synced

/datum/status_effect/crusher_mark/on_creation(mob/living/new_owner, obj/item/kinetic_crusher/new_hammer_synced)
	. = ..()
	if(.)
		hammer_synced = new_hammer_synced

/datum/status_effect/crusher_mark/on_apply()
	. = ..()
	if(owner.mob_size >= MOB_SIZE_LARGE)
		marked_underlay = mutable_appearance('icons/effects/effects.dmi', "shield2")
		marked_underlay.pixel_x = -owner.pixel_x
		marked_underlay.pixel_y = -owner.pixel_y
		owner.underlays += marked_underlay
		return TRUE
	return FALSE

/datum/status_effect/crusher_mark/Destroy()
	hammer_synced = null
	if(owner)
		owner.underlays -= marked_underlay
	QDEL_NULL(marked_underlay)
	return ..()

/datum/status_effect/crusher_mark/be_replaced()
	owner.underlays -= marked_underlay //if this is being called, we should have an owner at this point.
	..()

/datum/status_effect/eldritch
	duration = 15 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	on_remove_on_mob_delete = TRUE
	///underlay used to indicate that someone is marked
	var/mutable_appearance/marked_underlay
	///path for the underlay
	var/effect_sprite = ""

/datum/status_effect/eldritch/on_creation(mob/living/new_owner, ...)
	marked_underlay = mutable_appearance('icons/effects/effects.dmi', effect_sprite,BELOW_MOB_LAYER)
	return ..()

/datum/status_effect/eldritch/on_apply()
	. = ..()
	if(owner.mob_size >= MOB_SIZE_HUMAN)
		RegisterSignal(owner,COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_owner_underlay))
		owner.update_icon()
		return TRUE
	return FALSE

/datum/status_effect/eldritch/on_remove()
	UnregisterSignal(owner,COMSIG_ATOM_UPDATE_OVERLAYS)
	owner.update_icon()
	return ..()

/datum/status_effect/eldritch/proc/update_owner_underlay(atom/source, list/overlays)
	overlays += marked_underlay

/datum/status_effect/eldritch/Destroy()
	QDEL_NULL(marked_underlay)
	return ..()

/**
  * What happens when this mark gets popped
  *
  * Adds actual functionality to each mark
  */
/datum/status_effect/eldritch/proc/on_effect()
	playsound(owner, 'sound/magic/repulse.ogg', 75, TRUE)
	qdel(src) //what happens when this is procced.

//Each mark has diffrent effects when it is destroyed that combine with the mansus grasp effect.
/datum/status_effect/eldritch/flesh
	id = "flesh_mark"
	effect_sprite = "emark1"

/datum/status_effect/eldritch/flesh/on_effect()

	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		var/obj/item/bodypart/bodypart = pick(H.bodyparts)
		var/datum/wound/slash/severe/crit_wound = new
		crit_wound.apply_wound(bodypart)
	return ..()

/datum/status_effect/eldritch/ash
	id = "ash_mark"
	effect_sprite = "emark2"
	///Dictates how much damage and stamina loss this mark will cause.
	var/repetitions = 1

/datum/status_effect/eldritch/ash/on_creation(mob/living/new_owner, _repetition = 5)
	. = ..()
	repetitions = min(1,_repetition)

/datum/status_effect/eldritch/ash/on_effect()
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.adjustStaminaLoss(10 * repetitions)
		carbon_owner.adjustFireLoss(5 * repetitions)
		for(var/mob/living/carbon/victim in range(1,carbon_owner))
			if(IS_HERETIC(victim) || victim == carbon_owner)
				continue
			victim.apply_status_effect(type,repetitions-1)
			break
	return ..()

/datum/status_effect/eldritch/rust
	id = "rust_mark"
	effect_sprite = "emark3"

/datum/status_effect/eldritch/rust/on_effect()
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/carbon_owner = owner
	for(var/obj/item/I in carbon_owner.get_all_gear())	//Affects roughly 75% of items
		if(!QDELETED(I) && prob(75)) //Just in case
			I.take_damage(100)
	return ..()

/datum/status_effect/eldritch/void
	id = "void_mark"
	effect_sprite = "emark4"

/datum/status_effect/eldritch/void/on_effect()
	var/turf/open/turfie = get_turf(owner)
	turfie.TakeTemperature(-40)
	owner.adjust_bodytemperature(-60)
	return ..()

/datum/status_effect/domain
	id = "domain"
	alert_type = null
	var/movespeed_mod = /datum/movespeed_modifier/status_effect/domain

/datum/status_effect/domain/on_creation(mob/living/new_owner, set_duration)
	if(isliving(owner))
		var/mob/living/carbon/C = owner
		C.add_movespeed_modifier(movespeed_mod)

/datum/status_effect/electrode/on_remove()
	if(isliving(owner))
		var/mob/living/carbon/C = owner
		C.remove_movespeed_modifier(movespeed_mod)
	. = ..()

/datum/status_effect/corrosion_curse
	id = "corrosion_curse"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	tick_interval = 1 SECONDS

/datum/status_effect/corrosion_curse/on_creation(mob/living/new_owner, ...)
	. = ..()
	to_chat(owner, "<span class='danger'>You feel your body starting to break apart...</span>")

/datum/status_effect/corrosion_curse/tick()
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	var/chance = rand(0,100)
	switch(chance)
		if(0 to 19)
			H.vomit()
		if(20 to 29)
			H.Dizzy(10)
		if(30 to 39)
			H.adjustOrganLoss(ORGAN_SLOT_LIVER,5)
		if(40 to 49)
			H.adjustOrganLoss(ORGAN_SLOT_HEART,5)
		if(50 to 59)
			H.adjustOrganLoss(ORGAN_SLOT_STOMACH,5)
		if(60 to 69)
			H.adjustOrganLoss(ORGAN_SLOT_EYES,10)
		if(70 to 79)
			H.adjustOrganLoss(ORGAN_SLOT_EARS,10)
		if(80 to 89)
			H.adjustOrganLoss(ORGAN_SLOT_LUNGS,10)
		if(90 to 99)
			H.adjustOrganLoss(ORGAN_SLOT_TONGUE,10)
		if(100)
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN,20)

/datum/status_effect/corrosion_curse/lesser
	id = "corrosion_curse_lesser"
	duration = 20 SECONDS

/datum/status_effect/corrosion_curse/lesser/tick()
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	var/chance = rand(0,100)
	switch(chance)
		if(0 to 19)
			H.adjustBruteLoss(10)
		if(20 to 29)
			H.Dizzy(10)
		if(30 to 39)
			H.adjustOrganLoss(ORGAN_SLOT_LIVER,2)
		if(40 to 49)
			H.adjustOrganLoss(ORGAN_SLOT_HEART,2)
		if(50 to 59)
			H.adjustOrganLoss(ORGAN_SLOT_STOMACH,2)
		if(60 to 69)
			H.adjustOrganLoss(ORGAN_SLOT_EYES,5)
		if(70 to 79)
			H.adjustOrganLoss(ORGAN_SLOT_EARS,5)
		if(80 to 89)
			H.adjustOrganLoss(ORGAN_SLOT_LUNGS,5)
		if(90 to 99)
			H.adjustOrganLoss(ORGAN_SLOT_TONGUE,5)
		if(100)
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN,10)

/datum/status_effect/amok
	id = "amok"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	duration = 10 SECONDS
	tick_interval = 1 SECONDS

/datum/status_effect/amok/on_apply(mob/living/afflicted)
	. = ..()
	to_chat(owner, "<span class='boldwarning'>You feel filled with a rage that is not your own!</span>")

/datum/status_effect/amok/tick()
	. = ..()
	var/prev_intent = owner.a_intent
	owner.a_intent = INTENT_HARM

	var/list/mob/living/targets = list()
	for(var/mob/living/potential_target in oview(owner, 1))
		if(IS_HERETIC(potential_target) || IS_HERETIC_MONSTER(potential_target))
			continue
		targets += potential_target
	if(LAZYLEN(targets))
		owner.log_message(" attacked someone due to the amok debuff.", LOG_ATTACK) //the following attack will log itself
		owner.ClickOn(pick(targets))
	owner.a_intent = prev_intent

/datum/status_effect/cloudstruck
	id = "cloudstruck"
	status_type = STATUS_EFFECT_REPLACE
	duration = 3 SECONDS
	on_remove_on_mob_delete = TRUE
	///This overlay is applied to the owner for the duration of the effect.
	var/mutable_appearance/mob_overlay

/datum/status_effect/cloudstruck/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	. = ..()

/datum/status_effect/cloudstruck/on_apply()
	. = ..()
	mob_overlay = mutable_appearance('icons/effects/eldritch.dmi', "cloud_swirl", ABOVE_MOB_LAYER)
	owner.overlays += mob_overlay
	owner.update_icon()
	ADD_TRAIT(owner, TRAIT_BLIND, "cloudstruck")
	return TRUE

/datum/status_effect/cloudstruck/on_remove()
	. = ..()
	if(QDELETED(owner))
		return
	REMOVE_TRAIT(owner, TRAIT_BLIND, "cloudstruck")
	if(owner)
		owner.overlays -= mob_overlay
		owner.update_icon()

/datum/status_effect/cloudstruck/Destroy()
	. = ..()
	QDEL_NULL(mob_overlay)


/datum/status_effect/stacking/saw_bleed
	id = "saw_bleed"
	tick_interval = 6
	delay_before_decay = 5
	stack_threshold = 10
	max_stacks = 10
	overlay_file = 'icons/effects/bleed.dmi'
	underlay_file = 'icons/effects/bleed.dmi'
	overlay_state = "bleed"
	underlay_state = "bleed"
	var/bleed_damage = 350

/datum/status_effect/stacking/saw_bleed/fadeout_effect()
	new /obj/effect/temp_visual/bleed(get_turf(owner))

/datum/status_effect/stacking/saw_bleed/threshold_cross_effect()
	owner.adjustBruteLoss(bleed_damage)
	var/turf/T = get_turf(owner)
	new /obj/effect/temp_visual/bleed/explode(T)
	for(var/d in GLOB.alldirs)
		new /obj/effect/temp_visual/dir_setting/bloodsplatter(T, d)
	playsound(T, "desceration", 100, TRUE, -1)

/datum/status_effect/stacking/saw_bleed/bloodletting
	id = "bloodletting"
	stack_threshold = 7
	max_stacks = 7
	bleed_damage = 40

/datum/status_effect/neck_slice
	id = "neck_slice"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	duration = -1

/datum/status_effect/neck_slice/tick()
	var/mob/living/carbon/human/H = owner
	var/obj/item/bodypart/throat = H.get_bodypart(BODY_ZONE_HEAD)
	if(H.stat == DEAD || !throat)
		H.remove_status_effect(/datum/status_effect/neck_slice)
	if(prob(10))
		H.emote(pick("gasp", "gag", "choke"))
		H.adjustBruteLoss(50)
	var/still_bleeding = FALSE
	for(var/thing in throat.wounds)
		var/datum/wound/W = thing
		if(W.wound_type == WOUND_SLASH && W.severity > WOUND_SEVERITY_MODERATE)
			still_bleeding = TRUE
			break
	if(!still_bleeding)
		H.remove_status_effect(/datum/status_effect/neck_slice)

/mob/living/proc/apply_necropolis_curse(set_curse, duration = 10 MINUTES)
	var/datum/status_effect/necropolis_curse/C = has_status_effect(STATUS_EFFECT_NECROPOLIS_CURSE)
	if(!set_curse)
		set_curse = pick(CURSE_BLINDING, CURSE_SPAWNING, CURSE_WASTING, CURSE_GRASPING)
	if(QDELETED(C))
		apply_status_effect(STATUS_EFFECT_NECROPOLIS_CURSE, set_curse, duration)

	else
		C.apply_curse(set_curse)
		C.duration += duration * 0.5 //additional curses add half their duration

/datum/status_effect/necropolis_curse
	id = "necrocurse"
	duration = 10 MINUTES //you're cursed for 10 minutes have fun
	tick_interval = 50
	alert_type = null
	var/curse_flags = NONE
	var/effect_last_activation = 0
	var/effect_cooldown = 100
	var/obj/effect/temp_visual/curse/wasting_effect = new

/datum/status_effect/necropolis_curse/on_creation(mob/living/new_owner, set_curse, _duration)
	if(_duration)
		duration = _duration
	. = ..()
	if(.)
		apply_curse(set_curse)

/datum/status_effect/necropolis_curse/Destroy()
	if(!QDELETED(wasting_effect))
		qdel(wasting_effect)
		wasting_effect = null
	return ..()

/datum/status_effect/necropolis_curse/on_remove()
	. = ..()
	remove_curse(curse_flags)

/datum/status_effect/necropolis_curse/proc/apply_curse(set_curse)
	curse_flags |= set_curse
	if(curse_flags & CURSE_BLINDING)
		owner.overlay_fullscreen("curse", /atom/movable/screen/fullscreen/scaled/curse, 1)

/datum/status_effect/necropolis_curse/proc/remove_curse(remove_curse)
	if(remove_curse & CURSE_BLINDING)
		owner.clear_fullscreen("curse", 50)
	curse_flags &= ~remove_curse

/datum/status_effect/necropolis_curse/tick()
	if(owner.stat == DEAD)
		return
	if(curse_flags & CURSE_WASTING)
		wasting_effect.forceMove(owner.loc)
		wasting_effect.setDir(owner.dir)
		wasting_effect.transform = owner.transform //if the owner has been stunned the overlay should inherit that position
		wasting_effect.alpha = 255
		animate(wasting_effect, alpha = 0, time = 32)
		playsound(owner, 'sound/effects/curse5.ogg', 20, 1, -1)
		owner.adjustFireLoss(0.75)
	if(effect_last_activation <= world.time)
		effect_last_activation = world.time + effect_cooldown
		if(curse_flags & CURSE_SPAWNING)
			var/turf/spawn_turf
			var/sanity = 10
			while(!spawn_turf && sanity)
				spawn_turf = locate(owner.x + pick(rand(10, 15), rand(-10, -15)), owner.y + pick(rand(10, 15), rand(-10, -15)), owner.z)
				sanity--
			if(spawn_turf)
				var/mob/living/simple_animal/hostile/asteroid/curseblob/C = new (spawn_turf)
				C.set_target = owner
				C.GiveTarget()
		if(curse_flags & CURSE_GRASPING)
			var/grab_dir = turn(owner.dir, pick(-90, 90, 180, 180)) //grab them from a random direction other than the one faced, favoring grabbing from behind
			var/turf/spawn_turf = get_ranged_target_turf(owner, grab_dir, 5)
			if(spawn_turf)
				grasp(spawn_turf)

/datum/status_effect/necropolis_curse/proc/grasp(turf/spawn_turf)
	set waitfor = FALSE
	new/obj/effect/temp_visual/dir_setting/curse/grasp_portal(spawn_turf, owner.dir)
	playsound(spawn_turf, 'sound/effects/curse2.ogg', 80, 1, -1)
	var/turf/ownerloc = get_turf(owner)
	var/obj/item/projectile/curse_hand/C = new (spawn_turf)
	C.preparePixelProjectile(ownerloc, spawn_turf)
	C.fire()

/obj/effect/temp_visual/curse
	icon_state = "curse"

/obj/effect/temp_visual/curse/Initialize(mapload)
	. = ..()
	deltimer(timerid)


//Kindle: Used by servants of Ratvar. 10-second knockdown, reduced by 1 second per 5 damage taken while the effect is active. Does not take into account Oxy-damage
/datum/status_effect/kindle
	id = "kindle"
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = 5
	duration = 100
	alert_type = /atom/movable/screen/alert/status_effect/kindle
	var/old_health
	var/old_oxyloss

/datum/status_effect/kindle/tick()
	owner.DefaultCombatKnockdown(15, TRUE, FALSE, 15)
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.silent = max(5, C.silent) //Increased, now lasts until five seconds after it ends, instead of 2
		C.stuttering = max(10, C.stuttering) //Increased, now lasts for five seconds after the mute ends, instead of 3
	if(!old_health)
		old_health = owner.health
	if(!old_oxyloss)
		old_oxyloss = owner.getOxyLoss()
	var/health_difference = old_health - owner.health - clamp(owner.getOxyLoss() - old_oxyloss,0, owner.getOxyLoss())
	if(!health_difference)
		return
	owner.visible_message("<span class='warning'>The light in [owner]'s eyes dims as [owner.ru_who()] harmed!</span>", \
	"<span class='boldannounce'>The dazzling lights dim as you're harmed!</span>")
	health_difference *= 2 //so 10 health difference translates to 20 deciseconds of stun reduction
	duration -= health_difference
	old_health = owner.health
	old_oxyloss = owner.getOxyLoss()

/datum/status_effect/kindle/on_remove()
	. = ..()
	owner.visible_message("<span class='warning'>The light in [owner]'s eyes fades!</span>", \
	"<span class='boldannounce'>You snap out of your daze!</span>")

/atom/movable/screen/alert/status_effect/kindle
	name = "Dazzling Lights"
	desc = "Blinding light dances in your vision, stunning and silencing you. <i>Any damage taken will shorten the light's effects!</i>"
	icon_state = "kindle"
	alerttooltipstyle = "clockcult"


//Ichorial Stain: Applied to servants revived by a vitality matrix. Prevents them from being revived by one again until the effect fades.
/datum/status_effect/ichorial_stain
	id = "ichorial_stain"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 600
	examine_text = "<span class='warning'>SUBJECTPRONOUN is drenched in thick, blue ichor!</span>"
	alert_type = /atom/movable/screen/alert/status_effect/ichorial_stain

/datum/status_effect/ichorial_stain/on_apply()
	. = ..()
	owner.visible_message("<span class='danger'>[owner] gets back up, [owner.ru_ego()] body dripping blue ichor!</span>", \
	"<span class='userdanger'>Thick blue ichor covers your body; you can't be revived like this again until it dries!</span>")
	return TRUE

/datum/status_effect/ichorial_stain/on_remove()
	. = ..()
	owner.visible_message("<span class='danger'>The blue ichor on [owner]'s body dries out!</span>", \
	"<span class='boldnotice'>The ichor on your body is dry - you can now be revived by vitality matrices again!</span>")

/atom/movable/screen/alert/status_effect/ichorial_stain
	name = "Ichorial Stain"
	desc = "Your body is covered in blue ichor! You can't be revived by vitality matrices."
	icon_state = "ichorial_stain"
	alerttooltipstyle = "clockcult"

/datum/status_effect/electrostaff
	id = "electrostaff"
	alert_type = null
	status_type = STATUS_EFFECT_REPLACE

/datum/status_effect/electrostaff/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	. = ..()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/electrostaff)

/datum/status_effect/electrostaff/on_remove()
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/electrostaff)

//GOLEM GANG

/datum/status_effect/strandling //get it, strand as in durathread strand + strangling = strandling hahahahahahahahahahhahahaha i want to die
	id = "strandling"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/strandling

/datum/status_effect/strandling/on_apply()
	ADD_TRAIT(owner, TRAIT_MAGIC_CHOKE, "dumbmoron")
	return ..()

/datum/status_effect/strandling/on_remove()
	REMOVE_TRAIT(owner, TRAIT_MAGIC_CHOKE, "dumbmoron")
	return ..()

/atom/movable/screen/alert/status_effect/strandling
	name = "Choking strand"
	desc = "A magical strand of Durathread is wrapped around your neck, preventing you from breathing! Click this icon to remove the strand."
	icon_state = "his_grace"
	alerttooltipstyle = "hisgrace"
	clickable_glow = TRUE

/atom/movable/screen/alert/status_effect/strandling/Click(location, control, params)
	. = ..()
	if(!.)
		return
	to_chat(owner, "<span class='notice'>You attempt to remove the durathread strand from around your neck.</span>")
	if(!do_after(owner, 3.5 SECONDS, owner))
		return
	if(!isliving(owner))
		return
	var/mob/living/L = owner
	to_chat(owner, "<span class='notice'>You successfully remove the durathread strand.</span>")
	L.remove_status_effect(STATUS_EFFECT_CHOKINGSTRAND)


/datum/status_effect/pacify
	id = "pacify"
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = 1
	duration = 100
	alert_type = null

/datum/status_effect/pacify/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	. = ..()

/datum/status_effect/pacify/on_apply()
	ADD_TRAIT(owner, TRAIT_PACIFISM, "status_effect")
	return ..()

/datum/status_effect/pacify/on_remove()
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, "status_effect")
	return ..()

/datum/status_effect/trance
	id = "trance"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 300
	tick_interval = 10
	examine_text = "<span class='warning'>SUBJECTPRONOUN seems slow and unfocused.</span>"
	var/is_stupor = FALSE
	var/stun = TRUE
	alert_type = /atom/movable/screen/alert/status_effect/trance

/atom/movable/screen/alert/status_effect/trance
	name = "Trance"
	desc = "Everything feels so distant, and you can feel your thoughts forming loops inside your head..."
	icon_state = "high"

/datum/status_effect/trance/tick()
	if(stun)
		owner.Stun(60, TRUE, TRUE)
	owner.dizziness = 20

/datum/status_effect/trance/on_apply()
	. = ..()
	if(!iscarbon(owner))
		return FALSE
	RegisterSignal(owner, COMSIG_MOVABLE_HEAR, PROC_REF(hypnotize))
	ADD_TRAIT(owner, TRAIT_MUTE, "trance")
	owner.add_client_colour(/datum/client_colour/monochrome/trance)
	owner.visible_message("[stun ? "<span class='warning'>[owner] stands still as [owner.ru_ego()] eyes seem to focus on a distant point.</span>" : ""]", \
	"<span class='warning'>[pick("You feel your thoughts slow down...", "You suddenly feel extremely dizzy...", "You feel like you're in the middle of a dream...","You feel incredibly relaxed...")]</span>")
	return TRUE

/datum/status_effect/trance/on_creation(mob/living/new_owner, _duration, _stun = TRUE, _is_stupor = FALSE)
	duration = _duration
	stun = _stun
	is_stupor = _is_stupor
	return ..()

/datum/status_effect/trance/on_remove()
	UnregisterSignal(owner, COMSIG_MOVABLE_HEAR)
	REMOVE_TRAIT(owner, TRAIT_MUTE, "trance")
	owner.dizziness = 0
	owner.remove_client_colour(/datum/client_colour/monochrome/trance)
	to_chat(owner, "<span class='warning'>You snap out of your trance!</span>")
	return ..()

/datum/status_effect/trance/proc/hypnotize(datum/source, list/hearing_args)
	if(!owner.can_hear())
		return
	var/mob/hearing_speaker = hearing_args[HEARING_SPEAKER]
	if(hearing_speaker == owner)
		return
	var/mob/living/carbon/C = owner
	var/hypnomsg = uncostumize_say(hearing_args[HEARING_RAW_MESSAGE], hearing_args[HEARING_MESSAGE_MODE])
	if (is_stupor) // Record when a hypnosis is applied
		var/mob/living/carbon/human/H = owner
		var/list/traumas = H.get_traumas()
		for(var/X in traumas)
			var/datum/brain_trauma/BT = X
			if (istype(BT, /datum/brain_trauma/severe/hypnotic_stupor))
				var/datum/brain_trauma/severe/hypnotic_stupor/T = BT
				T.on_hypnosis()
	C.cure_trauma_type(/datum/brain_trauma/hypnosis, TRAUMA_RESILIENCE_SURGERY) //clear previous hypnosis
	// The brain trauma itself does its own set of logging, but this is the only place the source of the hypnosis phrase can be found.
	hearing_speaker.log_message("has hypnotised [key_name(C)] with the phrase '[hypnomsg]'", LOG_ATTACK)
	C.log_message("has been hypnotised by the phrase '[hypnomsg]' spoken by [key_name(hearing_speaker)]", LOG_VICTIM, log_globally = FALSE)
	addtimer(CALLBACK(C, TYPE_PROC_REF(/mob/living/carbon, gain_trauma), /datum/brain_trauma/hypnosis, TRAUMA_RESILIENCE_SURGERY, hypnomsg), 10)
	addtimer(CALLBACK(C, TYPE_PROC_REF(/mob/living, Stun), 60, TRUE, TRUE), 15) //Take some time to think about it
	qdel(src)

/datum/status_effect/spasms
	id = "spasms"
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null

/datum/status_effect/spasms/tick()
	if(prob(15))
		switch(rand(1,5))
			if(1)
				if((!owner.lying && !owner.buckled) && isturf(owner.loc))
					to_chat(owner, "<span class='warning'>Your leg spasms!</span>")
					step(owner, pick(GLOB.cardinals))
			if(2)
				if(owner.incapacitated())
					return
				var/obj/item/I = owner.get_active_held_item()
				if(I)
					to_chat(owner, "<span class='warning'>Your fingers spasm!</span>")
					owner.log_message("used [I] due to a Muscle Spasm", LOG_ATTACK)
					I.attack_self(owner)
			if(3)
				var/prev_intent = owner.a_intent
				owner.a_intent = INTENT_HARM

				var/range = 1
				if(istype(owner.get_active_held_item(), /obj/item/gun)) //get targets to shoot at
					range = 7

				var/list/mob/living/targets = list()
				for(var/mob/M in oview(owner, range))
					if(isliving(M))
						targets += M
				if(LAZYLEN(targets))
					to_chat(owner, "<span class='warning'>Your arm spasms!</span>")
					owner.log_message(" attacked someone due to a Muscle Spasm", LOG_ATTACK) //the following attack will log itself
					owner.ClickOn(pick(targets))
				owner.a_intent = prev_intent
			if(4)
				var/prev_intent = owner.a_intent
				owner.a_intent = INTENT_HARM
				to_chat(owner, "<span class='warning'>Your arm spasms!</span>")
				owner.log_message("attacked [owner.p_them()]self to a Muscle Spasm", LOG_ATTACK)
				owner.ClickOn(owner)
				owner.a_intent = prev_intent
			if(5)
				if(owner.incapacitated())
					return
				var/obj/item/I = owner.get_active_held_item()
				var/list/turf/targets = list()
				for(var/turf/T in oview(owner, 3))
					targets += T
				if(LAZYLEN(targets) && I)
					to_chat(owner, "<span class='warning'>Your arm spasms!</span>")
					owner.log_message("threw [I] due to a Muscle Spasm", LOG_ATTACK)
					owner.throw_item(pick(targets))

/datum/status_effect/dna_melt
	id = "dna_melt"
	duration = 600
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/status_effect/dna_melt
	var/kill_either_way = FALSE //no amount of removing mutations is gonna save you now

/datum/status_effect/dna_melt/on_creation(mob/living/new_owner, set_duration, updating_canmove)
	. = ..()
	to_chat(new_owner, "<span class='boldwarning'>My body can't handle the mutations! I need to get my mutations removed fast!</span>")

/datum/status_effect/dna_melt/on_remove()
	if(!ishuman(owner))
		owner.gib() //fuck you in particular
		return
	var/mob/living/carbon/human/H = owner
	H.something_horrible(kill_either_way)
	return ..()

/atom/movable/screen/alert/status_effect/dna_melt
	name = "Genetic Breakdown"
	desc = "I don't feel so good. Your body can't handle the mutations! You have one minute to remove your mutations, or you will be met with a horrible fate."
	icon_state = "dna_melt"

/datum/status_effect/fake_virus
	id = "fake_virus"
	duration = 1800//3 minutes
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = 20
	alert_type = null
	var/msg_stage = 0//so you dont get the most intense messages immediately

/datum/status_effect/fake_virus/tick()
	var/fake_msg = ""
	var/fake_emote = ""
	switch(msg_stage)
		if(0 to 300)
			if(prob(1))
				fake_msg = pick("<span class='warning'>[pick("Your head hurts.", "Your head pounds.")]</span>",
				"<span class='warning'>[pick("You're having difficulty breathing.", "Your breathing becomes heavy.")]</span>",
				"<span class='warning'>[pick("You feel dizzy.", "Your head spins.")]</span>",
				"<span notice='warning'>[pick("You swallow excess mucus.", "You lightly cough.")]</span>",
				"<span class='warning'>[pick("Your head hurts.", "Your mind blanks for a moment.")]</span>",
				"<span class='warning'>[pick("Your throat hurts.", "You clear your throat.")]</span>")
		if(301 to 600)
			if(prob(2))
				fake_msg = pick("<span class='warning'>[pick("Your head hurts a lot.", "Your head pounds incessantly.")]</span>",
				"<span class='warning'>[pick("Your windpipe feels like a straw.", "Your breathing becomes tremendously difficult.")]</span>",
				"<span class='warning'>You feel very [pick("dizzy","woozy","faint")].</span>",
				"<span class='warning'>[pick("You hear a ringing in your ear.", "Your ears pop.")]</span>",
				"<span class='warning'>You nod off for a moment.</span>")
		else
			if(prob(3))
				if(prob(50))// coin flip to throw a message or an emote
					fake_msg = pick("<span class='userdanger'>[pick("Your head hurts!", "You feel a burning knife inside your brain!", "A wave of pain fills your head!")]</span>",
					"<span class='userdanger'>[pick("Your lungs hurt!", "It hurts to breathe!")]</span>",
					"<span class='warning'>[pick("You feel nauseated.", "You feel like you're going to throw up!")]</span>")
				else
					fake_emote = pick("cough", "snuffle", "sneeze") //BLUEMOON EDIT
	if(fake_emote)
		owner.emote(fake_emote)
	else if(fake_msg)
		to_chat(owner, fake_msg)
	msg_stage++

/datum/status_effect/cgau_conc
	id = "cgau_conc"
	examine_text = "<span class='warning'>SUBJECTPRONOUN sways from side to side hesitantly!</span>"
	duration = 5 SECONDS

/datum/status_effect/cgau_conc/on_apply()
	. = ..()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/gauntlet_concussion)
	if(ishostile(owner))
		var/mob/living/simple_animal/hostile/simple_owner = owner
		simple_owner.ranged_cooldown_time *= 2.5

/datum/status_effect/cgau_conc/on_remove()
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/gauntlet_concussion)
	if(ishostile(owner))
		var/mob/living/simple_animal/hostile/simple_owner = owner
		simple_owner.ranged_cooldown_time /= 2.5

///Maddly teleports the victim around all of space for 10 seconds
/datum/status_effect/teleport_madness
	id = "teleport_madness"
	duration = 10 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = 0.2 SECONDS

/datum/status_effect/teleport_madness/tick(seconds_between_ticks)
	dump_in_space(owner)

#undef HEALING_SLEEP_DEFAULT
