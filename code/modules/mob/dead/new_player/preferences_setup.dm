
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

/datum/preferences/proc/update_preview_icon(current_tab)
	if(preview_generating)
		return
	// Пропускаем регенерацию, если внешность не изменилась (сравниваем ключ по ключевым полям)
	var/datum/job/preview_job = get_highest_job()
	var/new_key = "[pref_species?.id]_[hair_style]_[hair_color]_[facial_hair_style]_[facial_hair_color]\
_[skin_tone]_[use_custom_skin_tone]_[preview_direction]_[preview_pref]_[preview_job?.type]\
_[features["mcolor"]]_[features["mcolor2"]]_[features["mcolor3"]]_[features["body_model"]]_[features["body_size"]]"
	if(new_key == last_preview_key && preview_icon64)
		return
	last_preview_key = new_key
	INVOKE_ASYNC(src, PROC_REF(_generate_preview_icon))

/datum/preferences/proc/_generate_preview_icon()
	if(QDELETED(src))
		return
	preview_generating = TRUE
	// Watchdog: если генерация зависла (рантайм/дедлок), сбрасываем флаг через 30 секунд
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/preferences, _reset_preview_generating)), 300)
	var/datum/job/previewJob = get_highest_job()

	if(previewJob)
		// Silicons only need a very basic preview since there is no customization for them.
		if(istype(previewJob,/datum/job/ai))
			var/icon/ai_icon = icon('icons/mob/ai.dmi', icon_state = resolve_ai_icon(preferred_ai_core_display), dir = preview_direction)
			preview_icon64 = icon2html(ai_icon, parent)
			preview_generating = FALSE
			var/mob/user = parent?.mob
			if(user)
				ShowChoices(user, skip_preview_update = TRUE)
			return
		if(istype(previewJob,/datum/job/cyborg))
			var/icon/bot_icon = icon('icons/mob/robots.dmi', icon_state = "robot", dir = preview_direction)
			preview_icon64 = icon2html(bot_icon, parent)
			preview_generating = FALSE
			var/mob/user = parent?.mob
			if(user)
				ShowChoices(user, skip_preview_update = TRUE)
			return

	// Set up the dummy for its photoshoot
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
	if(!mannequin)
		preview_generating = FALSE
		return
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
			/*
			mannequin.hidden_underwear = TRUE
			mannequin.hidden_undershirt = TRUE
			mannequin.hidden_socks = TRUE
			*/
		if(PREVIEW_PREF_NAKED_AROUSED)
			/*
			mannequin.hidden_underwear = TRUE
			mannequin.hidden_undershirt = TRUE
			mannequin.hidden_socks = TRUE
			*/
			for(var/obj/item/organ/genital/genital in mannequin.internal_organs)
				if(CHECK_BITFIELD(genital.genital_flags, GENITAL_CAN_AROUSE))
					genital.set_aroused_state(TRUE, null)

	mannequin.regenerate_icons()

	var/icon/flat = getFlatIcon(mannequin, defdir = preview_direction, no_anim = TRUE)
	if(flat)
		preview_icon64 = icon2html(flat, parent)
	else
		preview_icon64 = null
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)

	preview_generating = FALSE
	var/mob/user = parent?.mob
	if(user)
		ShowChoices(user, skip_preview_update = TRUE)

/// Сбрасывает preview_generating если флаг застрял (вызывается через addtimer watchdog).
/datum/preferences/proc/_reset_preview_generating()
	if(preview_generating)
		preview_generating = FALSE

/datum/preferences/proc/get_highest_job()
	var/highest_pref = 0
	var/datum/job/highest_job
	for(var/job in job_preferences)
		if(job_preferences["[job]"] > highest_pref)
			highest_job = SSjob.GetJob(job)
			highest_pref = job_preferences["[job]"]
	return highest_job
