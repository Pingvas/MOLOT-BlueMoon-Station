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
	rebuild_filtered(search_text)
	load_page_icons()
	INVOKE_ASYNC(src, PROC_REF(_preload_remaining_icons)) // фоновый прогрев оставшихся страниц
	refresh_preview_icon()

/datum/tgui_hair_style_picker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HairStylePicker", pick_type == "hair" ? "Выбор Причёски" : pick_type == "facial_hair" ? "Выбор Стиля Бороды" : "Выбор Цветового Перехода")
		ui.open()

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
	data["filtered_names"] = filtered_names.Copy()
	data["loaded_icons"] = current_icons.Copy()
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
			prefs.ShowChoices(holder.mob)
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
	INVOKE_ASYNC(src, PROC_REF(_do_refresh_preview))

/datum/tgui_hair_style_picker/proc/_do_refresh_preview()
	preview_generating = TRUE
	preview_pending = FALSE
	var/species_id = prefs.pref_species ? prefs.pref_species.id : "null"
	var/cache_key = "hairpick_[prefs.hair_style]_[prefs.hair_color]_[prefs.grad_style]_[prefs.facial_hair_style]_[prefs.facial_hair_color]_[prefs.skin_tone]_[species_id]"
	var/dummy_slot = "hair_picker_preview_[REF(src)]"
	var/icon/I = get_flat_human_icon(cache_key, null, prefs, dummy_slot, list(SOUTH), null, TRUE)
	if(QDELETED(src))
		return
	if(I)
		preview_icon64 = icon2html(I, holder, sourceonly = TRUE) // asset URL, не base64
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
