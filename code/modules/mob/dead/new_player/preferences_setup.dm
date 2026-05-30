
	//The mob should have a gender you want before running this proc. Will run fine without H
/datum/preferences/proc/random_character(gender_override)
	if(gender_override)
		gender = gender_override
	else
		gender = pick(MALE,FEMALE)
	underwear = random_underwear(gender)
	undie_color = random_short_color()
	undershirt = random_undershirt(gender)
	shirt_color = random_short_color()
	socks = random_socks()
	socks_color = random_short_color()
	use_custom_skin_tone = FALSE
	skin_tone = random_skin_tone()
	hair_style = random_hair_style(gender)
	facial_hair_style = random_facial_hair_style(gender)
	hair_color = random_short_color()
	facial_hair_color = random_short_color()
	var/random_eye_color = random_eye_color()
	left_eye_color = random_eye_color
	right_eye_color = random_eye_color
	if(!pref_species)
		var/rando_race = pick(GLOB.roundstart_races)
		pref_species = new rando_race()
	features = random_features(pref_species?.id, gender)
	bark_id = pick(GLOB.bark_random_list)
	bark_pitch = BARK_PITCH_RAND(gender)
	bark_variance = BARK_VARIANCE_RAND
	age = rand(AGE_MIN,AGE_MAX)

/datum/preferences/proc/update_preview_icon()
	if(preview_generating)
		pending_preview_update = TRUE
		return
	preview_generating = TRUE
	INVOKE_ASYNC(src, PROC_REF(_generate_preview_icon))

/// Вызывается при закрытии меню настроек. Для transient dummy больше не нужно.
/datum/preferences/proc/release_preview_mannequin()
	return

/// Сбрасывает флаг обновления превью. Вызывать при "тяжёлых" изменениях.
/datum/preferences/proc/invalidate_preview_mannequin()
	preview_change_hint = null

/datum/preferences/proc/_generate_preview_icon()
	if(QDELETED(src))
		preview_generating = FALSE
		return
	var/datum/job/previewJob = get_highest_job()

	if(previewJob)
		// Silicons only need a very basic preview since there is no customization for them.
		if(istype(previewJob, /datum/job/ai))
			parent?.show_character_previews(image('icons/mob/ai.dmi', icon_state = resolve_ai_icon(preferred_ai_core_display), dir = SOUTH))
			preview_generating = FALSE
			return
		if(istype(previewJob, /datum/job/cyborg))
			parent?.show_character_previews(image('icons/mob/robots.dmi', icon_state = "robot", dir = SOUTH))
			preview_generating = FALSE
			return

	// Simple approach: create a fresh dummy every time — stable, no item stacking bugs
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
	copy_to(mannequin, initial_spawn = TRUE)

	switch(preview_pref)
		if(PREVIEW_PREF_JOB)
			if(previewJob)
				mannequin.job = previewJob.title
				previewJob.equip(mannequin, TRUE, preference_source = parent)
		if(PREVIEW_PREF_LOADOUT)
			var/mob/preview_src_mob = parent?.mob
			if(preview_src_mob)
				SSjob.equip_loadout(preview_src_mob, mannequin, bypass_prereqs = TRUE, can_drop = FALSE, is_dummy = TRUE)
				SSjob.post_equip_loadout(preview_src_mob, mannequin, bypass_prereqs = TRUE, can_drop = FALSE, is_dummy = TRUE)
		if(PREVIEW_PREF_NAKED)
			pass()
		if(PREVIEW_PREF_NAKED_AROUSED)
			for(var/obj/item/organ/genital/genital in mannequin.internal_organs)
				if(CHECK_BITFIELD(genital.genital_flags, GENITAL_CAN_AROUSE))
					genital.set_aroused_state(TRUE, null)

	mannequin.regenerate_icons()

	// Apply the Dummy's preview background first so we properly layer everything else on top of it.
	mannequin.add_overlay(mutable_appearance('modular_citadel/icons/ui/backgrounds.dmi', bgstate, layer = SPACE_LAYER))

	parent?.show_character_previews(new /mutable_appearance(mannequin))
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)

	preview_generating = FALSE
	var/had_pending = pending_preview_update
	pending_preview_update = FALSE
	if(had_pending)
		update_preview_icon()

/datum/preferences/proc/get_highest_job()
	var/highest_pref = 0
	var/datum/job/highest_job
	for(var/job in job_preferences)
		var/pref = job_preferences["[job]"]
		if(pref > highest_pref)
			var/datum/job/J = SSjob.GetJob(job)
			if(J)
				highest_job = J
				highest_pref = pref
	return highest_job
