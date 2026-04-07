// Hair Style Picker
#define HAIR_PICKER_PAGE_SIZE 24
#define HAIR_ICON_CACHE_MAX 128

/datum/tgui_hair_style_picker
	var/client/holder
	var/datum/preferences/prefs
	var/pick_type = "hair"
	var/current_page = 0
	var/search_text = ""
	var/list/current_icons = list()
	var/total_pages = 1
	var/list/filtered_names = list()
	var/preview_icon64 = null
	var/preview_generating = FALSE
	var/preview_pending = FALSE
	var/last_preview_time = 0
	var/preview_timer_id = null
	/// Cached mannequin — held for the lifetime of the picker to avoid copy_to on every click
	var/mob/living/carbon/human/dummy/cached_mannequin
	var/mannequin_initialized = FALSE
	var/dummy_slot_key
	/// Кэш плоской иконки манекена БЕЗ hair layer — для быстрой композиции при переборе причёсок.
	var/icon/cached_base_icon = null

	// Статический кэш base64 иконок по типу.
	var/static/list/hair_icon_cache = null
	var/static/list/facial_icon_cache = null
	var/static/list/gradient_icon_cache = null

/datum/tgui_hair_style_picker/New(mob/user, type = "hair")
	if(istype(user, /client))
		holder = user
	else
		holder = user.client
	prefs = holder.prefs
	pick_type = type
	dummy_slot_key = "hair_picker_[REF(src)]"
	rebuild_filtered(search_text)
	load_page_icons()
	INVOKE_ASYNC(src, PROC_REF(_preload_remaining_icons)) // фоновый прогрев оставшихся страниц
	refresh_preview_icon()

/datum/tgui_hair_style_picker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HairStylePicker", pick_type == "hair" ? "Выбор Причёски" : pick_type == "facial_hair" ? "Выбор Стиля Бороды" : "Выбор Цветового Перехода")
		ui.open()

/datum/tgui_hair_style_picker/Destroy()
	if(preview_timer_id)
		deltimer(preview_timer_id)
		preview_timer_id = null
	if(cached_mannequin)
		unset_busy_human_dummy(dummy_slot_key)
		cached_mannequin = null
	cached_base_icon = null
	return ..()

/datum/tgui_hair_style_picker/ui_close(mob/user)
	qdel(src)

/datum/tgui_hair_style_picker/ui_state(mob/user)
	return GLOB.always_state

/datum/tgui_hair_style_picker/ui_static_data(mob/user)
	var/list/data = list()
	data["pick_type"] = pick_type
	var/list/all_names = list()
	for(var/name in get_style_list())
		all_names += name
	data["all_style_names"] = all_names
	return data

/datum/tgui_hair_style_picker/ui_data(mob/user)
	var/list/data = list()
	switch(pick_type)
		if("hair")
			data["current_style"] = prefs.hair_style
		if("facial_hair")
			data["current_style"] = prefs.facial_hair_style
		if("gradient")
			data["current_style"] = prefs.grad_style
	data["filtered_names"] = filtered_names
	data["loaded_icons"] = current_icons
	data["preview_icon64"] = preview_icon64
	return data

/datum/tgui_hair_style_picker/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("navigate")
			var/page = text2num(params["page"])
			var/new_search = params["search"]
			if(!istext(new_search))
				new_search = ""
			if(new_search != search_text)
				search_text = new_search
				rebuild_filtered(search_text)
				current_page = 0
			else
				current_page = clamp(round(page), 0, max(0, total_pages - 1))
			load_page_icons()
			return TRUE

		if("preview")
			var/style = params["style"]
			if(!style)
				return
			if(!(style in get_style_list()))
				return
			switch(pick_type)
				if("hair")
					prefs.hair_style = style
				if("facial_hair")
					prefs.facial_hair_style = style
				if("gradient")
					prefs.grad_style = style
			// ShowChoices() не вызывается при каждом клике — слишком дорого (2500+ строк логики).
			// Обновление главного меню происходит при confirm.
			refresh_preview_icon()
			return TRUE

		if("confirm")
			var/list/valid_styles = get_style_list()
			switch(pick_type)
				if("hair")
					if(!(prefs.hair_style in valid_styles))
						return
				if("facial_hair")
					if(!(prefs.facial_hair_style in valid_styles))
						return
				if("gradient")
					if(!(prefs.grad_style in valid_styles))
						return
			prefs.save_preferences()
			SStgui.update_user_uis(holder.mob)
			SStgui.close_uis(src)

/datum/tgui_hair_style_picker/proc/get_style_list()
	switch(pick_type)
		if("hair")
			return GLOB.hair_styles_list
		if("facial_hair")
			return GLOB.facial_hair_styles_list
		if("gradient")
			return GLOB.hair_gradients_list
	return list()

/datum/tgui_hair_style_picker/proc/get_icon_cache()
	switch(pick_type)
		if("hair")
			if(!hair_icon_cache)
				hair_icon_cache = list()
			return hair_icon_cache
		if("facial_hair")
			if(!facial_icon_cache)
				facial_icon_cache = list()
			return facial_icon_cache
		if("gradient")
			if(!gradient_icon_cache)
				gradient_icon_cache = list()
			return gradient_icon_cache
	return list()

/datum/tgui_hair_style_picker/proc/rebuild_filtered(filter)
	filtered_names = list()
	var/list/styles = get_style_list()
	var/lower_filter = lowertext(filter)
	for(var/name in styles)
		if(!filter || findtext(lowertext(name), lower_filter))
			filtered_names += name
	total_pages = max(1, ceil(filtered_names.len / HAIR_PICKER_PAGE_SIZE))

/datum/tgui_hair_style_picker/proc/load_page_icons()
	var/list/cache = get_icon_cache()
	var/list/styles = get_style_list()
	current_icons = list()

	var/start = current_page * HAIR_PICKER_PAGE_SIZE + 1
	var/end = min(start + HAIR_PICKER_PAGE_SIZE - 1, filtered_names.len)

	for(var/i = start to end)
		var/style_name = filtered_names[i]
		if(cache[style_name])
			current_icons[style_name] = cache[style_name]
			continue
		var/datum/sprite_accessory/SA = styles[style_name]
		if(SA && SA.icon && SA.icon_state)
			var/encode = icon2base64(icon(SA.icon, SA.icon_state, SOUTH, 1))
			if(encode)
				if(cache.len < HAIR_ICON_CACHE_MAX)
					cache[style_name] = encode
				current_icons[style_name] = encode

/datum/tgui_hair_style_picker/proc/refresh_preview_icon()
	if(preview_generating)
		preview_pending = TRUE
		return
	// Throttle: максимум ~3 превью в секунду (3 тика = 0.3с)
	// С кэшированной базой каждый рендер быстрый, можно снизить throttle
	var/time_since_last = world.time - last_preview_time
	if(time_since_last < 3)
		if(!preview_timer_id)
			preview_timer_id = addtimer(CALLBACK(src, PROC_REF(_throttled_preview)), 3 - time_since_last, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)
		return
	last_preview_time = world.time
	INVOKE_ASYNC(src, PROC_REF(_do_refresh_preview))

/datum/tgui_hair_style_picker/proc/_throttled_preview()
	preview_timer_id = null
	if(QDELETED(src))
		return
	last_preview_time = world.time
	INVOKE_ASYNC(src, PROC_REF(_do_refresh_preview))

/datum/tgui_hair_style_picker/proc/_do_refresh_preview()
	preview_generating = TRUE
	preview_pending = FALSE
	// Первый вызов — полная инициализация манекена (copy_to + regenerate_icons)
	// Последующие — только обновляем изменившееся поле (hair/facial/grad) + update_hair()
	if(!mannequin_initialized || QDELETED(cached_mannequin))
		cached_mannequin = generate_or_wait_for_human_dummy(dummy_slot_key)
		if(!cached_mannequin || QDELETED(src))
			preview_generating = FALSE
			return
		prefs.copy_to(cached_mannequin, initial_spawn = TRUE)
		cached_mannequin.regenerate_icons()
		mannequin_initialized = TRUE
		// Кэшируем базовую иконку БЕЗ hair layer — для быстрой композиции в дальнейшем
		cached_mannequin.remove_overlay(HAIR_LAYER)
		cached_base_icon = getFlatIcon(cached_mannequin, defdir = SOUTH, no_anim = TRUE)
		cached_mannequin.update_hair() // вернуть hair overlay
	else
		// Инкрементальное обновление — только изменившееся поле + пересборка hair-оверлеев
		switch(pick_type)
			if("hair")
				cached_mannequin.hair_style = prefs.hair_style
			if("facial_hair")
				cached_mannequin.facial_hair_style = prefs.facial_hair_style
			if("gradient")
				cached_mannequin.grad_style = prefs.grad_style
		cached_mannequin.update_hair()
	if(QDELETED(src))
		return
	// Если есть кэш базовой иконки — композиция вместо дорогого getFlatIcon()
	var/icon/I
	if(cached_base_icon)
		I = icon(cached_base_icon) // копия кэшированной базы
		// Берём hair-оверлеи с манекена и блендим поверх базы
		var/overlays_data = cached_mannequin.overlays_standing[HAIR_LAYER]
		if(overlays_data)
			var/list/overlay_list
			if(islist(overlays_data))
				overlay_list = overlays_data
			else
				overlay_list = list(overlays_data)
			for(var/mutable_appearance/MA in overlay_list)
				if(!MA.icon || !MA.icon_state)
					continue
				var/icon/hair_part = icon(MA.icon, MA.icon_state, SOUTH, 1)
				if(MA.color)
					hair_part.Blend(MA.color, ICON_MULTIPLY)
				if(MA.alpha < 255)
					hair_part.Blend(rgb(255, 255, 255, MA.alpha), ICON_MULTIPLY)
				I.Blend(hair_part, ICON_OVERLAY, MA.pixel_x, MA.pixel_y)
	else
		// Fallback — полный getFlatIcon() если кэш не создан
		I = getFlatIcon(cached_mannequin, defdir = SOUTH, no_anim = TRUE)
	if(QDELETED(src))
		return
	// Request cancellation: если пришёл новый запрос, пропускаем дорогой icon2html() —
	// текущий результат всё равно устареет, а icon2html() не бесплатен
	if(preview_pending)
		preview_generating = FALSE
		refresh_preview_icon()
		return
	if(I)
		preview_icon64 = icon2html(I, holder, sourceonly = TRUE)
	else
		preview_icon64 = null
	preview_generating = FALSE
	SStgui.update_uis(src)
	if(preview_pending)
		refresh_preview_icon()

/datum/tgui_hair_style_picker/proc/_preload_remaining_icons()
	var/list/cache = get_icon_cache()
	var/list/styles = get_style_list()
	var/batch = 0
	for(var/style_name in styles)
		if(QDELETED(src))
			return
		if(cache[style_name])
			continue
		if(cache.len >= HAIR_ICON_CACHE_MAX)
			return
		var/datum/sprite_accessory/SA = styles[style_name]
		if(SA && SA.icon && SA.icon_state)
			var/encode = icon2base64(icon(SA.icon, SA.icon_state, SOUTH, 1))
			if(encode)
				cache[style_name] = encode
		if(++batch % 8 == 0)
			CHECK_TICK
