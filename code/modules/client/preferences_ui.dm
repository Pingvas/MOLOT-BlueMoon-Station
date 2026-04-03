/datum/preferences/proc/ShowChoices(mob/user)
	if(!user || !user.client)
		return
	update_preview_icon(current_tab)
	var/list/dat
	// Compact inline CSS: конкретные значения цветов для BYOND-браузера.
	// Enhanced decoration — CSS-класс .csetup-decoration-enhanced (переключается без inline CSS).
	var/modern_palette_css = ""
	var/list/theme = get_character_setup_palette_modern()
	var/bg_primary = theme["bg_primary"]
	var/bg_secondary = theme["bg_secondary"]
	var/text_primary = theme["text_primary"]
	var/text_secondary = theme["text_secondary"]
	var/button_bg = theme["button_bg"]
	var/button_hover = theme["button_hover"]
	var/button_active = theme["button_active"]
	var/button_text = theme["button_text"]
	var/border_color = theme["border_color"]
	var/accent_color = theme["accent_color"]
	var/bg_pattern = theme["bg_pattern"]
	var/button_radius = "7px"
	switch(modern_button_shape)
		if("rect")
			button_radius = "0px"
		if("soft")
			button_radius = "4px"
		if("round")
			button_radius = "7px"
	// Custom-палитра: также выставляем CSS-переменные для современных браузеров (rgba(var(...)) и пр.)
	var/custom_vars = ""
	if(charcreation_theme == "modern_custom")
		var/accent_hex = replacetext(accent_color, "#", "")
		var/accent_r = text2num("0x[copytext(accent_hex, 1, 3)]")
		var/accent_g = text2num("0x[copytext(accent_hex, 3, 5)]")
		var/accent_b = text2num("0x[copytext(accent_hex, 5, 7)]")
		custom_vars = "--csetup-bg:[bg_primary];--csetup-panel:[bg_secondary];--csetup-panel-2:[bg_secondary];--csetup-border:[border_color];--csetup-text:[text_primary];--csetup-muted:[text_secondary];--csetup-accent:[accent_color];--csetup-accent-rgb:[accent_r],[accent_g],[accent_b];--csetup-btn-bg:[button_bg];--csetup-btn-hover:[button_hover];--csetup-btn-active:[button_active];--csetup-btn-active-text:[button_text];"
	modern_palette_css = "<style>\n\
	.csetup-root{[custom_vars]background-color:[bg_primary];color:[text_primary];background-image:[bg_pattern]}\n\
	.csetup-root a,.csetup-root a:link,.csetup-root a:visited{color:[text_primary];background-color:[button_bg];border-color:[border_color];border-radius:[button_radius]}\n\
	.csetup-root a:hover{background-color:[button_hover]}\n\
	.csetup-root .linkOn{background-color:[button_active];color:[button_text]}\n\
	.csetup-root a.linkOff,.csetup-root .linkOff{color:[text_secondary]}\n\
	.csetup-root hr{background-color:[border_color]}\n\
	.csetup-root table{background-color:[bg_secondary];border-color:[border_color]}\n\
	.csetup-root td,.csetup-root th{color:[text_primary];border-color:[border_color]}\n\
	.csetup-root .csetup_character_node{background-color:[bg_secondary];border-color:[border_color]}\n\
	.csetup-root .csetup_character_label{color:[text_secondary]}\n\
	.csetup-root .csetup-ai-core-preview img{border-color:[border_color];background-color:[bg_primary]}\n\
	.csetup-root .theme-selector{background-color:[bg_secondary];border-color:[border_color]}\n\
	.csetup-root .theme-label{color:[text_secondary]}\n\
	.csetup-root .theme-label-custom{color:[text_primary]}\n\
	.csetup-root .theme-sep{background:[border_color]}\n\
	.csetup-root .theme-custom-group{background-color:[bg_primary];border-color:[border_color]}\n\
	.csetup-root a.theme-swatch.active{border-color:[accent_color];outline:2px solid [accent_color];outline-offset:1px}\n\
	.csetup-root a.theme-swatch--custom{border-radius:[button_radius]}\n\
	.csetup-root a.theme-gear{border-radius:[button_radius]}\n\
	.csetup-root .theme-custom-editor{background-color:[bg_secondary];border-color:[border_color];color:[text_primary]}\n\
	.csetup-root .theme-custom-editor-hint{color:[text_secondary]}\n\
	</style>"
	var/theme_class = "csetup-theme-modern csetup-accent-blue"
	switch(charcreation_theme)
		if("modern")
			theme_class = "csetup-theme-modern csetup-scheme-dark csetup-accent-blue"
		if("modern_classic")
			theme_class = "csetup-theme-modern csetup-scheme-classic"
		if("modern_purple")
			theme_class = "csetup-theme-modern csetup-scheme-purple csetup-accent-purple"
		if("modern_green")
			theme_class = "csetup-theme-modern csetup-scheme-green csetup-accent-green"
		if("modern_neutral")
			theme_class = "csetup-theme-modern csetup-scheme-neutral csetup-accent-neutral"
		else
			theme_class = "csetup-theme-modern csetup-accent-blue"

	var/button_shape_class = "csetup-btnshape-[modern_button_shape]"
	var/decoration_class = ""
	switch(ui_decoration_level)
		if("minimal")
			decoration_class = "csetup-decoration-minimal"
		if("enhanced")
			decoration_class = "csetup-decoration-enhanced"
		// "standard" = baseline CSS без класса
	var/sidebar_class = (current_tab == SETTINGS_TAB ? " csetup-has-sidebar" : "")
	dat = list(modern_palette_css, "<div class='csetup-root [theme_class][button_shape_class ? " [button_shape_class]" : ""][decoration_class ? " [decoration_class]" : ""][sidebar_class]'>")

	// Compact theme picker (top-right): only for Modern UI themes.
	var/list/theme_order = list("modern_classic", "modern", "modern_purple", "modern_green", "modern_neutral")
	var/list/theme_titles = list(
		"modern_classic" = "Classic",
		"modern" = "Dark (Blue)",
		"modern_purple" = "Purple",
		"modern_green" = "Green",
		"modern_neutral" = "Neutral",
		"modern_custom" = "Custom"
	)
	var/list/theme_swatches = list(
		"modern_classic" = "#40628a",
		"modern" = "#4da3ff",
		"modern_purple" = "#c19bff",
		"modern_green" = "#8bffb1",
		"modern_neutral" = "#bfc2c7"
	)

	// Theme hub — icon buttons that never move
	dat += "<div class='theme-container'>"
	dat += "<div class='theme-hub'>"
	var/picker_active_cls = !modern_theme_picker_collapsed ? " active" : ""
	var/settings_active_cls = modern_theme_settings_open ? " active" : ""
	dat += "<a href='?_src_=prefs;preference=modern_theme_picker;action=toggle' class='theme-hub-btn[picker_active_cls]' title='Темы'>🎨</a>"
	dat += "<a href='?_src_=prefs;preference=modern_theme_settings;action=toggle' class='theme-hub-btn[settings_active_cls]' title='Настройки'>⚙</a>"
	dat += "</div>"
	// Theme picker panel
	if(!modern_theme_picker_collapsed)
		dat += "<div class='theme-picker-panel'>"
		dat += "<span class='theme-label'>Themes</span>"
		for(var/theme_id in theme_order)
			var/is_active = (charcreation_theme == theme_id)
			var/swatch_class = is_active ? "theme-swatch active" : "theme-swatch"
			var/swatch_color = theme_swatches[theme_id]
			var/swatch_title = theme_titles[theme_id]
			dat += "<a href='?_src_=prefs;preference=charcreation_set;theme=[theme_id]' class='[swatch_class]' style='background-color: [swatch_color];' title='[swatch_title]'></a>"
		var/custom_active = (charcreation_theme == "modern_custom")
		var/custom_class = custom_active ? "theme-swatch theme-swatch--custom active" : "theme-swatch theme-swatch--custom"
		var/custom_swatch_color = "#[modern_custom_bg_primary]"
		var/custom_title = modern_custom_enabled ? "Custom" : "Custom (Off)"
		dat += "<span class='theme-sep' aria-hidden='true'></span>"
		dat += "<span class='theme-custom-group'>"
		dat += "<span class='theme-label theme-label-custom'>Custom</span>"
		dat += "<a href='?_src_=prefs;preference=charcreation_set;theme=modern_custom' class='[custom_class]' style='background-color: [custom_swatch_color];' title='[custom_title]'></a>"
		dat += "<a href='?_src_=prefs;preference=modern_theme_editor;action=toggle' class='theme-gear' title='Custom theme settings (opens editor)'>⚙</a>"
		dat += "</span>"
		dat += "</div>"

	if(modern_theme_settings_open)
		dat += "<div class='theme-settings-panel'>"
		dat += "<div class='theme-settings-title'><b>Settings</b> <span class='theme-settings-hint'>(WIP)</span></div>"
		dat += "<div class='theme-settings-group'>"
		dat += "<div class='theme-settings-label'>Рамка</div>"
		dat += "<div class='theme-settings-options'>"
		var/shape_rect_cls = "theme-settings-pill is-rect[modern_button_shape == "rect" ? " linkOn" : ""]"
		var/shape_round_cls = "theme-settings-pill is-round[modern_button_shape == "round" ? " linkOn" : ""]"
		var/shape_soft_cls = "theme-settings-pill is-soft[modern_button_shape == "soft" ? " linkOn" : ""]"
		dat += "<a class='[shape_rect_cls]' href='?_src_=prefs;preference=modern_theme_settings;action=set_button_shape;shape=rect'>Квадрат</a>"
		dat += "<a class='[shape_round_cls]' href='?_src_=prefs;preference=modern_theme_settings;action=set_button_shape;shape=round'>Круг</a>"
		dat += "<a class='[shape_soft_cls]' href='?_src_=prefs;preference=modern_theme_settings;action=set_button_shape;shape=soft'>Мягкая</a>"
		dat += "</div></div>"
		dat += "<div class='theme-settings-group'>"
		dat += "<div class='theme-settings-label'>Язык</div>"
		dat += "<div class='theme-settings-options'>"
		dat += get_modern_language_selector(src)
		dat += "</div></div>"
		// UI Decoration Level
		dat += "<div class='theme-settings-group'>"
		var/decoration_title = get_modern_text("ui_decoration_title", src, "UI Decoration")
		var/decoration_hint = get_modern_text("ui_decoration_hint", src, "Effects performance")
		dat += "<div class='theme-settings-label'>[decoration_title] <span class='theme-settings-hint'>([decoration_hint])</span></div>"
		dat += "<div class='theme-settings-options'>"
		var/minimal_label = get_modern_text("ui_decoration_minimal", src, "Minimal")
		var/standard_label = get_modern_text("ui_decoration_standard", src, "Standard")
		var/enhanced_label = get_modern_text("ui_decoration_enhanced", src, "Enhanced")
		var/minimal_cls = "theme-settings-pill[ui_decoration_level == "minimal" ? " linkOn" : ""]"
		var/standard_cls = "theme-settings-pill[ui_decoration_level == "standard" ? " linkOn" : ""]"
		var/enhanced_cls = "theme-settings-pill[ui_decoration_level == "enhanced" ? " linkOn" : ""]"
		dat += "<a class='[minimal_cls]' href='?_src_=prefs;preference=modern_theme_settings;action=set_decoration_level;level=minimal'>[minimal_label]</a>"
		dat += "<a class='[standard_cls]' href='?_src_=prefs;preference=modern_theme_settings;action=set_decoration_level;level=standard'>[standard_label]</a>"
		dat += "<a class='[enhanced_cls]' href='?_src_=prefs;preference=modern_theme_settings;action=set_decoration_level;level=enhanced'>[enhanced_label]</a>"
		dat += "</div></div>"
		dat += "</div>"

	if(modern_custom_editor_open)
		dat += "<div class='theme-custom-editor'>"
		dat += "<div class='theme-custom-editor-title'><b>Custom theme</b> <span class='theme-custom-editor-hint'>(applies only to Custom)</span></div>"
		var/enabled_text = modern_custom_enabled ? "On" : "Off"
		dat += "<div class='theme-custom-editor-actions'>"
		dat += "<a href='?_src_=prefs;preference=modern_theme_editor;action=toggle' class='theme-action theme-action-close' title='Close editor'>Close</a> "
		dat += "<a href='?_src_=prefs;preference=modern_theme_editor;action=toggle_enabled' class='theme-action theme-action-enabled' title='Toggle custom palette'>Enabled: [enabled_text]</a> "
		dat += "<a href='?_src_=prefs;preference=modern_theme_editor;action=toggle_pattern' class='theme-action theme-action-pattern' title='Toggle subtle background stripes'>Pattern</a> "
		dat += "<a href='?_src_=prefs;preference=modern_theme_editor;action=reset' class='theme-action theme-action-reset' title='Reset custom palette to defaults'>Reset</a>"
		dat += "</div>"
		dat += "<table class='theme-custom-editor-table'>"
		var/list/rows = list(
			"bg_primary" = "Background",
			"bg_secondary" = "Panels",
			"border_color" = "Dividers",
			"text_primary" = "Text",
			"text_secondary" = "Muted text",
			"button_bg" = "Button",
			"button_hover" = "Button hover",
			"button_active" = "Button active",
			"button_text" = "Active text",
			"accent_color" = "Accent"
		)
		for(var/key in rows)
			var/label = rows[key]
			var/value_hex = ""
			switch(key)
				if("bg_primary") value_hex = modern_custom_bg_primary
				if("bg_secondary") value_hex = modern_custom_bg_secondary
				if("border_color") value_hex = modern_custom_border_color
				if("text_primary") value_hex = modern_custom_text_primary
				if("text_secondary") value_hex = modern_custom_text_secondary
				if("button_bg") value_hex = modern_custom_button_bg
				if("button_hover") value_hex = modern_custom_button_hover
				if("button_active") value_hex = modern_custom_button_active
				if("button_text") value_hex = modern_custom_button_text
				if("accent_color") value_hex = modern_custom_accent_color
			dat += "<tr><td class='k'>[label]</td><td class='v'><a class='colorbox' href='?_src_=prefs;preference=modern_custom_color;key=[key]' style='background-color: #[value_hex];' title='Pick color (opens BYOND color picker)'></a> #[value_hex]</td></tr>"
		dat += "</table>"
		dat += "</div>"
	dat += "</div>" // theme-container

	dat += "<center>"

	var/tab_class_settings = ""
	var/tab_class_preferences = ""
	var/tab_class_keybindings = ""
	if(current_tab == SETTINGS_TAB)
		tab_class_settings = "class='linkOn'"
	if(current_tab == PREFERENCES_TAB)
		tab_class_preferences = "class='linkOn'"
	if(current_tab == KEYBINDINGS_TAB)
		tab_class_keybindings = "class='linkOn'"

	var/main_tab_settings = T("tab_character_settings", "Character Settings")
	var/main_tab_preferences = T("tab_preferences", "Preferences")
	var/main_tab_keybindings = T("tab_keybindings", "Keybindings")

	dat += "<a href='?_src_=prefs;preference=tab;tab=[SETTINGS_TAB]' [tab_class_settings]>[main_tab_settings]</a>"
	dat += "<a href='?_src_=prefs;preference=tab;tab=[PREFERENCES_TAB]' [tab_class_preferences]>[main_tab_preferences]</a>"
	dat += "<a href='?_src_=prefs;preference=tab;tab=[KEYBINDINGS_TAB]' [tab_class_keybindings]>[main_tab_keybindings]</a>"

	if(!path)
		dat += "<div class='notice'>Please create an account to save your preferences</div>"

	dat += "</center>"

	dat += "<HR>"

	switch(current_tab)
		if(SETTINGS_TAB) // Character Settings
			dat += "<div class='csetup-settings-wrap'>"

			dat += "<div class='csetup-settings-sidebar'>"

			var/dir_s = (preview_direction == SOUTH)
			var/dir_n = (preview_direction == NORTH)
			var/dir_e = (preview_direction == EAST)
			var/dir_w = (preview_direction == WEST)
			var/dir_label_s = T("dir_south", "Front")
			var/dir_label_n = T("dir_north", "Back")
			var/dir_label_e = T("dir_east", "Right")
			var/dir_label_w = T("dir_west", "Left")
			dat += "<div class='csetup-dir-bar'>"
			dat += "<a class='csetup-dir-btn[dir_s ? " linkOn" : ""]' href='?_src_=prefs;preference=preview_direction;dir=[SOUTH]'>[dir_label_s]</a>"
			dat += "<a class='csetup-dir-btn[dir_n ? " linkOn" : ""]' href='?_src_=prefs;preference=preview_direction;dir=[NORTH]'>[dir_label_n]</a>"
			dat += "<a class='csetup-dir-btn[dir_e ? " linkOn" : ""]' href='?_src_=prefs;preference=preview_direction;dir=[EAST]'>[dir_label_e]</a>"
			dat += "<a class='csetup-dir-btn[dir_w ? " linkOn" : ""]' href='?_src_=prefs;preference=preview_direction;dir=[WEST]'>[dir_label_w]</a>"
			dat += "</div>"
			// Preview mode buttons
			var/preview_job_label    = T("preview_job",          "On job")
			var/preview_loadout_label = T("preview_loadout",     "Loadout")
			var/preview_naked_label   = T("preview_naked",       "Naked")
			var/preview_naked_aroused_label = T("preview_naked_aroused", "Naked+")
			dat += "<div class='csetup-preview-bar'>"
			dat += "<a class='csetup-preview-btn[preview_pref == PREVIEW_PREF_JOB ? " linkOn" : ""]' href='?_src_=prefs;preference=character_preview;tab=[PREVIEW_PREF_JOB]'>[preview_job_label]</a>"
			dat += "<a class='csetup-preview-btn[preview_pref == PREVIEW_PREF_LOADOUT ? " linkOn" : ""]' href='?_src_=prefs;preference=character_preview;tab=[PREVIEW_PREF_LOADOUT]'>[preview_loadout_label]</a>"
			dat += "<a class='csetup-preview-btn[preview_pref == PREVIEW_PREF_NAKED ? " linkOn" : ""]' href='?_src_=prefs;preference=character_preview;tab=[PREVIEW_PREF_NAKED]'>[preview_naked_label]</a>"
			dat += "<a class='csetup-preview-btn[preview_pref == PREVIEW_PREF_NAKED_AROUSED ? " linkOn" : ""]' href='?_src_=prefs;preference=character_preview;tab=[PREVIEW_PREF_NAKED_AROUSED]'>[preview_naked_aroused_label]</a>"
			dat += "</div>"

			// ── Slot panel ──
			if(path)
				var/savefile/S = new /savefile(path)
				if(S)
					var/name
					var/empty_slot_label = T("empty_slot_label", "Character")
					var/current_slot_name = ""
					S.cd = "/character[default_slot]"
					S["real_name"] >> current_slot_name
					if(!current_slot_name)
						current_slot_name = "[empty_slot_label][default_slot]"
					var/delete_slot_label = T("delete_slot_label", "Delete current slot")
					var/toggle_title = collapse_empty_character_slots ? T("show_empty_slots", "Show empty slots") : T("hide_empty_slots", "Hide empty slots")
					var/toggle_symbol = collapse_empty_character_slots ? "+" : "–"
					dat += "<div class='csetup-slot-header'>"
					dat += "<span class='csetup-slot-current-label'>[current_slot_name]</span>"
					dat += "<span class='csetup-slot-controls'>"
					if(max_save_slots > 4)
						dat += "<a class='csetup-slot-ctrl-btn' href='?_src_=prefs;preference=character_slots;action=toggle_empty' title='[toggle_title]'>[toggle_symbol]</a>"
					dat += "<a class='csetup-slot-ctrl-btn csetup-slot-delete' href='?_src_=prefs;preference=character_slots;action=delete_slot;slot=[default_slot]' title='[delete_slot_label]'>✕</a>"
					dat += "</span>"
					dat += "</div>"
					dat += "<div class='csetup-slot-panel'>"
					for(var/i=1, i<=max_save_slots, i++)
						name = null
						S.cd = "/character[i]"
						S["real_name"] >> name
						var/is_empty_slot = !name
						if(collapse_empty_character_slots && is_empty_slot && i != default_slot)
							continue
						if(!name)
							name = "[empty_slot_label][i]"
						var/slot_cls = "csetup-slot-btn"
						if(i == default_slot)
							slot_cls += " linkOn"
						if(is_empty_slot)
							slot_cls += " csetup-slot-empty"
						dat += "<a class='[slot_cls]' href='?_src_=prefs;preference=changeslot;num=[i];'>[name]</a>"
					dat += "</div>"

				// Character management
				dat += "<div class='csetup-mgmt-panel'>"
				var/local_storage_label = T("local_storage", "Local storage")
				var/empty_label = T("empty_label", "Empty")
				var/export_slot_label = T("export_slot", "Export slot")
				var/import_slot_label = T("import_slot", "Import")
				var/delete_local_label = T("delete_local", "Delete local")
				var/offer_slot_label = T("offer_slot", "Offer slot")
				var/cancel_offer_label = T("cancel_offer", "Cancel offer")
				var/retrieve_offered_label = T("retrieve_offered", "Retrieve offered")
				var/redemption_code_label = T("redemption_code", "Redemption code")
				var/offer_auto_cancel_label = T("offer_auto_cancel", "The offer will automatically be cancelled if there is an error, or if someone takes it")
				var/file = user.client.Import()
				var/savefile/client_file
				var/savefile_name
				if(file)
					client_file = new(file)
					if(istype(client_file, /savefile))
						if(!client_file["deleted"] || savefile_needs_update(client_file) != -2)
							client_file["real_name"] >> savefile_name
				dat += "<div class='csetup-mgmt-local'>[local_storage_label]: <b>[savefile_name ? savefile_name : empty_label]</b></div>"
				dat += "<div class='csetup-mgmt-btns'>"
				dat += "<a href='?_src_=prefs;preference=export_slot'>[export_slot_label]</a>"
				var/import_attr = "class='linkOff csetup-mgmt-btn'"
				if(savefile_name)
					import_attr = "class='csetup-mgmt-btn' href='?_src_=prefs;preference=import_slot'"
				var/offer_style = ""
				var/offer_text = offer_slot_label
				if(offer)
					offer_style = "class='csetup-mgmt-btn csetup-mgmt-danger'"
					offer_text = cancel_offer_label
				else
					offer_style = "class='csetup-mgmt-btn'"
				dat += "<a [import_attr]>[import_slot_label]</a>"
				dat += "<a class='csetup-mgmt-btn csetup-mgmt-danger' href='?_src_=prefs;preference=delete_local_copy'>[delete_local_label]</a>"
				dat += "<a [offer_style] href='?_src_=prefs;preference=give_slot'>[offer_text]</a>"
				dat += "<a class='csetup-mgmt-btn' href='?_src_=prefs;preference=retrieve_slot'>[retrieve_offered_label]</a>"
				dat += "</div>"
				if(offer)
					dat += "<div class='csetup-mgmt-code'>[redemption_code_label]: <b>[offer.redemption_code]</b></div>"
					dat += "<div class='csetup-mgmt-hint'>[offer_auto_cancel_label]</div>"
				dat += "</div>" // end csetup-mgmt-panel

			dat += "</div>" // end csetup-settings-sidebar

			dat += "<div class='csetup-settings-content'>"

			dat += "<center>"
			var/char_tab_class_general = ""
			var/char_tab_class_background = ""
			var/char_tab_class_appearance = ""
			var/char_tab_class_markings = ""
			var/char_tab_class_speech = ""
			var/char_tab_class_loadout = ""
			var/char_tab_class_quirks = ""
			if(character_settings_tab == GENERAL_CHAR_TAB)
				char_tab_class_general = "class='linkOn'"
			if(character_settings_tab == BACKGROUND_CHAR_TAB)
				char_tab_class_background = "class='linkOn'"
			if(character_settings_tab == APPEARANCE_CHAR_TAB)
				char_tab_class_appearance = "class='linkOn'"
			if(character_settings_tab == MARKINGS_CHAR_TAB)
				char_tab_class_markings = "class='linkOn'"
			if(character_settings_tab == SPEECH_CHAR_TAB)
				char_tab_class_speech = "class='linkOn'"
			if(character_settings_tab == LOADOUT_CHAR_TAB)
				char_tab_class_loadout = "class='linkOn'"
			if(character_settings_tab == QUIRKS_CHAR_TAB)
				char_tab_class_quirks = "class='linkOn'"

			var/char_tab_general = T("char_tab_general", "General")
			var/char_tab_background = T("char_tab_background", "Background")
			var/char_tab_appearance = T("char_tab_appearance", "Appearance")
			var/char_tab_markings = T("char_tab_markings", "Markings")
			var/char_tab_speech = T("char_tab_speech", "Speech")
			var/char_tab_loadout = T("char_tab_loadout", "Loadout")
			var/char_tab_quirks = T("char_tab_quirks", "Quirks")

			dat += "<a href='?_src_=prefs;preference=character_tab;tab=[GENERAL_CHAR_TAB]' [char_tab_class_general]>[char_tab_general]</a>"
			dat += "<a href='?_src_=prefs;preference=character_tab;tab=[BACKGROUND_CHAR_TAB]' [char_tab_class_background]>[char_tab_background]</a>"
			dat += "<a href='?_src_=prefs;preference=character_tab;tab=[APPEARANCE_CHAR_TAB]' [char_tab_class_appearance]>[char_tab_appearance]</a>"
			dat += "<a href='?_src_=prefs;preference=character_tab;tab=[MARKINGS_CHAR_TAB]' [char_tab_class_markings]>[char_tab_markings]</a>"
			dat += "<a href='?_src_=prefs;preference=character_tab;tab=[SPEECH_CHAR_TAB]' [char_tab_class_speech]>[char_tab_speech]</a>"
			dat += "<a href='?_src_=prefs;preference=character_tab;tab=[LOADOUT_CHAR_TAB]' [char_tab_class_loadout]>[char_tab_loadout]</a>" //If you change the index of this tab, change all the logic regarding tab
			if(CONFIG_GET(flag/roundstart_traits))
				dat += "<a href='?_src_=prefs;preference=character_tab;tab=[QUIRKS_CHAR_TAB]' [char_tab_class_quirks]>[char_tab_quirks]</a>"
			dat += "</center>"

			dat += "<HR>"
			// Declare common labels used across multiple tabs to avoid duplicate variable errors
			var/enabled_label = T("enabled", "Enabled")
			var/disabled_label = T("disabled", "Disabled")
			var/change_label = T("change", "Change")
			var/yes_label = T("yes", "Yes")
			var/no_label = T("no", "No")
			var/none_label = T("none", "None")

			if(character_settings_tab == LOADOUT_CHAR_TAB)
				gear_points = CONFIG_GET(number/initial_gear_points) + (IS_CKEY_DONATOR_GROUP(user.ckey, DONATOR_GROUP_TIER_1) ? CONFIG_GET(number/subscriber_extra_gear_points) : 0) + (IS_CKEY_DONATOR_GROUP(user.ckey, DONATOR_GROUP_TIER_2) ? CONFIG_GET(number/sponsor_extra_gear_points) : 0)
				var/loadout_points_label = T("loadout_points", "loadout point")
				var/loadout_points_remaining_label = T("loadout_points_remaining", "remaining")
				var/clear_loadout_label = T("clear_loadout", "Clear Loadout")
				var/list/chosen_gear = loadout_data["SAVE_[loadout_slot]"]
				if(islist(chosen_gear))
					loadout_errors = 0
					for(var/loadout_item in chosen_gear)
						var/loadout_item_path = loadout_item[LOADOUT_ITEM]
						if(loadout_item_path)
							var/datum/gear/loadout_gear = text2path(loadout_item_path)
							if(loadout_gear)
								gear_points -= initial(loadout_gear.cost)
							else
								loadout_errors++
						else
							loadout_errors++
				else
					chosen_gear = list()
				dat += "<center><b><font color='[gear_points == 0 ? "#E62100" : "#CCDDFF"]'>[gear_points]</font> [loadout_points_label] [loadout_points_remaining_label]</b></center>"
				var/loadout_enabled_label = T("loadout_enabled_label", "Replace clothing with loadout")
				var/loadout_toggle_color = loadout_enabled ? "#6ABF6A" : "#E62100"
				var/loadout_toggle_text = loadout_enabled ? (T("enabled", "ON")) : (T("disabled", "OFF"))
				dat += "<center>[loadout_enabled_label]: <a href='?_src_=prefs;preference=gear;toggle_loadout_enabled=1'><font color='[loadout_toggle_color]'><b>[loadout_toggle_text]</b></font></a></center>"
				dat += "<center><a href='?_src_=prefs;preference=gear;clear_loadout=1'>[clear_loadout_label]</a></center>"
				dat += "<HR>"
			switch(character_settings_tab)
				//General
				if(GENERAL_CHAR_TAB)
					var/occupation_choices_label = T("occupation_choices", "Occupation Choices")
					var/set_occupation_prefs_label = T("set_occupation_prefs", "Set Occupation Preferences")
					var/quirk_balance_remaining_label = T("quirk_balance_remaining", "Quirk balance remaining:")
					var/current_label = T("current", "Current:")
					var/open_quirks_tab_label = T("open_quirks_tab", "Open Quirks Tab")
					var/identity_label = T("identity", "Identity")
					var/you_are_banned_label = T("you_are_banned", "You are forbidden to use custom names and appearance. You can continue to set up your characters, but you will be randomized upon joining the game.")
					var/default_designation_label = T("default_designation", "Default designation")
					var/name_label = T("name_label", "Name")
					var/random_name_title_label = T("random_name_title", "Random name")
					var/hide_ckey_label = T("hide_ckey", "Hide ckey")
					var/be_nameless_label = T("be_nameless", "Be nameless")
					var/always_random_name_label = T("always_random_name", "Always random name")
					var/hardsuit_with_tail_label = T("hardsuit_with_tail", "Hardsuit with tail")
					var/age_label = T("age_label", "Age")
					var/custom_blood_color_label = T("custom_blood_color", "Custom blood color")
					var/blood_color_label = T("blood_color", "Blood color")
					var/special_names_label = T("special_names", "Special names")
					var/custom_job_preferences_label = T("custom_job_preferences", "Custom job preferences")
					var/preferred_security_dept_label = T("preferred_security_dept", "Preferred Security Department")
					var/preferred_ai_core_label = T("preferred_ai_core", "Preferred AI Core Display")
					var/pda_preferences_label = T("pda_preferences", "PDA preferences")
					var/pda_color_label = T("pda_color", "PDA color")
					var/pda_style_label = T("pda_style", "PDA style")
					var/pda_reskin_label = T("pda_reskin", "PDA reskin")
					var/pda_ringtone_label = T("pda_ringtone", "PDA ringtone")
					var/silicon_preferences_label = T("silicon_preferences", "Silicon preferences")
					var/server_has_disabled_laws_label = T("server_has_disabled_laws", "The server has disabled choosing your own laws, you can still choose and save, but it won't do anything in-game.")
					var/starting_lawset_label = T("starting_lawset", "Starting lawset")
					var/server_default_label = T("server_default", "Server default")
					var/lawset_not_found_label = T("lawset_not_found", "I was unable to find the laws for your lawset, sorry  <font style='translate: rotate(90deg)'>:(</font>")
					dat += "<center><h2>[occupation_choices_label]</h2>"
					dat += "<a href='?_src_=prefs;preference=job;task=menu'>[set_occupation_prefs_label]</a><br></center>"
					if(CONFIG_GET(flag/roundstart_traits))
						var/current_quirks_display = english_list(all_quirks, "None")
						//dat += "<center><h2>Quirks</h2></center>"
						// UI tweak
						dat += "<div class='notice csetup-quirks-summary'>"
						dat += "<div class='csetup-quirks-summary-title' style='color: white;'><b>[quirk_balance_remaining_label]</b> " + "[GetQuirkBalance(user)]" + "</div>"
						dat += "<div class='csetup-quirks-summary-current'><b>[current_label]</b> " + current_quirks_display + "</div>"
						dat += "<div class='csetup-quirks-summary-actions'><a href='?_src_=prefs;preference=character_tab;tab=[QUIRKS_CHAR_TAB]'>[open_quirks_tab_label]</a></div>"
						dat += "</div>"
					dat += "<br><center><h2>[identity_label]</h2></center>"
					dat += "<table width='100%'><tr><td width='30%' valign='top'>"
					if(jobban_isbanned(user, "appearance"))
						dat += "<b>[you_are_banned_label]</b><br>"

					dat += "<b>[nameless ? default_designation_label : name_label]:</b><br>"
					dat += "<div class='csetup-name-row'><a href='?_src_=prefs;preference=name;task=input'>[real_name]</a><a class='csetup-dice-btn' href='?_src_=prefs;preference=name;task=random' title='[random_name_title_label]' aria-label='[random_name_title_label]'>&#127922;</a></div><BR>"
					dat += "<a href='?_src_=prefs;preference=hide_ckey;task=input'><b>[hide_ckey_label]: [hide_ckey ? enabled_label : disabled_label]</b></a><BR>" // UI tweak
					dat += "<a style='display:block;width:150px' href='?_src_=prefs;preference=nameless'>[be_nameless_label]: [nameless ? yes_label : no_label]</a><BR>"
					dat += "<b>[always_random_name_label]:</b><a style='display:block;width:30px' href='?_src_=prefs;preference=name'>[be_random_name ? yes_label : no_label]</a><BR>"
					dat += "<b>[hardsuit_with_tail_label]:</b><a style='display:block;width:30px' href='?_src_=prefs;preference=hardsuit_with_tail'>[features["hardsuit_with_tail"] == TRUE ? yes_label : no_label]</a><BR>"

					dat += "<b>[age_label]:</b> <a style='display:block;width:30px' href='?_src_=prefs;preference=age;task=input'>[age]</a><BR>"
					dat += "<b>[custom_blood_color_label]:</b>"
					dat += "<a style='display:block;width:150px' href='?_src_=prefs;preference=toggle_custom_blood_color;task=input'>[custom_blood_color ? enabled_label : disabled_label]</a><BR>"
					if(custom_blood_color)
						dat += "<b>[blood_color_label]:</b> <span style='border:1px solid #161616; background-color: [blood_color];'><font color='[color_hex2num(blood_color) < 200 ? "FFFFFF" : "000000"]'>[blood_color]</font></span> <a href='?_src_=prefs;preference=blood_color;task=input'>[change_label]</a><BR>"
					dat += "</td>"

					dat += "<td valign='top'>"
					dat += "<b>[special_names_label]:</b><BR>"
					var/old_group
					for(var/custom_name_id in GLOB.preferences_custom_names)
						var/namedata = GLOB.preferences_custom_names[custom_name_id]
						if(!old_group)
							old_group = namedata["group"]
						else if(old_group != namedata["group"])
							old_group = namedata["group"]
							dat += "<br>"
						dat += "<a href ='?_src_=prefs;preference=[custom_name_id];task=input'><b>[namedata["pref_name"]]:</b> [custom_names[custom_name_id]]</a> "
					dat += "<br><br>"

					dat += "<b>[custom_job_preferences_label]:</b><BR>"
					dat += "<a href='?_src_=prefs;preference=sec_dept;task=input'><b>[preferred_security_dept_label]:</b> [prefered_security_department]</a><BR>" // UI tweak
					dat += "<a href='?_src_=prefs;preference=ai_core_icon;task=input'><b>[preferred_ai_core_label]:</b> [preferred_ai_core_display]</a><br>"
					var/ai_core_icon_state
					if(preferred_ai_core_display == "Random")
						ai_core_icon_state = "ai-random"
					else
						ai_core_icon_state = resolve_ai_icon(preferred_ai_core_display, TRUE)
					var/icon/ai_core_preview_icon = icon('icons/mob/ai.dmi', ai_core_icon_state, SOUTH, 1, FALSE)
					var/ai_core_preview_html = icon2base64html(ai_core_preview_icon)
					if(!ai_core_preview_html)
						ai_core_preview_html = ""
					dat += "<div class='csetup-ai-core-preview'>" + ai_core_preview_html + "</div>"
					dat += "</td>"

					dat += "<td valign='top'>"
					dat += "<h2>[pda_preferences_label]</h2>"
					dat += "<b>[pda_color_label]:</b> <span style='border:1px solid #161616; background-color: [pda_color];'><font color='[color_hex2num(pda_color) < 200 ? "FFFFFF" : "000000"]'>[pda_color]</font></span> <a href='?_src_=prefs;preference=pda_color;task=input'>[change_label]</a><BR>"
					dat += "<b>[pda_style_label]:</b> <a href='?_src_=prefs;task=input;preference=pda_style'>[pda_style]</a><br>"
					dat += "<b>[pda_reskin_label]:</b> <a href='?_src_=prefs;task=input;preference=pda_skin'>[pda_skin]</a><br>"
					dat += "<b>[pda_ringtone_label]:</b> <a href='?_src_=prefs;task=input;preference=pda_ringtone'>[pda_ringtone]</a><br>"

					dat += "<h2>[silicon_preferences_label]</h2>"
					if(!CONFIG_GET(flag/allow_silicon_choosing_laws))
						dat += "<i>[server_has_disabled_laws_label]</i><br>"
					dat += "<b>[starting_lawset_label]:</b> <a href='?_src_=prefs;task=input;preference=silicon_lawset'>[silicon_lawset ? silicon_lawset : server_default_label]</a><br>"

					if(silicon_lawset)
						var/list/config_laws = CONFIG_GET(keyed_list/choosable_laws)
						var/datum/ai_laws/law_datum = GLOB.all_law_datums[config_laws[silicon_lawset]]
						if(law_datum)
							dat += "<i>[law_datum]</i><br>"
							dat += english_list(law_datum.get_law_list(TRUE),
								lawset_not_found_label,
								"<br>", "<br>")

					dat += "</td></tr></table>"
				//Character quirks (Modern only)
				if(QUIRKS_CHAR_TAB)
					if(CONFIG_GET(flag/roundstart_traits))
						dat += GetInlineQuirksMarkup(user)
					else
						var/quirks_disabled_label = T("quirks_disabled", "Quirks are disabled on this server.")
						dat += "<center><i>[quirks_disabled_label]</i></center>"
				//Character background
				if(BACKGROUND_CHAR_TAB)
					var/flavor_text_label = T("flavor_text_header", "Flavor Text")
					var/set_flavor_text_label = T("set_flavor_text", "Set Examine Text")
					var/naked_flavor_text_label = T("naked_flavor_text", "Naked Flavor Text")
					var/set_naked_flavor_text_label = T("set_naked_flavor_text", "Set Naked Examine Text")
					var/custom_deathgasp_label = T("custom_deathgasp", "Custom Deathgasp")
					var/set_custom_deathgasp_label = T("set_custom_deathgasp", "Set Custom Deathgasp")
					var/custom_deathsound_label = T("custom_deathsound", "Custom Deathgasp Sound")
					var/set_custom_deathsound_label = T("set_custom_deathsound", "Set Custom Deathsound")
					var/preview_deathsound_label = T("preview_deathsound", "Preview Deathsound")
					var/silicon_flavor_text_label = T("silicon_flavor_text", "Silicon Flavor Text")
					var/set_silicon_flavor_text_label = T("set_silicon_flavor_text", "Set Silicon Examine Text")
					var/custom_species_lore_label = T("custom_species_lore", "Custom Species Lore")
					var/set_custom_species_lore_label = T("set_custom_species_lore", "Set Custom Species Lore Text")
					var/ooc_notes_label = T("ooc_notes", "OOC notes")
					var/set_ooc_notes_label = T("set_ooc_notes", "Set OOC notes")
					var/records_label = T("records", "Records")
					var/security_records_label = T("security_records", "Security Records")
					var/medical_records_label = T("medical_records", "Medical Records")
					var/headshots_label = T("headshots", "Headshots")
					var/set_headshot_1_label = T("set_headshot_1", "Set Headshot 1 Image")
					var/set_headshot_2_label = T("set_headshot_2", "Set Headshot 2 Image")
					var/set_headshot_3_label = T("set_headshot_3", "Set Headshot 3 Image")
					var/naked_headshots_label = T("naked_headshots", "Naked (NSFW) Headshots")
					var/set_naked_headshot_1_label = T("set_naked_headshot_1", "Set Headshot 1 Image")
					var/set_naked_headshot_2_label = T("set_naked_headshot_2", "Set Headshot 2 Image")
					var/set_naked_headshot_3_label = T("set_naked_headshot_3", "Set Headshot 3 Image")
					dat += "<table width='100%'><tr><td width='30%' valign='top'>"

					dat += "<h2>[flavor_text_label]</h2>"
					dat += "<a href='?_src_=prefs;preference=flavor_text;task=input'><b>[set_flavor_text_label]</b></a><br>"
					if(length(features["flavor_text"]) <= MAX_FLAVOR_PREVIEW_LEN)
						if(!length(features["flavor_text"]))
							dat += "\[...\]"
						else
							dat += "[features["flavor_text"]]"
					else
						dat += "[TextPreview(features["flavor_text"])]..."
					//SPLURT edit - naked flavor text
					dat += "<h2>[naked_flavor_text_label]</h2>"
					dat += "<a href='?_src_=prefs;preference=naked_flavor_text;task=input'><b>[set_naked_flavor_text_label]</b></a><br>"
					if(length(features["naked_flavor_text"]) <= MAX_FLAVOR_PREVIEW_LEN)
						if(!length(features["naked_flavor_text"]))
							dat += "\[...\]<BR>"
						else
							dat += "[html_encode(features["naked_flavor_text"])]<BR>"
					else
						dat += "[TextPreview(html_encode(features["naked_flavor_text"]))]...<BR>"
					//SPLURT edit end
					// BLUEMOON ADD START - пользовательский эмоут смерти
					dat += "<h2>[custom_deathgasp_label]</h2>"
					dat += "<a href='?_src_=prefs;preference=custom_deathgasp;task=input'><b>[set_custom_deathgasp_label]</b></a><br>"
					if(length(features["custom_deathgasp"]) <= MAX_FLAVOR_PREVIEW_LEN)
						if(!length(features["custom_deathgasp"]))
							dat += "\[...\]<BR>"
						else
							dat += "[html_encode(features["custom_deathgasp"])]<BR>"
					else
						dat += "[TextPreview(html_encode(features["custom_deathgasp"]))]...<BR>"
					dat += "<h2>[custom_deathsound_label]</h2>"
					dat += "<a href='?_src_=prefs;preference=custom_deathsound;task=input'><b>[set_custom_deathsound_label]</b></a><br>"
					dat += "[features["custom_deathsound"]]<BR>"
					dat += "<BR><a href='?_src_=prefs;preference=deathsoundpreview;task=input''>[preview_deathsound_label]</a><BR>"
					// BLUEMOON ADD END
					dat += "<h2>[silicon_flavor_text_label]</h2>"
					dat += "<a href='?_src_=prefs;preference=silicon_flavor_text;task=input'><b>[set_silicon_flavor_text_label]</b></a><br>"
					if(length(features["silicon_flavor_text"]) <= MAX_FLAVOR_PREVIEW_LEN)
						if(!length(features["silicon_flavor_text"]))
							dat += "\[...\]"
						else
							dat += "[features["silicon_flavor_text"]]"
					else
						dat += "[TextPreview(features["silicon_flavor_text"])]...<BR>"
					//SPLURT EDIT
					// BLUEMOON REMOVE
					/*
					dat += "<h2>Headshot Image</h2>"
					dat += "<a href='?_src_=prefs;preference=headshot'><b>Set Headshot Image</b></a><br>"
					if(features["headshot_link"])
						dat += "<img src='[features["headshot_link"]]' width='160px' height='120px'>"
					dat += "<br><br>"
					*/
					// BLUEMOON REMOVE END
					//SPLURT EDIT END
					dat += "</td>"

					dat += "<td width='35%' valign='top'>"
					dat += "<h2>[records_label]</h2>"
					dat += "<a href='?_src_=prefs;preference=security_records;task=input'><b>[security_records_label]</b></a><br>"
					if(length_char(security_records) <= 40)
						if(!length(security_records))
							dat += "\[...\]"
						else
							dat += "[security_records]"
					else
						dat += "[TextPreview(security_records)]..."

					dat += "<br><a href='?_src_=prefs;preference=medical_records;task=input'><b>[medical_records_label]</b></a><br>"
					if(length_char(medical_records) <= 40)
						if(!length(medical_records))
							dat += "\[...\]"
						else
							dat += "[medical_records]"
					else
						dat += "[TextPreview(medical_records)]..."

					dat += "<br><h2>[custom_species_lore_label]</h2>"
					dat += "<a href='?_src_=prefs;preference=custom_species_lore;task=input'><b>[set_custom_species_lore_label]</b></a><br>"
					if(length(features["custom_species_lore"]) <= MAX_FLAVOR_PREVIEW_LEN)
						if(!length(features["custom_species_lore"]))
							dat += "\[...\]<BR>"
						else
							dat += "[features["custom_species_lore"]]<BR>"
					else
						dat += "[TextPreview(features["custom_species_lore"])]...<BR>"
					dat += "<h2>[ooc_notes_label]</h2>"
					dat += "<a href='?_src_=prefs;preference=ooc_notes;task=input'><b>[set_ooc_notes_label]</b></a><br>"
					var/ooc_notes_len = length(features["ooc_notes"])
					if(ooc_notes_len <= MAX_FLAVOR_PREVIEW_LEN)
						if(!ooc_notes_len)
							dat += "\[...\]"
						else
							dat += "[features["ooc_notes"]]"
					else
						dat += "[TextPreview(features["ooc_notes"])]..."

					dat += "</td>"
					dat += "<td width='35%' valign='top'>"

					// BLUEMOON ADD
					dat += "<h2>[headshots_label]</h2>"

					dat += "<a href='?_src_=prefs;preference=headshot'><b>[set_headshot_1_label]</b></a><br>"
					if(features["headshot_link"])
						dat += "<img src='[features["headshot_link"]]' style='border: 1px solid black' width='140px' height='140px'>"
					dat += "<br><br>"

					dat += "<a href='?_src_=prefs;preference=headshot1'><b>[set_headshot_2_label]</b></a><br>"
					if(features["headshot_link1"])
						dat += "<img src='[features["headshot_link1"]]' style='border: 1px solid black' width='140px' height='140px'>"
					dat += "<br><br>"

					dat += "<a href='?_src_=prefs;preference=headshot2'><b>[set_headshot_3_label]</b></a><br>"
					if(features["headshot_link2"])
						dat += "<img src='[features["headshot_link2"]]' style='border: 1px solid black' width='140px' height='140px'>"
					//dat += "<br><br>"

					dat += "<h2>[naked_headshots_label]</h2>"

					dat += "<a href='?_src_=prefs;preference=headshot_naked'><b>[set_naked_headshot_1_label]</b></a><br>"
					if(features["headshot_naked_link"])
						dat += "<img src='[features["headshot_naked_link"]]' style='border: 1px solid black' width='140px' height='140px'>"
					dat += "<br><br>"

					dat += "<a href='?_src_=prefs;preference=headshot_naked1'><b>[set_naked_headshot_2_label]</b></a><br>"
					if(features["headshot_naked_link1"])
						dat += "<img src='[features["headshot_naked_link1"]]' style='border: 1px solid black' width='140px' height='140px'>"
					dat += "<br><br>"

					dat += "<a href='?_src_=prefs;preference=headshot_naked2'><b>[set_naked_headshot_3_label]</b></a><br>"
					if(features["headshot_naked_link2"])
						dat += "<img src='[features["headshot_naked_link2"]]' style='border: 1px solid black' width='140px' height='140px'>"
					dat += "<br><br>"
					// BLUEMOON ADD END
					dat += "</td></tr></table>"
				//Character Appearance
				if(APPEARANCE_CHAR_TAB)
					var/body_label = T("appearance_body", "Body")
					var/gender_label = T("gender", "Gender")
					var/male_label = T("male", "Male")
					var/female_label = T("female", "Female")
					var/non_binary_label = T("non_binary", "Non-binary")
					var/object_label = T("object", "Object")
					var/body_model_label = T("body_model", "Body Model")
					var/body_model_masc_label = T("body_model_masc", "Masculine")
					var/body_model_fem_label = T("body_model_fem", "Feminine")
					var/advanced_colors_hint = T("advanced_colors_hint", "Enables advanced coloring of individual body parts (if supported by species).")
					var/mismatched_parts_hint = T("mismatched_parts_hint", "Show parts/markings that do not match the current species.")
					var/advanced_colors_label = T("advanced_colors", "Advanced colors")
					var/mismatched_parts_label = T("mismatched_parts", "Mismatched parts")
					var/limb_modification_label = T("limb_modification", "Limb Modification")
					var/modify_limbs_label = T("modify_limbs", "Modify Limbs")
					var/species_label = T("species_label", "Species")
					var/custom_species_name_label = T("custom_species_name", "Custom Species Name")
					var/random_body_label = T("random_body", "Random Body")
					var/randomize_label = T("randomize", "Randomize!")
					var/always_random_body_label = T("always_random_body", "Always Random Body")
					var/cycle_background_label = T("cycle_background", "Cycle background")
					var/skin_tone_label = T("skin_tone", "Skin Tone")
					var/custom_label = T("custom_label", "custom")
					var/genitals_use_skintone_label = T("genitals_use_skintone", "Genitals use skintone")
					var/body_colors_label = T("body_colors", "Body Colors")
					var/primary_color_label = T("primary_color", "Primary Color")
					var/secondary_color_label = T("secondary_color", "Secondary Color")
					var/tertiary_color_label = T("tertiary_color", "Tertiary Color")
					var/body_size_label = T("body_size", "Body Size")
					var/normalized_size_label = T("normalized_size", "Normalized Size")
					var/scaled_appearance_label = T("scaled_appearance", "Scaled Appearance")
					var/fuzzy_label = T("fuzzy", "Fuzzy")
					var/sharp_label = T("sharp", "Sharp")
					var/weight_label = T("weight", "Weight")
					var/eye_type_label = T("eye_type", "Eye Type")
					var/heterochromia_label = T("heterochromia", "Heterochromia")
					var/heterochromia_hint = T("heterochromia_hint", "Eyes with special heterochromia: wide, big, bigcyclops, skrell, third, thirdbig.")
					var/eye_color_label = T("eye_color", "Eye Color")
					var/left_eye_color_label = T("left_eye_color", "Left Eye Color")
					var/right_eye_color_label = T("right_eye_color", "Right Eye Color")

					// ── Appearance sub-tab bar ────────────────────────────────
					var/app_sub_body_label     = T("app_sub_body",     "Body")
					var/app_sub_hair_label     = T("app_sub_hair",     "Hair")
					var/app_sub_mutparts_label = T("app_sub_mutparts", "Mutant Parts")
					var/app_sub_intimacy_label = T("app_sub_intimacy", "Intimacy")
					var/asub_body_cls     = appearance_subtab == APPEARANCE_SUBTAB_BODY     ? "class='linkOn'" : ""
					var/asub_hair_cls     = appearance_subtab == APPEARANCE_SUBTAB_HAIR_EYES ? "class='linkOn'" : ""
					var/asub_mutparts_cls = appearance_subtab == APPEARANCE_SUBTAB_MUTPARTS ? "class='linkOn'" : ""
					var/asub_intimacy_cls = appearance_subtab == APPEARANCE_SUBTAB_INTIMACY ? "class='linkOn'" : ""
					dat += "<center class='csetup-app-subtabs'>"
					dat += "<a href='?_src_=prefs;preference=appearance_subtab;tab=[APPEARANCE_SUBTAB_BODY]' [asub_body_cls]>[app_sub_body_label]</a>"
					dat += "<a href='?_src_=prefs;preference=appearance_subtab;tab=[APPEARANCE_SUBTAB_HAIR_EYES]' [asub_hair_cls]>[app_sub_hair_label]</a>"
					dat += "<a href='?_src_=prefs;preference=appearance_subtab;tab=[APPEARANCE_SUBTAB_MUTPARTS]' [asub_mutparts_cls]>[app_sub_mutparts_label]</a>"
					dat += "<a href='?_src_=prefs;preference=appearance_subtab;tab=[APPEARANCE_SUBTAB_INTIMACY]' [asub_intimacy_cls]>[app_sub_intimacy_label]</a>"
					dat += "</center>"
					dat += "<HR>"

					if(appearance_subtab == APPEARANCE_SUBTAB_BODY)
						dat += "<table><tr><td width='20%' height='300px' valign='top'>"

						dat += "<h2>[body_label]</h2>"
						dat += "<b>[gender_label]:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=gender;task=input'>[gender == MALE ? male_label : (gender == FEMALE ? female_label : (gender == PLURAL ? non_binary_label : object_label))]</a><BR>"
						if(pref_species.sexes)
							dat += "<b>[body_model_label]:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=body_model'>[features["body_model"] == MALE ? body_model_masc_label : body_model_fem_label]</a><BR>"
						dat += "<b><span title='[advanced_colors_hint]'>[advanced_colors_label]:</span></b><a style='display:block;width:100px' href='?_src_=prefs;preference=color_scheme;task=input'>[(features["color_scheme"] == ADVANCED_CHARACTER_COLORING) ? enabled_label : disabled_label]</a><BR>"
						dat += "<b><span title='[mismatched_parts_hint]'>[mismatched_parts_label]:</span></b><a style='display:block;width:100px' href='?_src_=prefs;preference=mismatched_markings;task=input'>[show_mismatched_markings ? enabled_label : disabled_label]</a><BR>"
						dat += "<b>[limb_modification_label]:</b><BR>"
						dat += "<a href='?_src_=prefs;preference=modify_limbs;task=input'>[modify_limbs_label]</a><BR>"
						for(var/modification in modified_limbs)
							if(modified_limbs[modification][1] == LOADOUT_LIMB_PROSTHETIC)
								dat += "<b>[modification]: [modified_limbs[modification][2]]</b><BR>"
							else
								dat += "<b>[modification]: [modified_limbs[modification][1]]</b><BR>"
						dat += "<BR>"
						dat += "<b>[species_label]:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=species;task=input'>[pref_species.name]</a><BR>"
						dat += "<b>[custom_species_name_label]:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=custom_species;task=input'>[custom_species ? custom_species : none_label]</a><BR>"
						dat += "<b>[random_body_label]:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=all;task=random'>[randomize_label]</A><BR>"
						dat += "<b>[always_random_body_label]:</b><a href='?_src_=prefs;preference=all'>[be_random_body ? yes_label : no_label]</A><BR>"
						dat += "<br><b>[cycle_background_label]:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=cycle_bg;task=input'>[bgstate]</a><BR>"

						dat += "</td>"

						var/use_skintones = pref_species.use_skintones
						if(use_skintones)
							dat += APPEARANCE_CATEGORY_COLUMN

							dat += "<h3>[skin_tone_label]</h3>"

							dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=s_tone;task=input'>[use_custom_skin_tone ? "[custom_label]: <span style='border:1px solid #161616; background-color: [skin_tone];'><font color='[color_hex2num(skin_tone) < 200 ? "FFFFFF" : "000000"]'>[skin_tone]</font></span>" : skin_tone]</a><BR>"

						var/mutant_colors
						if((MUTCOLORS in pref_species.species_traits) || (MUTCOLORS_PARTSONLY in pref_species.species_traits))
							if(!use_skintones)
								dat += APPEARANCE_CATEGORY_COLUMN

							dat += "<h2>[body_colors_label]</h2>"

							dat += "<b>[primary_color_label]:</b><BR>"
							dat += "<span style='border: 1px solid #161616; background-color: #[features["mcolor"]];'><font color='[color_hex2num(features["mcolor"]) < 200 ? "FFFFFF" : "000000"]'>#[features["mcolor"]]</font></span> <a href='?_src_=prefs;preference=mutant_color;task=input'>[change_label]</a><BR>"

							dat += "<b>[secondary_color_label]:</b><BR>"
							dat += "<span style='border: 1px solid #161616; background-color: #[features["mcolor2"]];'><font color='[color_hex2num(features["mcolor2"]) < 200 ? "FFFFFF" : "000000"]'>#[features["mcolor2"]]</font></span> <a href='?_src_=prefs;preference=mutant_color2;task=input'>[change_label]</a><BR>"

							dat += "<b>[tertiary_color_label]:</b><BR>"
							dat += "<span style='border: 1px solid #161616; background-color: #[features["mcolor3"]];'><font color='[color_hex2num(features["mcolor3"]) < 200 ? "FFFFFF" : "000000"]'>#[features["mcolor3"]]</font></span> <a href='?_src_=prefs;preference=mutant_color3;task=input'>[change_label]</a><BR>"
							mutant_colors = TRUE
							// UI tweak
							if(pref_species.use_skintones)
								dat += "<b>[genitals_use_skintone_label]:</b><a href='?_src_=prefs;preference=genital_colour'>[features["genitals_use_skintone"] == TRUE ? yes_label : no_label]</a><BR>"

							dat += "<b>[body_size_label]:</b> <a href='?_src_=prefs;preference=body_size;task=input'>[features["body_size"]*100]%</a><br>"
							dat += "<b>[normalized_size_label]:</b> <a href='?_src_=prefs;preference=normalized_size;task=input'>[features["normalized_size"]*100]%</a><br>"
							dat += "<b>[scaled_appearance_label]:</b> <a href='?_src_=prefs;preference=toggle_fuzzy;task=input'>[fuzzy ? fuzzy_label : sharp_label]</a><br>"
							dat += "<b>[weight_label]:</b> <a href='?_src_=prefs;preference=body_weight;task=input'>[all_quirks.Find("Пожиратель") ? NAME_WEIGHT_NORMAL : body_weight]</a><br>" //BLUEMOON ADD вес персонажей

						if(!(NOEYES in pref_species.species_traits))
							dat += "<h3>[eye_type_label]</h3>"
							dat += "</b><a style='display:block;width:100px' href='?_src_=prefs;preference=eye_type;task=input'>[eye_type]</a>"
							if((EYECOLOR in pref_species.species_traits))
								if(!use_skintones && !mutant_colors)
									dat += APPEARANCE_CATEGORY_COLUMN
								if(left_eye_color != right_eye_color)
									split_eye_colors = TRUE
								// UI tweak start
								dat += "<h3 title='[heterochromia_hint]'>[heterochromia_label]</h3>"
								// UI tweak end
								dat += "</b><a style='display:block;width:100px' href='?_src_=prefs;preference=toggle_split_eyes;task=input'>[split_eye_colors ? enabled_label : disabled_label]</a>"
								if(!split_eye_colors)
									dat += "<h3>[eye_color_label]</h3>"
									dat += "<span style='border: 1px solid #161616; background-color: #[left_eye_color];'><font color='[color_hex2num(left_eye_color) < 200 ? "FFFFFF" : "000000"]'>#[left_eye_color]</font></span> <a href='?_src_=prefs;preference=eyes;task=input'>[change_label]</a>"
								else
									dat += "<h3>[left_eye_color_label]</h3>"
									dat += "<span style='border: 1px solid #161616; background-color: #[left_eye_color];'><font color='[color_hex2num(left_eye_color) < 200 ? "FFFFFF" : "000000"]'>#[left_eye_color]</font></span> <a href='?_src_=prefs;preference=eye_left;task=input'>[change_label]</a>"
									dat += "<h3>[right_eye_color_label]</h3>"
									dat += "<span style='border: 1px solid #161616; background-color: #[right_eye_color];'><font color='[color_hex2num(right_eye_color) < 200 ? "FFFFFF" : "000000"]'>#[right_eye_color]</font></span> <a href='?_src_=prefs;preference=eye_right;task=input'>[change_label]</a><BR>"

					var/hair_style_label = T("hair_style", "Hair Style")
					var/facial_hair_style_label = T("facial_hair_style", "Facial Hair Style")
					var/hair_gradient_label = T("hair_gradient", "Hair Gradient")
					var/clothing_equipment_label = T("clothing_equipment", "Clothing & Equipment")
					var/backpack_label = T("backpack", "Backpack")
					var/jumpsuit_label = T("jumpsuit", "Jumpsuit")

					// Clothing & Equipment column in Body sub-tab
					if(appearance_subtab == APPEARANCE_SUBTAB_BODY)
						dat += APPEARANCE_CATEGORY_COLUMN
						dat += "<h2>[clothing_equipment_label]</h2>"
						dat += "<b>[backpack_label]:</b><a style='display:block;width:100px' href ='?_src_=prefs;preference=bag;task=input'>[backbag]</a>"
						dat += "<b>[jumpsuit_label]:</b><BR><a href ='?_src_=prefs;preference=suit;task=input'>[jumpsuit_style]</a><BR>"
					if(appearance_subtab == APPEARANCE_SUBTAB_BODY && ((HAS_FLESH in pref_species.species_traits) || (HAS_BONE in pref_species.species_traits)))
						dat += "<b>Temporal Scarring:</b><BR><a href='?_src_=prefs;preference=persistent_scars'>[(persistent_scars) ? "Enabled" : "Disabled"]</A>"
						dat += "<a href='?_src_=prefs;preference=clear_scars'>Clear scar slots</A>"
					if(appearance_subtab == APPEARANCE_SUBTAB_BODY)
						dat += "<br>"
						dat += "<b>Uplink Location:</b><a style='display:block;width:100px' href ='?_src_=prefs;preference=uplink_loc;task=input'>[uplink_spawn_loc]</a>"
						dat += "</td>"

					// Close Body sub-tab table
					if(appearance_subtab == APPEARANCE_SUBTAB_BODY)
						dat += "</tr></table>"

					if(appearance_subtab == APPEARANCE_SUBTAB_HAIR_EYES)
						dat += "<table><tr>"

					if(appearance_subtab == APPEARANCE_SUBTAB_HAIR_EYES && (HAIR in pref_species.species_traits))
						dat += "<td width='20%' valign='top'>"

						dat += "<h3>[hair_style_label]</h3>"

						dat += "<a style='display:block;width:180px' href='?_src_=prefs;preference=hair_style;task=input'>[hair_style]</a>" // BLUEMOON EDIT - увеличена ширина со 100 до 180
						dat += "<a href='?_src_=prefs;preference=previous_hair_style;task=input'>&lt;</a> <a href='?_src_=prefs;preference=next_hair_style;task=input'>&gt;</a> "
						dat += "<a href='?_src_=prefs;preference=open_hair_picker;task=input' style='font-size:11px;padding:1px 5px;border:1px solid #555;background:#2a2a3a;border-radius:3px;'>&#x1F4CB; Выбрать</a><BR>"
						dat += "<span style='border:1px solid #161616; background-color: #[hair_color];'><font color='[color_hex2num(hair_color) < 200 ? "FFFFFF" : "000000"]'>#[hair_color]</font></span> <a href='?_src_=prefs;preference=hair;task=input'>[change_label]</a><BR>"

						dat += "<h3>[facial_hair_style_label]</h3>"

						dat += "<a style='display:block;width:180px' href='?_src_=prefs;preference=facial_hair_style;task=input'>[facial_hair_style]</a>" // BLUEMOON EDIT - увеличена ширина со 100 до 180
						dat += "<a href='?_src_=prefs;preference=previous_facehair_style;task=input'>&lt;</a> <a href='?_src_=prefs;preference=next_facehair_style;task=input'>&gt;</a> "
						dat += "<a href='?_src_=prefs;preference=open_facial_hair_picker;task=input' style='font-size:11px;padding:1px 5px;border:1px solid #555;background:#2a2a3a;border-radius:3px;'>&#x1F4CB; Выбрать</a><BR>"
						dat += "<span style='border:1px solid #161616; background-color: #[facial_hair_color];'><font color='[color_hex2num(facial_hair_color) < 200 ? "FFFFFF" : "000000"]'>#[facial_hair_color]</font></span> <a href='?_src_=prefs;preference=facial;task=input'>[change_label]</a><BR>"

						dat += "<h3>[hair_gradient_label]</h3>"

						dat += "<a style='display:block;width:180px' href='?_src_=prefs;preference=grad_style;task=input'>[grad_style]</a>"
						dat += "<a href='?_src_=prefs;preference=previous_grad_style;task=input'>&lt;</a> <a href='?_src_=prefs;preference=next_grad_style;task=input'>&gt;</a> "
						dat += "<a href='?_src_=prefs;preference=open_gradient_picker;task=input' style='font-size:11px;padding:1px 5px;border:1px solid #555;background:#2a2a3a;border-radius:3px;'>&#x1F4CB; Выбрать</a><BR>"
						dat += "<span style='border:1px solid #161616; background-color: #[grad_color];'><font color='[color_hex2num(grad_color) < 200 ? "FFFFFF" : "000000"]'>#[grad_color]</font></span> <a href='?_src_=prefs;preference=grad_color;task=input'>[change_label]</a><BR>"

						dat += "</td>"

					if(appearance_subtab == APPEARANCE_SUBTAB_HAIR_EYES)
						dat += "</tr></table>"

				//Mutant stuff
					if(appearance_subtab == APPEARANCE_SUBTAB_MUTPARTS)
						dat += "<table><tr>"
					var/mutant_category = 0

					for(var/mutant_part in GLOB.all_mutant_parts)
						if(mutant_part == "mam_body_markings")
							continue
						if(appearance_subtab == APPEARANCE_SUBTAB_MUTPARTS && parent?.can_have_part(mutant_part))
							if(!mutant_category)
								dat += "<td width='20%' valign='top'>"
							var/mutant_part_label = T(mutant_part, GLOB.all_mutant_parts[mutant_part])
							dat += "<h3>[mutant_part_label]</h3>"
							dat += "<a style='display:block;width:180px' href='?_src_=prefs;preference=[mutant_part];task=input'>[features[mutant_part]]</a>" // BLUEMOON EDIT - увеличена ширина со 100 до 180
							// BLUEMOON ADD START - <_AND_>_FOR_CHARACTER_REDACTOR
							dat += "<a href='?_src_=prefs;preference=previous_[mutant_part]_style;task=input'>&lt;</a> <a href='?_src_=prefs;preference=next_[mutant_part]_style;task=input'>&gt;</a><BR>"
							// BLUEMOON ADD END
							var/color_type = GLOB.colored_mutant_parts[mutant_part] //if it can be coloured, show the appropriate button
							if(color_type)
								dat += "<span style='border:1px solid #161616; background-color: #[features[color_type]];'><font color='[color_hex2num(features[color_type]) < 200 ? "FFFFFF" : "000000"]'>#[features[color_type]]</font></span> <a href='?_src_=prefs;preference=[color_type];task=input'>Change</a><BR>"
							else
								if(features["color_scheme"] == ADVANCED_CHARACTER_COLORING) //advanced individual part colouring system
									//is it matrixed or does it have extra parts to be coloured?
									var/find_part = features[mutant_part] || pref_species.mutant_bodyparts[mutant_part]
									var/find_part_list = GLOB.mutant_reference_list[mutant_part]
									if(find_part && find_part != "None" && find_part_list)
										var/datum/sprite_accessory/accessory = find_part_list[find_part]
										if(accessory)
											if(accessory.color_src == MATRIXED || accessory.color_src == MUTCOLORS || accessory.color_src == MUTCOLORS2 || accessory.color_src == MUTCOLORS3) //mutcolors1-3 are deprecated now, please don't rely on these in the future
												var/mutant_string = accessory.mutant_part_string
												var/primary_feature = "[mutant_string]_primary"
												var/secondary_feature = "[mutant_string]_secondary"
												var/tertiary_feature = "[mutant_string]_tertiary"
												if(!features[primary_feature])
													features[primary_feature] = features["mcolor"]
												if(!features[secondary_feature])
													features[secondary_feature] = features["mcolor2"]
												if(!features[tertiary_feature])
													features[tertiary_feature] = features["mcolor3"]

												var/matrixed_sections = accessory.matrixed_sections
												if(accessory.color_src == MATRIXED && !matrixed_sections)
													message_admins("Sprite Accessory Failure (customization): Accessory [accessory.type] is a matrixed item without any matrixed sections set!")
													continue
												else if(accessory.color_src == MATRIXED)
													switch(matrixed_sections)
														if(MATRIX_GREEN) //only composed of a green section
															primary_feature = secondary_feature //swap primary for secondary, so it properly assigns the second colour, reserved for the green section
														if(MATRIX_BLUE)
															primary_feature = tertiary_feature //same as above, but the tertiary feature is for the blue section
														if(MATRIX_RED_BLUE) //composed of a red and blue section
															secondary_feature = tertiary_feature //swap secondary for tertiary, as blue should always be tertiary
														if(MATRIX_GREEN_BLUE) //composed of a green and blue section
															primary_feature = secondary_feature //swap primary for secondary, as first option is green, which is linked to the secondary
															secondary_feature = tertiary_feature //swap secondary for tertiary, as second option is blue, which is linked to the tertiary
												dat += "<b>Primary Color</b><BR>"
												dat += "<span style='border:1px solid #161616; background-color: #[features[primary_feature]];'><font color='[color_hex2num(features[primary_feature]) < 200 ? "FFFFFF" : "000000"]'>#[features[primary_feature]]</font></span> <a href='?_src_=prefs;preference=[primary_feature];task=input'>Change</a><BR>"
												if((accessory.color_src == MATRIXED && (matrixed_sections == MATRIX_RED_BLUE || matrixed_sections == MATRIX_GREEN_BLUE || matrixed_sections == MATRIX_RED_GREEN || matrixed_sections == MATRIX_ALL)) || (accessory.extra && (accessory.extra_color_src == MUTCOLORS || accessory.extra_color_src == MUTCOLORS2 || accessory.extra_color_src == MUTCOLORS3)))
													dat += "<b>Secondary Color</b><BR>"
													dat += "<span style='border:1px solid #161616; background-color: #[features[secondary_feature]];'><font color='[color_hex2num(features[secondary_feature]) < 200 ? "FFFFFF" : "000000"]'>#[features[secondary_feature]]</font></span> <a href='?_src_=prefs;preference=[secondary_feature];task=input'>Change</a><BR>"
													if((accessory.color_src == MATRIXED && matrixed_sections == MATRIX_ALL) || (accessory.extra2 && (accessory.extra2_color_src == MUTCOLORS || accessory.extra2_color_src == MUTCOLORS2 || accessory.extra2_color_src == MUTCOLORS3)))
														dat += "<b>Tertiary Color</b><BR>"
														dat += "<span style='border:1px solid #161616; background-color: #[features[tertiary_feature]];'><font color='[color_hex2num(features[tertiary_feature]) < 200 ? "FFFFFF" : "000000"]'>#[features[tertiary_feature]]</font></span> <a href='?_src_=prefs;preference=[tertiary_feature];task=input'>Change</a><BR>"

							mutant_category++
							if(mutant_category >= MAX_MUTANT_ROWS)
								dat += "</td>"
								mutant_category = 0

					if(appearance_subtab == APPEARANCE_SUBTAB_MUTPARTS && length(pref_species.allowed_limb_ids))
						if(!chosen_limb_id || !(chosen_limb_id in pref_species.allowed_limb_ids))
							chosen_limb_id = pref_species.limbs_id || pref_species.id
						if(!mutant_category)
							dat += "<td width='20%' valign='top'>"
						dat += "<h3>Body sprite</h3>"
						dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=bodysprite;task=input'>[chosen_limb_id]</a>"

					//BLUEMOON edit start
					if(appearance_subtab == APPEARANCE_SUBTAB_MUTPARTS && pref_species.type == /datum/species/jelly/roundstartslime)
						if(!mutant_category)
							dat += "<td width='20%' valign='top'>"
						dat += "<h3>be a slime?</h3>"
						dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=puddle_slime_task;task=input'>[features["puddle_slime_fea"] ? "Yes" : "No"]</a>"
						dat += "</td>"
					//BLUEMOON edit end

					if(mutant_category)
						dat += "</td>"
						mutant_category = 0

					if(appearance_subtab == APPEARANCE_SUBTAB_MUTPARTS)
						dat += "</tr></table>"

					// Intimacy subtab: Consent, Pregnancy, Genitals
					if(appearance_subtab == APPEARANCE_SUBTAB_INTIMACY)
						dat += "<table><tr><td width='20%' valign='top'>"

					if(appearance_subtab == APPEARANCE_SUBTAB_INTIMACY)
						dat += "<h2>Consent preferences</h2>"
					if(appearance_subtab == APPEARANCE_SUBTAB_INTIMACY)
						dat += "ERP : <a href='?_src_=prefs;preference=erp_pref'>[erppref]</a><br>"
					if(appearance_subtab == APPEARANCE_SUBTAB_INTIMACY)
						dat += "Non-Con : <a href='?_src_=prefs;preference=noncon_pref'>[nonconpref]</a><br>"
					if(appearance_subtab == APPEARANCE_SUBTAB_INTIMACY)
						dat += "Vore : <a href='?_src_=prefs;preference=vore_pref'>[vorepref]</a><br>"
					if(appearance_subtab == APPEARANCE_SUBTAB_INTIMACY)
						dat += "Mob Non-Con Sex : <a href='?_src_=prefs;preference=mobsex_pref'>[mobsexpref]</a><br>"
					if(appearance_subtab == APPEARANCE_SUBTAB_INTIMACY)
						dat += "Horny Antags : <a href='?_src_=prefs;preference=hornyantags_pref'>[hornyantagspref]</a><br>"

					if(appearance_subtab == APPEARANCE_SUBTAB_INTIMACY)
						dat += "<h2>Lewd preferences</h2>"
					if(appearance_subtab == APPEARANCE_SUBTAB_INTIMACY)
						dat += "<b>Lust tolerance:</b><a href='?_src_=prefs;preference=lust_tolerance;task=input'>[lust_tolerance]</a><br>"
					if(appearance_subtab == APPEARANCE_SUBTAB_INTIMACY)
						dat += "<b>Sexual potency:</b><a href='?_src_=prefs;preference=sexual_potency;task=input'>[sexual_potency]</a>"

					//SPLURT EDIT BEGIN - gregnancy preferences
					if(appearance_subtab == APPEARANCE_SUBTAB_INTIMACY)
						dat += "<h3>Pregnancy preferences</h3>"
					if(appearance_subtab == APPEARANCE_SUBTAB_INTIMACY)
						dat += "<b>Chance of impregnation:</b><a style='display:block;width:100px' href ='?_src_=prefs;preference=virility;task=input'>[virility ? virility : "Disabled"]</a>"
					if(appearance_subtab == APPEARANCE_SUBTAB_INTIMACY)
						dat += "<b>Chance of getting pregnant:</b><a style='display:block;width:100px' href ='?_src_=prefs;preference=fertility;task=input'>[fertility ? fertility : "Disabled"]</a>"
					if(appearance_subtab == APPEARANCE_SUBTAB_INTIMACY)
						dat += "<b>Lay inert eggs:</b><a style='display:block;width:100px' href ='?_src_=prefs;preference=inert_eggs'>[features["inert_eggs"] == TRUE ? "Enabled" : "Disabled"]</a>"
					if(appearance_subtab == APPEARANCE_SUBTAB_INTIMACY && fertility)
						dat += "<b>Pregnancy inflation:</b><a style='display:block;width:100px' href ='?_src_=prefs;preference=pregnancy_inflation;task=input'>[pregnancy_inflation ? "Enabled" : "Disabled"]</a>"
					if(appearance_subtab == APPEARANCE_SUBTAB_INTIMACY && fertility)
						dat += "<b>Pregnancy breast growth:</b><a style='display:block;width:100px' href ='?_src_=prefs;preference=pregnancy_breast_growth;task=input'>[pregnancy_breast_growth ? "Enabled" : "Disabled"]</a>"
					if(appearance_subtab == APPEARANCE_SUBTAB_INTIMACY && (fertility || features["inert_eggs"]))
						dat += "<b>Egg shell:</b><a style='display:block;width:100px' href ='?_src_=prefs;preference=egg_shell;task=input'>[egg_shell]</a>"
					if(appearance_subtab == APPEARANCE_SUBTAB_INTIMACY)
						dat += "</td>"
					//SPLURT EDIT END
					if(appearance_subtab == APPEARANCE_SUBTAB_INTIMACY)
						dat += APPEARANCE_CATEGORY_COLUMN

					if(appearance_subtab == APPEARANCE_SUBTAB_INTIMACY)
						if(NOGENITALS in pref_species.species_traits)
							dat += "<b>Your species ([pref_species.name]) does not support genitals!</b><br>"
						else
							// Translation variables for genital section headers
							var/penis_header = T("penis", "Penis")
							var/vagina_header = T("vagina", "Vagina")
							var/breasts_header = T("breasts", "Breasts")
							var/butt_header = T("butt", "Butt")
							var/belly_header = T("belly", "Belly")
							var/has_penis_label = T("has_penis", "Has Penis")
							var/penis_color_label = T("penis_color", "Penis Color")
							var/penis_shape_label = T("penis_shape", "Penis Shape")
							var/penis_length_label = T("penis_length", "Penis Length")
							var/penis_diameter_ratio_label = T("penis_diameter_ratio", "Diameter Ratio")
							var/penis_visibility_label = T("penis_visibility", "Penis Visibility")
							var/penis_accessible_label = T("penis_accessible", "Penis Always Accessible")
							var/penis_stuffing_label = T("penis_stuffing", "Toys and Egg Stuffing")
							var/has_testicles_label = T("has_testicles", "Has Testicles")
							var/testicles_color_label = T("testicles_color", "Testicles Color")
							var/testicles_shape_label = T("testicles_shape", "Testicles Shape")
							var/testicles_visibility_label = T("testicles_visibility", "Testicles Visibility")
							var/testicles_accessible_label = T("testicles_accessible", "Testicles Always Accessible")
							var/testicles_stuffing_label = T("testicles_stuffing", "Toys and Egg Stuffing")
							var/testicles_fluid_label = T("testicles_fluid", "Produces")
							var/has_vagina_label = T("has_vagina", "Has Vagina")
							var/vagina_type_label = T("vagina_type", "Vagina Type")
							var/vagina_color_label = T("vagina_color", "Vagina Color")
							var/vagina_visibility_label = T("vagina_visibility", "Vagina Visibility")
							var/vagina_accessible_label = T("vagina_accessible", "Vagina Always Accessible")
							var/vagina_stuffing_label = T("vagina_stuffing", "Toys and Egg Stuffing")
							var/has_womb_label = T("has_womb", "Has Womb")
							var/womb_fluid_label = T("womb_fluid", "Produces")
							var/has_breasts_label = T("has_breasts", "Has Breasts")
							var/breasts_color_label = T("breast_color", "Color")
							var/breasts_size_label = T("breast_cup_size", "Cup Size")
							var/breasts_shape_label = T("breast_shape", "Breasts Shape")
							var/breasts_visibility_label = T("breast_visibility", "Breasts Visibility")
							var/breasts_lactates_label = T("breast_lactates", "Lactates")
							var/breasts_stuffing_label = T("breast_stuffing", "Toys and Egg Stuffing")
							var/breast_fluid_label = T("breast_fluid", "Produces")
							var/has_butt_label = T("has_butt", "Has Butt")
							var/butt_color_label = T("butt_color", "Color")
							var/butt_size_label = T("butt_size", "Butt Size")
							var/butt_visibility_label = T("butt_visibility", "Butt Visibility")
							var/butt_accessible_label = T("butt_accessible", "Butt Always Accessible")
							var/butt_stuffing_label = T("butt_stuffing", "Toys and Egg Stuffing")
							var/has_anus_label = T("has_anus", "Has Anus")
							var/anus_color_label = T("anus_color", "Butthole Color")
							var/anus_shape_label = T("anus_shape", "Butthole Shape")
							var/anus_visibility_label = T("anus_visibility", "Butthole Visibility")
							var/anus_accessible_label = T("anus_accessible", "Butthole Always Accessible")
							var/anus_stuffing_label = T("anus_stuffing", "Toys and Egg Stuffing")
							var/has_belly_label = T("has_belly", "Has Belly")
							var/belly_color_label = T("belly_color", "Color")
							var/belly_size_label = T("belly_size", "Belly Size")
							var/belly_visibility_label = T("belly_visibility", "Belly Visibility")
							var/belly_accessible_label = T("belly_accessible", "Belly Always Accessible")
							var/belly_stuffing_label = T("belly_stuffing", "Toys and Egg Stuffing")

							dat += "<h3>[penis_header]</h3>"
							dat += "<b>[has_penis_label]:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=has_cock'>[features["has_cock"] == TRUE ? "Yes" : "No"]</a>"
							if(features["has_cock"])
								if(pref_species.use_skintones && features["genitals_use_skintone"] == TRUE)
									dat += "<b>[penis_color_label]:</b></a><BR>"
									dat += "<span style='border: 1px solid #161616; background-color: [SKINTONE2HEX(skin_tone)];'><font color='[color_hex2num(SKINTONE2HEX(skin_tone)) < 200 ? "FFFFFF" : "000000"]'>[SKINTONE2HEX(skin_tone)]</font></span>(Skin tone overriding)</a><br>"
								else
									dat += "<b>[penis_color_label]:</b></a><BR>"
									dat += "<span style='border: 1px solid #161616; background-color: #[features["cock_color"]];'><font color='[color_hex2num(features["cock_color"]) < 200 ? "FFFFFF" : "000000"]'>#[features["cock_color"]]</font></span> <a href='?_src_=prefs;preference=cock_color;task=input'>Change</a><br>"
								var/tauric_shape = FALSE
								if(features["cock_taur"])
									var/datum/sprite_accessory/penis/P = GLOB.cock_shapes_list[features["cock_shape"]]
									if(P?.taur_icon && parent?.can_have_part("taur"))
										var/datum/sprite_accessory/taur/T = GLOB.taur_list[features["taur"]]
										if(T.taur_mode & P.accepted_taurs)
											tauric_shape = TRUE
								dat += "<b>[penis_shape_label]:</b> <a style='display:block;width:120px' href='?_src_=prefs;preference=cock_shape;task=input'>[features["cock_shape"]][tauric_shape ? " (Taur)" : ""]</a>"
								dat += "<b>[penis_length_label]:</b> <a style='display:block;width:120px' href='?_src_=prefs;preference=cock_length;task=input'>[features["cock_length"]] centimeter(-s)</a>"
								dat += "<b>Max Length:</b><a style='display:block;width:120px' href='?_src_=prefs;preference=cock_max_length;task=input'>[features["cock_max_length"] ? features["cock_max_length"] : "Disabled"]</a>"
								dat += "<b>Min Length:</b><a style='display:block;width:120px' href='?_src_=prefs;preference=cock_min_length;task=input'>[features["cock_min_length"] ? features["cock_min_length"] : "Disabled"]</a>"
								dat += "<b>[penis_diameter_ratio_label]:</b> <a style='display:block;width:120px' href='?_src_=prefs;preference=cock_diameter_ratio;task=input'>[features["cock_diameter_ratio"]]</a>" //SPLURT Edit
								dat += "<b>[penis_visibility_label]:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=cock_visibility;task=input'>[features["cock_visibility"]]</a>"
								dat += "<b>[penis_accessible_label]:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=cock_accessible'>[features["cock_accessible"] ? "Yes" : "No"]</a>"
								dat += "<b>[penis_stuffing_label]:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=cock_stuffing'>[features["cock_stuffing"] == TRUE ? "Yes" : "No"]</a>" //SPLURT Edit

							dat += "<h3>Testicles</h3>"
							dat += "<b>[has_testicles_label]:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=has_balls'>[features["has_balls"] == TRUE ? "Yes" : "No"]</a>"
							if(features["has_balls"])
								if(pref_species.use_skintones && features["genitals_use_skintone"] == TRUE)
									dat += "<b>Testicles Color:</b></a><BR>"
									dat += "<span style='border: 1px solid #161616; background-color: [SKINTONE2HEX(skin_tone)];'><font color='[color_hex2num(SKINTONE2HEX(skin_tone)) < 200 ? "FFFFFF" : "000000"]'>[SKINTONE2HEX(skin_tone)]</font></span>(Skin tone overriding)<br>"
								else
									dat += "<b>[testicles_color_label]:</b></a><BR>"
									dat += "<span style='border: 1px solid #161616; background-color: #[features["balls_color"]];'><font color='[color_hex2num(features["balls_color"]) < 200 ? "FFFFFF" : "000000"]'>#[features["balls_color"]]</font></span> <a href='?_src_=prefs;preference=balls_color;task=input'>Change</a><br>"
								dat += "<b>[testicles_shape_label]:</b> <a style='display:block;width:120px' href='?_src_=prefs;preference=balls_shape;task=input'>[features["balls_shape"]]</a>"
								dat += "<b>Testicles Size:</b> <a style='display:block;width:120px' href='?_src_=prefs;preference=balls_size;task=input'>[features["balls_size"]]</a>"
								dat += "<b>[testicles_visibility_label]:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=balls_visibility;task=input'>[features["balls_visibility"]]</a>"
								dat += "<b>[testicles_accessible_label]:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=balls_accessible'>[features["balls_accessible"] ? "Yes" : "No"]</a>"

								//SPLURT Edit
								dat += "<b>[testicles_stuffing_label]:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=balls_stuffing'>[features["balls_stuffing"] == TRUE ? "Yes" : "No"]</a>"
								dat += "<b>Max Size:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=balls_max_size;task=input'>[features["balls_max_size"] ? features["balls_max_size"] : "Disabled"]</a>"
								dat += "<b>Min Size:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=balls_min_size;task=input'>[features["balls_min_size"] ? features["balls_min_size"] : "Disabled"]</a>"
								dat += "<b>[testicles_fluid_label]:</b>"
								var/datum/reagent/balls_fluid = find_reagent_object_from_type(features["balls_fluid"])
								if(balls_fluid && (balls_fluid in GLOB.genital_fluids_list))
									dat += "<a style='display:block;width:50px' href='?_src_=prefs;preference=balls_fluid;task=input'>[balls_fluid.name]</a>"
								else
									dat += "<a style='display:block;width:50px' href='?_src_=prefs;preference=balls_fluid;task=input'>Nothing?</a>"
								//SPLURT Edit end

							dat += "</td>"
							dat += APPEARANCE_CATEGORY_COLUMN
							dat += "<h3>[vagina_header]</h3>"
							dat += "<b>[has_vagina_label]:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=has_vag'>[features["has_vag"] == TRUE ? "Yes" : "No"]</a>"
							if(features["has_vag"])
								dat += "<b>[vagina_type_label]:</b> <a style='display:block;width:100px' href='?_src_=prefs;preference=vag_shape;task=input'>[features["vag_shape"]]</a>"
								if(pref_species.use_skintones && features["genitals_use_skintone"] == TRUE)
									dat += "<b>[vagina_color_label]:</b></a><BR>"
									dat += "<span style='border: 1px solid #161616; background-color: [SKINTONE2HEX(skin_tone)];'><font color='[color_hex2num(SKINTONE2HEX(skin_tone)) < 200 ? "FFFFFF" : "000000"]'>[SKINTONE2HEX(skin_tone)]</font></span>(Skin tone overriding)<br>"
								else
									dat += "<b>[vagina_color_label]:</b></a><BR>"
									dat += "<span style='border: 1px solid #161616; background-color: #[features["vag_color"]];'><font color='[color_hex2num(features["vag_color"]) < 200 ? "FFFFFF" : "000000"]'>#[features["vag_color"]]</font></span> <a href='?_src_=prefs;preference=vag_color;task=input'>Change</a><br>"
								dat += "<b>[vagina_visibility_label]:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=vag_visibility;task=input'>[features["vag_visibility"]]</a>"
								dat += "<b>[vagina_accessible_label]:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=vag_accessible'>[features["vag_accessible"] ? "Yes" : "No"]</a>"
								dat += "<b>[vagina_stuffing_label]:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=vag_stuffing'>[features["vag_stuffing"] == TRUE ? "Yes" : "No"]</a>" //SPLURT Edit
								dat += "<b>[has_womb_label]:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=has_womb'>[features["has_womb"] == TRUE ? "Yes" : "No"]</a>"
								//SPLURT Edit
								if(features["has_womb"] == TRUE)
									dat += "<b>[womb_fluid_label]:</b>"
									var/datum/reagent/womb_fluid = find_reagent_object_from_type(features["womb_fluid"])
									if(womb_fluid && (womb_fluid in GLOB.genital_fluids_list))
										dat += "<a style='display:block;width:50px' href='?_src_=prefs;preference=womb_fluid;task=input'>[womb_fluid.name]</a>"
									else
										dat += "<a style='display:block;width:50px' href='?_src_=prefs;preference=womb_fluid;task=input'>Nothing?</a>"
								//SPLURT Edit end
							dat += "</td>"
							dat += APPEARANCE_CATEGORY_COLUMN
							dat += "<h3>[breasts_header]</h3>"
							dat += "<b>[has_breasts_label]:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=has_breasts'>[features["has_breasts"] == TRUE ? "Yes" : "No"]</a>"
							if(features["has_breasts"])
								if(pref_species.use_skintones && features["genitals_use_skintone"] == TRUE)
									dat += "<b>[breasts_color_label]:</b></a><BR>"
									dat += "<span style='border: 1px solid #161616; background-color: [SKINTONE2HEX(skin_tone)];'><font color='[color_hex2num(SKINTONE2HEX(skin_tone)) < 200 ? "FFFFFF" : "000000"]'>[SKINTONE2HEX(skin_tone)]</font></span>(Skin tone overriding)<br>"
								else
									dat += "<b>[breasts_color_label]:</b></a><BR>"
									dat += "<span style='border: 1px solid #161616; background-color: #[features["breasts_color"]];'><font color='[color_hex2num(features["breasts_color"]) < 200 ? "FFFFFF" : "000000"]'>#[features["breasts_color"]]</font></span> <a href='?_src_=prefs;preference=breasts_color;task=input'>Change</a><br>"
								dat += "<b>[breasts_size_label]:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=breasts_size;task=input'>[features["breasts_size"]]</a>"
								dat += "<b>[breasts_shape_label]:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=breasts_shape;task=input'>[features["breasts_shape"]]</a>"
								dat += "<b>[breasts_visibility_label]:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=breasts_visibility;task=input'>[features["breasts_visibility"]]</a>"
								dat += "<b>[breasts_lactates_label]:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=breasts_producing'>[features["breasts_producing"] == TRUE ? "Yes" : "No"]</a>"
								//SPLURT Edit
								dat += "<b>[breasts_stuffing_label]:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=breasts_stuffing'>[features["breasts_stuffing"] == TRUE ? "Yes" : "No"]</a>"
								dat += "<b>Max Size:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=breasts_max_size;task=input'>[features["breasts_max_size"] ? features["breasts_max_size"] : "Disabled"]</a>"
								dat += "<b>Min Size:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=breasts_min_size;task=input'>[features["breasts_min_size"] ? features["breasts_min_size"] : "Disabled"]</a>"
								if(features["breasts_producing"] == TRUE)
									dat += "<b>[breast_fluid_label]:</b>"
									var/datum/reagent/breasts_fluid = find_reagent_object_from_type(features["breasts_fluid"])
									if(breasts_fluid && (breasts_fluid in GLOB.genital_fluids_list))
										dat += "<a style='display:block;width:50px' href='?_src_=prefs;preference=breasts_fluid;task=input'>[breasts_fluid.name]</a>"
									else
										dat += "<a style='display:block;width:50px' href='?_src_=prefs;preference=breasts_fluid;task=input'>Nothing?</a>"
								//SPLURT Edit end
							dat += "</td>"
							dat += APPEARANCE_CATEGORY_COLUMN
							dat += "<h3>[butt_header]</h3>"
							dat += "<b>[has_butt_label]:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=has_butt'>[features["has_butt"] == TRUE ? "Yes" : "No"]</a>"
							if(features["has_butt"])
								if(pref_species.use_skintones && features["genitals_use_skintone"] == TRUE)
									dat += "<b>[butt_color_label]:</b></a><BR>"
									dat += "<span style='border: 1px solid #161616; background-color: [SKINTONE2HEX(skin_tone)];'><font color='[color_hex2num(SKINTONE2HEX(skin_tone)) < 200 ? "FFFFFF" : "000000"]'>[SKINTONE2HEX(skin_tone)]</font></span>(Skin tone overriding)<br>"
								else
									dat += "<b>[butt_color_label]:</b></a><BR>"
									dat += "<span style='border: 1px solid #161616; background-color: #[features["butt_color"]];'><font color='[color_hex2num(features["butt_color"]) < 200 ? "FFFFFF" : "000000"]'>#[features["butt_color"]]</font></span> <a href='?_src_=prefs;preference=butt_color;task=input'>Change</a><br>"
								dat += "<b>[butt_size_label]:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=butt_size;task=input'>[features["butt_size"]]</a>"
								dat += "<b>[butt_visibility_label]:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=butt_visibility;task=input'>[features["butt_visibility"]]</a>"
								dat += "<b>[butt_accessible_label]:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=butt_accessible'>[features["butt_accessible"] ? "Yes" : "No"]</a>"
							//SPLURT Edit
								dat += "<b>[butt_stuffing_label]:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=butt_stuffing'>[features["butt_stuffing"] == TRUE ? "Yes" : "No"]</a>"
								dat += "<b>Max Size:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=butt_max_size;task=input'>[features["butt_max_size"] ? features["butt_max_size"] : "Disabled"]</a>"
								dat += "<b>Min Size:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=butt_min_size;task=input'>[features["butt_min_size"] ? features["butt_min_size"] : "Disabled"]</a>"
								dat += "<b>[has_anus_label]:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=has_anus'>[features["has_anus"] == TRUE ? "Yes" : "No"]</a>"
								if(features["has_anus"])
									dat += "<b>[anus_color_label]:</b></a><BR>"
									if(pref_species.use_skintones && features["genitals_use_skintone"] == TRUE)
										dat += "<span style='border: 1px solid #161616; background-color: [SKINTONE2HEX(skin_tone)];'><font color='[color_hex2num(SKINTONE2HEX(skin_tone)) < 200 ? "FFFFFF" : "000000"]'>[SKINTONE2HEX(skin_tone)]</font></span>(Skin tone overriding)<br>"
									else
										dat += "<span style='border: 1px solid #161616; background-color: #[features["anus_color"]];'><font color='[color_hex2num(features["anus_color"]) < 200 ? "FFFFFF" : "000000"]'>#[features["anus_color"]]</font></span> <a href='?_src_=prefs;preference=anus_color;task=input'>Change</a><br>"
									dat += "<b>[anus_shape_label]:</b> <a style='display:block;width:120px' href='?_src_=prefs;preference=anus_shape;task=input'>[features["anus_shape"]]</a>"
									dat += "<b>[anus_visibility_label]:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=anus_visibility;task=input'>[features["anus_visibility"]]</a>"
									dat += "<b>[anus_accessible_label]:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=anus_accessible'>[features["anus_accessible"] ? "Yes" : "No"]</a>"
									dat += "<b>[anus_stuffing_label]:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=anus_stuffing'>[features["anus_stuffing"] == TRUE ? "Yes" : "No"]</a>"

							dat += "</td>"
							dat += APPEARANCE_CATEGORY_COLUMN
							dat += "<h3>[belly_header]</h3>"
							dat += "<b>[has_belly_label]:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=has_belly'>[features["has_belly"] == TRUE ? "Yes" : "No"]</a>"
							if(features["has_belly"])
								if(pref_species.use_skintones && features["genitals_use_skintone"] == TRUE)
									dat += "<b>[belly_color_label]:</b></a><BR>"
									dat += "<span style='border: 1px solid #161616; background-color: [SKINTONE2HEX(skin_tone)];'><font color='[color_hex2num(SKINTONE2HEX(skin_tone)) < 200 ? "FFFFFF" : "000000"]'>[SKINTONE2HEX(skin_tone)]</font></span>(Skin tone overriding)<br>"
								else
									dat += "<b>[belly_color_label]:</b></a><BR>"
									dat += "<span style='border: 1px solid #161616; background-color: #[features["belly_color"]];'><font color='[color_hex2num(features["belly_color"]) < 200 ? "FFFFFF" : "000000"]'>#[features["belly_color"]]</font></span> <a href='?_src_=prefs;preference=belly_color;task=input'>Change</a><br>"
								dat += "<b>[belly_size_label]:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=belly_size;task=input'>[features["belly_size"]]</a>"
								dat += "<b>Max Size:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=belly_max_size;task=input'>[features["belly_max_size"] ? features["belly_max_size"] : "Disabled" ]</a>"
								dat += "<b>Min Size:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=belly_min_size;task=input'>[features["belly_min_size"] ? features["belly_min_size"] : "Disabled" ]</a>"
								dat += "<b>[belly_visibility_label]:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=belly_visibility;task=input'>[features["belly_visibility"]]</a>"
								dat += "<b>[belly_stuffing_label]:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=belly_stuffing'>[features["belly_stuffing"] == TRUE ? "Yes" : "No"]</a>"
								dat += "<b>[belly_accessible_label]:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=belly_accessible'>[features["belly_accessible"] ? "Yes" : "No"]</a>"
							dat += "</td>"
							if(all_quirks.Find("Дуллахан"))
								dat += APPEARANCE_CATEGORY_COLUMN
								dat += "<h3>Neckfire</h3>"
								dat += "<a style='display:block;width:50px' href='?_src_=prefs;preference=has_neckfire;task=input'>[features["neckfire"] ? "Yes" : "No"]</a>"
								if(features["neckfire"])
									dat += "<b>Color:</b></a><BR>"
									dat += "<span style='border: 1px solid #161616; background-color: #[features["neckfire_color"]];'><font color='[color_hex2num(features["neckfire_color"]) < 200 ? "FFFFFF" : "000000"]'>#[features["neckfire_color"]]</font></span><a href='?_src_=prefs;preference=has_neckfire_color;task=input'>Change</a><br>"

								dat += "</td>"
							//SPLURT Edit end
							dat += "</td>"
					if(appearance_subtab == APPEARANCE_SUBTAB_INTIMACY)
						dat += "</tr></table>"
				//Markings
				if(MARKINGS_CHAR_TAB)
					var/character_tattoos_label = T("character_tattoos", "Character Tattoos")
					var/view_delete_tattoos_label = T("view_delete_tattoos", "View and delete tattoos")
					var/danger_zone_label = T("danger_zone", "Danger Zone")
					var/remove_all_markings_label = T("remove_all_markings", "Remove All Markings")
					var/add_label = T("add_label", "Add")
					var/clear_label = T("clear_label", "Clear")
					var/move_label = T("move_label", "Move")
					var/name_column_label = T("name_column", "Name")
					var/colors_label = T("colors_label", "Colors")
					var/top_label = T("top_label", "Top")
					var/up_label = T("up_label", "Up")
					var/down_label = T("down_label", "Down")
					var/bottom_label = T("bottom_label", "Bottom")
					var/limb_head_label = T("limb_head", "Head")
					var/limb_right_leg_label = T("limb_right_leg", "Right Leg")
					var/limb_chest_label = T("limb_chest", "Chest")
					var/limb_left_arm_label = T("limb_left_arm", "Left Arm")
					var/limb_left_leg_label = T("limb_left_leg", "Left Leg")
					var/limb_right_arm_label = T("limb_right_arm", "Right Arm")
					// BLUEMOON ADD - Tattoo Manager Button
					dat += "<center>"
					dat += "<h3>[character_tattoos_label]</h3>"
					dat += "<a href='?_src_=prefs;preference=open_tattoo_manager'>[view_delete_tattoos_label]</a>"
					dat += "</center>"
					dat += "<hr>"
					// BLUEMOON ADD END
					var/iterated_markings = 0
					var/total_pages = 0
					// rp marking selection
					// assume you can only have mam markings or regular markings or none, never both
					var/marking_type
					if(parent?.can_have_part("mam_body_markings"))
						marking_type = "mam_body_markings"
					if(marking_type)
						dat += APPEARANCE_CATEGORY_COLUMN
						dat += "<div class='csetup-markings'>"
						dat += "<div class='csetup-markings-toolbar'>"
						dat += "<span class='csetup-toolbar-label'>[T(marking_type, GLOB.all_mutant_parts[marking_type])]</span>"
						dat += "<a href='?_src_=prefs;preference=marking_add;marking_type=[marking_type];task=input'>[add_label]</a>"
						dat += "</div>"
						dat += "<div class='csetup-markings-grid'>"
						var/list/ordered_limbs = list("Head", "Right Leg", "Chest", "Left Arm", "Left Leg", "Right Arm")
						for(var/limb in ordered_limbs)
							var/limb_label = limb
							switch(limb)
								if("Head")
									limb_label = limb_head_label
								if("Right Leg")
									limb_label = limb_right_leg_label
								if("Chest")
									limb_label = limb_chest_label
								if("Left Arm")
									limb_label = limb_left_arm_label
								if("Left Leg")
									limb_label = limb_left_leg_label
								if("Right Arm")
									limb_label = limb_right_arm_label
							dat += "<section class='csetup-marking-card'>"
							dat += "<div class='csetup-marking-card-header'>"
							dat += "<div class='csetup-marking-card-title'>[limb_label]</div>"
							dat += "<div class='csetup-marking-card-actions'>"
							dat += "<a class='csetup-mini-action' href='?_src_=prefs;preference=marking_add;marking_type=[marking_type];limb=[url_encode(limb)];task=input'>[add_label]</a>"
							dat += "<a class='csetup-mini-action csetup-mini-danger' href='?_src_=prefs;preference=markings_clear_limb;marking_type=[marking_type];limb=[url_encode(limb)];task=input'>[clear_label]</a>"
							dat += "</div>"
							dat += "</div>"
							dat += "<table class='csetup-marking-table'>"
							dat += "<thead class='csetup-marking-table-head'><tr><th class='csetup-col-index'>#</th><th class='csetup-col-move'>[move_label]</th><th>[name_column_label]</th><th class='csetup-col-colors'>[colors_label]</th><th class='csetup-col-del'></th></tr></thead>"
							dat += "<tbody>"
							var/has_any = FALSE
							if(length(features[marking_type]))
								var/list/markings = features[marking_type]
								if(!islist(markings))
									markings = list()
								for(var/list/marking_list in markings)
									var/marking_index = markings.Find(marking_list)
									var/limb_value = marking_list[1]
									var/actual_name = GLOB.bodypart_names[num2text(limb_value)]
									if(actual_name != limb)
										continue
									has_any = TRUE
									var/color_marking_dat = ""
									var/number_colors = 1
									var/datum/sprite_accessory/mam_body_markings/S = GLOB.mam_body_markings_list[marking_list[2]]
									var/matrixed_sections = S.covered_limbs[actual_name]
									if(S && matrixed_sections)
										if(length(marking_list) == 2)
											var/first = "#FFFFFF"
											var/second = "#FFFFFF"
											var/third = "#FFFFFF"
											if(features["mcolor"])
												first = "#[features["mcolor"]]"
											if(features["mcolor2"])
												second = "#[features["mcolor2"]]"
											if(features["mcolor3"])
												third = "#[features["mcolor3"]]"
											marking_list += list(list(first, second, third))
										var/primary_index = 1
										var/secondary_index = 2
										var/tertiary_index = 3
										switch(matrixed_sections)
											if(MATRIX_GREEN)
												primary_index = 2
											if(MATRIX_BLUE)
												primary_index = 3
											if(MATRIX_RED_BLUE)
												secondary_index = 2
											if(MATRIX_GREEN_BLUE)
												primary_index = 2
												secondary_index = 3
										color_marking_dat += "<a class='csetup-marking-chip-link' href='?_src_=prefs;preference=marking_color_specific;marking_index=[marking_index];marking_type=[marking_type];number_color=[number_colors];task=input'><span class='csetup-marking-chip' style='background-color: [marking_list[3][primary_index]];' title='[marking_list[3][primary_index]]'></span></a>"
										if(matrixed_sections == MATRIX_RED_BLUE || matrixed_sections == MATRIX_GREEN_BLUE || matrixed_sections == MATRIX_RED_GREEN || matrixed_sections == MATRIX_ALL)
											number_colors = 2
											color_marking_dat += "<a class='csetup-marking-chip-link' href='?_src_=prefs;preference=marking_color_specific;marking_index=[marking_index];marking_type=[marking_type];number_color=[number_colors];task=input'><span class='csetup-marking-chip' style='background-color: [marking_list[3][secondary_index]];' title='[marking_list[3][secondary_index]]'></span></a>"
										if(matrixed_sections == MATRIX_ALL)
											number_colors = 3
											color_marking_dat += "<a class='csetup-marking-chip-link' href='?_src_=prefs;preference=marking_color_specific;marking_index=[marking_index];marking_type=[marking_type];number_color=[number_colors];task=input'><span class='csetup-marking-chip' style='background-color: [marking_list[3][tertiary_index]];' title='[marking_list[3][tertiary_index]]'></span></a>"
									dat += "<tr class='csetup-marking-row'>"
									dat += "<td class='csetup-col-index'>[marking_index]</td>"
									dat += "<td class='csetup-col-move'><span class='csetup-marking-move'>"
									dat += "<a title='[top_label]' href='?_src_=prefs;preference=marking_top;task=input;marking_index=[marking_index];marking_type=[marking_type]'>&#8679;</a>"
									dat += "<a title='[up_label]' href='?_src_=prefs;preference=marking_up;task=input;marking_index=[marking_index];marking_type=[marking_type]'>&#709;</a>"
									dat += "<a title='[down_label]' href='?_src_=prefs;preference=marking_down;task=input;marking_index=[marking_index];marking_type=[marking_type];'>&#708;</a>"
									dat += "<a title='[bottom_label]' href='?_src_=prefs;preference=marking_bottom;task=input;marking_index=[marking_index];marking_type=[marking_type]'>&#8681;</a>"
									dat += "</span></td>"
									dat += "<td>[marking_list[2]]</td>"
									dat += "<td class='csetup-col-colors'>[color_marking_dat]</td>"
									dat += "<td class='csetup-col-del'><a class='csetup-marking-del' href='?_src_=prefs;preference=marking_remove;task=input;marking_index=[marking_index];marking_type=[marking_type]'>&times;</a></td>"
									dat += "</tr>"
							if(!has_any)
								dat += "<tr class='csetup-marking-row csetup-marking-row-empty'><td class='csetup-marking-empty' colspan='5'>Нет маркингов на этой части тела.</td></tr>"
							dat += "</tbody></table>"
							dat += "</section>"
						dat += "</div>"
						dat += "<div class='csetup-danger-zone'>"
						dat += "<div class='csetup-danger-zone-title'>[danger_zone_label]</div>"
						dat += "<a href='?_src_=prefs;preference=markings_remove;task=input'>[remove_all_markings_label]</a>"
						dat += "</div>"
						dat += "</div>"
						dat += "<div class='csetup-markings-classic'>"
						var/add_marking_label = T("add_marking", "Add marking")
						dat += "<center>"
						dat += "<h3>[T(marking_type, GLOB.all_mutant_parts[marking_type])]</h3>" // give it the appropriate title for the type of marking
						dat += "<a href='?_src_=prefs;preference=marking_add;marking_type=[marking_type];task=input'>[add_marking_label]</a>"
						dat += "</center>"

						dat += "<table width=100%><tr>"

						for(var/limb in GLOB.bodypart_values)
							if(length(GLOB.bodypart_values) % 3 != 0)
								continue
							total_pages++

						for(var/limb in GLOB.bodypart_values)
							if(!iterated_markings)
								dat += "<td width=[(100 / total_pages)]%>"
							dat += "<h3><center>[limb]</center></h3>"
							dat += "<table align='center'; width='100%'; height='100px'; style='background-color:#13171C'>"
							dat += "<td width=4%><font size=2> </font></td>"
							dat += "<td width=10%><font size=2> </font></td>"
							dat += "<td width=6%><font size=2> </font></td>"
							dat += "<td width=25%><font size=2> </font></td>"
							dat += "<td width=40%><font size=2> </font></td>"
							dat += "<td width=15%><font size=2> </font></td>"
							dat += "</tr>"

							// list out the current markings you have
							if(length(features[marking_type]))
								var/list/markings = features[marking_type]
								if(!islist(markings))
									// something went terribly wrong
									markings = list()

								for(var/list/marking_list in markings)
									var/marking_index = markings.Find(marking_list) // consider changing loop to go through indexes over lists instead of using Find here
									var/limb_value = marking_list[1]
									var/actual_name = GLOB.bodypart_names[num2text(limb_value)] // get the actual name from the bitflag representing the part the marking is applied to
									if(actual_name != limb)
										continue
									var/color_marking_dat = ""
									var/number_colors = 1
									var/datum/sprite_accessory/mam_body_markings/S = GLOB.mam_body_markings_list[marking_list[2]]
									var/matrixed_sections = S.covered_limbs[actual_name]
									if(S && matrixed_sections)
										// if it has nothing initialize it to white
										if(length(marking_list) == 2)
											var/first = "#FFFFFF"
											var/second = "#FFFFFF"
											var/third = "#FFFFFF"
											if(features["mcolor"])
												first = "#[features["mcolor"]]"
											if(features["mcolor2"])
												second = "#[features["mcolor2"]]"
											if(features["mcolor3"])
												third = "#[features["mcolor3"]]"
											marking_list += list(list(first, second, third)) // just assume its 3 colours if it isnt it doesnt matter we just wont use the other values
										// index magic
										var/primary_index = 1
										var/secondary_index = 2
										var/tertiary_index = 3
										switch(matrixed_sections)
											if(MATRIX_GREEN)
												primary_index = 2
											if(MATRIX_BLUE)
												primary_index = 3
											if(MATRIX_RED_BLUE)
												secondary_index = 2
											if(MATRIX_GREEN_BLUE)
												primary_index = 2
												secondary_index = 3

										// we know it has one matrixed section at minimum
										color_marking_dat += "<a href='?_src_=prefs;preference=marking_color_specific;marking_index=[marking_index];marking_type=[marking_type];number_color=[number_colors];task=input'><span style='border: 1px solid #161616; background-color: [marking_list[3][primary_index]];'><font color='[color_hex2num(marking_list[3][primary_index]) < 200 ? "FFFFFF" : "000000"]'>[marking_list[3][primary_index]]</font></span></a>"
										// if it has a second section, add it
										if(matrixed_sections == MATRIX_RED_BLUE || matrixed_sections == MATRIX_GREEN_BLUE || matrixed_sections == MATRIX_RED_GREEN || matrixed_sections == MATRIX_ALL)
											number_colors = 2
											color_marking_dat += "<a href='?_src_=prefs;preference=marking_color_specific;marking_index=[marking_index];marking_type=[marking_type];number_color=[number_colors];task=input'><span style='border: 1px solid #161616; background-color: [marking_list[3][secondary_index]];'><font color='[color_hex2num(marking_list[3][secondary_index]) < 200 ? "FFFFFF" : "000000"]'>[marking_list[3][secondary_index]]</font></span></a>"
										// if it has a third section, add it
										if(matrixed_sections == MATRIX_ALL)
											number_colors = 3
											color_marking_dat += "<a href='?_src_=prefs;preference=marking_color_specific;marking_index=[marking_index];marking_type=[marking_type];number_color=[number_colors];task=input'><span style='border: 1px solid #161616; background-color: [marking_list[3][tertiary_index]];'><font color='[color_hex2num(marking_list[3][tertiary_index]) < 200 ? "FFFFFF" : "000000"]'>[marking_list[3][tertiary_index]]</font></span></a>"
									dat += "<tr style='vertical-align:top;'>"
									dat += "<td>[marking_index]</td>"
									dat += "<td><a href='?_src_=prefs;preference=marking_up;task=input;marking_index=[marking_index];marking_type=[marking_type]'>&#709;</a></td>"
									dat += "<td><a href='?_src_=prefs;preference=marking_down;task=input;marking_index=[marking_index];marking_type=[marking_type];'>&#708;</a></td>"
									dat += "<td>[marking_list[2]]</td>"
									dat += "<td>[color_marking_dat]</td>"
									dat += "<td><a href='?_src_=prefs;preference=marking_remove;task=input;marking_index=[marking_index];marking_type=[marking_type]'>X</a></td>"
									dat += "</tr>"

							else
								dat += "<tr style='vertical-align:top;'>"
								dat += "<td> </td>"
								dat += "<td> </td>"
								dat += "<td> </td>"
								dat += "<td> </td>"
								dat += "<td> </td>"
								dat += "<td> </td>"
								dat += "</tr>"

							dat += "</table>"

							iterated_markings++
							if(iterated_markings >= 3)
								dat += "</td>"
								iterated_markings = 0
						dat += "</tr></table>"
						// BLUEMOON ADD START - кнопка для удаления всех маркингов на персонаже
						dat += "<center>"
						dat += "<h3>Danger Zone</h3>"
						dat += "<a href='?_src_=prefs;preference=markings_remove;task=input'>Remove All Markings</a>"
						dat += "</center>"
						// BLUEMOON ADD END
						dat += "</div>"

				if(SPEECH_CHAR_TAB)
					dat += "<table><tr><td width='340px' height='300px' valign='top'>"
					var/speech_preferences_label = T("speech_preferences", "Speech preferences")
					var/custom_speech_verb_label = T("custom_speech_verb", "Custom Speech Verb")
					var/custom_tongue_label = T("custom_tongue", "Custom Tongue")
					var/laugh_label = T("laugh", "Laugh")
					var/preview_laugh_label = T("preview_laugh", "Preview Laugh")
					var/additional_language_label = T("additional_language", "Additional Language")
					var/custom_runechat_color_label = T("custom_runechat_color", "Custom runechat color")
					var/vocal_bark_preferences_label = T("vocal_bark_preferences", "Vocal Bark preferences")
					var/vocal_bark_sound_label = T("vocal_bark_sound", "Vocal Bark Sound")
					var/vocal_bark_speed_label = T("vocal_bark_speed", "Vocal Bark Speed")
					var/vocal_bark_pitch_label = T("vocal_bark_pitch", "Vocal Bark Pitch")
					var/vocal_bark_variance_label = T("vocal_bark_variance", "Vocal Bark Variance")
					var/preview_bark_label = T("preview_bark", "Preview Bark")
					var/invalid_label = T("invalid_label", "INVALID")
					dat += "<h2>[speech_preferences_label]</h2>"
					dat += "<b>[custom_speech_verb_label]</b><BR>"
					dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=speech_verb;task=input'>[custom_speech_verb]</a><BR>"
					dat += "<b>[custom_tongue_label]</b><BR>"
					dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=tongue;task=input'>[custom_tongue]</a><BR>"
					// BLUEMOON ADD выбор смеха
					dat += "<b>[laugh_label]</b><BR>"
					dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=laugh;task=input'>[custom_laugh]</a>"
					if(custom_laugh != "Default")
						dat += "<a href='?_src_=prefs;preference=laughpreview;task=input''>[preview_laugh_label]</a><BR>"
					// BLUEMOON ADD END
					//SANDSTORM EDIT - additional language + runechat color
					dat += "<BR><b>[additional_language_label]</b><br>"
					dat += "<a href='?_src_=prefs;preference=language;task=menu'>[english_list(language, none_label)]</a></center><BR>"
					dat += "<BR><b>[custom_runechat_color_label]</b> <a href='?_src_=prefs;preference=enable_personal_chat_color'>[enable_personal_chat_color ? enabled_label : disabled_label]</a><br> [enable_personal_chat_color ? "<span style='border: 1px solid #161616; background-color: [personal_chat_color];'><font color='[color_hex2num(personal_chat_color) < 200 ? "#FFFFFF" : "#000000"]'>[personal_chat_color]</font></span> <a href='?_src_=prefs;preference=personal_chat_color;task=input'>[change_label]</a>" : ""]<br>"
					dat += "</td>"
					//END OF SANDSTORM EDIT
					dat += "<td width='340px' height='300px' valign='top'>"
					dat += "<h2>[vocal_bark_preferences_label]</h2>"
					var/datum/bark/B = GLOB.bark_list[bark_id]
					dat += "<b>[vocal_bark_sound_label]</b><BR>"
					dat += "<a style='display:block;width:200px' href='?_src_=prefs;preference=barksound;task=input'>[B ? initial(B.name) : invalid_label]</a><BR>"
					dat += "<b>[vocal_bark_speed_label]</b> <a href='?_src_=prefs;preference=barkspeed;task=input'>[bark_speed]</a><BR>"
					dat += "<b>[vocal_bark_pitch_label]</b> <a href='?_src_=prefs;preference=barkpitch;task=input'>[bark_pitch]</a><BR>"
					dat += "<b>[vocal_bark_variance_label]</b> <a href='?_src_=prefs;preference=barkvary;task=input'>[bark_variance]</a><BR>"
					dat += "<BR><a href='?_src_=prefs;preference=barkpreview'>[preview_bark_label]</a><BR>"
					dat += "</td>"
					dat += "</tr></table>"
				if(LOADOUT_CHAR_TAB)
					dat += "<table align='center' width='100%'>"
					var/loadout_slot_label = T("loadout_slot", "Loadout slot")
					dat += "<tr><td colspan=4><center><b>[loadout_slot_label]</b></center></td></tr>"
					dat += "<tr><td colspan=4><center>"
					for(var/iteration in 1 to MAXIMUM_LOADOUT_SAVES)
						var/loadout_slot_attr = (loadout_slot == iteration) ? "class='linkOn'" : "href='?_src_=prefs;preference=gear;select_slot=[iteration]'"
						dat += "<a [loadout_slot_attr]>[iteration]</a>"
					dat += "</center></td></tr>"
					dat += "<tr><td colspan=4><center><i style=\"color: grey;\">You can only choose one item per category, unless it's an item that spawns in your backpack or hands.</center></td></tr>"
					dat += "<tr><td colspan=4><center><b>"

					if(!length(GLOB.loadout_items))
						dat += "<center>ERROR: No loadout categories - something is horribly wrong!"
					else
						if(!GLOB.loadout_categories[gear_category])
							gear_category = GLOB.loadout_categories[1]
						var/firstcat = TRUE
						for(var/category in GLOB.loadout_categories)
							if(firstcat)
								firstcat = FALSE
							else
								dat += " |"
							if(category == gear_category)
								dat += " <a href='?_src_=prefs;preference=gear;select_category=[url_encode(category)]' class='linkOn'>[(category == LOADOUT_CATEGORY_ERROR && loadout_errors) ? "[category] (<font color=\"red\">!</font>)" : category]</a> "
							else
								dat += " <a href='?_src_=prefs;preference=gear;select_category=[url_encode(category)]'>[(category == LOADOUT_CATEGORY_ERROR && loadout_errors) ? "[category] (<font color=\"red\">!</font>)" : category]</a> "

						dat += "</b></center></td></tr>"
						dat += "<tr><td colspan=4><hr></td></tr>"

						dat += "<tr><td colspan=4><center><b>"

						if(!length(GLOB.loadout_categories[gear_category]))
							dat += "No subcategories detected. Something is horribly wrong!"
						else
							var/list/subcategories = GLOB.loadout_categories[gear_category]
							if(!subcategories.Find(gear_subcategory))
								gear_subcategory = subcategories[1]

							var/firstsubcat = TRUE
							for(var/subcategory in subcategories)
								if(firstsubcat)
									firstsubcat = FALSE
								else
									dat += " |"
								if(gear_subcategory == subcategory)
									dat += " <a href='?_src_=prefs;preference=gear;select_subcategory=[url_encode(subcategory)]' class='linkOn'>[subcategory]</a> "
								else
									dat += " <a href='?_src_=prefs;preference=gear;select_subcategory=[url_encode(subcategory)]'>[subcategory]</a> "
							dat += "</b></center></td></tr>"

							var/even = FALSE
							if(gear_category != LOADOUT_CATEGORY_ERROR)
								dat += "<table align='center'; width='100%'; height='100%'; style='background-color:#13171C'>"
								dat += "<center>"
								dat += "<tr width=10% style='vertical-align:top;'><td width=15%><b>Name</b></td>"
								dat += "<td style='vertical-align:top'><b>Cost</b></td>"
								dat += "<td width=10%><font size=2><b>Restrictions</b></font></td>"
								dat += "<td width=80%><font size=2><b>Description</b></font></td></tr>"
								dat += "</center>"

								// BLUEMOON FIX - Add null check to prevent runtime when category/subcategory has no items
								var/list/category_items = GLOB.loadout_items[gear_category]
								var/list/subcategory_items = category_items ? category_items[gear_subcategory] : null
								if(!length(subcategory_items))
									// Only log if category SHOULD exist (defined in loadout_categories) but has no items (initialization failure)
									if(GLOB.loadout_categories[gear_category] && (gear_subcategory in GLOB.loadout_categories[gear_category]))
										stack_trace("Loadout init failure: Category '[gear_category]'/subcategory '[gear_subcategory]' defined but has no items (user: [user?.ckey])")
									dat += "<tr><td colspan=4><center><i style=\"color: grey;\">No items available in this category.</i></center></td></tr>"
								// BLUEMOON FIX END
								for(var/name in subcategory_items)
									var/datum/gear/gear = subcategory_items[name]
									if(!gear)
										continue
									var/donoritem = gear.donoritem
									if(donoritem && !gear.donator_ckey_check(user.ckey))
										continue
									var/background_cl = "#23273C"
									if(even)
										background_cl = "#17191C"
									even = !even
									var/class_link = ""
									var/list/loadout_item = has_loadout_gear(loadout_slot, "[gear.type]")
									var/extra_loadout_data = ""
									if(gear.base64icon)
										extra_loadout_data += "<center><img src='data:image/jpeg;base64,[gear.base64icon]'></center>"
									if(loadout_item)
										class_link = "style='white-space:normal;' class='linkOn' href='?_src_=prefs;preference=gear;toggle_gear_path=[url_encode(name)];toggle_gear=0'"
										if(gear.loadout_flags & LOADOUT_CAN_COLOR_POLYCHROMIC)
											extra_loadout_data += "<BR><a href='?_src_=prefs;preference=gear;loadout_color_polychromic=1;loadout_gear_name=[url_encode(gear.name)];'>Color</a>"
											for(var/loadout_color in loadout_item[LOADOUT_COLOR])
												extra_loadout_data += "<span style='border: 1px solid #161616; background-color: [loadout_color];'><font color='[color_hex2num(loadout_color) < 200 ? "FFFFFF" : "000000"]'>[loadout_color]</font></span>"
										else
											var/loadout_color_non_poly = "#FFFFFF"
											if(length(loadout_item[LOADOUT_COLOR]))
												loadout_color_non_poly = loadout_item[LOADOUT_COLOR][1]
											extra_loadout_data += "<BR><a href='?_src_=prefs;preference=gear;loadout_color=1;loadout_gear_name=[url_encode(gear.name)];'>Color</a>"
											extra_loadout_data += "<span style='border: 1px solid #161616; background-color: [loadout_color_non_poly];'><font color='[color_hex2num(loadout_color_non_poly) < 200 ? "FFFFFF" : "000000"]'>[loadout_color_non_poly]</font></span>"
											extra_loadout_data += "<BR><a href='?_src_=prefs;preference=gear;loadout_color_HSV=1;loadout_gear_name=[url_encode(gear.name)];'>HSV Color</a>" // SPLURT EDIT
										if(gear.loadout_flags & LOADOUT_CAN_NAME)
											extra_loadout_data += "<BR><a href='?_src_=prefs;preference=gear;loadout_rename=1;loadout_gear_name=[url_encode(gear.name)];'>Name</a> [loadout_item[LOADOUT_CUSTOM_NAME] ? loadout_item[LOADOUT_CUSTOM_NAME] : "N/A"]"
										if(gear.loadout_flags & LOADOUT_CAN_DESCRIPTION)
											extra_loadout_data += "<BR><a href='?_src_=prefs;preference=gear;loadout_redescribe=1;loadout_gear_name=[url_encode(gear.name)];'>Description</a>"
										else
											extra_loadout_data += "<BR><a href='?_src_=prefs;preference=gear;loadout_addheirloom=1;loadout_gear_name=[url_encode(gear.name)];'>Select as Heirloom</a><BR>"
										// BLUEMOON ADD START - выбор вещей из лодаута как family heirloom
										if(loadout_item[LOADOUT_IS_HEIRLOOM])
											extra_loadout_data += "<BR><a class='linkOn' href='?_src_=prefs;preference=gear;loadout_removeheirloom=1;loadout_gear_name=[url_encode(gear.name)];'>Select as Heirloom</a><BR>"
										else
											extra_loadout_data += "<BR><a href='?_src_=prefs;preference=gear;loadout_addheirloom=1;loadout_gear_name=[url_encode(gear.name)];'>Select as Heirloom</a><BR>"
										if(ispath(gear.path, /obj/item/clothing))
											extra_loadout_data += "<BR><a [loadout_item["loadout_examtooltip"] ? "class='linkOn' " : ""]href='?_src_=prefs;preference=gear;loadout_examtooltip=1;loadout_gear_name=[url_encode(gear.name)];'>Examine tooltip: [loadout_item["loadout_examtooltip"] ? "Set!" : "None"]</a>"
										if(ispath(gear.path, /obj/item/clothing/neck/petcollar)) //"name tag" sounds better for me, but in petcollar code "tagname" is used so let it be.
											extra_loadout_data += "<BR><a href='?_src_=prefs;preference=gear;loadout_tagname=1;loadout_gear_name=[url_encode(gear.name)];'>Name tag</a> [loadout_item["loadout_custom_tagname"] ? loadout_item["loadout_custom_tagname"] : "Name tag is visible for everyone looking at wearer."]"
								  // BLUEMOON ADD END
									else if(!is_loadout_slot_available(gear.category))
										class_link = "style='white-space:normal;' class='linkOff'"
									else if((gear_points - gear.cost) < 0)
										class_link = "style='white-space:normal;' class='linkOff'"
									else if(donoritem)
										class_link = "style='white-space:normal;background:#2e6eeb;' href='?_src_=prefs;preference=gear;toggle_gear_path=[url_encode(name)];toggle_gear=1'"
									else if(!istype(gear, /datum/gear/unlockable) || can_use_unlockable(gear))
										class_link = "style='white-space:normal;' href='?_src_=prefs;preference=gear;toggle_gear_path=[url_encode(name)];toggle_gear=1'"
									else
										class_link = "style='white-space:normal;background:#eb2e2e;' class='linkOff'"
									dat += "<tr style='vertical-align:top; background-color: [background_cl];'><td width=15%><a [class_link]>[name]</a>[extra_loadout_data]</td>"
									dat += "<td width = 5% style='vertical-align:top'>[gear.cost]</td><td>"
									if(islist(gear.restricted_roles))
										if(gear.restricted_roles.len)
											if(gear.restricted_desc)
												dat += "<font size=2>"
												dat += gear.restricted_desc
												dat += "</font>"
											else
												dat += "<font size=2>"
												dat += gear.restricted_roles.Join(";")
												dat += "</font>"
									if(!istype(gear, /datum/gear/unlockable))
										var/is_heirloom_string = loadout_item ? (loadout_item[LOADOUT_IS_HEIRLOOM] ? "<br><br><center><b>Ваша семейная реликвия!</b></center>" : "") : "" // BLUEMOON EDIT - выбор вещей из лодаута как family heirloom
										// the below line essentially means "if the loadout item is picked by the user and has a custom description, give it the custom description, otherwise give it the default description"
										dat += "</td><td><font size=2><i>[loadout_item ? (loadout_item[LOADOUT_CUSTOM_DESCRIPTION] ? loadout_item[LOADOUT_CUSTOM_DESCRIPTION] : gear.description) : gear.description]</i> [is_heirloom_string]</font></td></tr>" // BLUEMOON EDIT - выбор вещей из лодаута как family heirloom
									else
										//we add the user's progress to the description assuming they have progress
										var/datum/gear/unlockable/unlockable = gear
										var/progress_made = unlockable_loadout_data[unlockable.progress_key]
										if(!progress_made)
											progress_made = 0
										dat += "</td><td><font size=2><i>[loadout_item ? (loadout_item[LOADOUT_CUSTOM_DESCRIPTION] ? loadout_item[LOADOUT_CUSTOM_DESCRIPTION] : gear.description) : gear.description] Progress: [min(progress_made, unlockable.progress_required)]/[unlockable.progress_required]</i></font></td></tr>"
								dat += "</table>"
							else
								dat += "<table align='center'; width='100%'; height='100%'; style='background-color:#13171C'>"
								dat += "<center>"
								dat += "<tr width=10% style='vertical-align:top;'><td width=15%><b>Item type</b></td>"
								dat += "<td><font size=2><b>Data contained</b></font></td></tr>"
								dat += "</center>"
								var/list/sanitize_current_slot = loadout_data["SAVE_[loadout_slot]"]
								for(var/list/entry in sanitize_current_slot)
									var/test_item = entry["loadout_item"]
									if(text2path(test_item))
										continue
									var/background_cl = "#23273C"
									if(even)
										background_cl = "#17191C"
									even = !even
									var/test_item_display = test_item ? test_item : "no path!!?! Report to an admin!"
									var/encoded_test_item = url_encode(test_item ? test_item : "")
									dat += "<tr style='vertical-align:top; background-color: [background_cl];'><td width=15%><a style='white-space:normal;' href='?_src_=prefs;preference=gear;clear_invalid_gear=[encoded_test_item];'>[test_item_display]</a></td>"
									dat += "<td style='vertical-align:top'>"
									var/list/other_data = entry["loadout_item"] ? entry - "loadout_item" : entry
									dat += json_encode(other_data)
									dat += "</td></tr>"
					dat += "</table>"
			dat += "</div>" // end csetup-settings-content
			dat += "</div>" // end csetup-settings-wrap
		if(PREFERENCES_TAB) // Game Preferences
			dat += "<center>"
			// Declare common labels used across multiple preferences tabs to avoid undefined var errors
			var/enabled_label = T("enabled", "Enabled")
			var/disabled_label = T("disabled", "Disabled")
			var/change_label = T("change", "Change")
			var/yes_label = T("yes", "Yes")
			var/no_label = T("no", "No")
			var/pref_general = T("pref_general", "General")
			var/pref_ooc = T("pref_ooc", "OOC")
			var/pref_content = T("pref_content", "Content")
			dat += "<a href='?_src_=prefs;preference=preferences_tab;tab=[GAME_PREFS_TAB]' " + (preferences_tab == GAME_PREFS_TAB ? "class='linkOn'" : "") + ">[pref_general]</a>"
			dat += "<a href='?_src_=prefs;preference=preferences_tab;tab=[OOC_PREFS_TAB]' " + (preferences_tab == OOC_PREFS_TAB ? "class='linkOn'" : "") + ">[pref_ooc]</a>"
			dat += "<a href='?_src_=prefs;preference=preferences_tab;tab=[CONTENT_PREFS_TAB]' " + (preferences_tab == CONTENT_PREFS_TAB ? "class='linkOn'" : "") + ">[pref_content]</a>"
			dat += "</center>"
			dat += "<HR>"
			switch(preferences_tab)
				if(GAME_PREFS_TAB)
					dat += "<table><tr><td width='340px' height='300px' valign='top'>"
					var/ui_style_label = T("ui_style", "UI Style")
					var/outline_label = T("outline", "Outline")
					var/outline_color_label = T("outline_color", "Outline Color")
					var/outline_color_theme_based = T("outline_color_theme_based", "Theme-based (null)")
					var/screentip_label = T("screentip", "Screentip")
					var/screentip_color_label = T("screentip_color", "Screentip Color")
					var/screentip_images_label = T("screentip_images_label", "Screentip context with images")
					var/screentip_images_tooltip = T("screentip_images_tooltip", "This is an accessibility preference, if disabled, fallbacks to only text which colorblind people can understand better")
					var/allowed_label = T("allowed", "Allowed")
					var/disallowed_label = T("disallowed", "Disallowed")
					var/tgui_input_label = T("tgui_input_mode", "Input Framework")
					var/tgui_input_verbs_label = T("tgui_input_verbs", "Input Verbs (SAY, ME, OOC, etc.) Framework")
					var/tgui_monitors_label = T("tgui_monitors", "tgui Monitors")
					var/tgui_monitor_primary = T("tgui_monitor_primary", "Primary")
					var/tgui_monitor_all = T("tgui_monitor_all", "All")
					var/tgui_style_label = T("tgui_style", "tgui Style")
					var/tgui_style_fancy = T("tgui_style_fancy", "Fancy")
					var/tgui_style_no_frills = T("tgui_style_no_frills", "No Frills")
					var/runechat_bubbles_label = T("runechat_bubbles", "Show Runechat Chat Bubbles")
					var/runechat_looc_bubbles_label = T("runechat_looc_bubbles", "Show Runechat LOOC Chat Bubbles")
					var/runechat_char_limit_label = T("runechat_char_limit", "Runechat message char limit")
					var/runechat_non_mobs_label = T("runechat_non_mobs", "See Runechat for non-mobs")
					var/runechat_emotes_label = T("runechat_emotes", "See Runechat for emotes")
					var/pixelshift_view_label = T("pixelshift_view", "Shift view when pixelshifting")
					var/ghost_form_label = T("ghost_form", "Ghost Form")
					var/ghost_orbit_label = T("ghost_orbit", "Ghost Orbit")
					var/ghost_accessories_label = T("ghost_accessories", "Ghost Accessories")
					var/ghosts_of_others_label = T("ghosts_of_others", "Ghosts of Others")
					var/ghost_ears_label = T("ghost_ears", "Ghost Ears")
					var/ghost_radio_label = T("ghost_radio", "Ghost Radio")
					var/ghost_sight_label = T("ghost_sight", "Ghost Sight")
					var/ghost_whispers_label = T("ghost_whispers", "Ghost Whispers")
					var/ghost_pda_label = T("ghost_pda", "Ghost PDA")
					var/ghost_all_speech_label = T("ghost_all_speech", "All Speech")
					var/ghost_nearest_creatures_label = T("ghost_nearest_creatures", "Nearest Creatures")
					var/ghost_all_messages_label = T("ghost_all_messages", "All Messages")
					var/ghost_no_messages_label = T("ghost_no_messages", "No Messages")
					var/ghost_all_emotes_label = T("ghost_all_emotes", "All Emotes")
					var/auto_capitalize_label = T("auto_capitalize", "Auto-Capitalize Speech")
					var/preferred_chaos_level_label = T("preferred_chaos_level", "Preferred Chaos Level")
					var/antag_banned_label = T("antag_banned", "You are banned from antagonist roles.")
					var/disable_all_antag_label = T("disable_all_antag", "DISABLE ALL ANTAGONISM")
					var/be_role_label = T("be_role", "Be")
					var/banned_label = T("banned", "BANNED")
					var/in_label = T("in_label", "IN")
					var/days_label = T("days_label", "DAYS")
					var/low_label = T("low", "Low")
					var/allow_midround_antag_label = T("allow_midround_antag", "Allow Midround Antagonist Roll")
					var/sec_interface = T("pref_sec_interface", "Interface")
					var/sec_chat = T("pref_sec_chat", "Chat")
					var/sec_ghost = T("pref_sec_ghost", "Ghost")
					var/sec_misc = T("pref_sec_misc", "Other")
					var/sec_antag = T("pref_sec_antag", "Antagonists")
					dat += "<h2>[sec_interface]</h2>"
					dat += "<b>[ui_style_label]:</b> <a href='?_src_=prefs;task=input;preference=ui'>[UI_style]</a><br>"
					dat += "<b>[outline_label]:</b> <a href='?_src_=prefs;preference=outline_enabled'>[outline_enabled ? enabled_label : disabled_label]</a><br>"
					dat += "<b>[outline_color_label]:</b> [outline_color ? "<span style='border:1px solid #161616; background-color: [outline_color];'>" : "[outline_color_theme_based]"]<font color='[color_hex2num(outline_color) < 200 ? "FFFFFF" : "000000"]'>[outline_color]</font></span> <a href='?_src_=prefs;preference=outline_color'>[change_label]</a><BR>"
					dat += "<b>[screentip_label]:</b> <a href='?_src_=prefs;preference=screentip_pref'>[screentip_pref]</a><br>"
					dat += "<b>[screentip_color_label]:</b> <span style='border:1px solid #161616; background-color: [screentip_color];'><font color='[color_hex2num(screentip_color) < 200 ? "FFFFFF" : "000000"]'>[screentip_color]</font></span> <a href='?_src_=prefs;preference=screentip_color'>[change_label]</a><BR>"
					dat += "<font style='border-bottom:2px dotted white; cursor:help;'\
						title=\"[screentip_images_tooltip]\">\
						<b>[screentip_images_label]:</b></font> <a href='?_src_=prefs;preference=screentip_images'>[screentip_images ? allowed_label : disallowed_label]</a><br>"
					dat += "<b>[tgui_input_label]:</b> <a href='?_src_=prefs;preference=tgui_input_mode'>[(tgui_input_mode) ? "TGUI" : "BYOND"]</a><br>"
					if(tgui_input_mode)
						dat += "<b>[tgui_input_verbs_label]:</b> <a href='?_src_=prefs;preference=tgui_input_verbs'>[(tgui_input_verbs) ? "TGUI" : "BYOND"]</a><br>"
					dat += "<b>[tgui_monitors_label]:</b> <a href='?_src_=prefs;preference=tgui_lock'>[(tgui_lock) ? tgui_monitor_primary : tgui_monitor_all]</a><br>"
					dat += "<b>[tgui_style_label]:</b> <a href='?_src_=prefs;preference=tgui_fancy'>[(tgui_fancy) ? tgui_style_fancy : tgui_style_no_frills]</a><br>"
					dat += "<h2>[sec_chat]</h2>"
					dat += "<b>[runechat_bubbles_label]:</b> <a href='?_src_=prefs;preference=chat_on_map'>[chat_on_map ? enabled_label : disabled_label]</a><br>"
					if(chat_on_map)
						dat += "<b>[runechat_looc_bubbles_label]:</b> <a href='?_src_=prefs;preference=chat_on_map_looc'>[chat_on_map_looc ? enabled_label : disabled_label]</a><br>"
					dat += "<b>[runechat_char_limit_label]:</b> <a href='?_src_=prefs;preference=max_chat_length;task=input'>[max_chat_length]</a><br>"
					dat += "<b>[runechat_non_mobs_label]:</b> <a href='?_src_=prefs;preference=see_chat_non_mob'>[see_chat_non_mob ? enabled_label : disabled_label]</a><br>"
					//SANDSTORM CHANGES BEGIN
					dat += "<b>[runechat_emotes_label]:</b> <a href='?_src_=prefs;preference=see_chat_emotes'>[see_chat_emotes ? enabled_label : disabled_label]</a><br>"
					//SANDSTORM CHANGES END
					dat += "<b>[pixelshift_view_label]:</b> <a href='?_src_=prefs;preference=view_pixelshift'>[view_pixelshift ? enabled_label : disabled_label]</a><br>" //SPLURT Edit
					dat += "<h2>[sec_ghost]</h2>"
					dat += "<b>[ghost_ears_label]:</b> <a href='?_src_=prefs;preference=ghost_ears'>[(chat_toggles & CHAT_GHOSTEARS) ? ghost_all_speech_label : ghost_nearest_creatures_label]</a><br>"
					dat += "<b>[ghost_radio_label]:</b> <a href='?_src_=prefs;preference=ghost_radio'>[(chat_toggles & CHAT_GHOSTRADIO) ? ghost_all_messages_label : ghost_no_messages_label]</a><br>"
					dat += "<b>[ghost_sight_label]:</b> <a href='?_src_=prefs;preference=ghost_sight'>[(chat_toggles & CHAT_GHOSTSIGHT) ? ghost_all_emotes_label : ghost_nearest_creatures_label]</a><br>"
					dat += "<b>[ghost_whispers_label]:</b> <a href='?_src_=prefs;preference=ghost_whispers'>[(chat_toggles & CHAT_GHOSTWHISPER) ? ghost_all_speech_label : ghost_nearest_creatures_label]</a><br>"
					dat += "<b>[ghost_pda_label]:</b> <a href='?_src_=prefs;preference=ghost_pda'>[(chat_toggles & CHAT_GHOSTPDA) ? ghost_all_messages_label : ghost_nearest_creatures_label]</a><br>"
					if(unlock_content)
						dat += "<b>[ghost_form_label]:</b> <a href='?_src_=prefs;task=input;preference=ghostform'>[ghost_form]</a><br>"
						dat += "<b>[ghost_orbit_label]:</b> <a href='?_src_=prefs;task=input;preference=ghostorbit'>[ghost_orbit]</a><br>"
					var/button_name_ghost = "If you see this something went wrong."
					switch(ghost_accs)
						if(GHOST_ACCS_FULL)
							button_name_ghost = GHOST_ACCS_FULL_NAME
						if(GHOST_ACCS_DIR)
							button_name_ghost = GHOST_ACCS_DIR_NAME
						if(GHOST_ACCS_NONE)
							button_name_ghost = GHOST_ACCS_NONE_NAME
					dat += "<b>[ghost_accessories_label]:</b> <a href='?_src_=prefs;task=input;preference=ghostaccs'>[button_name_ghost]</a><br>"
					switch(ghost_others)
						if(GHOST_OTHERS_THEIR_SETTING)
							button_name_ghost = GHOST_OTHERS_THEIR_SETTING_NAME
						if(GHOST_OTHERS_DEFAULT_SPRITE)
							button_name_ghost = GHOST_OTHERS_DEFAULT_SPRITE_NAME
						if(GHOST_OTHERS_SIMPLE)
							button_name_ghost = GHOST_OTHERS_SIMPLE_NAME
					dat += "<b>[ghosts_of_others_label]:</b> <a href='?_src_=prefs;task=input;preference=ghostothers'>[button_name_ghost]</a><br>"
					dat += "<h2>[sec_misc]</h2>"
					dat += "<b>[auto_capitalize_label]:</b> <a href='?_src_=prefs;preference=auto_capitalize_enabled'>[(auto_capitalize_enabled ? enabled_label : disabled_label)]</a><br>"
					dat += "<b>[preferred_chaos_level_label]:</b> <a style='display:block;width:30px' href='?_src_=prefs;preference=preferred_chaos_level'>[preferred_chaos_level]</a><br>"

					dat += "</td>"

					dat += "<td width='300px' height='300px' valign='top'>"

					dat += "<h2>[sec_antag]</h2>"

					if(jobban_isbanned(user, ROLE_INTEQ))
						dat += "<font color=red><b>[antag_banned_label]</b></font>"
						src.be_special = list()

					dat += "<b>[disable_all_antag_label]</b> <a href='?_src_=prefs;preference=disable_antag'>[(toggles & NO_ANTAG) ? yes_label : no_label]</a><br>"

					for (var/i in GLOB.special_roles)
						if(jobban_isbanned(user, i))
							dat += "<b>[be_role_label] [capitalize(i)]:</b> <a href='?_src_=prefs;jobbancheck=[i]'>[banned_label]</a><br>"
						else
							var/days_remaining = null
							if(ispath(GLOB.special_roles[i]) && CONFIG_GET(flag/use_age_restriction_for_jobs)) //If it's a game mode antag, check if the player meets the minimum age
								var/mode_path = GLOB.special_roles[i]
								var/datum/game_mode/temp_mode = new mode_path
								days_remaining = temp_mode.get_remaining_days(user.client)

							if(days_remaining)
								dat += "<b>[be_role_label] [capitalize(i)]:</b> <font color=red> \[[in_label] [days_remaining] [days_label]\]</font><br>"
							else
								var/enabled_text = ""
								if(i in be_special)
									if(be_special[i] >= 1)
										enabled_text = enabled_label
									else
										enabled_text = low_label
								else
									enabled_text = disabled_label
								dat += "<b>[be_role_label] [capitalize(i)]:</b> <a href='?_src_=prefs;preference=be_special;be_special_type=[i]'>[enabled_text]</a><br>"
					dat += "<b>[allow_midround_antag_label]:</b> <a href='?_src_=prefs;preference=allow_midround_antag'>[(toggles & MIDROUND_ANTAG) ? enabled_label : disabled_label]</a><br>"

					dat += "</td></tr></table>"

				if(OOC_PREFS_TAB)
					dat += "<table>"
					dat += "<tr><td width='340px' height='300px' valign='top'>"
					var/window_flashing_label = T("window_flashing", "Window Flashing")
					var/window_noise_label = T("window_noise", "Window Noise")
					var/play_admin_midis_label = T("play_admin_midis", "Play Admin MIDIs")
					var/play_lobby_music_label = T("play_lobby_music", "Play Lobby Music")
					var/see_pull_requests_label = T("see_pull_requests", "See Pull Requests")
					var/byond_publicity_label = T("byond_membership_publicity", "BYOND Membership Publicity")
					var/public_label = T("public", "Public")
					var/hidden_label = T("hidden", "Hidden")
					var/custom_color_ooc_label = T("custom_color_ooc", "Custom OOC Color")
					var/ooc_color_label = T("ooc_color", "OOC Color")
					var/custom_color_aooc_label = T("custom_color_aooc", "Custom AOOC Color")
					var/antag_ooc_color_label = T("antag_ooc_color", "Antag OOC Color")
					var/adminhelp_sounds_label = T("adminhelp_sounds", "Adminhelp Sounds")
					var/announce_login_label = T("announce_login", "Announce Login")
					var/combo_hud_lighting_label = T("combo_hud_lighting", "Combo HUD Lighting")
					var/full_bright_label = T("full_bright", "Full-bright")
					var/no_change_label = T("no_change", "No Change")
					var/deadmin_while_playing_label = T("deadmin_while_playing", "Deadmin While Playing")
					var/onlogin_deadmin_label = T("onlogin_deadmin", "Deadmin On Login")
					var/onspawn_deadmin_label = T("onspawn_deadmin", "Deadmin On Spawn")
					var/forced_label = T("forced", "FORCED")
					var/as_antag_label = T("as_antag", "As Antag")
					var/as_command_label = T("as_command", "As Command")
					var/as_security_label = T("as_security", "As Security")
					var/as_silicon_label = T("as_silicon", "As Silicon")
					var/deadmin_label = T("deadmin", "Deadmin")
					var/keep_admin_label = T("keep_admin", "Keep Admin")
					var/sec_sound = T("pref_sec_sound", "Sound")
					var/sec_notify = T("pref_sec_notify", "Notifications")
					var/sec_ooc = T("pref_sec_ooc", "OOC")
					var/sec_admin = T("pref_sec_admin", "Administrator")
					dat += "<h2>[sec_sound]</h2>"
					dat += "<b>[play_admin_midis_label]:</b> <a href='?_src_=prefs;preference=hear_midis'>[(toggles & SOUND_MIDI) ? enabled_label : disabled_label]</a><br>"
					dat += "<b>[play_lobby_music_label]:</b> <a href='?_src_=prefs;preference=lobby_music'>[(toggles & SOUND_LOBBY) ? enabled_label : disabled_label]</a><br>"
					dat += "<h2>[sec_notify]</h2>"
					dat += "<b>[window_flashing_label]:</b> <a href='?_src_=prefs;preference=winflash'>[(windowflashing) ? enabled_label : disabled_label]</a><br>"
					dat += "<b>[window_noise_label]:</b> <a href='?_src_=prefs;preference=winnoise'>[(windownoise) ? enabled_label : disabled_label]</a><br>"
					dat += "<b>[see_pull_requests_label]:</b> <a href='?_src_=prefs;preference=pull_requests'>[(chat_toggles & CHAT_PULLR) ? enabled_label : disabled_label]</a><br>"
					dat += "<h2>[sec_ooc]</h2>"
					if(user.client)
						if(unlock_content)
							dat += "<b>[byond_publicity_label]:</b> <a href='?_src_=prefs;preference=publicity'>[(toggles & MEMBER_PUBLIC) ? public_label : hidden_label]</a><br>"
						if(unlock_content || is_admin(user.client))
							dat += "<b>[custom_color_ooc_label]:</b> <a href='?_src_=prefs;preference=custom_color_ooc'>[(custom_colors & CUSTOM_OOC)? enabled_label : disabled_label]</a><br>"
							if(custom_colors & CUSTOM_OOC)
								dat += "<b>[ooc_color_label]:</b> <span style='border: 1px solid #161616; background-color: [ooccolor ? ooccolor : GLOB.normal_ooc_colour];'><font color='[color_hex2num(ooccolor ? ooccolor : GLOB.normal_ooc_colour) < 200 ? "FFFFFF" : "000000"]'>[ooccolor ? ooccolor : GLOB.normal_ooc_colour]</font></span> <a href='?_src_=prefs;preference=ooccolor;task=input'>[change_label]</a><br>"
							dat += "<b>[custom_color_aooc_label]:</b> <a href='?_src_=prefs;preference=custom_color_aooc'>[(custom_colors & CUSTOM_AOOC)? enabled_label : disabled_label]</a><br>"
							if(custom_colors & CUSTOM_AOOC)
								dat += "<b>[antag_ooc_color_label]:</b> <span style='border: 1px solid #161616; background-color: [aooccolor ? aooccolor : GLOB.normal_aooc_colour];'><font color='[color_hex2num(aooccolor ? aooccolor : GLOB.normal_aooc_colour) < 200 ? "FFFFFF" : "000000"]'>[aooccolor ? aooccolor : GLOB.normal_aooc_colour]</font></span> <a href='?_src_=prefs;preference=aooccolor;task=input'>[change_label]</a><br>"

					if(is_admin(user.client))
						dat += "<h2>[sec_admin]</h2>"
						dat += "<b>[adminhelp_sounds_label]:</b> <a href='?_src_=prefs;preference=hear_adminhelps'>[(toggles & SOUND_ADMINHELP)? enabled_label : disabled_label]</a><br>"
						dat += "<b>[announce_login_label]:</b> <a href='?_src_=prefs;preference=announce_login'>[(toggles & ANNOUNCE_LOGIN)? enabled_label : disabled_label]</a><br>"
						dat += "<br>"
						dat += "<b>[combo_hud_lighting_label]:</b> <a href = '?_src_=prefs;preference=combohud_lighting'>[(toggles & COMBOHUD_LIGHTING)? full_bright_label : no_change_label]</a><br>"

						//deadmin
						dat += "<h2>[deadmin_while_playing_label]</h2>"
						dat += "<b>[onlogin_deadmin_label]:</b> <a href = '?_src_=prefs;preference=toggle_deadmin_onlogin'>[(deadmin & DEADMIN_ONLOGIN)? enabled_label : disabled_label]</a><br>"
						if(CONFIG_GET(flag/auto_deadmin_players))
							dat += "<b>[onspawn_deadmin_label]:</b> [forced_label]</a><br>"
						else
							dat += "<b>[onspawn_deadmin_label]:</b> <a href = '?_src_=prefs;preference=toggle_deadmin_onspawn'>[(deadmin & DEADMIN_ONSPAWN)? enabled_label : disabled_label]</a><br>"
							if(!(deadmin & DEADMIN_ONSPAWN))
								dat += "<br>"
								if(!CONFIG_GET(flag/auto_deadmin_antagonists))
									dat += "<b>[as_antag_label]:</b> <a href = '?_src_=prefs;preference=toggle_deadmin_antag'>[(deadmin & DEADMIN_ANTAGONIST)? deadmin_label : keep_admin_label]</a><br>"
								else
									dat += "<b>[as_antag_label]:</b> [forced_label]<br>"

								if(!CONFIG_GET(flag/auto_deadmin_heads))
									dat += "<b>[as_command_label]:</b> <a href = '?_src_=prefs;preference=toggle_deadmin_head'>[(deadmin & DEADMIN_POSITION_HEAD)? deadmin_label : keep_admin_label]</a><br>"
								else
									dat += "<b>[as_command_label]:</b> [forced_label]<br>"

								if(!CONFIG_GET(flag/auto_deadmin_security))
									dat += "<b>[as_security_label]:</b> <a href = '?_src_=prefs;preference=toggle_deadmin_security'>[(deadmin & DEADMIN_POSITION_SECURITY)? deadmin_label : keep_admin_label]</a><br>"
								else
									dat += "<b>[as_security_label]:</b> [forced_label]<br>"

								if(!CONFIG_GET(flag/auto_deadmin_silicons))
									dat += "<b>[as_silicon_label]:</b> <a href = '?_src_=prefs;preference=toggle_deadmin_silicon'>[(deadmin & DEADMIN_POSITION_SILICON)? deadmin_label : keep_admin_label]</a><br>"
								else
									dat += "<b>[as_silicon_label]:</b> [forced_label]<br>"

					dat += "</td>"

					dat += "<td width='300px' height='300px' valign='top'>"

					// Labels
					var/widescreen_label = T("widescreen", "Widescreen")
					var/fullscreen_label = T("fullscreen", "Fullscreen")
					var/long_strip_menu_label = T("long_strip_menu", "Long strip menu")
					var/modern_accent_label_text = T("modern_accent", "Modern Accent")
					var/auto_stand_label = T("auto_stand", "Auto stand")
					var/auto_ooc_label = T("auto_ooc", "Auto OOC")
					var/force_slot_storage_label = T("force_slot_storage", "Force Slot Storage HUD")
					var/screen_shake_label = T("screen_shake", "Screen Shake")
					var/damage_screen_shake_label = T("damage_screen_shake", "Damage Screen Shake")
					var/recoil_screen_push_label = T("recoil_screen_push", "Recoil Screen Push")
					var/full_label = T("full", "Full")
					var/none_label = T("none", "None")
					var/on_label = T("on", "On")
					var/off_label = T("off", "Off")
					var/only_when_down_label = T("only_when_down", "Only when down")
					var/be_victim_label = T("be_victim", "Be Antagonist Victim")
					var/disable_combat_cursor_label = T("disable_combat_cursor", "Disable combat mode cursor")
					var/disable_combat_mouse_lock_label = T("disable_combat_mouse_lock", "Disable combat mode mouse lock")
					var/playerpanel_style_label = T("playerpanel_style", "Splashscreen Player Panel Style")
					var/tg_label = T("tg_label", "TG")
					var/old_label = T("old_label", "Old")
					var/fps_label = T("fps", "FPS")
					var/income_updates_label = T("income_updates", "Income Updates")
					var/allowed_label = T("allowed", "Allowed")
					var/muted_label = T("muted", "Muted")
					var/parallax_label = T("parallax", "Parallax (Fancy Space)")
					var/low_label = T("low", "Low")
					var/medium_label = T("medium", "Medium")
					var/high_label = T("high", "High")
					var/insane_label = T("insane", "Insane")
					var/ambient_occlusion_label = T("ambient_occlusion", "Ambient Occlusion")
					var/fit_viewport_label = T("fit_viewport", "Fit Viewport")
					var/auto_label = T("auto", "Auto")
					var/manual_label = T("manual", "Manual")
					var/hud_button_flashes_label = T("hud_button_flashes", "HUD Button Flashes")
					var/hud_flash_color_label = T("hud_flash_color", "HUD Button Flash Color")
					var/preferred_map_label = T("preferred_map", "Preferred Map")
					var/default_label = T("default", "Default")
					var/sec_screen = T("pref_sec_screen", "Screen")
					var/sec_hud_label = T("pref_sec_hud", "HUD")
					var/sec_gameplay = T("pref_sec_gameplay", "Gameplay")
					var/sec_map = T("pref_sec_map", "Map")

					// Экран
					dat += "<h2>[sec_screen]</h2>"
					dat += "<b>[widescreen_label]:</b> <a href='?_src_=prefs;preference=widescreenpref'>[widescreenpref ? "[enabled_label] ([CONFIG_GET(string/default_view)])" : "[disabled_label] (15x15)"]</a><br>"
					dat += "<b>[fullscreen_label]:</b> <a href='?_src_=prefs;preference=fullscreen'>[fullscreen ? enabled_label : disabled_label]</a><br>"
					dat += "<b>[fps_label]:</b> <a href='?_src_=prefs;preference=clientfps;task=input'>[clientfps ? clientfps : "Авто ([CONFIG_GET(number/fps)])"]</a><br>"
					dat += "<b>[fit_viewport_label]:</b> <a href='?_src_=prefs;preference=auto_fit_viewport'>[auto_fit_viewport ? auto_label : manual_label]</a><br>"
					dat += "<b>[parallax_label]:</b> <a href='?_src_=prefs;preference=parallaxdown' oncontextmenu='window.location.href=\"?_src_=prefs;preference=parallaxup\";return false;'>"
					switch (parallax)
						if (PARALLAX_LOW)
							dat += low_label
						if (PARALLAX_MED)
							dat += medium_label
						if (PARALLAX_INSANE)
							dat += insane_label
						if (PARALLAX_DISABLE)
							dat += disabled_label
						else
							dat += high_label
					dat += "</a><br>"
					dat += "<b>[ambient_occlusion_label]:</b> <a href='?_src_=prefs;preference=ambientocclusion'>[ambientocclusion ? enabled_label : disabled_label]</a><br>"
					dat += "<b>Размытие освещения:</b> <a href='?_src_=prefs;preference=lighting_blur'>[lighting_blur]</a>[lighting_blur >= 3 ? " <span style='color:#ff6600'>(может снизить FPS)</span>" : ""]<br>"
					dat += "<b>[screen_shake_label]:</b> <a href='?_src_=prefs;preference=screenshake'>[(screenshake==100) ? full_label : ((screenshake==0) ? none_label : screenshake)]</a><br>"
					if (user && user.client && !user.client.prefs.screenshake==0)
						dat += "<b>[damage_screen_shake_label]:</b> <a href='?_src_=prefs;preference=damagescreenshake'>[(damagescreenshake==1) ? on_label : ((damagescreenshake==0) ? off_label : only_when_down_label)]</a><br>"
					dat += "<b>[recoil_screen_push_label]:</b> <a href='?_src_=prefs;preference=recoil_screenshake'>[(recoil_screenshake==100) ? full_label : ((recoil_screenshake==0) ? none_label : recoil_screenshake)]</a><br>"

					// HUD
					dat += "<h2>[sec_hud_label]</h2>"
					dat += "<b>[long_strip_menu_label]:</b> <a href='?_src_=prefs;preference=long_strip_menu'>[long_strip_menu ? enabled_label : disabled_label]</a><br>"
					var/modern_accent_label = "—"
					if(findtext(charcreation_theme, "modern"))
						switch(charcreation_theme)
							if("modern_neutral")
								modern_accent_label = "—"
							if("modern_classic")
								modern_accent_label = "—"
							if("modern_purple")
								modern_accent_label = "Purple"
							if("modern_green")
								modern_accent_label = "Green"
							else
								modern_accent_label = "Blue"
						dat += "<b>[modern_accent_label_text]:</b> <a href='?_src_=prefs;preference=charcreation_accent'>[modern_accent_label]</a><br>"
					dat += "<b>[hud_button_flashes_label]:</b> <a href='?_src_=prefs;preference=hud_toggle_flash'>[hud_toggle_flash ? enabled_label : disabled_label]</a><br>"
					dat += "<b>[hud_flash_color_label]:</b> <span style='border: 1px solid #161616; background-color: [hud_toggle_color];'><font color='[color_hex2num(hud_toggle_color) < 200 ? "FFFFFF" : "000000"]'>[hud_toggle_color]</font></span> <a href='?_src_=prefs;preference=hud_toggle_color;task=input'>[change_label]</a><br>"
					dat += "<b>[income_updates_label]:</b> <a href='?_src_=prefs;preference=income_pings'>[(chat_toggles & CHAT_BANKCARD) ? allowed_label : muted_label]</a><br>"
					dat += "<b>[playerpanel_style_label]:</b> <a href='?_src_=prefs;preference=tg_playerpanel'>[(toggles & TG_PLAYER_PANEL) ? tg_label : old_label]</a><br>"
					dat += "<b>[force_slot_storage_label]:</b> <a href='?_src_=prefs;preference=no_tetris_storage'>[no_tetris_storage ? enabled_label : disabled_label]</a><br>"

					// Геймплей
					dat += "<h2>[sec_gameplay]</h2>"
					dat += "<b>[auto_stand_label]:</b> <a href='?_src_=prefs;preference=autostand'>[autostand ? enabled_label : disabled_label]</a><br>"
					dat += "<b>[auto_ooc_label]:</b> <a href='?_src_=prefs;preference=auto_ooc'>[auto_ooc ? enabled_label : disabled_label]</a><br>"
					dat += "<b>[be_victim_label]:</b> <a href='?_src_=prefs;preference=be_victim;task=input'>[be_victim ? be_victim : BEVICTIM_ASK]</a><br>"
					dat += "<b>[disable_combat_cursor_label]:</b> <a href='?_src_=prefs;preference=disable_combat_cursor'>[disable_combat_cursor ? yes_label : no_label]</a><br>"
					dat += "<b>[disable_combat_mouse_lock_label]:</b> <a href='?_src_=prefs;preference=disable_combat_mouse_lock'>[disable_combat_mouse_lock ? yes_label : no_label]</a><br>"

					// Карта
					if (CONFIG_GET(flag/maprotation) && CONFIG_GET(flag/tgstyle_maprotation))
						var/p_map = preferred_map
						if (!p_map)
							p_map = default_label
							if (config.defaultmap)
								p_map += " ([config.defaultmap.map_name])"
						else
							if (p_map in config.maplist)
								var/datum/map_config/VM = config.maplist[p_map]
								if (!VM)
									p_map += " (No longer exists)"
								else
									p_map = VM.map_name
							else
								p_map += " (No longer exists)"
						if(CONFIG_GET(flag/allow_map_voting))
							dat += "<h2>[sec_map]</h2>"
							dat += "<b>[preferred_map_label]:</b> <a href='?_src_=prefs;preference=preferred_map;task=input'>[p_map]</a><br>"
					dat += "</td></tr></table>"
				if(CONTENT_PREFS_TAB)
					var/sec_fetish = T("pref_sec_fetish", "Fetish Content")
					var/sec_other_content = T("pref_sec_other_content", "Other Content")
					var/allow_lewd_verbs_label = T("allow_lewd_verbs", "Allow Lewd Verbs")
					var/allow_lewd_ranged_verbs_label = T("allow_lewd_ranged_verbs", "Allow Lewd Ranged Verbs")
					var/lewd_verb_sounds_label = T("lewd_verb_sounds", "Lewd Verb Sounds")
					var/arousal_label = T("arousal", "Arousal")
					var/allow_knotting_label = T("allow_knotting", "Allow Knotting")
					var/genital_examine_label = T("genital_examine", "Genital Examine Text")
					var/vore_examine_label = T("vore_examine", "Vore Examine Text")
					var/medihound_sleeper_label = T("medihound_sleeper", "Voracious MediHound Sleepers")
					var/hear_vore_sounds_label = T("hear_vore_sounds", "Hear Vore Sounds")
					var/hear_vore_digestion_label = T("hear_vore_digestion", "Hear Vore Digestion Sounds")
					var/trash_forcefeed_label = T("trash_forcefeed", "Allow Trash Forcefeeding (requires Trashcan quirk)")
					var/forced_fem_label = T("forced_fem", "Forced Feminization")
					var/forced_masc_label = T("forced_masc", "Forced Masculinization")
					var/lewd_hypno_label = T("lewd_hypno", "Lewd Hypno")
					var/bimbofication_label = T("bimbofication", "Bimbofication")
					var/breast_enlargement_label = T("breast_enlargement", "Breast Enlargement")
					var/penis_enlargement_label = T("penis_enlargement", "Penis Enlargement")
					var/butt_enlargement_label = T("butt_enlargement", "Butt Enlargement")
					var/belly_inflation_label = T("belly_inflation", "Belly Inflation")
					var/hypno_label = T("hypno", "Hypno")
					var/aphrodisiacs_label = T("aphrodisiacs", "Aphrodisiacs")
					var/ass_slapping_label = T("ass_slapping", "Ass Slapping")
					var/sex_jitter_label = T("sex_jitter", "Sex Jitter")
					var/chastity_label = T("chastity_interactions", "Chastity Interactions")
					var/genital_stim_label = T("genital_stimulation", "Genital Stimulation Modifiers")
					var/edging_label = T("edging", "Edging")
					var/receive_cum_label = T("receive_cum", "Receive Cum Covering")
					var/unholy_erp_label = T("unholy_erp_verbs", "Unholy ERP Verbs")
					var/unholy_erp_tooltip = T("unholy_erp_tooltip", "Enables verbs involving farts, shit and piss.")
					var/extreme_erp_label = T("extreme_erp_verbs", "Extreme ERP Verbs")
					var/extreme_erp_tooltip = T("extreme_erp_tooltip", "Enables verbs involving ear/brain fucking.")
					var/macro_tooltip = T("macro_micro_tooltip", "Enables macro / micro stepping and stomping interactions.")
					var/harmful_erp_label = T("harmful_erp_verbs", "Harmful ERP Verbs")
					var/auto_wag_label = T("auto_wag", "Automatic Wagging")
					var/disco_dance_label = T("disco_dance", "Dance Near Disco Ball")
					var/tattoos_from_others_label = T("tattoos_from_others", "Tattoos From Others")
					var/gfluid_blacklist_label = T("genital_fluid_blacklist", "Genital Fluid Blacklist")
					var/gfluid_blacklist_tooltip = T("genital_fluid_blacklist_tooltip", "If anyone cums a blacklisted fluid into you, it uses the default fluid for that genital.")
					var/gfluid_unblacklist_label = T("genital_fluid_unblacklist", "Genital Fluid Un-Blacklist")
					var/gfluid_unblacklist_tooltip = T("genital_fluid_unblacklist_tooltip", "Remove a genital fluid from your blacklist.")
					var/allowed_label = T("allowed", "Allowed")
					var/disallowed_label = T("disallowed", "Disallowed")
					dat += "<table><tr><td width='340px' height='300px' valign='top'>"
					dat += "<h2>[sec_fetish]</h2>"
					dat += "<b>[allow_lewd_verbs_label]:</b> <a href='?_src_=prefs;preference=verb_consent'>[(toggles & VERB_CONSENT) ? yes_label : no_label]</a><br>" // Skyrat - ERP Mechanic Addition
					dat += "<b>[allow_lewd_ranged_verbs_label]:</b> <a href='?_src_=prefs;preference=ranged_verb_consent'>[(toggles & RANGED_VERBS_CONSENT) ? yes_label : no_label]</a><br>" // BLUEMOON ADD интеракты с расстояния
					dat += "<b>[lewd_verb_sounds_label]:</b> <a href='?_src_=prefs;preference=lewd_verb_sounds'>[(toggles & LEWD_VERB_SOUNDS) ? yes_label : no_label]</a><br>" // Sandstorm - ERP Mechanic Addition
					dat += "<b>[arousal_label]:</b><a href='?_src_=prefs;preference=arousable'>[arousable == TRUE ? enabled_label : disabled_label]</a><BR>"
					dat += "<b>[allow_knotting_label]:</b><a href='?_src_=prefs;preference=sexknotting'>[sexknotting == TRUE ? enabled_label : disabled_label]</a><BR>"
					dat += "<b>[genital_examine_label]</b>:<a href='?_src_=prefs;preference=genital_examine'>[(cit_toggles & GENITAL_EXAMINE) ? enabled_label : disabled_label]</a><BR>"
					dat += "<b>[vore_examine_label]</b>:<a href='?_src_=prefs;preference=vore_examine'>[(cit_toggles & VORE_EXAMINE) ? enabled_label : disabled_label]</a><BR>"
					dat += "<b>[medihound_sleeper_label]:</b> <a href='?_src_=prefs;preference=hound_sleeper'>[(cit_toggles & MEDIHOUND_SLEEPER) ? yes_label : no_label]</a><br>"
					dat += "<b>[hear_vore_sounds_label]:</b> <a href='?_src_=prefs;preference=toggleeatingnoise'>[(cit_toggles & EATING_NOISES) ? yes_label : no_label]</a><br>"
					dat += "<b>[hear_vore_digestion_label]:</b> <a href='?_src_=prefs;preference=toggledigestionnoise'>[(cit_toggles & DIGESTION_NOISES) ? yes_label : no_label]</a><br>"
					dat += "<b>[trash_forcefeed_label]</b> <a href='?_src_=prefs;preference=toggleforcefeedtrash'>[(cit_toggles & TRASH_FORCEFEED) ? yes_label : no_label]</a><br>"
					dat += "<b>[forced_fem_label]:</b> <a href='?_src_=prefs;preference=feminization'>[(cit_toggles & FORCED_FEM) ? allowed_label : disallowed_label]</a><br>"
					dat += "<b>[forced_masc_label]:</b> <a href='?_src_=prefs;preference=masculinization'>[(cit_toggles & FORCED_MASC) ? allowed_label : disallowed_label]</a><br>"
					dat += "<b>[lewd_hypno_label]:</b> <a href='?_src_=prefs;preference=hypno'>[(cit_toggles & HYPNO) ? allowed_label : disallowed_label]</a><br>"
					dat += "<b>[bimbofication_label]:</b> <a href='?_src_=prefs;preference=bimbo'>[(cit_toggles & BIMBOFICATION) ? allowed_label : disallowed_label]</a><br>"
					dat += "</td>"
					dat +="<td width='300px' height='300px' valign='top'>"
					dat += "<h2>[sec_other_content]</h2>"
					dat += "<b>[breast_enlargement_label]:</b> <a href='?_src_=prefs;preference=breast_enlargement'>[(cit_toggles & BREAST_ENLARGEMENT) ? allowed_label : disallowed_label]</a><br>"
					dat += "<b>[penis_enlargement_label]:</b> <a href='?_src_=prefs;preference=penis_enlargement'>[(cit_toggles & PENIS_ENLARGEMENT) ? allowed_label : disallowed_label]</a><br>"
					dat += "<b>[butt_enlargement_label]:</b> <a href='?_src_=prefs;preference=butt_enlargement'>[(cit_toggles & BUTT_ENLARGEMENT) ? allowed_label : disallowed_label]</a><br>"
					dat += "<b>[belly_inflation_label]:</b> <a href='?_src_=prefs;preference=belly_inflation'>[(cit_toggles & BELLY_INFLATION) ? allowed_label : disallowed_label]</a><br>" //SPLURT Edit
					dat += "<b>[hypno_label]:</b> <a href='?_src_=prefs;preference=never_hypno'>[(cit_toggles & NEVER_HYPNO) ? disallowed_label : allowed_label]</a><br>"
					dat += "<b>[aphrodisiacs_label]:</b> <a href='?_src_=prefs;preference=aphro'>[(cit_toggles & NO_APHRO) ? disallowed_label : allowed_label]</a><br>"
					dat += "<b>[ass_slapping_label]:</b> <a href='?_src_=prefs;preference=ass_slap'>[(cit_toggles & NO_ASS_SLAP) ? disallowed_label : allowed_label]</a><br>"
					dat += "<b>[sex_jitter_label]:</b> <a href='?_src_=prefs;preference=sex_jitter'>[(cit_toggles & SEX_JITTER) ? allowed_label : disallowed_label]</a><br>"
					dat += "<b>[chastity_label]:</b> <a href='?_src_=prefs;preference=chastitypref'>[(cit_toggles & CHASTITY) ? allowed_label : disallowed_label]</a><br>"
					dat += "<b>[genital_stim_label]:</b> <a href='?_src_=prefs;preference=stimulationpref'>[(cit_toggles & STIMULATION) ? allowed_label : disallowed_label]</a><br>"
					dat += "<b>[edging_label]:</b> <a href='?_src_=prefs;preference=edgingpref'>[(cit_toggles & EDGING) ? allowed_label : disallowed_label]</a><br>"
					dat += "<b>[receive_cum_label]:</b> <a href='?_src_=prefs;preference=cumontopref'>[(cit_toggles & CUM_ONTO) ? allowed_label : disallowed_label]</a><br>"
					dat += "<span style='border-radius: 2px;border:1px dotted white;cursor:help;' title='[unholy_erp_tooltip]'>?</span> "
					dat += "<b>[unholy_erp_label]:</b> <a href='?_src_=prefs;preference=unholypref'>[unholypref]</a><br>" // Сила - Срать и лаять афаф
					dat += "<span style='border-radius: 2px;border:1px dotted white;cursor:help;' title='[macro_tooltip]'>?</span> "
	//					dat += "<b>Stomping Interactions :</b> <a href='?_src_=prefs;preference=stomppref'>[stomppref ? yes_label : no_label]</a><br>"
					dat += "<span style='border-radius: 2px;border:1px dotted white;cursor:help;' title='[extreme_erp_tooltip]'>?</span> "
					//SANDSTORM EDIT
					dat += 	"<b>[extreme_erp_label]:</b> <a href='?_src_=prefs;preference=extremepref'>[extremepref]</a><br>" // https://youtu.be/0YrU9ASVw6w
					if(extremepref != "No")
						dat += "<span style='border-radius: 2px;border:1px dotted white;cursor:help;' title='[extreme_erp_tooltip]'>?</span> " //SPLURT Edit
						dat += "<b><span style='color: #e60000;'>[harmful_erp_label]:</b> <a href='?_src_=prefs;preference=extremeharm'>[extremeharm]</a><br>"
					dat += "<b>[auto_wag_label]:</b> <a href='?_src_=prefs;preference=auto_wag'>[(cit_toggles & NO_AUTO_WAG) ? disabled_label : enabled_label]</a><br>"
					dat += "<b>[disco_dance_label]:</b> <a href='?_src_=prefs;preference=disco_dance'>[(cit_toggles & NO_DISCO_DANCE) ? disabled_label : enabled_label]</a><br>"
					dat += "<b>[tattoos_from_others_label]:</b> <a href='?_src_=prefs;preference=tattoo_pref'>[tattoopref]</a><br>" // BLUEMOON ADD - tattoo consent
					dat += "<span style='border-radius: 2px;border:1px dotted white;cursor:help;' title='[gfluid_blacklist_tooltip]'>?</span> "
					dat += "<b><a href='?_src_=prefs;preference=gfluid_black;task=input'>[gfluid_blacklist_label]</a></b><br>"
					if(gfluid_blacklist?.len)
						dat += "<span style='border-radius: 2px;border:1px dotted white;cursor:help;' title='[gfluid_unblacklist_tooltip]'>?</span> "
						dat += "<b><a href='?_src_=prefs;preference=gfluid_unblack;task=input'>[gfluid_unblacklist_label]</a></b><br>"
					dat += "</tr></table>"

		if(KEYBINDINGS_TAB) // Custom keybindings
			dat += "<b>Keybindings:</b> <a href='?_src_=prefs;preference=hotkeys'>[(hotkeys) ? "Hotkeys" : "Input"]</a><br>"
			dat += "Keybindings mode controls how the game behaves with tab and map/input focus.<br>If it is on <b>Hotkeys</b>, the game will always attempt to force you to map focus, meaning keypresses are sent \
			directly to the map instead of the input. You will still be able to use the command bar, but you need to tab to do it every time you click on the game map.<br>\
			If it is on <b>Input</b>, the game will not force focus away from the input bar, and you can switch focus using TAB between these two modes: If the input bar is pink, that means that you are in non-hotkey mode, sending all keypresses of the normal \
			alphanumeric characters, punctuation, spacebar, backspace, enter, etc, typing keys into the input bar. If the input bar is white, you are in hotkey mode, meaning all keypresses go into the game's keybind handling system unless you \
			manually click on the input bar to shift focus there.<br>\
			Input mode is the closest thing to the old input system.<br>\
			<b>IMPORTANT:</b> While in input mode's non hotkey setting (tab toggled), Ctrl + KEY will send KEY to the keybind system as the key itself, not as Ctrl + KEY. This means Ctrl + T/W/A/S/D/all your familiar stuff still works, but you \
			won't be able to access any regular Ctrl binds.<br>"
			dat += "<br><b>Modifier-Independent binding</b> - This is a singular bind that works regardless of if Ctrl/Shift/Alt are held down. For example, if combat mode is bound to C in modifier-independent binds, it'll trigger regardless of if you are \
			holding down shift for sprint. <b>Each keybind can only have one independent binding, and each key can only have one keybind independently bound to it.</b>"
			// Create an inverted list of keybindings -> key
			var/list/user_binds = list()
			var/list/user_modless_binds = list()
			for (var/key in key_bindings)
				for(var/kb_name in key_bindings[key])
					user_binds[kb_name] += list(key)
			for (var/key in modless_key_bindings)
				user_modless_binds[modless_key_bindings[key]] = key

			var/list/kb_categories = list()
			// Group keybinds by category
			for (var/name in GLOB.keybindings_by_name)
				var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
				kb_categories[kb.category] += list(kb)

			dat += {"
			<style>
			span.bindname { display: inline-block; position: absolute; width: 20% ; left: 5px; padding: 5px; } \
			span.bindings { display: inline-block; position: relative; width: auto; left: 20%; width: auto; right: 20%; padding: 5px; } \
			span.independent { display: inline-block; position: absolute; width: 20%; right: 5px; padding: 5px; } \
			</style><body>
			"}

			for (var/category in kb_categories)
				dat += "<h3>[category]</h3>"
				for (var/i in kb_categories[category])
					var/datum/keybinding/kb = i
					var/current_independent_binding = user_modless_binds[kb.name] || "Unbound"
					if(!length(user_binds[kb.name]))
						dat += "<span class='bindname'>[kb.full_name]</span><span class='bindings'><a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=Unbound'>Unbound</a>"
						var/list/default_keys = hotkeys ? kb.hotkey_keys : kb.classic_keys
						if(LAZYLEN(default_keys))
							dat += "| Default: [default_keys.Join(", ")]"
						dat += "</span>"
						if(!kb.special && !kb.clientside)
							dat += "<span class='independent'>Independent Binding: <a href='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=[current_independent_binding];independent=1'>[current_independent_binding]</a></span>"
						dat += "<br>"
					else
						var/bound_key = user_binds[kb.name][1]
						dat += "<span class='bindname'l>[kb.full_name]</span><span class='bindings'><a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=[bound_key]'>[bound_key]</a>"
						for(var/bound_key_index in 2 to length(user_binds[kb.name]))
							bound_key = user_binds[kb.name][bound_key_index]
							dat += " | <a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=[bound_key]'>[bound_key]</a>"
						if(length(user_binds[kb.name]) < MAX_KEYS_PER_KEYBIND)
							dat += "| <a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name]'>Add Secondary</a>"
						var/list/default_keys = hotkeys ? kb.classic_keys : kb.hotkey_keys
						if(LAZYLEN(default_keys))
							dat += "| Default: [default_keys.Join(", ")]"
						dat += "</span>"
						if(!kb.special && !kb.clientside)
							dat += "<span class='independent'>Independent Binding: <a href='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=[current_independent_binding];independent=1'>[current_independent_binding]</a></span>"
						dat += "<br>"

			dat += "<br><br>"
			dat += "<a href ='?_src_=prefs;preference=keybindings_reset'>\[Reset to default\]</a>"
			dat += "</body>"


	dat += "<hr>"
	dat += "<center>"

	if(!IsGuestKey(user.key))
		dat += "<a href='?_src_=prefs;preference=load'>Undo</a>"
		dat += "<a href='?_src_=prefs;preference=save'>Save Setup</a>"

	dat += "<a href='?_src_=prefs;preference=reset_all'>Reset Setup</a>"
	dat += "</center>"

	dat += "</div>"

	if(!user?.client)
		return

	winshow(user, "preferences_window", TRUE)
	var/datum/browser/popup = new(user, "preferences_browser", "<div align='center'>Character Setup</div>", 640, 770)
	if(findtext(charcreation_theme, "modern"))
		popup.add_stylesheet("preferences_modern", 'html/browser/preferences_modern.css')
	if(findtext(charcreation_theme, "modern"))
		popup.add_script("prefs_state", 'html/browser/prefs_state.js')
	popup.set_content(dat.Join())
	popup.open(FALSE)
	var/map_visible = (current_tab == SETTINGS_TAB) ? "true" : "false"
	winset(user.client, "character_preview_map", "is-visible=[map_visible]")
	onclose(user, "preferences_window", src)

/datum/preferences/proc/cycle_character_creation_modern_accent()
	if(!findtext(charcreation_theme, "modern"))
		return
	if(charcreation_theme == "modern")
		charcreation_theme = "modern_purple"
		return
	if(charcreation_theme == "modern_purple")
		charcreation_theme = "modern_green"
		return
	// includes modern_green and any unknown modern variant
	charcreation_theme = "modern"

#undef SETUP_START_NODE
#undef SETUP_GET_LINK
#undef SETUP_GET_LINK_RANDOM
#undef SETUP_COLOR_BOX
#undef SETUP_NODE_SWITCH
#undef SETUP_NODE_INPUT
#undef SETUP_NODE_COLOR
#undef SETUP_NODE_RANDOM
#undef SETUP_NODE_INPUT_RANDOM
#undef SETUP_NODE_COLOR_RANDOM
#undef SETUP_CLOSE_NODE

#undef APPEARANCE_CATEGORY_COLUMN
#undef MAX_MUTANT_ROWS

/datum/preferences/proc/CaptureKeybinding(mob/user, datum/keybinding/kb, old_key, independent = FALSE, special = FALSE)
	var/HTML = {"
<div id='focus' style="outline: 0;" tabindex=0>Keybinding: [kb.full_name]<br>[kb.description]<br><br><b>Press any key to change<br>Press ESC to clear</b></div>
<script>
var deedDone = false;
document.onkeyup = function(e) {
	if(deedDone){ return; }
	var alt = e.altKey ? 1 : 0;
	var ctrl = e.ctrlKey ? 1 : 0;
	var shift = e.shiftKey ? 1 : 0;
	var numpad = (95 < e.keyCode && e.keyCode < 112) ? 1 : 0;
	var escPressed = e.keyCode == 27 ? 1 : 0;
	var url = 'byond://?_src_=prefs;preference=keybindings_set;keybinding=[kb.name];old_key=[old_key];[independent?"independent=1;":""][special?"special=1;":""]clear_key='+escPressed+';key='+e.key+';alt='+alt+';ctrl='+ctrl+';shift='+shift+';numpad='+numpad+';key_code='+e.keyCode;
	window.location=url;
	deedDone = true;
}
document.getElementById('focus').focus();
</script>
"}
	winshow(user, "capturekeypress", TRUE)
	var/datum/browser/popup = new(user, "capturekeypress", "<div align='center'>Keybindings</div>", 350, 300)
	popup.set_content(HTML)
	popup.open(FALSE)
	onclose(user, "capturekeypress", src)



// ========== Sand: Language selection ==========
//SANDSTORM EDIT - extra language
/datum/preferences/proc/SetLanguage(mob/user)
	var/list/dat = list()
	dat += "<center><b>Choose Additional Languages</b></center><br>"
	if(!CONFIG_GET(number/max_languages) == 0)
		dat += "<center>Do note, however, you can have many languages. <b>Do not abuse this.</b></center><br>"
		dat += "<center>If you want no additional language at all, click reset to disable all languages.</center><br>"
		dat += "<hr>"
		if(SSlanguage && SSlanguage.languages_by_name.len)
			for(var/V in SSlanguage.languages_by_name)
				var/datum/language/L = SSlanguage.languages_by_name[V]
				if(!L)
					return
				var/language_name = L.name
				var/restricted = FALSE
				if(L.restricted)
					restricted = TRUE
				if(restricted && !(language_name in pref_species.languagewhitelist))
					var/quirklanguagefound = FALSE
					for(var/datum/quirk/Q in all_quirks)
						if(language_name in Q.languagewhitelist)
							quirklanguagefound = TRUE
					if(!quirklanguagefound)
						continue
				else
					dat += "<a [(language_name in language) ? "class='linkOn'" : ""] href='?_src_=prefs;preference=language;task=update;language=[language_name]'><b>[language_name]</a></b> [L.desc]<br><br>"
		else
			dat += "<center><b>The language subsystem hasn't fully loaded yet! Please wait a bit and try again.</b></center><br>"
		dat += "<hr>"
		dat += "<td><center><a style='white-space:normal;background:#eb2e2e;' href='?_src_=prefs;preference=language;task=reset'>Reset</center></span></td>"
	else
		dat += "<hr>"
		dat += "<b>Additional Languages are disabled.</b>"
		dat += "<hr>"
	dat += "<center><a href='?_src_=prefs;preference=language;task=close'>Done</a></center>"

	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Language Preference</div>", 900, 600) //no reason not to reuse the occupation window, as it's cleaner that way
	popup.set_window_options("can_close=0")
	popup.set_content(dat.Join())
	popup.open(FALSE)
//

/datum/preferences/proc/toggle_language(lang)
	if(lang in language)
		language -= lang
		return TRUE
	else if(check_language_maxhit())
		if(CONFIG_GET(number/max_languages) == 1)
			tgui_alert(usr, "You can only have 1 additional language!", timeout = 5 SECONDS)
		else
			tgui_alert(usr, "You can only have up to [CONFIG_GET(number/max_languages)] additional languages!", timeout = 5 SECONDS)
		return FALSE
	else
		language += lang
		return TRUE

/datum/preferences/proc/check_language_maxhit()
	if(CONFIG_GET(number/max_languages) == -1) //infinite
		return FALSE
	else if(language.len >= CONFIG_GET(number/max_languages))
		return TRUE
