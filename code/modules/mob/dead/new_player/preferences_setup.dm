
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
	// Сброс кэша направлений — внешность изменилась
	preview_dir_cache = null
	preview_reference_cache = null
	if(preview_generating)
		pending_preview_update = TRUE
		return
	preview_generating = TRUE
	INVOKE_ASYNC(src, PROC_REF(_generate_preview_icon))

/// Освобождает персистентный манекен превью. Вызывать при закрытии меню настроек.
/datum/preferences/proc/release_preview_mannequin()
	if(preview_mannequin)
		unset_busy_human_dummy("preview_mannequin_[REF(src)]")
		preview_mannequin = null
	preview_mannequin_initialized = FALSE

/// Инвалидирует персистентный манекен — при следующем обновлении будет полная пересборка.
/// Вызывать при смене species, gender, body_type и других "тяжёлых" изменений.
/datum/preferences/proc/invalidate_preview_mannequin()
	preview_mannequin_initialized = FALSE
	preview_change_hint = null

/datum/preferences/proc/_generate_preview_icon()
	if(QDELETED(src))
		preview_generating = FALSE
		return
	var/datum/job/previewJob = get_highest_job()

	if(previewJob)
		// Silicons only need a very basic preview since there is no customization for them.
		if(istype(previewJob,/datum/job/ai))
			LAZYINITLIST(preview_dir_cache)
			for(var/dir in GLOB.cardinals)
				var/icon/ai_icon = icon('icons/mob/ai.dmi', icon_state = resolve_ai_icon(preferred_ai_core_display), dir = dir)
				preview_dir_cache["[dir]"] = icon2html(ai_icon, parent)
			preview_icon64 = preview_dir_cache["[preview_direction]"]
			preview_generating = FALSE
			var/had_pending_ai = pending_preview_update
			pending_preview_update = FALSE
			if(had_pending_ai)
				update_preview_icon()
			else
				parent?.character_setup?.update_preview()
			return
		if(istype(previewJob,/datum/job/cyborg))
			LAZYINITLIST(preview_dir_cache)
			for(var/dir in GLOB.cardinals)
				var/icon/bot_icon = icon('icons/mob/robots.dmi', icon_state = "robot", dir = dir)
				preview_dir_cache["[dir]"] = icon2html(bot_icon, parent)
			preview_icon64 = preview_dir_cache["[preview_direction]"]
			preview_generating = FALSE
			var/had_pending_cyborg = pending_preview_update
			pending_preview_update = FALSE
			if(had_pending_cyborg)
				update_preview_icon()
			else
				parent?.character_setup?.update_preview()
			return

	// --- Персистентный манекен: избегаем copy_to() + regenerate_icons() при каждом клике ---
	var/slot_key = "preview_mannequin_[REF(src)]"
	var/current_hint = preview_change_hint
	preview_change_hint = null // Очищаем, чтобы следующий вызов без hint шёл полным путём

	if(preview_mannequin_initialized && !QDELETED(preview_mannequin) && current_hint)
		// Инкрементальный путь: обновляем только нужные слои на уже инициализированном манекене
		switch(current_hint)
			if(PREVIEW_HINT_HAIR)
				preview_mannequin.hair_style = hair_style
				preview_mannequin.hair_color = hair_color
				preview_mannequin.facial_hair_style = facial_hair_style
				preview_mannequin.facial_hair_color = facial_hair_color
				preview_mannequin.grad_style = grad_style
				preview_mannequin.grad_color = grad_color
				preview_mannequin.update_hair()
			if(PREVIEW_HINT_BODY)
				copy_to(preview_mannequin, initial_spawn = TRUE)
				preview_mannequin.update_body(TRUE)
				preview_mannequin.update_hair()
			if(PREVIEW_HINT_MUTANT_BODYPARTS)
				copy_to(preview_mannequin, initial_spawn = TRUE)
				preview_mannequin.update_body(TRUE)
				preview_mannequin.update_mutant_bodyparts()
				preview_mannequin.update_hair()
			else
				copy_to(preview_mannequin, initial_spawn = TRUE)
				preview_mannequin.regenerate_icons()
	else
		// Полная инициализация — первый вызов или после инвалидации
		if(QDELETED(preview_mannequin))
			preview_mannequin = generate_or_wait_for_human_dummy(slot_key)
		if(!preview_mannequin)
			preview_generating = FALSE
			return
		copy_to(preview_mannequin, initial_spawn = TRUE)

		// Reset size to default for preview — body_size distorts getFlatIcon canvas, making large characters tiny
		var/current_size = get_size(preview_mannequin)
		if(current_size != RESIZE_DEFAULT_SIZE)
			preview_mannequin.update_size(RESIZE_DEFAULT_SIZE, current_size)

		switch(preview_pref)
			if(PREVIEW_PREF_JOB)
				if(previewJob)
					preview_mannequin.job = previewJob.title
					previewJob.equip(preview_mannequin, TRUE, preference_source = parent)
			if(PREVIEW_PREF_LOADOUT)
				var/mob/preview_src_mob = parent?.mob
				if(preview_src_mob)
					SSjob.equip_loadout(preview_src_mob, preview_mannequin, bypass_prereqs = TRUE, can_drop = FALSE, is_dummy = TRUE)
					SSjob.post_equip_loadout(preview_src_mob, preview_mannequin, bypass_prereqs = TRUE, can_drop = FALSE, is_dummy = TRUE)
			if(PREVIEW_PREF_NAKED)
				pass()
			if(PREVIEW_PREF_NAKED_AROUSED)
				for(var/obj/item/organ/genital/genital in preview_mannequin.internal_organs)
					if(CHECK_BITFIELD(genital.genital_flags, GENITAL_CAN_AROUSE))
						genital.set_aroused_state(TRUE, null)

		preview_mannequin.regenerate_icons()
		preview_mannequin_initialized = TRUE

	var/mob/living/carbon/human/dummy/mannequin = preview_mannequin

	// Размер персонажа отображается через DM icon.Scale() + размещение на фиксированном canvas 64x64.
	// Canvas 64px → CSS 320px = чистый 5x upscale без субпиксельных артефактов.
	var/preview_body_size = features["body_size"] || RESIZE_DEFAULT_SIZE
	var/visual_scale = clamp(preview_body_size, 0.25, 3)
	var/canvas_size = 64
	var/is_fuzzy = (fuzzy == SCALED_FUZZY)
	var/is_parts = (fuzzy == SCALED_PARTS) // WIP: per-part скейлинг не доработан, тестовый режим

	// Per-Part: применяем размер на манекен — оверлеи скейлятся по частям через apply_overlay,
	// getFlatIcon захватит уже отмасштабированный результат
	if(is_parts && visual_scale != RESIZE_DEFAULT_SIZE)
		mannequin.update_size(visual_scale, RESIZE_DEFAULT_SIZE)

	// Fuzzy при нестандартном размере: CSS делает bilinear scale напрямую из исходных пикселей
	var/scale_prefix
	if(is_fuzzy && visual_scale != RESIZE_DEFAULT_SIZE)
		scale_prefix = "<img style='image-rendering: smooth; image-rendering: auto; transform: scale([visual_scale]); transform-origin: bottom center;' "

	LAZYCLEARLIST(preview_dir_cache)
	LAZYINITLIST(preview_dir_cache)
	var/build_reference = preview_show_reference
	if(build_reference)
		LAZYCLEARLIST(preview_reference_cache)
		LAZYINITLIST(preview_reference_cache)
	else
		LAZYCLEARLIST(preview_reference_cache)

	// Сначала генерируем только текущее направление — мгновенный отклик для пользователя
	_generate_preview_for_dir(mannequin, preview_direction, canvas_size, visual_scale, is_fuzzy, is_parts, scale_prefix, build_reference)
	preview_icon64 = preview_dir_cache["[preview_direction]"]

	// Показываем результат сразу, не дожидаясь остальных 3 направлений
	// В TGUI превью обновляется через character_setup_ui.update_preview() → ByondUi map
	parent?.character_setup?.update_preview()

	// Догенерируем остальные 3 направления в фоне (для мгновенных поворотов)
	for(var/dir in GLOB.cardinals)
		if(dir == preview_direction)
			continue
		// Если пришёл новый запрос на обновление — прерываем, актуальные данные пересоздадутся
		if(pending_preview_update)
			break
		_generate_preview_for_dir(mannequin, dir, canvas_size, visual_scale, is_fuzzy, is_parts, scale_prefix, build_reference)

	// НЕ освобождаем манекен — он персистентный и переиспользуется при следующем обновлении
	// Размер нужно сбросить если он менялся для рендера
	if(is_parts && visual_scale != RESIZE_DEFAULT_SIZE)
		mannequin.update_size(RESIZE_DEFAULT_SIZE, visual_scale)

	preview_generating = FALSE
	var/had_pending = pending_preview_update
	pending_preview_update = FALSE
	if(had_pending)
		update_preview_icon()

/// Генерирует и кэширует превью-иконку для одного направления
/datum/preferences/proc/_generate_preview_for_dir(mob/living/carbon/human/mannequin, dir, canvas_size, visual_scale, is_fuzzy, is_parts, scale_prefix, build_reference)
	var/icon/flat = getFlatIcon(mannequin, defdir = dir, no_anim = TRUE)
	if(!flat)
		preview_dir_cache["[dir]"] = null
		if(build_reference)
			preview_reference_cache["[dir]"] = null
		return
	// Reference: копируем иконку ДО масштабирования — это и есть 100%
	if(build_reference)
		var/icon/ref_flat = icon(flat)
		var/rfw = ref_flat.Width()
		var/ref_crop_x1 = 1 - round((canvas_size - rfw) / 2)
		ref_flat.Crop(ref_crop_x1, 1, ref_crop_x1 + canvas_size - 1, canvas_size)
		preview_reference_cache["[dir]"] = icon2html(ref_flat, parent)
	// Sharp: масштабируем в DM nearest-neighbor (как PIXEL_SCALE в игре)
	// Fuzzy: оставляем оригинальный размер — CSS сделает bilinear через transform
	// Parts: оверлеи уже отмасштабированы на манекене — пропускаем
	if(!is_fuzzy && !is_parts && visual_scale != RESIZE_DEFAULT_SIZE)
		flat.Scale(max(1, round(flat.Width() * visual_scale)), max(1, round(flat.Height() * visual_scale)))
	// Размещаем на canvas 64x64: bottom-center (ноги на земле, как в игре)
	var/fw = flat.Width()
	var/crop_x1 = 1 - round((canvas_size - fw) / 2)
	flat.Crop(crop_x1, 1, crop_x1 + canvas_size - 1, canvas_size)

	var/raw_html = icon2html(flat, parent)
	if(scale_prefix)
		preview_dir_cache["[dir]"] = replacetext(raw_html, "<img ", scale_prefix)
	else
		preview_dir_cache["[dir]"] = raw_html

/datum/preferences/proc/get_highest_job()
	var/highest_pref = 0
	var/datum/job/highest_job
	for(var/job in job_preferences)
		if(job_preferences["[job]"] > highest_pref)
			highest_job = SSjob.GetJob(job)
			highest_pref = job_preferences["[job]"]
	return highest_job
