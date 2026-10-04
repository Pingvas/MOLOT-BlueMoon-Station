// Джоб менюшка похуй может потом доделаю все по красоте.
// В этот раз без пидор_бэк дефайнов.
#define JOB_MENU_LATEJOIN "latejoin"
#define JOB_MENU_PREFS "prefs"

/mob/dead/new_player
	var/datum/job_menu/job_menu

/datum/preferences
	var/datum/job_menu/job_menu

/datum/job_menu /// Один из JOB_MENU
	var/mode
	var/datum/preferences/prefs
	var/selected
	var/selected_ghost
	var/list/previews
	var/pushed_preview
	var/cached_slot

/datum/job_menu/New(new_mode, datum/preferences/new_prefs)
	mode = new_mode
	prefs = new_prefs
	previews = list()

/datum/job_menu/Destroy(force, ...)
	SStgui.close_uis(src)
	previews = null
	prefs = null
	return ..()

 // заменяет тело старого на новый
/mob/dead/new_player/proc/open_job_menu()
	if(QDELETED(job_menu))
		job_menu = new(JOB_MENU_LATEJOIN, client?.prefs)
	job_menu.ui_interact(src)

/datum/preferences/proc/open_job_menu(mob/user)
	if(QDELETED(job_menu))
		job_menu = new(JOB_MENU_PREFS, src)
	job_menu.ui_interact(user)

// Основные стейты для УИ, подсасывает старые значения не меняя их
/datum/job_menu/ui_state(mob/user)
	if(mode == JOB_MENU_LATEJOIN)
		return GLOB.new_player_state
	return GLOB.always_state

/datum/job_menu/ui_status(mob/user, datum/ui_state/state)
	if(!user?.client)
		return UI_CLOSE
	// Вот эту логику копируйте для всех переходящих в обсерв гостов если у нас появится подобие такой же менюшки, например для мини-игр или типа того.
	if(mode == JOB_MENU_LATEJOIN)
		return GLOB.new_player_state.can_use_topic(src, user)
	return (user.client.prefs == prefs) ? UI_INTERACTIVE : UI_CLOSE // на всякий случай я ебу

/datum/job_menu/ui_interact(mob/user, datum/tgui/ui)
	if(!prefs && user?.client)
		prefs = user.client.prefs
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui) // Единственное место где может наебнуться меню, изначально окно загружается без кэша.
		pushed_preview = null
		var/window_title = (mode == JOB_MENU_LATEJOIN) ? "Выберите профессию" : "Настройка профессий"
		ui = new(user, src, "JobMenu", window_title)
		ui.open()
		ui.set_autoupdate(FALSE)

// Дата
/datum/job_menu/ui_data(mob/user)
	var/list/data = list()
	if(!prefs && user?.client)
		prefs = user.client.prefs

	if(prefs && prefs.default_slot != cached_slot)
		previews.Cut()
		pushed_preview = null
		cached_slot = prefs.default_slot

	data["mode"] = mode
	data["selected"] = selected
	data["selectedGhost"] = selected_ghost

	if(selected && pushed_preview != selected)
		var/preview_image = previews[selected]
		if(isnull(preview_image))
			preview_image = generate_preview(selected, user)
			previews[selected] = preview_image
		pushed_preview = selected
		if(length(preview_image))
			data["preview"] = preview_image
			data["previewJob"] = selected

	data["departments"] = build_departments(user)

	if(mode == JOB_MENU_LATEJOIN)
		data["ghostRoles"] = build_ghost_roles()
		data["round"] = build_round_info()
	else
		data["joblessrole"] = build_jobless_text()
		data["overflowRole"] = SSjob.overflow_role

	return data

 // Повторяем группировку отделов с старого меню, порядок меняется позицией в листе.
/datum/job_menu/proc/build_departments(mob/user)
	. = list()
	if(!SSjob || !length(SSjob.occupations))
		return

	var/list/categories = list(
		GLOB.command_positions,
		GLOB.supply_positions,
		GLOB.engineering_positions,
		GLOB.nonhuman_positions - "pAI",
		GLOB.civilian_positions,
		GLOB.law_positions,
		GLOB.medical_positions,
		GLOB.science_positions,
		GLOB.security_positions,
	)

	var/latejoin_mode = (mode == JOB_MENU_LATEJOIN)

	if(latejoin_mode)
		for(var/datum/job/prioritized_job in SSjob.prioritized_jobs.Copy())
			if(prioritized_job.current_positions >= prioritized_job.total_positions)
				SSjob.prioritized_jobs -= prioritized_job

	var/list/emitted = list()

	for(var/list/category in categories)
		if(!length(category))
			continue
		var/datum/job/head_job = SSjob.name_occupations[category[1]]
		if(!head_job)
			continue

		var/list/jobs = list()
		for(var/job_title in category)
			var/datum/job/job_datum = SSjob.name_occupations[job_title] // Проверка на датум, у которого поменялось название. Например Бриг педик это не валидное значение, делаем его валидным.
			if(!job_datum)
				continue
			// Часть профессий попадают под несколько отделов, например КМ состоит и в главах и в карго.
			var/is_head = (job_title == category[1])
			if(!is_head && (job_datum.title in emitted))
				continue
			emitted += job_datum.title
			if(latejoin_mode)
				var/mob/dead/new_player/J = user
				// Вакансии которые ваще не доступны скрываем
				if(!istype(J) || J.IsJobUnavailable(job_datum.title, TRUE) != JOB_AVAILABLE)
					continue
			jobs += list(build_job_entry(job_datum, user))

		var/department_type = head_job.exp_type_department
		. += list(list(
			"name" = (GLOB.exp_type_department_ru[department_type] || department_type),
			"color" = head_job.selection_color,
			"jobs" = jobs,
		))

/// строка профессии
/datum/job_menu/proc/build_job_entry(datum/job/job_datum, mob/user)
	var/list/entry = list(
		"title" = job_datum.title,
		"command" = (job_datum.title in GLOB.command_positions),
		"current" = job_datum.current_positions,
		"total" = job_datum.total_positions,
	)

	if(prefs)
		var/display_title = job_datum.title
		if(prefs.alt_titles_preferences[job_datum.title])
			display_title = prefs.alt_titles_preferences[job_datum.title]
		entry["displayTitle"] = display_title

	if(length(job_datum.alt_titles))
		entry["hasAltTitles"] = TRUE

	if(mode == JOB_MENU_LATEJOIN)
		if(job_datum in SSjob.prioritized_jobs)
			entry["pinned"] = TRUE
		return entry

	var/blocked_reason = prefs_blocked_reason(job_datum, user)
	if(blocked_reason)
		entry["blocked"] = blocked_reason

	var/priority = prefs.job_preferences["[job_datum.title]"]
	if(priority)
		entry["priority"] = priority

	if(job_datum.title == SSjob.overflow_role)
		entry["overflow"] = TRUE
	else if(prefers_overflow_locked(job_datum, user))
		entry["locked"] = TRUE

	return entry

// даем инфо о блоке профессии
/datum/job_menu/proc/prefs_blocked_reason(datum/job/job_datum, mob/user)
	if(!user?.client || !prefs)
		return null
	var/rank = job_datum.title

	if(jobban_isbanned(user, rank))
		return "ЗАБАНЕН"

	var/required_playtime_remaining = job_datum.required_playtime_remaining(user.client)
	if(required_playtime_remaining)
		return "[get_exp_format(required_playtime_remaining)] как [job_datum.get_exp_req_type()]"

	if(!job_datum.player_old_enough(user.client))
		return "ЧЕРЕЗ [job_datum.available_in_days(user.client)] ДН."

	if(!prefs.pref_species.qualifies_for_rank(rank, prefs.features))
		if(prefs.pref_species.id == SPECIES_HUMAN)
			return "МУТАНТ"
		return "НЕ ЧЕЛОВЕК"

	if(job_datum.is_species_blacklisted(user.client))
		return "РАСА ЗАПРЕЩЕНА"

	return null

/// флажок клоуна
/datum/job_menu/proc/prefers_overflow_locked(datum/job/job_datum, mob/user)
	if(!prefs || job_datum.title == SSjob.overflow_role)
		return FALSE
	if(prefs.job_preferences["[SSjob.overflow_role]"] != JP_LOW)
		return FALSE
	if(user && jobban_isbanned(user, SSjob.overflow_role))
		return FALSE
	return TRUE

/// Гост роли
/datum/job_menu/proc/build_ghost_roles()
	var/list/ghost_roles = list()
	for(var/spawner in GLOB.mob_spawners)
		var/list/spawner_list = GLOB.mob_spawners[spawner]
		if(!length(spawner_list))
			continue
		var/obj/effect/mob_spawn/spawn_landmark = pick(spawner_list)
		if(!istype(spawn_landmark) || !spawn_landmark.can_latejoin())
			continue
		ghost_roles += spawner
	return ghost_roles

/// Баннер сверху о состоянии раунда. Время, код и цвет
/datum/job_menu/proc/build_round_info()
	var/list/info = list()
	if(SSticker && SSticker.IsRoundInProgress())
		info["duration"] = DisplayTimeText(world.time - SSticker.round_start_time)
		info["alert"] = capitalize(SECURITY_LEVEL_NAME_RU(GLOB.security_level) || SECURITY_LEVEL_NAME_RU(SEC_LEVEL_GREEN) || "зелёный")
		info["alertColor"] = SECURITY_LEVEL_COLOR(GLOB.security_level)

	if(SSshuttle.emergency)
		switch(SSshuttle.emergency.mode)
			if(SHUTTLE_ESCAPE)
				info["shuttle"] = "Экипаж станции эвакуировался."
			if(SHUTTLE_CALL)
				if(!SSshuttle.canRecall())
					info["shuttle"] = "Станция сейчас проводит процедуру эвакуации экипажа."

	return info

/// Что делать, если приоритеты не подойдут
/datum/job_menu/proc/build_jobless_text()
	if(!prefs)
		return null
	switch(prefs.joblessrole)
		if(BEOVERFLOW)
			return "Стать [SSjob.overflow_role], если префы недоступны"
		if(BERANDOMJOB)
			return "Случайная работа, если префы недоступны"
		if(RETURNTOLOBBY)
			return "Вернуться в лобби, если префы недоступны"
	return "Стать [SSjob.overflow_role], если префы недоступны"

// ПРЕВЬЮ

/datum/job_menu/proc/generate_preview(job_title, mob/user)
	var/datum/preferences/preview_prefs = prefs || user?.client?.prefs
	if(!preview_prefs || !SSjob)
		return ""
	var/datum/job/job_datum = SSjob.GetJob(job_title)
	if(!job_datum)
		return ""

	// Синтетики
	if(istype(job_datum, /datum/job/ai))
		return encode_preview_icon(icon('icons/mob/AI.dmi', resolve_ai_icon(preview_prefs.preferred_ai_core_display), SOUTH))
	if(istype(job_datum, /datum/job/cyborg))
		return encode_preview_icon(icon('icons/mob/robots.dmi', "robot", SOUTH))

	var/icon/flat_icon = get_flat_human_icon(null, job_datum, preview_prefs, null, list(SOUTH))
	return encode_preview_icon(flat_icon)

/datum/job_menu/proc/encode_preview_icon(icon/target)
	if(!isicon(target))
		return ""
	var/encoded = icon2base64_scaled(target, 2)
	return istext(encoded) ? encoded : ""

// АКТы

/datum/job_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	. = TRUE
	// опять забавный вар на всякий случай
	var/mob/ui_user = usr

	switch(action)
		if("refresh")
			return

		if("select")
			var/job_title = params["job"]
			if(!istext(job_title) || !SSjob?.GetJob(job_title))
				return
			selected = job_title
			selected_ghost = null
			return

		if("select_ghost")
			var/spawner_key = params["spawner"]
			if(!istext(spawner_key) || !GLOB.mob_spawners[spawner_key])
				return
			selected_ghost = spawner_key
			selected = null
			return

		if("join")
			if(mode != JOB_MENU_LATEJOIN || !isnewplayer(ui_user))
				return
			var/job_title = params["job"]
			if(!istext(job_title))
				return
			if(!SSticker || !SSticker.IsRoundInProgress())
				to_chat(ui_user, "<span class='danger'>Раунд ещё не начался или уже закончился...</span>")
				return
			if(!entry_allowed(ui_user))
				return
			var/mob/dead/new_player/joiner = ui_user
			joiner.AttemptLateSpawn(job_title)
			return

		if("join_ghost")
			if(mode != JOB_MENU_LATEJOIN || !isnewplayer(ui_user))
				return
			var/spawner_key = params["spawner"]
			if(!istext(spawner_key))
				return
			if(!entry_allowed(ui_user))
				return
			var/list/spawner_list = GLOB.mob_spawners[spawner_key]
			if(!length(spawner_list))
				to_chat(ui_user, "<span class='warning'>Эта роль больше недоступна.</span>")
				return
			var/obj/effect/mob_spawn/spawn_landmark = pick(spawner_list)
			if(!istype(spawn_landmark))
				to_chat(ui_user, "<span class='warning'>Эта роль больше недоступна.</span>")
				return
			if(spawn_landmark.attack_ghost(ui_user, latejoinercalling = TRUE))
				SSticker.queued_players -= ui_user
				SSticker.queue_delay = 4
				qdel(ui_user)
			return

		if("set_priority")
			if(mode != JOB_MENU_PREFS || !prefs)
				return
			set_priority(ui_user, params["job"], params["level"])
			return

		if("joblessrole")
			if(mode != JOB_MENU_PREFS || !prefs)
				return
			switch(prefs.joblessrole)
				if(RETURNTOLOBBY)
					prefs.joblessrole = jobban_isbanned(ui_user, SSjob.overflow_role) ? BERANDOMJOB : BEOVERFLOW
				if(BEOVERFLOW)
					prefs.joblessrole = BERANDOMJOB
				else
					prefs.joblessrole = RETURNTOLOBBY
			return

		if("reset")
			if(mode != JOB_MENU_PREFS || !prefs)
				return
			prefs.ResetJobs()
			return

		if("alt_title")
			if(!prefs)
				return
			var/job_title = params["job"]
			var/datum/job/job_datum = SSjob?.GetJob(job_title)
			if(!job_datum)
				return
			var/list/titles_list = list(job_title)
			for(var/alt_title in job_datum.alt_titles)
				titles_list += alt_title
			var/chosen_title = tgui_input_list(ui_user, "Выберите название должности:", "Настройка профессий", titles_list)
			if(chosen_title)
				if(chosen_title == job_title)
					prefs.alt_titles_preferences.Remove(job_title)
				else
					prefs.alt_titles_preferences[job_title] = chosen_title
			return

		if("close")
			ui?.close()
			return

 // Проверки входа в раунд при разных условиях
/datum/job_menu/proc/entry_allowed(mob/user)
	if(!GLOB.enter_allowed)
		to_chat(user, "<span class='notice'>Администрация запретила вход в игру!</span>")
		return FALSE

	var/relevant_cap
	var/hpc = CONFIG_GET(number/hard_popcap)
	var/epc = CONFIG_GET(number/extreme_popcap)
	if(hpc && epc)
		relevant_cap = min(hpc, epc)
	else
		relevant_cap = max(hpc, epc)

	if(length(SSticker.queued_players) && !(user.ckey in GLOB.admin_datums))
		if((living_player_count() >= relevant_cap) || (user != SSticker.queued_players[1]))
			to_chat(user, "<span class='warning'>Сервер заполнен.</span>") // лол
			return FALSE

	return TRUE

/datum/job_menu/proc/set_priority(mob/user, job_title, level)
	if(!prefs || !istext(job_title))
		return
	var/datum/job/job_datum = SSjob?.GetJob(job_title)
	if(!job_datum || !length(SSjob.occupations))
		return

	var/new_level = level
	if(!isnum(new_level))
		new_level = text2num("[new_level]")
	if(isnull(new_level) || new_level < 0 || new_level > JP_HIGH)
		return

	if(job_title == SSjob.overflow_role)
		// Переполнение - это простое "Да/Нет": Да означает JP_LOW.
		if(new_level)
			prefs.job_preferences["[job_title]"] = JP_LOW
		else
			prefs.job_preferences -= "[job_title]"
		return

	if(prefers_overflow_locked(job_datum, user))
		return

	if(!new_level)
		prefs.job_preferences -= "[job_title]"
		return

	prefs.SetJobPreferenceLevel(job_datum, new_level)

#undef JOB_MENU_LATEJOIN
#undef JOB_MENU_PREFS
