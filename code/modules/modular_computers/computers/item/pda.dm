/**
 * Modular PDA
 *
 * A handheld computer that replaces the legacy /obj/item/modular_computer/pda system.
 * Uses the modular_computer framework with TGUI-based programs.
 */
/obj/item/modular_computer/pda
	name = "pda"
	icon = 'icons/obj/pda_alt.dmi'
	icon_state = "pda"
	base_icon_state = "pda"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	item_state = "electronic"

	overlays_icon = 'icons/obj/devices/modular_pda.dmi'

	icon_state_menu = "menu"
	max_capacity = 64
	hardware_flag = PROGRAM_PDA
	max_idle_programs = 2
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_ID | ITEM_SLOT_BELT
	has_light = TRUE //LED flashlight!
	comp_light_luminosity = 2.3
	looping_sound = FALSE

	///The item currently inserted into the PDA, starts with a pen.
	var/obj/item/inserted_item = /obj/item/pen

	///Whether the PDA should have 'pda_programs' apps installed on Initialize.
	var/has_pda_programs = TRUE
	///Static list of default PDA apps to install on Initialize.
	var/static/list/datum/computer_file/pda_programs = list(
		/datum/computer_file/program/messenger,
		/datum/computer_file/program/notepad,
		/datum/computer_file/program/crew_manifest,
	)
	///List of items that can be stored in a PDA
	var/static/list/contained_item = list(
		/obj/item/pen,
		/obj/item/toy/crayon,
		/obj/item/lipstick,
		/obj/item/flashlight/pen,
		/obj/item/reagent_containers/hypospray/medipen,
	)

	// ---- Legacy compatibility aliases ----
	// These bridge old system code that references /obj/item/pda properties.

	/// Legacy alias for saved_identification
	var/owner
	/// Legacy alias for saved_job
	var/ownjob
	/// Legacy messaging-off flag (checked by subsystem/job.dm)
	var/toff = FALSE
	/// Legacy hidden flag (for syndicate PDAs to not appear in PDA lists)
	var/hidden = FALSE
	/// Legacy ID card reference alias — use stored_id instead
	var/obj/item/card/id/id
	/// Legacy silent flag — if TRUE, PDA won't beep on messages
	var/silent = FALSE
	/// Legacy text note buffer (used by AI/borg message log)
	var/tnote
	/// Legacy flashlight-on flag
	var/fon = FALSE
	/// Legacy flashlight luminosity
	var/f_lum = 2.3
	/// Legacy photo datum
	var/datum/picture/picture
	/// Legacy HTML note text (used by camera.dm when holding PDA up to camera)
	var/notehtml = ""
	/// Legacy cartridge var (unused, exists for map-compat)
	var/default_cartridge
	/// Legacy note text (raw text, used by map objects)
	var/note
	/// Legacy background color (used by map objects)
	var/background_color
	/// Legacy UI mode number (used by old cart.dm Browser/Topic UI — dead code)
	var/mode = 0
	/// Legacy honk virus counter (used by clown virus cart)
	var/honkamt = 0
	/// Legacy ringtone text (used by mime virus cart)
	var/ttone = "beep"
	/// Legacy cartridge reference (used by syndicate virus cart for access checks)
	var/obj/item/cartridge/cartridge
	/// Legacy detonatable flag (used by syndicate virus cart)
	var/detonatable = TRUE

/// Legacy stub for old cart.dm UI (dead code)
/obj/item/modular_computer/pda/proc/msg_input()
	return null

/obj/item/modular_computer/pda/Initialize(mapload)
	. = ..()
	if(inserted_item)
		inserted_item = new inserted_item(src)
	// Sync legacy aliases
	owner = saved_identification
	ownjob = saved_job
	id = stored_id
	GLOB.PDAs += src

/obj/item/modular_computer/pda/equipped(mob/user, slot)
	. = ..()
	if(!user.client)
		return
	update_style(user.client)

// PDAs don't use hardware battery components — they always have power.
/obj/item/modular_computer/pda/check_power_override()
	return TRUE

// PDAs store the ID directly instead of using card_slot hardware.
/obj/item/modular_computer/pda/GetAccess()
	if(stored_id)
		return stored_id.GetAccess()
	return ..()

/obj/item/modular_computer/pda/GetID()
	return stored_id || ..()

/obj/item/modular_computer/pda/RemoveID()
	if(!stored_id)
		return ..()
	var/obj/item/card/id/removed = stored_id
	stored_id = null
	id = null
	update_id_imprint(null, null)
	update_appearance()
	if(ishuman(loc))
		var/mob/living/carbon/human/human_wearer = loc
		if(human_wearer.wear_id == src)
			human_wearer.sec_hud_set_ID()
	return removed

/obj/item/modular_computer/pda/InsertID(obj/item/inserting_item)
	var/obj/item/card/id/inserting_id = inserting_item.RemoveID()
	if(!inserting_id)
		return FALSE
	if(stored_id)
		return FALSE
	inserting_id.forceMove(src)
	stored_id = inserting_id
	id = inserting_id
	update_id_imprint(inserting_id.registered_name, inserting_id.get_assignment_name())
	update_appearance()
	if(ishuman(loc))
		var/mob/living/carbon/human/human_wearer = loc
		if(human_wearer.wear_id == src)
			human_wearer.sec_hud_set_ID()
	return TRUE

/obj/item/modular_computer/pda/Destroy()
	GLOB.PDAs -= src
	if(istype(inserted_item))
		QDEL_NULL(inserted_item)
	return ..()

/// Legacy compat: update_label syncs owner/ownjob and updates device name.
/obj/item/modular_computer/pda/proc/update_label(new_name, new_job)
	if(new_name)
		owner = new_name
		saved_identification = new_name
	if(new_job)
		ownjob = new_job
		saved_job = new_job
	if(owner)
		name = "[owner]'s PDA ([ownjob])"
	else
		name = initial(name)
	update_id_imprint(saved_identification, saved_job)

/// Legacy compat: send_message is a no-op stub (messaging uses programs now).
/obj/item/modular_computer/pda/proc/send_message(message, flash = TRUE)
	return

/// Legacy compat: receive_message is a no-op stub (messaging uses programs now).
/obj/item/modular_computer/pda/proc/receive_message(datum/signal/subspace/pda/signal)
	return

/// Legacy compat: create_message wraps send_message (used by AI/borg code).
/obj/item/modular_computer/pda/proc/create_message(mob/living/user, obj/item/modular_computer/pda/target)
	send_message(user, list(target))

/// Legacy compat wrapper for the LED flashlight toggle.
/obj/item/modular_computer/pda/proc/toggle_light(mob/user)
	toggle_flashlight()
	update_icon()

/obj/item/modular_computer/pda/install_default_programs()
	var/list/apps_to_download = list()
	if(has_pda_programs)
		apps_to_download += default_programs + pda_programs
	apps_to_download += starting_programs

	for(var/programs in apps_to_download)
		var/datum/computer_file/program/program_type = new programs
		store_file(program_type)

/obj/item/modular_computer/pda/update_overlays()
	. = ..()
	if(stored_id)
		. += mutable_appearance(overlays_icon, "id_overlay")
	if(light_on)
		. += mutable_appearance(overlays_icon, "light_overlay")
	if(inserted_pai)
		. += mutable_appearance(overlays_icon, "pai_inserted")

/obj/item/modular_computer/pda/interact(mob/user)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_PDA_MESSAGE_MENU_RIGGED))
		explode(user, from_message_menu = TRUE)

/obj/item/modular_computer/pda/attack_self(mob/user)
	// bypass literacy checks to access syndicate uplink
	var/datum/component/uplink/hidden_uplink = GetComponent(/datum/component/uplink)
	if(hidden_uplink?.owner && HAS_TRAIT(user, TRAIT_ILLITERATE))
		if(hidden_uplink.owner != user.key)
			return ..()

		hidden_uplink.locked = FALSE
		hidden_uplink.interact(null, user)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	return ..()

/obj/item/modular_computer/pda/pre_attack(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	if(!inserted_disk || !ismachinery(target))
		return ..()

	var/obj/machinery/target_machine = target
	if(!target_machine.panel_open && !istype(target, /obj/machinery/computer))
		return ..()

	if(!istype(inserted_disk, /obj/item/computer_disk/virus/clown))
		return ..()
	var/obj/item/computer_disk/virus/clown/installed_cartridge = inserted_disk
	if(!installed_cartridge.charges)
		to_chat(user, span_notice("Out of virus charges."))
		return ..()

	to_chat(user, span_notice("You upload the virus to [target]!"))
	installed_cartridge.charges--
	return TRUE

/obj/item/modular_computer/pda/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(inserted_item)
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Remove [inserted_item]"
		. = CONTEXTUAL_SCREENTIP_SET
	else if(istype(held_item) && is_type_in_list(held_item, contained_item))
		context[SCREENTIP_CONTEXT_LMB] = "Insert [held_item]"
		. = CONTEXTUAL_SCREENTIP_SET

	return . || NONE

/obj/item/modular_computer/pda/attackby(obj/item/tool, mob/user, params)
	if(is_type_in_list(tool, contained_item))
		if(tool.w_class >= WEIGHT_CLASS_SMALL)
			to_chat(user, span_warning("[tool] is too big to fit in [src]!"))
			return
		if(!user.transferItemToLoc(tool, src))
			return
		if(inserted_item)
			swap_pen(user, tool)
		else
			to_chat(user, span_notice("You insert [tool] into [src]."))
			inserted_item = tool
			playsound(src, 'sound/machines/pda_button/pda_button1.ogg', 50, TRUE)
		return
	return ..()

/obj/item/modular_computer/pda/CtrlClick(mob/user)
	if(isturf(loc))
		return ..()
	remove_pen(user)

///Finds how hard it is to send a virus to this tablet, checking all programs downloaded.
/obj/item/modular_computer/pda/proc/get_detomatix_difficulty()
	var/detomatix_difficulty
	for(var/datum/computer_file/program/downloaded_apps in stored_files)
		detomatix_difficulty += downloaded_apps.detomatix_resistance
	return detomatix_difficulty

/obj/item/modular_computer/pda/proc/remove_pen(mob/user)
	if(issilicon(user) || !user.canUseTopic(src, BE_CLOSE, no_tk = TRUE))
		return
	if(inserted_item)
		balloon_alert(user, "removed [inserted_item]")
		user.put_in_hands(inserted_item)
		inserted_item = null
		update_appearance()
		playsound(src, 'sound/machines/pda_button/pda_button2.ogg', 50, TRUE)

/obj/item/modular_computer/pda/proc/swap_pen(mob/user, obj/item/tool)
	if(inserted_item)
		balloon_alert(user, "swapped pens")
		user.put_in_hands(inserted_item)
		inserted_item = tool
		update_appearance()
		playsound(src, 'sound/machines/pda_button/pda_button1.ogg', 50, TRUE)

/obj/item/modular_computer/pda/proc/explode(mob/target, mob/bomber, from_message_menu = FALSE)
	var/turf/current_turf = get_turf(src)

	if(from_message_menu)
		var/log_text = "[key_name(target)]'s tablet exploded as [target.p_they()] tried to open their tablet message menu because of a recent tablet bomb."
		log_game(log_text)
		message_admins(log_text)
	else
		var/log_text = "[key_name(bomber)] successfully tablet-bombed [key_name(target)] as [target.p_they()] tried to reply to a rigged tablet message"
		log_game(log_text)
		message_admins(log_text)

	if(ismob(loc))
		var/mob/loc_mob = loc
		loc_mob.show_message(\
			msg = span_userdanger("Your [src] explodes!"),\
			type = MSG_VISUAL,\
			alt_msg = span_warning("You hear a loud *pop*!"),\
			alt_type = MSG_AUDIBLE,\
		)
	else
		visible_message(span_danger("[src] explodes!"), span_warning("You hear a loud *pop*!"))

	if(current_turf)
		current_turf.hotspot_expose(700, 125)
		if(istype(inserted_disk, /obj/item/computer_disk/virus/detomatix))
			explosion(src, devastation_range = -1, heavy_impact_range = 1, light_impact_range = 3, flash_range = 4)
		else
			explosion(src, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 2, flash_range = 3)
	qdel(src)

/**
 * Applies the client's ringtone and skin prefs to the PDA.
 */
/obj/item/modular_computer/pda/proc/update_pda_prefs(client/owner_client)
	if(!owner_client)
		return

	var/new_ringtone = owner_client.prefs?.pda_ringtone
	if(new_ringtone && (new_ringtone != MESSENGER_RINGTONE_DEFAULT))
		update_ringtone(new_ringtone)

	var/new_skin = owner_client.prefs?.pda_skin
	if(new_skin)
		var/list/skin_data = GLOB.pda_reskins[new_skin]
		if(skin_data && skin_data["icon"])
			icon = skin_data["icon"]
			update_appearance()

/// Sets the ringtone on the messenger program.
/obj/item/modular_computer/pda/proc/update_ringtone(new_ringtone)
	if(!istext(new_ringtone))
		return
	var/datum/computer_file/program/messenger/messenger_app = locate() in stored_files
	if(messenger_app)
		messenger_app.ringtone = new_ringtone

/**
 * Nuclear PDA — given to nukies for disk pinpointer.
 */
/obj/item/modular_computer/pda/nukeops
	name = "nuclear pda"
	icon_state = "pda-syndicate"
	device_theme = PDA_THEME_SYNDICATE
	comp_light_luminosity = 6.3
	light_color = COLOR_RED
	long_ranged = TRUE
	starting_programs = list(
		/datum/computer_file/program/radar/fission360,
	)

/obj/item/modular_computer/pda/nukeops/Initialize(mapload)
	. = ..()
	var/datum/computer_file/program/messenger/msg = locate() in stored_files
	if(msg)
		msg.invisible = TRUE

/obj/item/modular_computer/pda/syndicate_contract_uplink
	name = "contractor tablet"
	icon_state = "pda-syndicate"
	icon_state_menu = "menu"
	device_theme = PDA_THEME_SYNDICATE
	comp_light_luminosity = 6.3
	has_pda_programs = FALSE

	starting_programs = list(
		/datum/computer_file/program/contract_uplink,
		/datum/computer_file/program/secureye,
	)

/**
 * Silicon PDA — built-in to Silicons.
 */
/obj/item/modular_computer/pda/silicon
	name = "modular interface"
	icon = 'icons/obj/devices/modular_pda.dmi'
	icon_state = "tablet-silicon"
	base_icon_state = "tablet-silicon"

	has_light = FALSE
	comp_light_luminosity = 0
	inserted_item = null
	has_pda_programs = FALSE
	starting_programs = list(
		/datum/computer_file/program/messenger,
	)

	///Ref to the silicon we're installed in.
	var/mob/living/silicon/silicon_owner

/obj/item/modular_computer/pda/silicon/pai
	starting_programs = list(
		/datum/computer_file/program/messenger,
		/datum/computer_file/program/chatclient,
	)

/obj/item/modular_computer/pda/silicon/cyborg
	starting_programs = list(
		/datum/computer_file/program/filemanager,
		/datum/computer_file/program/robotact,
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/messenger,
		/datum/computer_file/program/borg_monitor,
		/datum/computer_file/program/atmosscan,
	)

/obj/item/modular_computer/pda/silicon/Initialize(mapload)
	. = ..()
	vis_flags |= VIS_INHERIT_ID
	silicon_owner = loc
	if(!istype(silicon_owner))
		silicon_owner = null
		stack_trace("[type] initialized outside of a silicon, deleting.")
		return INITIALIZE_HINT_QDEL

/obj/item/modular_computer/pda/silicon/Destroy()
	silicon_owner = null
	return ..()

/obj/item/modular_computer/pda/silicon/turn_on(mob/user, open_ui = FALSE)
	if(silicon_owner?.stat != DEAD)
		return ..()
	return FALSE

/obj/item/modular_computer/pda/silicon/get_ntnet_status()
	if(!silicon_owner)
		return FALSE
	var/mob/living/silicon/robot/cyborg_check = silicon_owner
	if(!istype(cyborg_check))
		return ..()
	if(cyborg_check.locked_down)
		return FALSE
	if(!cyborg_check.cell || cyborg_check.cell.charge == 0)
		return FALSE
	return ..()

/obj/item/modular_computer/pda/silicon/cyborg/ui_data(mob/user)
	. = ..()
	.["has_light"] = TRUE
	if(iscyborg(silicon_owner))
		var/mob/living/silicon/robot/robo = silicon_owner
		.["light_on"] = robo.lamp_enabled
		.["comp_light_color"] = robo.lamp_color

/obj/item/modular_computer/pda/silicon/toggle_flashlight(mob/user)
	if(!silicon_owner || QDELETED(silicon_owner))
		return FALSE
	if(iscyborg(silicon_owner))
		var/mob/living/silicon/robot/robo = silicon_owner
		robo.toggle_headlamp()
	return TRUE

/obj/item/modular_computer/pda/silicon/set_flashlight_color(color)
	if(!silicon_owner || QDELETED(silicon_owner) || !color)
		return FALSE
	if(iscyborg(silicon_owner))
		var/mob/living/silicon/robot/robo = silicon_owner
		robo.lamp_color = color
		robo.toggle_headlamp(FALSE, TRUE)
	return TRUE

/obj/item/modular_computer/pda/silicon/ui_state(mob/user)
	return GLOB.deep_inventory_state

/obj/item/modular_computer/pda/silicon/cyborg/syndicate
	icon_state = "tablet-silicon-syndicate"
	device_theme = PDA_THEME_SYNDICATE

/obj/item/modular_computer/pda/silicon/cyborg/syndicate/Initialize(mapload)
	. = ..()
	if(iscyborg(silicon_owner))
		var/mob/living/silicon/robot/robo = silicon_owner
		robo.lamp_color = COLOR_RED

// ---- Global PDA helpers ----

/// Returns a list of all PDAs whose owners are visible in the PDA messenger list.
/proc/get_viewable_pdas()
	. = list()
	for(var/obj/item/modular_computer/pda/P in GLOB.PDAs)
		if(!P.owner || P.toff || P.hidden)
			continue
		. += P

// ---- AI PDA messaging ----

/mob/living/silicon/ai/proc/cmd_send_pdamesg(mob/user)
	var/list/plist = list()
	var/list/namecounts = list()

	if(aiPDA.toff)
		to_chat(user, "Включите приём сообщений для работы мессенджера.")
		return

	for(var/obj/item/modular_computer/pda/P in get_viewable_pdas())
		if(P == aiPDA)
			continue
		plist[avoid_assoc_duplicate_keys(P.owner, namecounts)] = P

	var/c = input(user, "Выберите PDA") as null|anything in sort_list(plist)
	if(!c)
		return
	var/obj/item/modular_computer/pda/selected = plist[c]

	var/message = tgui_input_text(user, "Введите сообщение", "PDA сообщение", max_length = 1024, encode = FALSE)
	if(!message)
		return

	if(incapacitated())
		return

	var/datum/computer_file/program/messenger/ai_messenger = locate() in aiPDA.stored_files
	var/datum/computer_file/program/messenger/target_messenger = locate() in selected.stored_files
	if(!ai_messenger || !target_messenger)
		to_chat(user, span_notice("Мессенджер недоступен."))
		return

	ai_messenger.send_message(user, message, list(target_messenger))

/mob/living/silicon/ai/verb/cmd_toggle_pda_receiver()
	set category = "AI Commands"
	set name = "PDA - Toggle Sender/Receiver"
	if(usr.stat == DEAD)
		return
	if(!isnull(aiPDA))
		aiPDA.toff = !aiPDA.toff
		to_chat(usr, "<span class='notice'>Отправление/получение сообщений PDA переключёно на [(aiPDA.toff ? "Off" : "On")]!</span>")
	else
		to_chat(usr, "У вас нет PDA. Вам следует сделать донос о проблеме.")

/mob/living/silicon/ai/verb/cmd_toggle_pda_silent()
	set category = "AI Commands"
	set name = "PDA - Toggle Ringer"
	if(usr.stat == DEAD)
		return
	if(!isnull(aiPDA))
		aiPDA.silent = !aiPDA.silent
		to_chat(usr, "<span class='notice'>Уведомления PDA переключены на [(aiPDA.silent ? "Off" : "On")]!</span>")
	else
		to_chat(usr, "У вас нет PDA. Вам следует сделать донос о проблеме.")

/mob/living/silicon/ai/proc/cmd_show_message_log(mob/user)
	if(incapacitated())
		return
	if(!isnull(aiPDA))
		var/datum/computer_file/program/messenger/ai_messenger = locate() in aiPDA.stored_files
		if(!ai_messenger)
			to_chat(user, span_notice("Мессенджер недоступен."))
			return
		ai_messenger.ui_interact(user)
	else
		to_chat(user, "У вас нет PDA. Вам следует сделать донос о проблеме.")

// ---- Borg PDA messaging ----

/mob/living/silicon/robot/proc/cmd_send_pdamesg(mob/user)
	var/list/plist = list()
	var/list/namecounts = list()

	if(aiPDA.toff)
		to_chat(user, "Включите приём сообщений для работы мессенджера.")
		return

	for(var/obj/item/modular_computer/pda/P in get_viewable_pdas())
		if(P == aiPDA)
			continue
		plist[avoid_assoc_duplicate_keys(P.owner, namecounts)] = P

	var/c = input(user, "Выберите PDA") as null|anything in sort_list(plist)
	if(!c)
		return
	var/obj/item/modular_computer/pda/selected = plist[c]

	var/message = tgui_input_text(user, "Введите сообщение", "PDA сообщение", max_length = 1024, encode = FALSE)
	if(!message)
		return

	if(incapacitated())
		return

	var/datum/computer_file/program/messenger/borg_messenger = locate() in aiPDA.stored_files
	var/datum/computer_file/program/messenger/target_messenger = locate() in selected.stored_files
	if(!borg_messenger || !target_messenger)
		to_chat(user, span_notice("Мессенджер недоступен."))
		return

	borg_messenger.send_message(user, message, list(target_messenger))

/mob/living/silicon/robot/proc/cmd_show_message_log(mob/user)
	if(incapacitated())
		return
	if(!isnull(aiPDA))
		var/datum/computer_file/program/messenger/borg_messenger = locate() in aiPDA.stored_files
		if(!borg_messenger)
			to_chat(user, span_notice("Мессенджер недоступен."))
			return
		borg_messenger.ui_interact(user)
	else
		to_chat(user, "У вас нет PDA. Вам следует сделать донос о проблеме.")
