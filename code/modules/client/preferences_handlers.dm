/datum/preferences/Topic(href, href_list, hsrc)			//yeah, gotta do this I guess..
	. = ..()
	if(href_list["close"])
		var/client/C = usr.client
		if(C)
			C.clear_character_previews()

/datum/preferences/proc/process_link(mob/user, list/href_list)
	if(href_list["jobbancheck"])
		var/job = href_list["jobbancheck"]
		var/datum/db_query/query_get_jobban = SSdbcore.NewQuery({"
			SELECT reason, bantime, duration, expiration_time, IFNULL((SELECT byond_key FROM [format_table_name("player")] WHERE [format_table_name("player")].ckey = [format_table_name("ban")].a_ckey), a_ckey)
			FROM [format_table_name("ban")] WHERE ckey = :ckey AND (bantype = 'JOB_PERMABAN'  OR (bantype = 'JOB_TEMPBAN' AND expiration_time > Now())) AND isnull(unbanned) AND job = :job
			"}, list("ckey" = user.ckey, "job" = job))
		if(!query_get_jobban.warn_execute())
			qdel(query_get_jobban)
			return
		if(query_get_jobban.NextRow())
			var/reason = query_get_jobban.item[1]
			var/bantime = query_get_jobban.item[2]
			var/duration = query_get_jobban.item[3]
			var/expiration_time = query_get_jobban.item[4]
			var/admin_key = query_get_jobban.item[5]
			var/text
			text = "<span class='redtext'>You, or another user of this computer, ([user.key]) is banned from playing [job]. The ban reason is:<br>[reason]<br>This ban was applied by [admin_key] on [bantime]"
			if(text2num(duration) > 0)
				text += ". The ban is for [duration] minutes and expires on [expiration_time] (server time)"
			text += ".</span>"
			to_chat(user, text, confidential = TRUE)
		qdel(query_get_jobban)
		return

	if(href_list["preference"] == "charcreation_accent")
		cycle_character_creation_modern_accent()
		ShowChoices(user)
		return TRUE

	if(href_list["preference"] == "charcreation_set")
		var/selected_theme = href_list["theme"]
		if(selected_theme)
			switch(selected_theme)
				if("modern")
					charcreation_theme = "modern"
					save_preferences(silent = TRUE)
					ShowChoices(user)
					return TRUE
				if("modern_classic")
					charcreation_theme = "modern_classic"
					save_preferences(silent = TRUE)
					ShowChoices(user)
					return TRUE
				if("modern_purple")
					charcreation_theme = "modern_purple"
					save_preferences(silent = TRUE)
					ShowChoices(user)
					return TRUE
				if("modern_green")
					charcreation_theme = "modern_green"
					save_preferences(silent = TRUE)
					ShowChoices(user)
					return TRUE
				if("modern_neutral")
					charcreation_theme = "modern_neutral"
					save_preferences(silent = TRUE)
					ShowChoices(user)
					return TRUE
				if("modern_custom")
					charcreation_theme = "modern_custom"
					modern_custom_enabled = TRUE
					save_preferences(silent = TRUE)
					ShowChoices(user)
					return TRUE
		ShowChoices(user)
		return TRUE

	if(href_list["preference"] == "modern_theme_editor")
		switch(href_list["action"])
			if("toggle")
				modern_custom_editor_open = !modern_custom_editor_open
				if(modern_custom_editor_open)
					charcreation_theme = "modern_custom"
					modern_custom_enabled = TRUE
					save_preferences(silent = TRUE)
				ShowChoices(user)
				return TRUE
			if("toggle_enabled")
				charcreation_theme = "modern_custom"
				modern_custom_enabled = !modern_custom_enabled
				save_preferences(silent = TRUE)
				ShowChoices(user)
				return TRUE
			if("toggle_pattern")
				charcreation_theme = "modern_custom"
				modern_custom_bg_pattern = !modern_custom_bg_pattern
				save_preferences(silent = TRUE)
				ShowChoices(user)
				return TRUE
			if("reset")
				charcreation_theme = "modern_custom"
				reset_modern_custom_theme()
				save_preferences(silent = TRUE)
				ShowChoices(user)
				return TRUE
		ShowChoices(user)
		return TRUE

	if(href_list["preference"] == "modern_theme_picker")
		switch(href_list["action"])
			if("toggle")
				modern_theme_picker_collapsed = !modern_theme_picker_collapsed
				modern_theme_picker_animate = FALSE
				save_preferences(bypass_cooldown = TRUE, silent = TRUE)
				ShowChoices(user)
				return TRUE
		ShowChoices(user)
		return TRUE

	if(href_list["preference"] == "modern_theme_settings")
		switch(href_list["action"])
			if("toggle")
				modern_theme_settings_open = !modern_theme_settings_open
				ShowChoices(user)
				return TRUE
			if("set_button_shape")
				var/shape = href_list["shape"]
				modern_button_shape = sanitize_inlist(shape, list("rect", "soft", "round"), initial(modern_button_shape))
				save_preferences(bypass_cooldown = TRUE, silent = TRUE)
				ShowChoices(user)
				return TRUE
			if("set_language")
				var/lang = href_list["lang"]
				if(lang == "ru")
					modern_ui_language = 1
				else if(lang == "en")
					modern_ui_language = 0
				save_preferences(bypass_cooldown = TRUE, silent = TRUE)
				ShowChoices(user)
				return TRUE
			if("set_decoration_level")
				var/level = href_list["level"]
				ui_decoration_level = sanitize_inlist(level, list("minimal", "standard", "enhanced"), initial(ui_decoration_level))
				save_preferences(bypass_cooldown = TRUE, silent = TRUE)
				ShowChoices(user)
				return TRUE
		ShowChoices(user)
		return TRUE

	if(href_list["preference"] == "character_slots")
		switch(href_list["action"])
			if("toggle_empty")
				collapse_empty_character_slots = !collapse_empty_character_slots
				save_preferences(silent = TRUE)
				ShowChoices(user)
				return TRUE
			if("delete_slot")
				var/slot = text2num(href_list["slot"])
				if(!slot)
					ShowChoices(user)
					return TRUE
				// Подсчитываем количество непустых слотов
				var/occupied_count = 0
				if(path)
					var/savefile/S = new /savefile(path)
					if(S)
						for(var/i in 1 to max_save_slots)
							S.cd = "/character[i]"
							var/check_name
							S["real_name"] >> check_name
							if(check_name)
								occupied_count++
				if(occupied_count <= 1)
					tgui_alert_async(user, "Нельзя удалить единственного персонажа! / Cannot delete the only character!")
					ShowChoices(user)
					return TRUE
				// Запрашиваем подтверждение
				var/confirm = tgui_alert(user, "Вы уверены, что хотите удалить этого персонажа? Это действие необратимо! / Are you sure you want to delete this character? This cannot be undone!", "Delete Character", list("Yes", "No"))
				if(confirm != "Yes")
					ShowChoices(user)
					return TRUE
				if(delete_character(slot))
					tgui_alert_async(user, "Персонаж удалён. / Character deleted.")
				else
					tgui_alert_async(user, "Не удалось удалить персонажа. / Failed to delete character.")
				ShowChoices(user)
				return TRUE
		ShowChoices(user)
		return TRUE

	if(href_list["preference"] == "modern_custom_color")
		var/color_key = href_list["key"]
		if(!color_key)
			ShowChoices(user)
			return TRUE
		charcreation_theme = "modern_custom"
		modern_custom_enabled = TRUE
		var/current_value = ""
		switch(color_key)
			if("bg_primary") current_value = modern_custom_bg_primary
			if("bg_secondary") current_value = modern_custom_bg_secondary
			if("text_primary") current_value = modern_custom_text_primary
			if("text_secondary") current_value = modern_custom_text_secondary
			if("button_bg") current_value = modern_custom_button_bg
			if("button_hover") current_value = modern_custom_button_hover
			if("button_active") current_value = modern_custom_button_active
			if("button_text") current_value = modern_custom_button_text
			if("border_color") current_value = modern_custom_border_color
			if("accent_color") current_value = modern_custom_accent_color
		var/new_value = input(user, "Выберите цвет:", "Custom theme: [color_key]", "#[current_value]") as color|null
		if(isnull(new_value))
			ShowChoices(user)
			return TRUE
		if(set_modern_custom_color(color_key, new_value))
			save_preferences(silent = TRUE)
		else
			to_chat(user, span_warning("Неверный цвет."))
		ShowChoices(user)
		return TRUE

	if(href_list["preference"] == "job")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				ShowChoices(user)
			if("reset")
				ResetJobs()
				SetChoices(user)
			if("random")
				switch(joblessrole)
					if(RETURNTOLOBBY)
						if(jobban_isbanned(user, SSjob.overflow_role))
							joblessrole = BERANDOMJOB
						else
							joblessrole = BEOVERFLOW
					if(BEOVERFLOW)
						joblessrole = BERANDOMJOB
					if(BERANDOMJOB)
						joblessrole = RETURNTOLOBBY
				SetChoices(user)
			if("setJobLevel")
				UpdateJobPreference(user, href_list["text"], text2num(href_list["level"]))
			if("alt_title")
				var/job_title = href_list["job_title"]
				var/titles_list = list(job_title)
				var/datum/job/J = SSjob.GetJob(job_title)
				for(var/i in J.alt_titles)
					titles_list += i
				var/chosen_title
				chosen_title = tgui_input_list(user, "Choose your job's title:", "Job Preference", titles_list)
				if(chosen_title)
					if(chosen_title == job_title)
						if(alt_titles_preferences[job_title])
							alt_titles_preferences.Remove(job_title)
					else
						alt_titles_preferences[job_title] = chosen_title
				SetChoices(user)
			else
				SetChoices(user)
		return TRUE

	else if(href_list["preference"] == "trait")
		var/is_inline_quirks = (character_settings_tab == QUIRKS_CHAR_TAB && CONFIG_GET(flag/roundstart_traits))
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				ShowChoices(user)
			if("update")
				var/quirk = href_list["trait"]
				if(!SSquirks.quirks[quirk])
					return
				for(var/V in SSquirks.quirk_blacklist) //V is a list
					var/list/L = V
					for(var/Q in all_quirks)
						if((quirk in L) && (Q in L) && !(Q == quirk)) //two quirks have lined up in the list of the list of quirks that conflict with each other, so return (see quirks.dm for more details)
							to_chat(user, "<span class='danger'>[quirk] имеет несовместимость с квирком [Q].</span>") //BLUEMOON EDIT перевод
							return
				var/value = SSquirks.quirk_points[quirk]
				var/balance = GetQuirkBalance(user)
				if(quirk in all_quirks)
					if(balance + value < 0)
						to_chat(user, "<span class='warning'>Refunding this would cause you to go below your balance!</span>")
						return
					all_quirks -= quirk
				else
					if(GetPositiveQuirkCount() >= MAX_QUIRKS && value > 0)
						to_chat(user, "<span class='warning'>You can't have more than [MAX_QUIRKS] positive quirks!</span>")
						return
					if(balance - value < 0)
						to_chat(user, "<span class='warning'>You don't have enough balance to gain this quirk!</span>")
						return
					all_quirks += quirk
				if(is_inline_quirks)
					ShowChoices(user)
				else
					SetQuirks(user)
			if("reset")
				all_quirks = list()
				if(is_inline_quirks)
					ShowChoices(user)
				else
					SetQuirks(user)
			else
				if(is_inline_quirks)
					ShowChoices(user)
				else
					SetQuirks(user)
	// BLUEMOON ADD START - возможность настраивать квирки
	else if(href_list["preference"] == "traits_setup")
		var/is_inline_quirks = (character_settings_tab == QUIRKS_CHAR_TAB && CONFIG_GET(flag/roundstart_traits))
		switch(href_list["task"])
			if("change_shriek_option") // изменение вида крика от квирка крикуна
				var/client/C = usr.client
				if(C)
					var/new_shriek_type = tgui_input_list(user, "Choose your character's shriek type.", "Character Preference", GLOB.shriek_types)
					if(new_shriek_type)
						shriek_type = new_shriek_type
						if(is_inline_quirks)
							ShowChoices(user)
						else
							SetQuirks(user)
			if("lewd_summon_nickname")
				var/client/C = usr.client
				if(C)
					var/new_summon_nickname = input(user, "Задайте прозвище во время призыва вашего персонажа:", "Character Preference")  as text|null
					if(new_summon_nickname)
						new_summon_nickname = reject_bad_name(new_summon_nickname, allow_numbers = TRUE)
						if(new_summon_nickname)
							summon_nickname = new_summon_nickname
							if(is_inline_quirks)
								ShowChoices(user)
							else
								SetQuirks(user)
						else
							to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, А-Я, а-я, -, ' and .</font>")

	// BLUEMOON ADD END
		return TRUE

	else if(href_list["quirk_category"])
		var/is_inline_quirks = (character_settings_tab == QUIRKS_CHAR_TAB && CONFIG_GET(flag/roundstart_traits))
		var/temp_quirk_category = href_list["quirk_category"]
		if(temp_quirk_category == QUIRK_POSITIVE || temp_quirk_category == QUIRK_NEUTRAL || temp_quirk_category == QUIRK_NEGATIVE)
			quirk_category = temp_quirk_category
			if(is_inline_quirks)
				ShowChoices(user)
			else
				SetQuirks(user)

	else if(href_list["preference"] == "language")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				ShowChoices(user)
				return TRUE
			if("update")
				var/lang = href_list["language"]
				if(!SSlanguage.languages_by_name[lang])
					return
				if(!toggle_language(lang))
					return
				language = sort_list(language)
			if("reset")
				language = list()
		SetLanguage(user)
		return TRUE

	switch(href_list["task"])
		if("random")
			switch(href_list["preference"])
				if("name")
					real_name = pref_species.random_name(gender,1)
				if("age")
					age = rand(AGE_MIN, AGE_MAX)
				if("hair")
					hair_color = random_short_color()
				if("hair_style")
					hair_style = random_hair_style(gender)
				if("facial")
					facial_hair_color = random_short_color()
				if("facial_hair_style")
					facial_hair_style = random_facial_hair_style(gender)
				/*
				if("underwear")
					underwear = random_underwear(gender)
					undie_color = random_short_color()
				if("undershirt")
					undershirt = random_undershirt(gender)
					shirt_color = random_short_color()
				if("socks")
					socks = random_socks()
					socks_color = random_short_color()
				*/
				if(BODY_ZONE_PRECISE_EYES)
					var/random_eye_color = random_eye_color()
					left_eye_color = random_eye_color
					right_eye_color = random_eye_color
				if("s_tone")
					skin_tone = random_skin_tone()
					use_custom_skin_tone = null
				if("bag")
					backbag = pick(GLOB.backbaglist)
				if("suit")
					jumpsuit_style = pick(GLOB.jumpsuitlist)
				if("all")
					random_character()

		if("input")

			if(href_list["preference"] in GLOB.preferences_custom_names)
				ask_for_custom_name(user,href_list["preference"])


			switch(href_list["preference"])
				if("ghostform")
					if(unlock_content)
						var/new_form = tgui_input_list(user, "Thanks for supporting BYOND - Choose your ghostly form:","Thanks for supporting BYOND", GLOB.ghost_forms, null)
						if(new_form)
							ghost_form = new_form
				if("ghostorbit")
					if(unlock_content)
						var/new_orbit = tgui_input_list(user, "Thanks for supporting BYOND - Choose your ghostly orbit:","Thanks for supporting BYOND",  GLOB.ghost_orbits, null)
						if(new_orbit)
							ghost_orbit = new_orbit

				if("ghostaccs")
					var/new_ghost_accs = alert("Do you want your ghost to show full accessories where possible, hide accessories but still use the directional sprites where possible, or also ignore the directions and stick to the default sprites?",,GHOST_ACCS_FULL_NAME, GHOST_ACCS_DIR_NAME, GHOST_ACCS_NONE_NAME)
					switch(new_ghost_accs)
						if(GHOST_ACCS_FULL_NAME)
							ghost_accs = GHOST_ACCS_FULL
						if(GHOST_ACCS_DIR_NAME)
							ghost_accs = GHOST_ACCS_DIR
						if(GHOST_ACCS_NONE_NAME)
							ghost_accs = GHOST_ACCS_NONE

				if("ghostothers")
					var/new_ghost_others = alert("Do you want the ghosts of others to show up as their own setting, as their default sprites or always as the default white ghost?",,GHOST_OTHERS_THEIR_SETTING_NAME, GHOST_OTHERS_DEFAULT_SPRITE_NAME, GHOST_OTHERS_SIMPLE_NAME)
					switch(new_ghost_others)
						if(GHOST_OTHERS_THEIR_SETTING_NAME)
							ghost_others = GHOST_OTHERS_THEIR_SETTING
						if(GHOST_OTHERS_DEFAULT_SPRITE_NAME)
							ghost_others = GHOST_OTHERS_DEFAULT_SPRITE
						if(GHOST_OTHERS_SIMPLE_NAME)
							ghost_others = GHOST_OTHERS_SIMPLE

				if("name")
					var/new_name = input(user, "Задайте имя вашего персонажа:", "Character Preference")  as text|null
					if(new_name)
						new_name = reject_bad_name(new_name, allow_numbers = TRUE)
						if(new_name)
							real_name = new_name
						else
							to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, А-Я, а-я, -, ' and .</font>")

				if("age")
					var/new_age = tgui_input_number(user, "Задайте возраст вашего персонажа:\n([AGE_MIN]-[AGE_MAX_INPUT])", "Character Preference", null, AGE_MAX_INPUT, AGE_MIN)
					if(new_age)
						age = max(min( round(text2num(new_age)), AGE_MAX_INPUT),AGE_MIN)

				if("security_records")
					var/rec = stripped_multiline_input(usr, "Напишите заметки службы безопасности о вашем персонаже.", "Security Records", html_decode(security_records), MAX_FLAVOR_LEN, TRUE)
					if(!isnull(rec))
						security_records = rec

				if("medical_records")
					var/rec = stripped_multiline_input(usr, "Напишите медицинские заметки о вашем персонаже.", "Medical Records", html_decode(medical_records), MAX_FLAVOR_LEN, TRUE)
					if(!isnull(rec))
						medical_records = rec

				if("flavor_text")
					var/msg = input(usr, "Задайте внешнее описание вашего персонажа.", "Описание Bнешности Персонажа", features["flavor_text"]) as message|null //Skyrat edit, removed stripped_multiline_input()
					if(!isnull(msg))
						features["flavor_text"] = strip_html_simple(msg, MAX_FLAVOR_LEN, TRUE) //Skyrat edit, removed strip_html_simple()

				//SPLURT edit
				if("naked_flavor_text")
					var/msg = input(usr, "Задайте описание вашего персонажа без одежды.", "Описание Bнешности Голого Персонажа", features["naked_flavor_text"]) as message|null
					if(!isnull(msg))
						features["naked_flavor_text"] = strip_html_simple(msg, MAX_FLAVOR_LEN, TRUE)

				//SPLURT edit end
				if("silicon_flavor_text")
					var/msg = input(usr, "Задайте особые признаки внешности своего синтетического (борга) персонажа!", "Описание Борга", features["silicon_flavor_text"]) as message|null //Skyrat edit, removed stripped_multiline_input()
					if(!isnull(msg))
						features["silicon_flavor_text"] = strip_html_simple(msg, MAX_FLAVOR_LEN, TRUE) //Skyrat edit, uses strip_html_simple()

				if("custom_species_lore")
					var/msg = input(usr, "Задайте особую предысторию расы своего персонажа!", "Предыстория Расы Bашего Персонажа", features["custom_species_lore"]) as message|null //Skyrat edit, removed stripped_multiline_input()
					if(!isnull(msg))
						features["custom_species_lore"] = strip_html_simple(msg, MAX_FLAVOR_LEN, TRUE)
				// BLUEMOON ADD START - пользовательский эмоут смерти
				if("custom_deathgasp")
					var/msg = input(usr, "Задайте эмоцию, которая будет проигрываться при смерти вашего персонажа!", "Сообщение О Смерти", features["custom_deathgasp"]) as message|null
					if(!isnull(msg))
						features["custom_deathgasp"] = strip_html_simple(msg, MAX_DEATHGASP_LEN, TRUE)
				if("custom_deathsound")
					var/sound_name = tgui_input_list(user, "Выберите звук смерти персонажа!", "Звук Смерти", GLOB.deathgasp_sounds)
					if(sound_name)
						features["custom_deathsound"] = sound_name
				if("deathsoundpreview")
					if(SSticker.current_state == GAME_STATE_STARTUP) //Timers don't tick at all during game startup, so let's just give an error message
						to_chat(user, "<span class='warning'>Deathgasp sound previews can't play during initialization!</span>")
						return
					if(!COOLDOWN_FINISHED(src, deathsound_preview))
						return
					if(!user)
						return
					COOLDOWN_START(src, deathsound_preview, (3 SECONDS))
					var/picked_deathsound_name = features["custom_deathsound"]
					var/picked_deathsound_path
					if(picked_deathsound_name)
						if(picked_deathsound_name == "По умолчанию")
							picked_deathsound_path = pick('sound/voice/deathgasp1.ogg', 'sound/voice/deathgasp2.ogg')
						if(picked_deathsound_name == "Беззвучный")
							picked_deathsound_path = 0
						if(GLOB.deathgasp_sounds[picked_deathsound_name])
							picked_deathsound_path = GLOB.deathgasp_sounds[picked_deathsound_name]
					if(picked_deathsound_path)
						user.playsound_local(user, picked_deathsound_path, 60)
					else
						to_chat(user, "<span class='warning'>Вы выбрали беззвучный deathgasp или выбранный вами звук отсутствует!</span>")
				// BLUEMOON ADD END
				if("ooc_notes")
					var/msg = stripped_multiline_input(usr, "Установите всегда видимые OOC-заметки, связанные с вашими предпочтениями.", "ООС-Заметки", html_decode(features["ooc_notes"]), MAX_FLAVOR_LEN, TRUE)
					if(!isnull(msg))
						features["ooc_notes"] = msg

				if("hide_ckey")
					hide_ckey = !hide_ckey
					if(user)
						user.mind?.hide_ckey = hide_ckey

				//SPLURT EDIT BEGIN - gregnancy
				if("virility")
					var/viri = input(user, "Set the chance of you impregnating something (set to 0 to disable). \n(0 = minimum, 100 = maximum)", "Character Preference", virility) as num|null
					virility = clamp(viri, 0, 100)

				if("fertility")
					var/fert = input(user, "Set the chance of you getting impregnated (set to 0 to disable). \n(0 = minimum, 100 = maximum)", "Character Preference", fertility) as num|null
					fertility = clamp(fert, 0, 100)

				if("egg_shell")
					var/shell = tgui_input_list(user, "Pick a shell for your eggs", "Character Preferences", GLOB.egg_skins)
					if(shell)
						egg_shell = shell

				if("pregnancy_inflation")
					pregnancy_inflation = !pregnancy_inflation

				if("pregnancy_breast_growth")
					pregnancy_breast_growth = !pregnancy_breast_growth

				//SPLURT EDIT END

				if("hair")
					var/new_hair = input(user, "Choose your character's hair colour:", "Character Preference","#"+hair_color) as color|null
					if(new_hair)
						hair_color = sanitize_hexcolor(new_hair, 6)

				if("hair_style")
					var/new_hair_style
					new_hair_style = tgui_input_list(user, "Choose your character's hair style:", "Character Preference", GLOB.hair_styles_list)
					if(new_hair_style)
						hair_style = new_hair_style

				if("next_hair_style")
					hair_style = next_list_item(hair_style, GLOB.hair_styles_list)

				if("previous_hair_style")
					hair_style = previous_list_item(hair_style, GLOB.hair_styles_list)

				if("facial")
					var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character Preference","#"+facial_hair_color) as color|null
					if(new_facial)
						facial_hair_color = sanitize_hexcolor(new_facial, 6)

				if("facial_hair_style")
					var/new_facial_hair_style
					new_facial_hair_style = tgui_input_list(user, "Choose your character's facial-hair style:", "Character Preference", GLOB.facial_hair_styles_list)
					if(new_facial_hair_style)
						facial_hair_style = new_facial_hair_style

				if("next_facehair_style")
					facial_hair_style = next_list_item(facial_hair_style, GLOB.facial_hair_styles_list)

				if("previous_facehair_style")
					facial_hair_style = previous_list_item(facial_hair_style, GLOB.facial_hair_styles_list)

				if("grad_color")
					var/new_grad_color = input(user, "Choose your character's gradient colour:", "Character Preference","#"+grad_color) as color|null
					if(new_grad_color)
						grad_color = sanitize_hexcolor(new_grad_color, 6)

				if("grad_style")
					var/new_grad_style
					new_grad_style = tgui_input_list(user, "Choose your character's hair gradient style:", "Character Preference", GLOB.hair_gradients_list)
					if(new_grad_style)
						grad_style = new_grad_style

				if("next_grad_style")
					grad_style = next_list_item(grad_style, GLOB.hair_gradients_list)

				if("previous_grad_style")
					grad_style = previous_list_item(grad_style, GLOB.hair_gradients_list)

				// BLUEMOON ADD START - <_AND_>_FOR_CHARACTER_REDACTOR

				// HORNS
				if("next_horns_style")
					features["horns"] = next_list_item(features["horns"], GLOB.horns_list)

				if("previous_horns_style")
					features["horns"] = previous_list_item(features["horns"], GLOB.horns_list)

				// MEAT TYPE
				if("next_meat_type_style")
					features["meat_type"] = next_list_item(features["meat_type"], GLOB.meat_types)

				if("previous_meat_type_style")
					features["meat_type"] = previous_list_item(features["meat_type"], GLOB.meat_types)

				// IPC ANTENNA
				if("next_ipc_antenna_style")
					features["ipc_antenna"] = next_list_item(features["ipc_antenna"], GLOB.ipc_antennas_list)

				if("previous_ipc_antenna_style")
					features["ipc_antenna"] = previous_list_item(features["ipc_antenna"], GLOB.ipc_antennas_list)

				// IPC SCREENS
				if("next_ipc_screen_style")
					features["ipc_screen"] = next_list_item(features["ipc_screen"], GLOB.ipc_screens_list)

				if("previous_ipc_screen_style")
					features["ipc_screen"] = previous_list_item(features["ipc_screen"], GLOB.ipc_screens_list)

				// XENO DORSALS
				if("next_xenodorsal_style")
					features["xenodorsal"] = next_list_item(features["xenodorsal"], GLOB.xeno_dorsal_list)

				if("previous_xenodorsal_style")
					features["xenodorsal"] = previous_list_item(features["xenodorsal"], GLOB.xeno_dorsal_list)

				// XENO TAILS
				if("next_xenotail_style")
					features["xenotail"] = next_list_item(features["xenotail"], GLOB.xeno_tail_list)

				if("previous_xenotail_style")
					features["xenotail"] = previous_list_item(features["xenotail"], GLOB.xeno_tail_list)

				// XENO HEADS
				if("next_xenohead_style")
					features["xenohead"] = next_list_item(features["xenohead"], GLOB.xeno_head_list)

				if("previous_xenohead_style")
					features["xenohead"] = previous_list_item(features["xenohead"], GLOB.xeno_head_list)

				// ARACHNIDS MANDIBLES
				if("next_arachnid_mandibles_style")
					features["arachnid_mandibles"] = next_list_item(features["arachnid_mandibles"], GLOB.arachnid_mandibles_list)

				if("previous_arachnid_mandibles_style")
					features["arachnid_mandibles"] = previous_list_item(features["arachnid_mandibles"], GLOB.arachnid_mandibles_list)

				// ARACHINDS SPHINNERET
				if("next_arachnid_spinneret_style")
					features["arachnid_spinneret"] = next_list_item(features["arachnid_spinneret"], GLOB.arachnid_spinneret_list)

				if("previous_arachnid_spinneret_style")
					features["arachnid_spinneret"] = previous_list_item(features["arachnid_spinneret"], GLOB.arachnid_spinneret_list)

				// ARACHNIDS LEGS
				if("next_arachnid_legs_style")
					features["arachnid_legs"] = next_list_item(features["arachnid_legs"], GLOB.arachnid_legs_list)

				if("previous_arachnid_legs_style")
					features["arachnid_legs"] = previous_list_item(features["arachnid_legs"], GLOB.arachnid_legs_list)

				// WINGS
				if("next_wings_style")
					features["wings"] = next_list_item(features["wings"], GLOB.wings_list)

				if("previous_wings_style")
					features["wings"] = previous_list_item(features["wings"], GLOB.wings_list)

				// TAUR BODY
				if("next_taur_style")
					features["taur"] = next_list_item(features["taur"], GLOB.taur_list)

				if("previous_taur_style")
					features["taur"] = previous_list_item(features["taur"], GLOB.taur_list)

				// INSECT FLUFF (NECK AND SPINE)
				if("next_insect_fluff_style")
					features["insect_fluff"] = next_list_item(features["insect_fluff"], GLOB.insect_fluffs_list)

				if("previous_insect_fluff_style")
					features["insect_fluff"] = previous_list_item(features["insect_fluff"], GLOB.insect_fluffs_list)

				// INSECT WINGS
				if("next_insect_wings_style")
					features["insect_wings"] = next_list_item(features["insect_wings"], GLOB.insect_wings_list)

				if("previous_insect_wings_style")
					features["insect_wings"] = previous_list_item(features["insect_wings"], GLOB.insect_wings_list)

				// DECO WINGS
				if("next_deco_wings_style")
					features["deco_wings"] = next_list_item(features["deco_wings"], GLOB.deco_wings_list)

				if("previous_deco_wings_style")
					features["deco_wings"] = previous_list_item(features["deco_wings"], GLOB.deco_wings_list)

				// LEGS
				if("next_legs_style")
					features["legs"] = next_list_item(features["legs"], GLOB.legs_list)

				if("previous_legs_style")
					features["legs"] = previous_list_item(features["legs"], GLOB.legs_list)

				// MAMMAL SNOUTS
				if("next_mam_snouts_style")
					features["mam_snouts"] = next_list_item(features["mam_snouts"], GLOB.mam_snouts_list)

				if("previous_mam_snouts_style")
					features["mam_snouts"] = previous_list_item(features["mam_snouts"], GLOB.mam_snouts_list)

				// EARS
				if("next_ears_style")
					features["ears"] = next_list_item(features["ears"], GLOB.ears_list)

				if("previous_ears_style")
					features["ears"] = previous_list_item(features["ears"], GLOB.ears_list)

				// MAMMAL EARS
				if("next_mam_ears_style")
					features["mam_ears"] = next_list_item(features["mam_ears"], GLOB.mam_ears_list)

				if("previous_mam_ears_style")
					features["mam_ears"] = previous_list_item(features["mam_ears"], GLOB.mam_ears_list)

				// LIZARDS SPINES
				if("next_spines_style")
					features["spines"] = next_list_item(features["spines"], GLOB.spines_list)

				if("previous_spines_style")
					features["spines"] = previous_list_item(features["spines"], GLOB.spines_list)

				// LIZARDS FRILLS
				if("next_frills_style")
					features["frills"] = next_list_item(features["frills"], GLOB.frills_list)

				if("previous_frills_style")
					features["frills"] = previous_list_item(features["frills"], GLOB.frills_list)

				// LIZARDS SNOUTS
				if("next_snout_style")
					features["snout"] = next_list_item(features["snout"], GLOB.snouts_list)

				if("previous_snout_style")
					features["snout"] = previous_list_item(features["snout"], GLOB.snouts_list)

				// HUMAN TAILS
				if("next_tail_human_style")
					features["tail_human"] = next_list_item(features["tail_human"], GLOB.tails_list_human)

				if("previous_tail_human_style")
					features["tail_human"] = previous_list_item(features["tail_human"], GLOB.tails_list_human)

				// LIZARDS TAILS
				if("next_tail_lizard_style")
					features["tail_lizard"] = next_list_item(features["tail_lizard"], GLOB.tails_list_lizard)

				if("previous_tail_lizard_style")
					features["tail_lizard"] = previous_list_item(features["tail_lizard"], GLOB.tails_list_lizard)

				// MAMMAL TAILS
				if("next_mam_tail_style")
					features["mam_tail"] = next_list_item(features["mam_tail"], GLOB.mam_tails_list)

				if("previous_mam_tail_style")
					features["mam_tail"] = previous_list_item(features["mam_tail"], GLOB.mam_tails_list)
				// BLUEMOON ADD END

				if("cycle_bg")
					bgstate = next_list_item(bgstate, bgstate_options)

				if("modify_limbs")
					var/limb_type = tgui_input_list(user, "Choose the limb to modify:", "Character Preference", LOADOUT_ALLOWED_LIMB_TARGETS)
					if(limb_type)
						var/modification_type = tgui_input_list(user, "Choose the modification to the limb:", "Character Preference", LOADOUT_LIMBS)
						if(modification_type)
							if(modification_type == LOADOUT_LIMB_PROSTHETIC)
								var/prosthetic_type = tgui_input_list(user, "Choose the type of prosthetic", "Character Preference", (list("prosthetic") + GLOB.prosthetic_limb_types))
								if(prosthetic_type)
									var/number_of_prosthetics = 0
									for(var/modified_limb in modified_limbs)
										if(modified_limbs[modified_limb][1] == LOADOUT_LIMB_PROSTHETIC && modified_limb != limb_type)
											number_of_prosthetics += 1
									if(number_of_prosthetics == MAXIMUM_LOADOUT_PROSTHETICS)
										to_chat(user, "<span class='danger'>You can only have up to two prosthetic limbs!</span>")
									else
										//save the actual prosthetic data
										modified_limbs[limb_type] = list(modification_type, prosthetic_type)
							else
								if(modification_type == LOADOUT_LIMB_NORMAL)
									modified_limbs -= limb_type
								else
									modified_limbs[limb_type] = list(modification_type)

				/*
				if("underwear")
					var/new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in GLOB.underwear_list
					if(new_underwear)
						underwear = new_underwear

				if("undie_color")
					var/n_undie_color = input(user, "Choose your underwear's color.", "Character Preference", "#[undie_color]") as color|null
					if(n_undie_color)
						undie_color = sanitize_hexcolor(n_undie_color, 6)

				if("undershirt")
					var/new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in GLOB.undershirt_list
					if(new_undershirt)
						undershirt = new_undershirt

				if("shirt_color")
					var/n_shirt_color = input(user, "Choose your undershirt's color.", "Character Preference", "#[shirt_color]") as color|null
					if(n_shirt_color)
						shirt_color = sanitize_hexcolor(n_shirt_color, 6)

				if("socks")
					var/new_socks = input(user, "Choose your character's socks:", "Character Preference") as null|anything in GLOB.socks_list
					if(new_socks)
						socks = new_socks

				if("socks_color")
					var/n_socks_color = input(user, "Choose your socks' color.", "Character Preference", "#[socks_color]") as color|null
					if(n_socks_color)
						socks_color = sanitize_hexcolor(n_socks_color, 6)
				*/

				if("eyes")
					var/new_eyes = input(user, "Choose your character's eye colour:", "Character Preference","#"+left_eye_color) as color|null
					if(new_eyes)
						left_eye_color = sanitize_hexcolor(new_eyes, 6)
						right_eye_color = sanitize_hexcolor(new_eyes, 6)

				if("eye_left")
					var/new_eyes = input(user, "Choose your character's left eye colour:", "Character Preference","#"+left_eye_color) as color|null
					if(new_eyes)
						left_eye_color = sanitize_hexcolor(new_eyes, 6)

				if("eye_right")
					var/new_eyes = input(user, "Choose your character's right eye colour:", "Character Preference","#"+right_eye_color) as color|null
					if(new_eyes)
						right_eye_color = sanitize_hexcolor(new_eyes, 6)

				if("eye_type")
					var/new_eye_type = tgui_input_list(user, "Choose your character's eye type.", "Character Preference", GLOB.eye_types)
					if(new_eye_type)
						eye_type = new_eye_type

				if("toggle_split_eyes")
					split_eye_colors = !split_eye_colors
					right_eye_color = left_eye_color

				if("species")
					var/result = tgui_input_list(user, "Select a species", "Species Selection", GLOB.roundstart_race_names)
					if(result)
						var/newtype = GLOB.species_list[GLOB.roundstart_race_names[result]]
						pref_species = new newtype()
						//let's ensure that no weird shit happens on species swapping.
						custom_species = null
						if(!parent?.can_have_part("mam_body_markings"))
							features["mam_body_markings"] = list()
						if(parent?.can_have_part("mam_body_markings"))
							if(features["mam_body_markings"] == "None")
								features["mam_body_markings"] = list()
						if(parent?.can_have_part("tail_lizard"))
							features["tail_lizard"] = "Smooth"
						if(pref_species.id == "felinid")
							features["mam_tail"] = "Cat"
							features["mam_ears"] = "Cat"

						//Now that we changed our species, we must verify that the mutant colour is still allowed.
						var/temp_hsv = RGBtoHSV(features["mcolor"])
						if(features["mcolor"] == "#000000" || (!(MUTCOLORS_PARTSONLY in pref_species.species_traits) && ReadHSV(temp_hsv)[3] < ReadHSV("#202020")[3]))
							features["mcolor"] = pref_species.default_color
						if(features["mcolor2"] == "#000000" || (!(MUTCOLORS_PARTSONLY in pref_species.species_traits) && ReadHSV(temp_hsv)[3] < ReadHSV("#202020")[3]))
							features["mcolor2"] = pref_species.default_color
						if(features["mcolor3"] == "#000000" || (!(MUTCOLORS_PARTSONLY in pref_species.species_traits) && ReadHSV(temp_hsv)[3] < ReadHSV("#202020")[3]))
							features["mcolor3"] = pref_species.default_color

						//switch to the type of eyes the species uses
						eye_type = pref_species.eye_type

				if("custom_species")
					var/new_species = reject_bad_name(input(user, "Выберите особую расу персонажа, если он уникален. Это будет отображаться при осмотре и сканировании здоровья. Не злоупотребляйте этим:", "Character Preference", custom_species) as null|text, TRUE)
					if(new_species)
						custom_species = new_species
					else
						custom_species = null

				if("mutant_color")
					var/new_mutantcolor = input(user, "Choose your character's alien/mutant color:", "Character Preference","#"+features["mcolor"]) as color|null
					if(new_mutantcolor)
						var/temp_hsv = RGBtoHSV(new_mutantcolor)
						if(new_mutantcolor == "#000000" && features["mcolor"] != pref_species.default_color) //SPLURT EDIT
							features["mcolor"] = pref_species.default_color
						else if((MUTCOLORS_PARTSONLY in pref_species.species_traits) || ReadHSV(temp_hsv)[3] >= ReadHSV(MINIMUM_MUTANT_COLOR)[3] || !CONFIG_GET(flag/character_color_limits)) // mutantcolors must be bright, but only if they affect the skin //SPLURT EDIT
							features["mcolor"] = sanitize_hexcolor(new_mutantcolor, 6)
						else
							to_chat(user, "<span class='danger'>Invalid color. Your color is not bright enough.</span>")

				if("mutant_color2")
					var/new_mutantcolor = input(user, "Choose your character's secondary alien/mutant color:", "Character Preference","#"+features["mcolor2"]) as color|null
					if(new_mutantcolor)
						var/temp_hsv = RGBtoHSV(new_mutantcolor)
						if(new_mutantcolor == "#000000" && features["mcolor2"] != pref_species.default_color) //SPLURT EDIT
							features["mcolor2"] = pref_species.default_color
						else if((MUTCOLORS_PARTSONLY in pref_species.species_traits) || ReadHSV(temp_hsv)[3] >= ReadHSV(MINIMUM_MUTANT_COLOR)[3] || !CONFIG_GET(flag/character_color_limits)) // mutantcolors must be bright, but only if they affect the skin //SPLURT EDIT
							features["mcolor2"] = sanitize_hexcolor(new_mutantcolor, 6)
						else
							to_chat(user, "<span class='danger'>Invalid color. Your color is not bright enough.</span>")

				if("mutant_color3")
					var/new_mutantcolor = input(user, "Choose your character's tertiary alien/mutant color:", "Character Preference","#"+features["mcolor3"]) as color|null
					if(new_mutantcolor)
						var/temp_hsv = RGBtoHSV(new_mutantcolor)
						if(new_mutantcolor == "#000000" && features["mcolor3"] != pref_species.default_color) //SPLURT EDIT
							features["mcolor3"] = pref_species.default_color
						else if((MUTCOLORS_PARTSONLY in pref_species.species_traits) || ReadHSV(temp_hsv)[3] >= ReadHSV(MINIMUM_MUTANT_COLOR)[3] || !CONFIG_GET(flag/character_color_limits)) // mutantcolors must be bright, but only if they affect the skin //SPLURT EDIT
							features["mcolor3"] = sanitize_hexcolor(new_mutantcolor, 6)
						else
							to_chat(user, "<span class='danger'>Invalid color. Your color is not bright enough.</span>")

				if("mismatched_markings")
					show_mismatched_markings = !show_mismatched_markings

				if("puddle_slime_task")
					features["puddle_slime_fea"] = !features["puddle_slime_fea"]

				if("has_neckfire")
					features["neckfire"] = !features["neckfire"]
				if("has_neckfire_color")
					var/new_neckfire_color = input(user, "Choose your fire's color:", "Character Preference", "#"+features["neckfire_color"]) as color|null
					if(new_neckfire_color)
						var/temp_hsv = RGBtoHSV(new_neckfire_color)
						if(new_neckfire_color == "#000000" && features["neckfire_color"] != pref_species.default_color) //SPLURT EDIT
							features["neckfire_color"] = pref_species.default_color
						else if(ReadHSV(temp_hsv)[3] >= ReadHSV(MINIMUM_MUTANT_COLOR)[3] || !CONFIG_GET(flag/character_color_limits)) //SPLURT EDIT
							features["neckfire_color"] = sanitize_hexcolor(new_neckfire_color, 6)
						else
							to_chat(user,"<span class='danger'>Invalid color. Your color is not bright enough.</span>")

				if("ipc_screen")
					var/new_ipc_screen
					new_ipc_screen = tgui_input_list(user, "Choose your character's screen:", "Character Preference", GLOB.ipc_screens_list)
					if(new_ipc_screen)
						features["ipc_screen"] = new_ipc_screen

				if("ipc_antenna")
					var/list/snowflake_antenna_list = list()
					//Potential todo: turn all of THIS into a define to reduce copypasta.
					for(var/path in GLOB.ipc_antennas_list)
						var/datum/sprite_accessory/antenna/instance = GLOB.ipc_antennas_list[path]
						if(istype(instance, /datum/sprite_accessory))
							var/datum/sprite_accessory/S = instance
							if(!show_mismatched_markings && S.recommended_species && !S.recommended_species.Find(pref_species.id))
								continue
							if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
								snowflake_antenna_list[S.name] = path
					var/new_ipc_antenna
					new_ipc_antenna = tgui_input_list(user, "Choose your character's antenna:", "Character Preference", snowflake_antenna_list)
					if(new_ipc_antenna)
						features["ipc_antenna"] = new_ipc_antenna

				if("arachnid_legs")
					var/new_arachnid_legs
					new_arachnid_legs = tgui_input_list(user, "Choose your character's variant of arachnid legs:", "Character Preference", GLOB.arachnid_legs_list)
					if(new_arachnid_legs)
						features["arachnid_legs"] = new_arachnid_legs

				if("arachnid_spinneret")
					var/new_arachnid_spinneret
					new_arachnid_spinneret = tgui_input_list(user, "Choose your character's spinneret markings:", "Character Preference", GLOB.arachnid_spinneret_list)
					if(new_arachnid_spinneret)
						features["arachnid_spinneret"] = new_arachnid_spinneret

				if("arachnid_mandibles")
					var/new_arachnid_mandibles
					new_arachnid_mandibles = tgui_input_list(user, "Choose your character's variant of mandibles:", "Character Preference", GLOB.arachnid_mandibles_list)
					if (new_arachnid_mandibles)
						features["arachnid_mandibles"] = new_arachnid_mandibles

				if("tail_lizard")
					var/new_tail
					new_tail = tgui_input_list(user, "Choose your character's tail:", "Character Preference", GLOB.tails_list_lizard)
					if(new_tail)
						features["tail_lizard"] = new_tail
						if(new_tail != "None")
							features["taur"] = "None"
							features["tail_human"] = "None"
							features["mam_tail"] = "None"

				if("tail_human")
					var/list/snowflake_tails_list = list()
					for(var/path in GLOB.tails_list_human)
						var/datum/sprite_accessory/tails/human/instance = GLOB.tails_list_human[path]
						if(istype(instance, /datum/sprite_accessory))
							var/datum/sprite_accessory/S = instance
							if(!show_mismatched_markings && S.recommended_species && !S.recommended_species.Find(pref_species.id))
								continue
							if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
								snowflake_tails_list[S.name] = path
					var/new_tail
					new_tail = tgui_input_list(user, "Choose your character's tail:", "Character Preference", snowflake_tails_list)
					if(new_tail)
						features["tail_human"] = new_tail
						if(new_tail != "None")
							features["taur"] = "None"
							features["tail_lizard"] = "None"
							features["mam_tail"] = "None"

				if("mam_tail")
					var/list/snowflake_tails_list = list()
					for(var/path in GLOB.mam_tails_list)
						var/datum/sprite_accessory/tails/mam_tails/instance = GLOB.mam_tails_list[path]
						if(istype(instance, /datum/sprite_accessory))
							var/datum/sprite_accessory/S = instance
							if(!show_mismatched_markings && S.recommended_species && !S.recommended_species.Find(pref_species.id))
								continue
							if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
								snowflake_tails_list[S.name] = path
					var/new_tail
					new_tail = tgui_input_list(user, "Choose your character's tail:", "Character Preference", snowflake_tails_list)
					if(new_tail)
						features["mam_tail"] = new_tail
						if(new_tail != "None")
							features["taur"] = "None"
							features["tail_human"] = "None"
							features["tail_lizard"] = "None"

				if("meat_type")
					var/new_meat
					new_meat = tgui_input_list(user, "Choose your character's meat type:", "Character Preference", GLOB.meat_types)
					if(new_meat)
						features["meat_type"] = new_meat

				if("snout")
					var/list/snowflake_snouts_list = list()
					for(var/path in GLOB.snouts_list)
						var/datum/sprite_accessory/snouts/mam_snouts/instance = GLOB.snouts_list[path]
						if(istype(instance, /datum/sprite_accessory))
							var/datum/sprite_accessory/S = instance
							if(!show_mismatched_markings && S.recommended_species && !S.recommended_species.Find(pref_species.id))
								continue
							if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
								snowflake_snouts_list[S.name] = path
					var/new_snout
					new_snout = tgui_input_list(user, "Choose your character's snout:", "Character Preference", snowflake_snouts_list)
					if(new_snout)
						features["snout"] = new_snout
						features["mam_snouts"] = "None"


				if("mam_snouts")
					var/list/snowflake_mam_snouts_list = list()
					for(var/path in GLOB.mam_snouts_list)
						var/datum/sprite_accessory/snouts/mam_snouts/instance = GLOB.mam_snouts_list[path]
						if(istype(instance, /datum/sprite_accessory))
							var/datum/sprite_accessory/S = instance
							if(!show_mismatched_markings && S.recommended_species && !S.recommended_species.Find(pref_species.id))
								continue
							if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
								snowflake_mam_snouts_list[S.name] = path
					var/new_mam_snouts
					new_mam_snouts = tgui_input_list(user, "Choose your character's snout:", "Character Preference", snowflake_mam_snouts_list)
					if(new_mam_snouts)
						features["mam_snouts"] = new_mam_snouts
						features["snout"] = "None"

				if("horns")
					var/new_horns
					new_horns = tgui_input_list(user, "Choose your character's horns:", "Character Preference", GLOB.horns_list)
					if(new_horns)
						features["horns"] = new_horns

				if("horns_color")
					var/new_horn_color = input(user, "Choose your character's horn colour:", "Character Preference","#"+features["horns_color"]) as color|null
					if(new_horn_color)
						if (new_horn_color == "#000000" && features["horns_color"] != "85615A") //SPLURT EDIT
							features["horns_color"] = "85615A"
						else
							features["horns_color"] = sanitize_hexcolor(new_horn_color, 6)

				if("wings")
					var/new_wings
					new_wings = tgui_input_list(user, "Choose your character's wings:", "Character Preference", GLOB.r_wings_list)
					if(new_wings)
						features["wings"] = new_wings

				if("wings_color")
					var/new_wing_color = input(user, "Choose your character's wing colour:", "Character Preference","#"+features["wings_color"]) as color|null
					if(new_wing_color)
						if (new_wing_color == "#000000" && features["wings_color"] != "#FFFFFF") //SPLURT EDIT
							features["wings_color"] = "#FFFFFF"
						else
							features["wings_color"] = sanitize_hexcolor(new_wing_color, 6)

				if("frills")
					var/new_frills
					new_frills = tgui_input_list(user, "Choose your character's frills:", "Character Preference", GLOB.frills_list)
					if(new_frills)
						features["frills"] = new_frills

				if("spines")
					var/new_spines
					new_spines = tgui_input_list(user, "Choose your character's spines:", "Character Preference", GLOB.spines_list)
					if(new_spines)
						features["spines"] = new_spines

				if("legs")
					var/new_legs
					new_legs = tgui_input_list(user, "Choose your character's legs:", "Character Preference", GLOB.legs_list)
					if(new_legs)
						features["legs"] = new_legs

				if("insect_wings")
					var/new_insect_wings
					new_insect_wings = tgui_input_list(user, "Choose your character's wings:", "Character Preference", GLOB.insect_wings_list)
					if(new_insect_wings)
						features["insect_wings"] = new_insect_wings

				if("deco_wings")
					var/new_deco_wings
					new_deco_wings = tgui_input_list(user, "Choose your character's wings:", "Character Preference", GLOB.deco_wings_list)
					if(new_deco_wings)
						features["deco_wings"] = new_deco_wings

				if("insect_fluff")
					var/new_insect_fluff
					new_insect_fluff = tgui_input_list(user, "Choose your character's wings:", "Character Preference", GLOB.insect_fluffs_list)
					if(new_insect_fluff)
						features["insect_fluff"] = new_insect_fluff

				if("insect_markings")
					var/new_insect_markings
					new_insect_markings = tgui_input_list(user, "Choose your character's markings:", "Character Preference", GLOB.insect_markings_list)
					if(new_insect_markings)
						features["insect_markings"] = new_insect_markings

				if("arachnid_legs")
					var/new_arachnid_legs
					new_arachnid_legs = tgui_input_list(user, "Choose your character's variant of arachnid legs:", "Character Preference", GLOB.arachnid_legs_list)
					if(new_arachnid_legs)
						features["arachnid_legs"] = new_arachnid_legs

				if("arachnid_spinneret")
					var/new_arachnid_spinneret
					new_arachnid_spinneret = tgui_input_list(user, "Choose your character's spinneret markings:", "Character Preference", GLOB.arachnid_spinneret_list)
					if(new_arachnid_spinneret)
						features["arachnid_spinneret"] = new_arachnid_spinneret

				if("arachnid_mandibles")
					var/new_arachnid_mandibles
					new_arachnid_mandibles = tgui_input_list(user, "Choose your character's variant of mandibles:", "Character Preference", GLOB.arachnid_mandibles_list)
					if (new_arachnid_mandibles)
						features["arachnid_mandibles"] = new_arachnid_mandibles

				if("s_tone")
					var/list/choices = GLOB.skin_tones - GLOB.nonstandard_skin_tones
					if(CONFIG_GET(flag/allow_custom_skintones))
						choices += "custom"
					var/new_s_tone = tgui_input_list(user, "Choose your character's skin tone:", "Character Preference", choices)
					if(new_s_tone)
						if(new_s_tone == "custom")
							var/default = use_custom_skin_tone ? skin_tone : null
							var/custom_tone = input(user, "Choose your custom skin tone:", "Character Preference", default) as color|null
							if(custom_tone)
								var/temp_hsv = RGBtoHSV(custom_tone)
								if(ReadHSV(temp_hsv)[3] < ReadHSV("#333333")[3] && CONFIG_GET(flag/character_color_limits)) // rgb(50,50,50) //SPLURT EDIT
									to_chat(user,"<span class='danger'>Invalid color. Your color is not bright enough.</span>")
								else
									use_custom_skin_tone = TRUE
									skin_tone = custom_tone
						else
							use_custom_skin_tone = FALSE
							skin_tone = new_s_tone

				if("taur")
					var/list/snowflake_taur_list = list()
					for(var/path in GLOB.taur_list)
						var/datum/sprite_accessory/taur/instance = GLOB.taur_list[path]
						if(istype(instance, /datum/sprite_accessory))
							var/datum/sprite_accessory/S = instance
							if(!show_mismatched_markings && S.recommended_species && !S.recommended_species.Find(pref_species.id))
								continue
							if(S.ignore)
								continue
							if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
								snowflake_taur_list[S.name] = path
					var/new_taur
					new_taur = tgui_input_list(user, "Choose your character's tauric body:", "Character Preference", snowflake_taur_list)
					if(new_taur)
						features["taur"] = new_taur
						if(new_taur != "None")
							features["mam_tail"] = "None"
							features["xenotail"] = "None"
							features["tail_human"] = "None"
							features["tail_lizard"] = "None"
							features["arachnid_spinneret"] = "None"

				if("ears")
					var/list/snowflake_ears_list = list()
					for(var/path in GLOB.ears_list)
						var/datum/sprite_accessory/ears/instance = GLOB.ears_list[path]
						if(istype(instance, /datum/sprite_accessory))
							var/datum/sprite_accessory/S = instance
							if(!show_mismatched_markings && S.recommended_species && !S.recommended_species.Find(pref_species.id))
								continue
							if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
								snowflake_ears_list[S.name] = path
					var/new_ears
					new_ears = tgui_input_list(user, "Choose your character's ears:", "Character Preference", snowflake_ears_list)
					if(new_ears)
						features["ears"] = new_ears

				if("mam_ears")
					var/list/snowflake_ears_list = list()
					for(var/path in GLOB.mam_ears_list)
						var/datum/sprite_accessory/ears/mam_ears/instance = GLOB.mam_ears_list[path]
						if(istype(instance, /datum/sprite_accessory))
							var/datum/sprite_accessory/S = instance
							if(!show_mismatched_markings && S.recommended_species && !S.recommended_species.Find(pref_species.id))
								continue
							if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
								snowflake_ears_list[S.name] = path
					var/new_ears
					new_ears = tgui_input_list(user, "Choose your character's ears:", "Character Preference", snowflake_ears_list)
					if(new_ears)
						features["mam_ears"] = new_ears

				//Xeno Bodyparts
				if("xenohead")//Head or caste type
					var/new_head
					new_head = tgui_input_list(user, "Choose your character's caste:", "Character Preference", GLOB.xeno_head_list)
					if(new_head)
						features["xenohead"] = new_head

				if("xenotail")//Currently one one type, more maybe later if someone sprites them. Might include animated variants in the future.
					var/new_tail
					new_tail = tgui_input_list(user, "Choose your character's tail:", "Character Preference", GLOB.xeno_tail_list)
					if(new_tail)
						features["xenotail"] = new_tail
						if(new_tail != "None")
							features["mam_tail"] = "None"
							features["taur"] = "None"
							features["tail_human"] = "None"
							features["tail_lizard"] = "None"

				if("xenodorsal")
					var/new_dors
					new_dors = tgui_input_list(user, "Choose your character's dorsal tube type:", "Character Preference", GLOB.xeno_dorsal_list)
					if(new_dors)
						features["xenodorsal"] = new_dors

				//every single primary/secondary/tertiary colouring done at once
				if("xenodorsal_primary","xenodorsal_secondary","xenodorsal_tertiary","xhead_primary","xhead_secondary","xhead_tertiary","tail_primary","tail_secondary","tail_tertiary","insect_markings_primary","insect_markings_secondary","insect_markings_tertiary","insect_fluff_primary","insect_fluff_secondary","insect_fluff_tertiary","ears_primary","ears_secondary","ears_tertiary","frills_primary","frills_secondary","frills_tertiary","ipc_antenna_primary","ipc_antenna_secondary","ipc_antenna_tertiary","taur_primary","taur_secondary","taur_tertiary","snout_primary","snout_secondary","snout_tertiary","spines_primary","spines_secondary","spines_tertiary", "mam_body_markings_primary", "mam_body_markings_secondary", "mam_body_markings_tertiary")
					var/the_feature = features[href_list["preference"]]
					if(!the_feature)
						features[href_list["preference"]] = "FFFFFF"
						the_feature = "FFFFFF"
					var/new_feature_color = input(user, "Choose your character's mutant part colour:", "Character Preference","#"+features[href_list["preference"]]) as color|null
					if(new_feature_color)
						var/temp_hsv = RGBtoHSV(new_feature_color)
						if(new_feature_color == "#000000" && features[href_list["preference"]] != pref_species.default_color) //SPLURT EDIT
							features[href_list["preference"]] = pref_species.default_color
						else if(ReadHSV(temp_hsv)[3] >= ReadHSV(MINIMUM_MUTANT_COLOR)[3] || !CONFIG_GET(flag/character_color_limits)) //SPLURT EDIT
							features[href_list["preference"]] = sanitize_hexcolor(new_feature_color, 6)
						else
							to_chat(user,"<span class='danger'>Invalid color. Your color is not bright enough.</span>")


				//advanced color mode toggle
				if("color_scheme")
					if(features["color_scheme"] == ADVANCED_CHARACTER_COLORING)
						features["color_scheme"] = OLD_CHARACTER_COLORING
					else
						features["color_scheme"] = ADVANCED_CHARACTER_COLORING

				//Genital code
				if("lust_tolerance")
					var/lust_tol = input(user, "Set how long you can last without climaxing. \n(25 = minimum, 200 = maximum.)", "Character Preference", lust_tolerance) as num|null
					if(lust_tol)
						lust_tolerance = clamp(lust_tol, 25, 200)
				if("sexual_potency")
					var/sexual_pot = input(user, "Set your sexual potency. \n(-1 = minimum, 25 = maximum.) This determines the number of times your character can orgasm before becoming impotent, use -1 for no impotency.", "Character Preference", sexual_potency) as num|null
					if(sexual_pot)
						sexual_potency = clamp(sexual_pot, -1, 25)

				if("cock_color")
					var/new_cockcolor = input(user, "Penis color:", "Character Preference","#"+features["cock_color"]) as color|null
					if(new_cockcolor)
						var/temp_hsv = RGBtoHSV(new_cockcolor)
						if(new_cockcolor == "#000000" && features["cock_color"] != pref_species.default_color) //SPLURT EDIT
							features["cock_color"] = pref_species.default_color
						else if(ReadHSV(temp_hsv)[3] >= ReadHSV(MINIMUM_MUTANT_COLOR)[3] || !CONFIG_GET(flag/character_color_limits)) //SPLURT EDIT
							features["cock_color"] = sanitize_hexcolor(new_cockcolor, 6)
						else
							to_chat(user,"<span class='danger'>Invalid color. Your color is not bright enough.</span>")

				if("cock_length")
					var/min_D = CONFIG_GET(number/penis_min_inches_prefs)
					var/max_D = CONFIG_GET(number/penis_max_inches_prefs)
					var/new_length = input(user, "Penis length in centimeters:\n([min_D]-[max_D])\nReminder that your sprite size will affect this.", "Character Preference") as num|null
					if(new_length)
						features["cock_length"] = clamp(round(new_length), min_D, max_D)

				if("cock_shape")
					var/new_shape
					var/list/hockeys = list()
					if(parent?.can_have_part("taur"))
						var/datum/sprite_accessory/taur/T = GLOB.taur_list[features["taur"]]
						for(var/A in GLOB.cock_shapes_list)
							var/datum/sprite_accessory/penis/P = GLOB.cock_shapes_list[A]
							if(P.taur_icon && T.taur_mode & P.accepted_taurs)
								LAZYSET(hockeys, "[A] (Taur)", A)
					new_shape = tgui_input_list(user, "Penis shape:", "Character Preference", (GLOB.cock_shapes_list + hockeys))
					if(new_shape)
						features["cock_taur"] = FALSE
						if(hockeys[new_shape])
							new_shape = hockeys[new_shape]
							features["cock_taur"] = TRUE
						features["cock_shape"] = new_shape

				if("cock_diameter_ratio")
					var/min_diameter_ratio = CONFIG_GET(number/diameter_ratio_min_size_prefs)
					var/max_diameter_ratio = CONFIG_GET(number/diameter_ratio_max_size_prefs)
					var/new_ratio = input(user, "Penis diameter ratio:\n([min_diameter_ratio]-[max_diameter_ratio])\nReminder that your sprite size will affect this.", "Character Preference") as num|null
					if(new_ratio)
						features["cock_diameter_ratio"] = clamp(round(new_ratio, 0.01), min_diameter_ratio, max_diameter_ratio)

				if("cock_visibility")
					var/n_vis = tgui_input_list(user, "Penis Visibility", "Character Preference", CONFIG_GET(str_list/safe_visibility_toggles))
					if(n_vis)
						features["cock_visibility"] = n_vis

				if("balls_color")
					var/new_ballscolor = input(user, "Testicles Color:", "Character Preference","#"+features["balls_color"]) as color|null
					if(new_ballscolor)
						var/temp_hsv = RGBtoHSV(new_ballscolor)
						if(new_ballscolor == "#000000" && features["balls_color"] != pref_species.default_color) //SPLURT EDIT
							features["balls_color"] = pref_species.default_color
						else if(ReadHSV(temp_hsv)[3] >= ReadHSV(MINIMUM_MUTANT_COLOR)[3] || !CONFIG_GET(flag/character_color_limits)) //SPLURT EDIT
							features["balls_color"] = sanitize_hexcolor(new_ballscolor, 6)
						else
							to_chat(user,"<span class='danger'>Invalid color. Your color is not bright enough.</span>")

				if("balls_shape")
					var/new_shape
					new_shape = tgui_input_list(user, "Testicle Shape", "Character Preference", GLOB.balls_shapes_list)
					if(new_shape)
						features["balls_shape"] = new_shape

				if("balls_size")
					var/new_size = tgui_input_number(user, "Testicles Size:\n([BALLS_SIZE_MIN]-[BALLS_SIZE_MAX])", "Character Preference", features["balls_size"], BALLS_SIZE_MAX, BALLS_SIZE_MIN)
					if(new_size)
						features["balls_size"] = clamp(round(new_size), BALLS_SIZE_MIN, BALLS_SIZE_MAX)

				if("balls_visibility")
					var/n_vis = tgui_input_list(user, "Testicles Visibility", "Character Preference", CONFIG_GET(str_list/safe_visibility_toggles))
					if(n_vis)
						features["balls_visibility"] = n_vis

				if("balls_fluid")
					var/datum/reagent/new_fluid
					var/list/full_options = list()
					LAZYADD(full_options, GLOB.genital_fluids_list)
					LAZYREMOVE(full_options, find_reagent_object_from_type(/datum/reagent/consumable/semen))
					full_options = list(find_reagent_object_from_type(/datum/reagent/consumable/semen)) + full_options
					new_fluid = tgui_input_list(user, "Balls Fluid", "Character Preference", full_options)
					if(new_fluid)
						features["balls_fluid"] = new_fluid.type

				if("breasts_size")
					var/new_size = tgui_input_list(user, "Breast Size", "Character Preference", CONFIG_GET(keyed_list/breasts_cups_prefs))
					if(new_size)
						features["breasts_size"] = new_size

				if("breasts_shape")
					var/new_shape
					new_shape = tgui_input_list(user, "Breast Shape", "Character Preference", GLOB.breasts_shapes_list)
					if(new_shape)
						features["breasts_shape"] = new_shape

				if("breasts_color")
					var/new_breasts_color = input(user, "Breast Color:", "Character Preference","#"+features["breasts_color"]) as color|null
					if(new_breasts_color)
						var/temp_hsv = RGBtoHSV(new_breasts_color)
						if(new_breasts_color == "#000000" && features["breasts_color"] != pref_species.default_color) //SPLURT EDIT
							features["breasts_color"] = pref_species.default_color
						else if(ReadHSV(temp_hsv)[3] >= ReadHSV(MINIMUM_MUTANT_COLOR)[3] || !CONFIG_GET(flag/character_color_limits)) //SPLURT EDIT
							features["breasts_color"] = sanitize_hexcolor(new_breasts_color, 6)
						else
							to_chat(user,"<span class='danger'>Invalid color. Your color is not bright enough.</span>")

				if("breasts_visibility")
					var/n_vis = tgui_input_list(user, "Breasts Visibility", "Character Preference", CONFIG_GET(str_list/safe_visibility_toggles))
					if(n_vis)
						features["breasts_visibility"] = n_vis

				if("breasts_fluid")
					var/datum/reagent/new_fluid
					var/list/full_options = list()
					LAZYADD(full_options, GLOB.genital_fluids_list)
					LAZYREMOVE(full_options, find_reagent_object_from_type(/datum/reagent/consumable/milk))
					full_options = list(find_reagent_object_from_type(/datum/reagent/consumable/milk)) + full_options
					new_fluid = tgui_input_list(user, "Breast Fluid", "Character Preference", full_options)
					if(new_fluid)
						features["breasts_fluid"] = new_fluid.type

				if("vag_shape")
					var/new_shape
					new_shape = tgui_input_list(user, "Vagina Type", "Character Preference", GLOB.vagina_shapes_list)
					if(new_shape)
						features["vag_shape"] = new_shape

				if("vag_color")
					var/new_vagcolor = input(user, "Vagina color:", "Character Preference","#"+features["vag_color"]) as color|null
					if(new_vagcolor)
						var/temp_hsv = RGBtoHSV(new_vagcolor)
						if(new_vagcolor == "#000000" && features["vag_color"] != pref_species.default_color) //SPLURT EDIT
							features["vag_color"] = pref_species.default_color
						else if(ReadHSV(temp_hsv)[3] >= ReadHSV(MINIMUM_MUTANT_COLOR)[3] || !CONFIG_GET(flag/character_color_limits)) //SPLURT EDIT
							features["vag_color"] = sanitize_hexcolor(new_vagcolor, 6)
						else
							to_chat(user,"<span class='danger'>Invalid color. Your color is not bright enough.</span>")

				if("vag_visibility")
					var/n_vis = tgui_input_list(user, "Vagina Visibility", "Character Preference", CONFIG_GET(str_list/safe_visibility_toggles))
					if(n_vis)
						features["vag_visibility"] = n_vis

				if("womb_fluid")
					var/datum/reagent/new_fluid
					var/list/full_options = list()
					LAZYADD(full_options, GLOB.genital_fluids_list)
					LAZYREMOVE(full_options, find_reagent_object_from_type(/datum/reagent/consumable/semen/femcum))
					full_options = list(find_reagent_object_from_type(/datum/reagent/consumable/semen/femcum)) + full_options
					new_fluid = tgui_input_list(user, "Womb Fluid", "Character Preference", full_options)
					if(new_fluid)
						features["womb_fluid"] = new_fluid.type

				if("belly_color")
					var/new_bellycolor = input(user, "Belly Color:", "Character Preference", "#"+features["belly_color"]) as color|null
					if(new_bellycolor)
						var/temp_hsv = RGBtoHSV(new_bellycolor)
						if(new_bellycolor == "#000000" && features["belly_color"] != pref_species.default_color) //SPLURT EDIT
							features["belly_color"] = pref_species.default_color
						else if(ReadHSV(temp_hsv)[3] >= ReadHSV(MINIMUM_MUTANT_COLOR)[3] || !CONFIG_GET(flag/character_color_limits)) //SPLURT EDIT
							features["belly_color"] = sanitize_hexcolor(new_bellycolor, 6)
						else
							to_chat(user,"<span class='danger'>Invalid color. Your color is not bright enough.</span>")

				if("butt_color")
					var/new_buttcolor = input(user, "Butt color:", "Character Preference","#"+features["butt_color"]) as color|null
					if(new_buttcolor)
						var/temp_hsv = RGBtoHSV(new_buttcolor)
						if(new_buttcolor == "#000000" && features["butt_color"] != pref_species.default_color) //SPLURT EDIT
							features["butt_color"] = pref_species.default_color
						else if(ReadHSV(temp_hsv)[3] >= ReadHSV(MINIMUM_MUTANT_COLOR)[3] || !CONFIG_GET(flag/character_color_limits)) //SPLURT EDIT
							features["butt_color"] = sanitize_hexcolor(new_buttcolor, 6)
						else
							to_chat(user,"<span class='danger'>Invalid color. Your color is not bright enough.</span>")

				if("anus_color")
					var/new_anuscolor = input(user, "Butthole color:", "Character Preference", "#"+features["anus_color"]) as color|null
					if(new_anuscolor)
						var/temp_hsv = RGBtoHSV(new_anuscolor)
						if(new_anuscolor == "#000000" && features["anus_color"] != pref_species.default_color) //SPLURT EDIT
							features["anus_color"] = pref_species.default_color
						else if(ReadHSV(temp_hsv)[3] >= ReadHSV(MINIMUM_MUTANT_COLOR)[3] || !CONFIG_GET(flag/character_color_limits)) //SPLURT EDIT
							features["anus_color"] = sanitize_hexcolor(new_anuscolor, 6)
						else
							to_chat(user, "<span class='danger'>Invalid color. Your color is not bright enough.</span>")

				if("anus_shape")
					var/new_shape
					new_shape = tgui_input_list(user, "Butthole Shape", "Character Preference", GLOB.anus_shapes_list)
					if(new_shape)
						features["anus_shape"] = new_shape

				if("belly_size")
					var/min_belly = CONFIG_GET(number/belly_min_size_prefs)
					var/max_belly = CONFIG_GET(number/belly_max_size_prefs)
					var/new_bellysize = input(user, "Belly size :\n([min_belly]-[max_belly])", "Character Preference") as num|null
					if(!isnull(new_bellysize))
						features["belly_size"] = clamp(new_bellysize, min_belly, max_belly)

				if("butt_size")
					var/min_B = CONFIG_GET(number/butt_min_size_prefs)
					var/max_B = CONFIG_GET(number/butt_max_size_prefs)
					var/new_length = input(user, "Butt size:\n([min_B]-[max_B])", "Character Preference") as num|null
					if(new_length)
						features["butt_size"] = clamp(round(new_length), min_B, max_B)

				if("butt_visibility")
					var/n_vis = tgui_input_list(user, "Butt Visibility", "Character Preference", CONFIG_GET(str_list/safe_visibility_toggles))
					if(n_vis)
						features["butt_visibility"] = n_vis

				if("anus_visibility")
					var/n_vis = tgui_input_list(user, "Butthole Visibility", "Character Preference", CONFIG_GET(str_list/safe_visibility_toggles))
					if(n_vis)
						features["anus_visibility"] = n_vis

				if("belly_visibility")
					var/n_vis = tgui_input_list(user, "Belly Visibility", "Character Preference", CONFIG_GET(str_list/safe_visibility_toggles))
					if(n_vis)
						features["belly_visibility"] = n_vis

				if("cock_max_length")
					var/max_B = CONFIG_GET(number/penis_max_inches_prefs)
					var/new_size = input(user, "Max size:\n([features["cock_length"]]-[max_B])(0 = disabled)", "Character Preference") as num|null
					if(new_size)
						features["cock_max_length"] = clamp(round(new_size), features["cock_length"], max_B)
					else
						features -= "cock_max_length"

				if("balls_max_size")
					var/new_size = input(user, "Max size:\n([BALLS_SIZE_MIN]-[BALLS_SIZE_MAX])(0 = disabled)", "Character Preference") as num|null
					if(new_size)
						features["balls_max_size"] = clamp(round(new_size), BALLS_SIZE_MIN, BALLS_SIZE_MAX)
					else
						features -= "balls_max_size"

				if("breasts_max_size")
					var/new_size = tgui_input_list(user, "Breast Max Size (cancel to disable)", "Character Preference", GLOB.breast_values)
					if(new_size)
						features["breasts_max_size"] = new_size
					else
						features -= "breasts_max_size"

				if("belly_max_size")
					var/max_B = CONFIG_GET(number/belly_max_size_prefs)
					var/new_size = input(user, "Max size:\n([features["belly_size"]]-[max_B])(0 = disabled)", "Character Preference") as num|null
					if(new_size)
						features["belly_max_size"] = clamp(round(new_size), features["belly_size"], max_B)
					else
						features -= "belly_max_size"

				if("butt_max_size")
					var/max_B = CONFIG_GET(number/butt_max_size_prefs)
					var/new_size = input(user, "Max size:\n([features["butt_size"]]-[max_B])(0 = disabled)", "Character Preference") as num|null
					if(new_size)
						features["butt_max_size"] = clamp(round(new_size), features["butt_size"], max_B)
					else
						features -= "butt_max_size"

				if("cock_min_length")
					var/min_B = CONFIG_GET(number/penis_min_inches_prefs)
					var/new_size = input(user, "Min size:\n([min_B]-[features["cock_length"]])(0 = disabled)", "Character Preference") as num|null
					if(new_size)
						features["cock_min_length"] = clamp(round(new_size), min_B, features["cock_length"])
					else
						features -= "cock_min_length"

				if("balls_min_size")
					var/new_size = input(user, "Min size:\n([BALLS_SIZE_MIN]-[BALLS_SIZE_MAX])(0 = disabled)", "Character Preference") as num|null
					if(new_size)
						features["balls_min_size"] = clamp(round(new_size), BALLS_SIZE_MIN, BALLS_SIZE_MAX)
					else
						features -= "balls_min_size"

				if("breasts_min_size")
					var/new_size = tgui_input_list(user, "Breast Min Size (cancel to disable)", "Character Preference", GLOB.breast_values)
					if(new_size)
						features["breasts_min_size"] = new_size
					else
						features -= "breasts_min_size"

				if("belly_min_size")
					var/min_B = CONFIG_GET(number/belly_min_size_prefs)
					var/new_size = input(user, "Min size:\n([min_B]-[features["belly_size"]])(0 = disabled)", "Character Preference") as num|null
					if(new_size)
						features["belly_min_size"] = clamp(round(new_size), min_B, features["belly_size"])
					else
						features -= "belly_min_size"

				if("butt_min_size")
					var/min_B = CONFIG_GET(number/butt_min_size_prefs)
					var/new_size = input(user, "Min size:\n([min_B]-[features["butt_size"]])(0 = disabled)", "Character Preference") as num|null
					if(new_size)
						features["butt_min_size"] = clamp(round(new_size), min_B, features["butt_size"])
					else
						features -= "butt_min_size"

				if("ooccolor")
					var/new_ooccolor = input(user, "Choose your OOC colour:", "Game Preference",ooccolor) as color|null
					if(new_ooccolor)
						ooccolor = sanitize_ooccolor(new_ooccolor)

				if("aooccolor")
					var/new_aooccolor = input(user, "Choose your Antag OOC colour:", "Game Preference",ooccolor) as color|null
					if(new_aooccolor)
						aooccolor = sanitize_ooccolor(new_aooccolor)

				if("bag")
					var/new_backbag = tgui_input_list(user, "Choose your character's style of bag:", "Character Preference", GLOB.backbaglist)
					if(new_backbag)
						backbag = new_backbag

				if("suit")
					if(jumpsuit_style == PREF_SUIT)
						jumpsuit_style = PREF_SKIRT
					else
						jumpsuit_style = PREF_SUIT


				if("uplink_loc")
					var/new_loc = tgui_input_list(user, "Choose your character's traitor uplink spawn location:", "Character Preference", GLOB.uplink_spawn_loc_list)
					if(new_loc)
						uplink_spawn_loc = new_loc

				if("ai_core_icon")
					var/ai_core_icon = tgui_input_list(user, "Choose your preferred AI core display screen:", "AI Core Display Screen Selection", GLOB.ai_core_display_screens)
					if(ai_core_icon)
						preferred_ai_core_display = ai_core_icon

				if("sec_dept")
					var/department = tgui_input_list(user, "Choose your preferred security department:", "Security Departments", GLOB.security_depts_prefs)
					if(department)
						prefered_security_department = department

				if ("preferred_map")
					var/maplist = list()
					var/default = "Default"
					if (config.defaultmap)
						default += " ([config.defaultmap.map_name])"
					for (var/M in config.maplist)
						var/datum/map_config/VM = config.maplist[M]
						var/friendlyname = "[VM.map_name] "
						if (VM.voteweight <= 0)
							friendlyname += " (disabled)"
						maplist[friendlyname] = VM.map_name
					maplist[default] = null
					var/pickedmap = tgui_input_list(user, "Choose your preferred map. This will be used to help weight random map selection.", "Character Preference", maplist)
					if (pickedmap)
						preferred_map = maplist[pickedmap]

				if ("be_victim")
					var/pickedvictim = tgui_input_list(user, "Are you ok with antagonists interacting with you (e.g. kidnapping)? ERP consent is seperate: This setting does NOT mean they are allowed to rape you.", "Antag Victim Consent", list(BEVICTIM_NO,BEVICTIM_ASK,BEVICTIM_YES))
					be_victim = pickedvictim
				if ("clientfps")
					var/config_fps = CONFIG_GET(number/fps)
					var/list/fps_options = list(
						"0 (синхронизация с сервером: [config_fps])" = 0,
						"60" = 60,
						"120 (рекомендуется)" = 120,
						"180" = 180,
						"240" = 240,
						"300" = 300,
						"360" = 360,
						"420" = 420,
						"480" = 480,
					)
					var/current_label
					for(var/label in fps_options)
						if(fps_options[label] == clientfps)
							current_label = label
							break
					var/picked = tgui_input_list(user, "Выберите желаемый FPS. Рекомендуется 120.", "FPS", fps_options, current_label)
					if(!isnull(picked))
						var/desiredfps = fps_options[picked]
						clientfps = desiredfps
						parent.fps = desiredfps
				if("ui")
					var/pickedui = tgui_input_list(user, "Choose your UI style.", "Character Preference", GLOB.available_ui_styles, UI_style)
					if(pickedui)
						UI_style = pickedui
						if (pickedui && parent && parent.mob && parent.mob.hud_used)
							QDEL_NULL(parent.mob.hud_used)
							parent.mob.create_mob_hud()
							parent.mob.hud_used.show_hud(1, parent.mob)
				if("toggle_custom_blood_color")
					custom_blood_color = !custom_blood_color
				if("blood_color")
					var/pickedBloodColor = input(user, "Выбирайте цвет крови своего персонажа.", "Character Preference", blood_color) as color|null
					if(!pickedBloodColor)
						return
					if(pickedBloodColor)
						blood_color = sanitize_hexcolor(pickedBloodColor, 6, 1, initial(blood_color))
						if(!custom_blood_color)
							custom_blood_color = TRUE
				///
				if("pda_style")
					var/pickedPDAStyle = tgui_input_list(user, "Выбирайте стиль своего КПК.", "Character Preference", GLOB.pda_styles, pda_style)
					if(pickedPDAStyle)
						pda_style = pickedPDAStyle
				if("pda_color")
					var/pickedPDAColor = input(user, "Выбирайте цвет интерфейса своего КПК.", "Character Preference", pda_color) as color|null
					if(pickedPDAColor)
						pda_color = pickedPDAColor
				if("pda_skin")
					var/pickedPDASkin = tgui_input_list(user, "Выбирайте модель своего КПК.", "Character Preference", GLOB.pda_reskins, pda_skin)
					if(pickedPDASkin)
						pda_skin = pickedPDASkin
				if("pda_ringtone")
					var/pickedPDARingtone = reject_bad_name(input(user, "Выбирайте рингтон своего КПК.", "Character Preference", pda_ringtone) as null|text, TRUE)
					if(pickedPDARingtone)
						pda_ringtone = pickedPDARingtone
				if("silicon_lawset")
					var/picked_lawset = tgui_input_list(user, "Выбирайте предпочитаемый список законов", "Silicon preference", list("None") + CONFIG_GET(keyed_list/choosable_laws), silicon_lawset)
					if(picked_lawset)
						if(picked_lawset == "None")
							picked_lawset = null
						silicon_lawset = picked_lawset
				if ("max_chat_length")
					var/desiredlength = input(user, "Choose the max character length of shown Runechat messages. Valid range is 1 to [CHAT_MESSAGE_MAX_LENGTH] (default: [initial(max_chat_length)]))", "Character Preference", max_chat_length)  as null|num
					if (!isnull(desiredlength))
						max_chat_length = clamp(desiredlength, 1, CHAT_MESSAGE_MAX_LENGTH)
				//Sandstorm changes begin
				if("personal_chat_color")
					var/new_chat_color = input(user, "Choose your character's runechat color:", "Character Preference",personal_chat_color) as color|null
					if(new_chat_color)
						if(color_hex2num(new_chat_color) > 200)
							personal_chat_color = sanitize_hexcolor(new_chat_color, 6, TRUE)
						else
							to_chat(user, "<span class='danger'>Invalid color. Your color is not bright enough.</span>")
				//End of sandstorm changes

				if("hud_toggle_color")
					var/new_toggle_color = input(user, "Choose your HUD toggle flash color:", "Game Preference",hud_toggle_color) as color|null
					if(new_toggle_color)
						hud_toggle_color = new_toggle_color

				if("gender")
					var/chosengender = tgui_input_list(user, "Select your character's gender.", "Gender Selection", list(MALE,FEMALE,"nonbinary","object"), gender)
					if(!chosengender)
						return
					switch(chosengender)
						if("nonbinary")
							chosengender = PLURAL
							features["body_model"] = pick(MALE, FEMALE)
						if("object")
							chosengender = NEUTER
							features["body_model"] = MALE
						else
							features["body_model"] = chosengender
					gender = chosengender

				if("body_size")
					var/new_body_size = input(user, "Choose your desired sprite size: ([CONFIG_GET(number/body_size_min)*100]-[CONFIG_GET(number/body_size_max)*100]%)\nWarning: This may make your character look distorted. Additionally, any size affects speed and max health", "Character Preference", features["body_size"]*100) as num|null
					if(new_body_size)
						features["body_size"] = clamp(new_body_size * 0.01, CONFIG_GET(number/body_size_min), CONFIG_GET(number/body_size_max))

				if("toggle_fuzzy")
					fuzzy = !fuzzy

				//BLUEMOON ADD выбор веса персонажа, замена квирков на вес
				if("body_weight")
					if(all_quirks.Find("Пожиратель"))
						tgui_alert(user, "Квирк Пожиратель несовместим с любым весом кроме стандартного", "Ugh, you cant", list("Ok", "Understood"))
					else
						var/new_body_weight = tgui_input_list(user, "Выберите вес персонажа!", "Character Preference", GLOB.mob_sizes)
						if(new_body_weight)
							if(tgui_alert(user, "[GLOB.mob_sizes[new_body_weight]]", "Confirm your choice", list("Good", "Nevermind")) == "Good")
								var/quirk_balance_check = GetQuirkBalance() - mob_size_name_to_quirk_cost(new_body_weight) + mob_size_name_to_quirk_cost(body_weight)
								if(quirk_balance_check >= 0)
									body_weight = new_body_weight
								else
									tgui_alert(user, "для взятия данного веса нужно ещё [abs(quirk_balance_check)] очков квирков", "Ugh, you cant", list("Ok", "Understood"))

				// Нормализируемый размер (размер при нормализации)
				if("normalized_size")
					var/max_size = 	min(CONFIG_GET(number/body_size_max), 1.2)	// Магическая цифра (предел MOB_SIZE_HUMAN по proc/adjust_mobsize)
					var/min_size =	max(CONFIG_GET(number/body_size_min), 0.81)	// Магическая цифра (предел MOB_SIZE_HUMAN по proc/adjust_mobsize)
					var/new_normialzed_size = input(user, "Choose your desired normalized size: ([min_size * 100]-[max_size * 100]%)\nUsed with normalizer stuff", "Character Preference", features["normalized_size"]*100) as num|null
					if(new_normialzed_size)
						features["normalized_size"] = clamp(new_normialzed_size * 0.01, min_size, max_size)

				// Выбор смеха
				if("laugh")
					var/select_laugh = tgui_input_list(user, "Choose your desired laugh", "Character Preference", GLOB.mob_laughs)
					if(select_laugh)
						custom_laugh = select_laugh

				if("laughpreview")
					if(SSticker.current_state == GAME_STATE_STARTUP) //Timers don't tick at all during game startup, so let's just give an error message
						to_chat(user, "<span class='warning'>Laugh sound previews can't play during initialization!</span>")
						return
					if(!COOLDOWN_FINISHED(src, laugh_preview))
						return
					if(!user || custom_laugh == "Default")
						return
					COOLDOWN_START(src, laugh_preview, (3 SECONDS))
					user.playsound_local(user, pick(get_laugh_sound(custom_laugh, FALSE)), 50)
				//BLUEMOON ADD END

				if("tongue")
					var/selected_custom_tongue = tgui_input_list(user, "Choose your desired tongue (none means your species tongue)", "Character Preference", GLOB.roundstart_tongues)
					if(selected_custom_tongue)
						custom_tongue = selected_custom_tongue
				if("speech_verb")
					var/selected_custom_speech_verb = tgui_input_list(user, "Choose your desired speech verb (none means your species speech verb)", "Character Preference", GLOB.speech_verbs)
					if(selected_custom_speech_verb)
						custom_speech_verb = selected_custom_speech_verb

				if("barksound")
					var/list/woof_woof = list()
					for(var/path in GLOB.bark_list)
						var/datum/bark/B = GLOB.bark_list[path]
						if(initial(B.ignore))
							continue
						if(initial(B.ckeys_allowed))
							var/list/allowed = initial(B.ckeys_allowed)
							if(!allowed.Find(user.client.ckey))
								continue
						woof_woof[initial(B.name)] = initial(B.id)
					var/new_bork = tgui_input_list(user, "Choose your desired vocal bark", "Character Preference", woof_woof)
					if(new_bork)
						bark_id = woof_woof[new_bork]
						var/datum/bark/B = GLOB.bark_list[bark_id] //Now we need sanitization to take into account bark-specific min/max values
						bark_speed = round(clamp(bark_speed, initial(B.minspeed), initial(B.maxspeed)), 1)
						bark_pitch = clamp(bark_pitch, initial(B.minpitch), initial(B.maxpitch))
						bark_variance = clamp(bark_variance, initial(B.minvariance), initial(B.maxvariance))

				if("barkspeed")
					var/datum/bark/B = GLOB.bark_list[bark_id]
					var/borkset = input(user, "Choose your desired bark speed (Higher is slower, lower is faster). Min: [initial(B.minspeed)]. Max: [initial(B.maxspeed)]", "Character Preference") as null|num
					if(!isnull(borkset))
						bark_speed = round(clamp(borkset, initial(B.minspeed), initial(B.maxspeed)), 1)

				if("barkpitch")
					var/datum/bark/B = GLOB.bark_list[bark_id]
					var/borkset = input(user, "Choose your desired baseline bark pitch. Min: [initial(B.minpitch)]. Max: [initial(B.maxpitch)]", "Character Preference") as null|num
					if(!isnull(borkset))
						bark_pitch = clamp(borkset, initial(B.minpitch), initial(B.maxpitch))

				if("barkvary")
					var/datum/bark/B = GLOB.bark_list[bark_id]
					var/borkset = input(user, "Choose your desired baseline bark pitch. Min: [initial(B.minvariance)]. Max: [initial(B.maxvariance)]", "Character Preference") as null|num
					if(!isnull(borkset))
						bark_variance = clamp(borkset, initial(B.minvariance), initial(B.maxvariance))

				if("bodysprite")
					var/selected_body_sprite = tgui_input_list(user, "Choose your desired body sprite", "Character Preference", pref_species.allowed_limb_ids)
					if(selected_body_sprite)
						chosen_limb_id = selected_body_sprite //this gets sanitized before loading

				if("marking_down")
					// move the specified marking down
					var/index = text2num(href_list["marking_index"])
					var/marking_type = href_list["marking_type"]
					if(index && marking_type && features[marking_type] && index != length(features[marking_type]))
						var/index_down = index + 1
						var/markings = features[marking_type]
						var/first_marking = markings[index]
						var/second_marking = markings[index_down]
						markings[index] = second_marking
						markings[index_down] = first_marking

				if("marking_up")
					// move the specified marking up
					var/index = text2num(href_list["marking_index"])
					var/marking_type = href_list["marking_type"]
					if(index && marking_type && features[marking_type] && index != 1)
						var/index_up = index - 1
						var/markings = features[marking_type]
						var/first_marking = markings[index]
						var/second_marking = markings[index_up]
						markings[index] = second_marking
						markings[index_up] = first_marking

				if("marking_top")
					// move the specified marking to the top
					var/index = text2num(href_list["marking_index"])
					var/marking_type = href_list["marking_type"]
					if(index && marking_type && features[marking_type] && index != 1)
						var/list/markings = features[marking_type]
						var/list/entry = markings[index]
						markings.Cut(index, index + 1)
						markings.Insert(1, entry)

				if("marking_bottom")
					// move the specified marking to the bottom
					var/index = text2num(href_list["marking_index"])
					var/marking_type = href_list["marking_type"]
					if(index && marking_type && features[marking_type] && index != length(features[marking_type]))
						var/list/markings = features[marking_type]
						var/list/entry = markings[index]
						markings.Cut(index, index + 1)
						markings += list(entry)

				if("marking_remove")
					// move the specified marking up
					var/index = text2num(href_list["marking_index"])
					var/marking_type = href_list["marking_type"]
					if(index && marking_type && features[marking_type])
						// because linters are just absolutely awful:
						var/list/L = features[marking_type]
						L.Cut(index, index + 1)

				if("marking_add")
					// add a marking
					var/marking_type = href_list["marking_type"]
					if(marking_type && features[marking_type])
						var/selected_limb = href_list["limb"]
						if(!selected_limb)
							selected_limb = tgui_input_list(user, "Choose the limb to apply to.", "Character Preference", list("Head", "Chest", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "All"))
						if(selected_limb)
							var/list/marking_list = GLOB.mam_body_markings_list
							var/list/snowflake_markings_list = list()
							for(var/path in marking_list)
								var/datum/sprite_accessory/S = marking_list[path]
								if(istype(S))
									if(istype(S, /datum/sprite_accessory/mam_body_markings))
										var/datum/sprite_accessory/mam_body_markings/marking = S
										if(!(selected_limb in marking.covered_limbs) && selected_limb != "All")
											continue

									if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
										snowflake_markings_list[S.name] = path
							var/selected_marking = tgui_input_list(user, "Select the marking to apply to the limb.", "Character Preference", snowflake_markings_list)
							if(selected_marking)
								if(selected_limb != "All")
									var/limb_value = text2num(GLOB.bodypart_values[selected_limb])
									features[marking_type] += list(list(limb_value, selected_marking))
								else
									var/datum/sprite_accessory/mam_body_markings/S = marking_list[selected_marking]
									for(var/limb in S.covered_limbs)
										var/limb_value = text2num(GLOB.bodypart_values[limb])
										features[marking_type] += list(list(limb_value, selected_marking))

				if("markings_clear_limb")
					var/marking_type = href_list["marking_type"]
					if(marking_type && features[marking_type])
						var/selected_limb = href_list["limb"]
						if(!selected_limb)
							selected_limb = tgui_input_list(user, "Choose the limb to clear.", "Character Preference", list("Head", "Chest", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "All"))
						if(selected_limb)
							if(selected_limb == "All")
								clearlist(features[marking_type])
							else
								var/limb_value = text2num(GLOB.bodypart_values[selected_limb])
								var/list/L = features[marking_type]
								for(var/i = length(L), i >= 1, i--)
									var/list/entry = L[i]
									if(entry[1] == limb_value)
										L.Cut(i, i + 1)

				// BLUEMOON ADD START - кнопка для удаления всех маркингов на персонаже
				if("markings_remove")
					var/are_you_sure_about_that = tgalert(parent.mob, "Это действие удалит все татуировки с персонажа. Вы уверены, что хотите сделать это?", "Удаление всех маркингов" ,"Да", "Нет")
					if(are_you_sure_about_that == "Да")
						clearlist(features["mam_body_markings"])
				// BLUEMOON ADD END
				if("marking_color_specific")
					var/index = text2num(href_list["marking_index"])
					var/marking_type = href_list["marking_type"]
					var/color_number = text2num(href_list["number_color"])
					if(index && marking_type && color_number && features[marking_type])
						// perform some magic on the color number
						var/list/marking_list = features[marking_type][index]
						var/datum/sprite_accessory/mam_body_markings/S = GLOB.mam_body_markings_list[marking_list[2]]
						var/matrixed_sections = S.covered_limbs[GLOB.bodypart_names[num2text(marking_list[1])]]
						if(color_number == 1)
							switch(matrixed_sections)
								if(MATRIX_GREEN)
									color_number = 2
								if(MATRIX_BLUE)
									color_number = 3
						else if(color_number == 2)
							switch(matrixed_sections)
								if(MATRIX_RED_BLUE)
									color_number = 3
								if(MATRIX_GREEN_BLUE)
									color_number = 3

						var/color_list = features[marking_type][index][3]
						var/new_marking_color = input(user, "Choose your character's marking color:", "Character Preference","#"+color_list[color_number]) as color|null
						if(new_marking_color)
							var/temp_hsv = RGBtoHSV(new_marking_color)
							if((MUTCOLORS_PARTSONLY in pref_species.species_traits) || ReadHSV(temp_hsv)[3] >= ReadHSV(MINIMUM_MUTANT_COLOR)[3] || !CONFIG_GET(flag/character_color_limits)) // mutantcolors must be bright, but only if they affect the skin //SPLURT EDIT
								color_list[color_number] = "#[sanitize_hexcolor(new_marking_color, 6)]"
							else
								to_chat(user, "<span class='danger'>Invalid color. Your color is not bright enough.</span>")
				//SPLURT Edit
				if("gfluid_black")
					var/list/datum/reagent/fluid_list = GLOB.genital_fluids_list.Copy()
					var/list/blacklisted = list()
					for(var/r in gfluid_blacklist)
						LAZYADD(blacklisted, find_reagent_object_from_type(r))
					LAZYREMOVE(fluid_list, GLOB.default_genital_fluids + blacklisted) //these are already blacklisted/are defaults
					var/datum/reagent/selected = tgui_input_list(user, "Blacklist a fluid:", "Genital Fluid Blacklist", fluid_list)
					if(selected)
						LAZYADD(gfluid_blacklist, selected.type)
				if("gfluid_unblack")
					var/list/datum/reagent/fluid_list
					for(var/r in gfluid_blacklist)
						LAZYADD(fluid_list, find_reagent_object_from_type(r))
					if(fluid_list)
						var/datum/reagent/selected = tgui_input_list(user, "Remove a fluid from your blacklist:", "Genital Fluid Blacklist", fluid_list)
						if(selected)
							LAZYREMOVE(gfluid_blacklist, selected.type)
					else
						to_chat(user, span_warning("You do not have blacklisted reagents!"))
				//SPLURT Edit end
		else
			switch(href_list["preference"])
				if("disable_combat_cursor")
					disable_combat_cursor = !disable_combat_cursor
				if("disable_combat_mouse_lock")
					disable_combat_mouse_lock = !disable_combat_mouse_lock
				if("tg_playerpanel")
					toggles ^= TG_PLAYER_PANEL
					to_chat(user, span_warning("Please relog in order to apply the changes"))
					save_preferences()
				//CITADEL PREFERENCES EDIT - I can't figure out how to modularize these, so they have to go here. :c -Pooj
				if("genital_colour")
					features["genitals_use_skintone"] = !features["genitals_use_skintone"]
				if("arousable")
					arousable = !arousable
				if("sexknotting")
					sexknotting = !sexknotting
				if("hardsuit_with_tail")
					features["hardsuit_with_tail"] = !features["hardsuit_with_tail"]
				if("has_cock")
					features["has_cock"] = !features["has_cock"]
					if(features["has_cock"] == FALSE)
						features["has_balls"] = FALSE
				if("cock_accessible")
					features["cock_accessible"] = !features["cock_accessible"]
				if("has_belly")
					features["has_belly"] = !features["has_belly"]
					if(features["has_belly"] == FALSE)
						features["belly_size"] = 1
				if("has_balls")
					features["has_balls"] = !features["has_balls"]
				if("balls_accessible")
					features["balls_accessible"] = !features["balls_accessible"]
				if("has_breasts")
					features["has_breasts"] = !features["has_breasts"]
					if(features["has_breasts"] == FALSE)
						features["breasts_producing"] = FALSE
				if("breasts_producing")
					features["breasts_producing"] = !features["breasts_producing"]
				if("breasts_accessible")
					features["breasts_accessible"] = !features["breasts_accessible"]
				if("has_vag")
					features["has_vag"] = !features["has_vag"]
					if(features["has_vag"] == FALSE)
						features["has_womb"] = FALSE
				if("vag_accessible")
					features["vag_accessible"] = !features["vag_accessible"]
				if("has_womb")
					features["has_womb"] = !features["has_womb"]
				if("has_butt")
					features["has_butt"] = !features["has_butt"]
					if(features["has_butt"] == FALSE)
						features["has_anus"] = FALSE
				if("butt_accessible")
					features["butt_accessible"] = !features["butt_accessible"]
				if("anus_accessible")
					features["anus_accessible"] = !features["anus_accessible"]
				if("has_anus")
					features["has_anus"] = !features["has_anus"]
				if("butt_accessible")
					features["butt_accessible"] = !features["butt_accessible"]
				if("anus_accessible")
					features["anus_accessible"] = !features["anus_accessible"]
				if("belly_accessible")
					features["belly_accessible"] = !features["belly_accessible"]
				if("widescreenpref")
					widescreenpref = !widescreenpref
					user.client.view_size.setDefault(getScreenSize(widescreenpref))
				if("fullscreen")
					fullscreen = !fullscreen
					parent.ToggleFullscreen()
				if("long_strip_menu")
					long_strip_menu = !long_strip_menu
				if("cock_stuffing")
					features["cock_stuffing"] = !features["cock_stuffing"]
				if("balls_stuffing")
					features["balls_stuffing"] = !features["balls_stuffing"]
				if("vag_stuffing")
					features["vag_stuffing"] = !features["vag_stuffing"]
				if("breasts_stuffing")
					features["breasts_stuffing"] = !features["breasts_stuffing"]
				if("butt_stuffing")
					features["butt_stuffing"] = !features["butt_stuffing"]
				if("anus_stuffing")
					features["anus_stuffing"] = !features["anus_stuffing"]
				if("belly_stuffing")
					features["belly_stuffing"] = !features["belly_stuffing"]
				if("inert_eggs")
					features["inert_eggs"] = !features["inert_eggs"]
				if("pixel_size")
					switch(pixel_size)
						if(PIXEL_SCALING_AUTO)
							pixel_size = PIXEL_SCALING_1X
						if(PIXEL_SCALING_1X)
							pixel_size = PIXEL_SCALING_1_2X
						if(PIXEL_SCALING_1_2X)
							pixel_size = PIXEL_SCALING_2X
						if(PIXEL_SCALING_2X)
							pixel_size = PIXEL_SCALING_3X
						if(PIXEL_SCALING_3X)
							pixel_size = PIXEL_SCALING_AUTO
					user.client.view_size.apply() //Let's winset() it so it actually works

				if("scaling_method")
					switch(scaling_method)
						if(SCALING_METHOD_NORMAL)
							scaling_method = SCALING_METHOD_DISTORT
						if(SCALING_METHOD_DISTORT)
							scaling_method = SCALING_METHOD_BLUR
						if(SCALING_METHOD_BLUR)
							scaling_method = SCALING_METHOD_NORMAL
					user.client.view_size.setZoomMode()

				if("autostand")
					autostand = !autostand
				if("auto_ooc")
					auto_ooc = !auto_ooc
				if("no_tetris_storage")
					no_tetris_storage = !no_tetris_storage
				if ("screenshake")
					var/desiredshake = input(user, "Set the amount of screenshake you want. \n(0 = disabled, 100 = full, no maximum (at your own risk).)", "Character Preference", screenshake)  as null|num
					if (!isnull(desiredshake))
						screenshake = desiredshake
				if("damagescreenshake")
					switch(damagescreenshake)
						if(0)
							damagescreenshake = 1
						if(1)
							damagescreenshake = 2
						if(2)
							damagescreenshake = 0
						else
							damagescreenshake = 1
				if ("recoil_screenshake")
					var/desiredshake = input(user, "Set the amount of recoil screenshake/push you want. \n(0 = disabled, 100 = full, no maximum (at your own risk).)", "Character Preference", screenshake)  as null|num
					if (!isnull(desiredshake))
						recoil_screenshake = desiredshake
				if("nameless")
					nameless = !nameless

				//Skyrat begin
				if("erp_pref")
					switch(erppref)
						if("Yes")
							erppref = "Ask"
						if("Ask")
							erppref = "No"
						if("No")
							erppref = "Yes"
				// BLUEMOON EDIT - tattoo consent
				if("tattoo_pref")
					switch(tattoopref)
						if("Yes")
							tattoopref = "Ask"
						if("Ask")
							tattoopref = "No"
						if("No")
							tattoopref = "Yes"
				// BLUEMOON EDIT END
				if("noncon_pref")
					var/nonconpref_old = nonconpref
					switch(nonconpref)
						if("Yes")
							nonconpref = "Ask"
						if("Ask")
							nonconpref = "No"
						if("No")
							nonconpref = "Yes"
					if(isliving(user?.mind?.current))
						var/mob/living/C = user.mind.current
						message_admins("[user.ckey]/[C.real_name] [ADMIN_FLW(C)][C.stat == DEAD ? " (DEAD)" : ""] меняет Non-Con c [nonconpref_old] на [nonconpref].")
						log_admin("[user.ckey]/[C.real_name][C.stat == DEAD ? " (DEAD)" : ""] меняет Non-Con c [nonconpref_old] на [nonconpref].")
						C.balloon_alert_to_viewers("Меняет Non-Con c [nonconpref_old] на [nonconpref].")
				if("vore_pref")
					switch(vorepref)
						if("Yes")
							vorepref = "Ask"
						if("Ask")
							vorepref = "No"
						if("No")
							vorepref = "Yes"
				if("unholypref") //...
					switch(unholypref)
						if("Yes")
							unholypref = "Ask"
						if("Ask")
							unholypref = "No"
						if("No")
							unholypref = "Yes"
				//Gardelin0 Addoon
				if("mobsex_pref") //...
					switch(mobsexpref)
						if("Yes")
							mobsexpref = "No"
						if("No")
							mobsexpref = "Yes"
				if("hornyantags_pref") //...
					switch(hornyantagspref)
						if("Yes")
							hornyantagspref = "No"
						if("No")
							hornyantagspref = "Yes"
//				if("stomppref") // What the fuck is this?
//					stomppref = !stomppref
				//Skyrat edit - *someone* offered me actual money for this shit
				if("extremepref") //i hate myself for doing this
					switch(extremepref) //why the fuck did this need to use cycling instead of input from a list
						if("Yes")		//seriously this confused me so fucking much
							extremepref = "Ask"
						if("Ask")
							extremepref = "No"
							extremeharm = "No"
						if("No")
							extremepref = "Yes"
				if("extremeharm")
					switch(extremeharm)
						if("Yes")	//this is cursed code
							extremeharm = "No"
						if("No")
							extremeharm = "Yes"
					if(extremepref == "No")
						extremeharm = "No"
				//END CITADEL EDIT
				if("publicity")
					if(unlock_content)
						toggles ^= MEMBER_PUBLIC

				if("body_model")
					features["body_model"] = features["body_model"] == MALE ? FEMALE : MALE

				if("hotkeys")
					hotkeys = !hotkeys
					user.client.ensure_keys_set(src)

				if("keybindings_capture")
					var/datum/keybinding/kb = GLOB.keybindings_by_name[href_list["keybinding"]]
					CaptureKeybinding(user, kb, href_list["old_key"], text2num(href_list["independent"]), kb.special || kb.clientside)
					return

				if("keybindings_set")
					var/kb_name = href_list["keybinding"]
					if(!kb_name)
						user << browse(null, "window=capturekeypress")
						ShowChoices(user)
						return

					var/independent = href_list["independent"]

					var/clear_key = text2num(href_list["clear_key"])
					var/old_key = href_list["old_key"]
					if(clear_key)
						if(independent)
							modless_key_bindings -= old_key
						else
							if(key_bindings[old_key])
								key_bindings[old_key] -= kb_name
								LAZYADD(key_bindings["Unbound"], kb_name)
								if(!length(key_bindings[old_key]))
									key_bindings -= old_key
						user << browse(null, "window=capturekeypress")
						if(href_list["special"])		// special keys need a full reset
							user.client.ensure_keys_set(src)
						save_preferences()
						ShowChoices(user)
						return

					var/new_key = uppertext(href_list["key"])
					var/AltMod = text2num(href_list["alt"]) ? "Alt" : ""
					var/CtrlMod = text2num(href_list["ctrl"]) ? "Ctrl" : ""
					var/ShiftMod = text2num(href_list["shift"]) ? "Shift" : ""
					var/numpad = text2num(href_list["numpad"]) ? "Numpad" : ""
					// var/key_code = text2num(href_list["key_code"])

					if(GLOB._kbMap[new_key])
						new_key = GLOB._kbMap[new_key]

					var/full_key
					switch(new_key)
						if("Alt")
							full_key = "[new_key][CtrlMod][ShiftMod]"
						if("Ctrl")
							full_key = "[AltMod][new_key][ShiftMod]"
						if("Shift")
							full_key = "[AltMod][CtrlMod][new_key]"
						else
							full_key = "[AltMod][CtrlMod][ShiftMod][numpad][new_key]"
					if(independent)
						modless_key_bindings -= old_key
						modless_key_bindings[full_key] = kb_name
					else
						if(key_bindings[old_key])
							key_bindings[old_key] -= kb_name
							if(!length(key_bindings[old_key]))
								key_bindings -= old_key
						key_bindings[full_key] += list(kb_name)
						key_bindings[full_key] = sort_list(key_bindings[full_key])
					if(href_list["special"])		// special keys need a full reset
						user.client.ensure_keys_set(src)
					user << browse(null, "window=capturekeypress")
					save_preferences()

				if("keybindings_reset")
					var/choice = tgalert(user, "Would you prefer 'hotkey' or 'classic' defaults?", "Setup keybindings", "Hotkey", "Classic", "Cancel")
					if(choice == "Cancel")
						ShowChoices(user)
						return
					hotkeys = (choice == "Hotkey")
					key_bindings = (hotkeys) ? deepCopyList(GLOB.hotkey_keybinding_list_by_key) : deepCopyList(GLOB.classic_keybinding_list_by_key)
					modless_key_bindings = list()
					user.client.ensure_keys_set(src)

				if("chat_on_map")
					chat_on_map = !chat_on_map
				if("see_chat_non_mob")
					see_chat_non_mob = !see_chat_non_mob
				//Sandstorm changes begin
				if("see_chat_emotes")
					see_chat_emotes = !see_chat_emotes
				if("enable_personal_chat_color")
					enable_personal_chat_color = !enable_personal_chat_color
				//End of sandstorm changes
				if("view_pixelshift") //SPLURT Edit
					view_pixelshift = !view_pixelshift
				if("tgui_fancy")
					tgui_fancy = !tgui_fancy
				if("tgui_input_mode")
					tgui_input_mode = !tgui_input_mode
				if("tgui_large_buttons")
					tgui_large_buttons = !tgui_large_buttons
				if("tgui_swapped_buttons")
					tgui_swapped_buttons = !tgui_swapped_buttons
				if("outline_enabled")
					outline_enabled = !outline_enabled
				if("outline_color")
					var/pickedOutlineColor = input(user, "Choose your outline color.", "General Preference", outline_color) as color|null
					if(pickedOutlineColor != outline_color)
						outline_color = pickedOutlineColor // nullable
				if("screentip_pref")
					var/choice = tgui_input_list(user, "Choose your screentip preference", "Screentipping?", GLOB.screentip_pref_options, screentip_pref)
					if(choice)
						screentip_pref = choice
				if("screentip_color")
					var/pickedScreentipColor = input(user, "Choose your screentip color.", "General Preference", screentip_color) as color|null
					if(pickedScreentipColor)
						screentip_color = pickedScreentipColor
				if("screentip_images")
					screentip_images = !screentip_images
				if("tgui_lock")
					tgui_lock = !tgui_lock
				if("winflash")
					windowflashing = !windowflashing
				if("winnoise")
					windownoise = !windownoise
				if("hear_adminhelps")
					toggles ^= SOUND_ADMINHELP
				if("announce_login")
					toggles ^= ANNOUNCE_LOGIN
				if("combohud_lighting")
					toggles ^= COMBOHUD_LIGHTING

				// Colors pref
				if("custom_color_ooc")
					custom_colors ^= CUSTOM_OOC
				if("custom_color_aooc")
					custom_colors ^= CUSTOM_AOOC

				// Deadmin preferences
				if("toggle_deadmin_onlogin")
					deadmin ^= DEADMIN_ONLOGIN
				if("toggle_deadmin_onspawn")
					deadmin ^= DEADMIN_ONSPAWN
				if("toggle_deadmin_antag")
					deadmin ^= DEADMIN_ANTAGONIST
				if("toggle_deadmin_head")
					deadmin ^= DEADMIN_POSITION_HEAD
				if("toggle_deadmin_security")
					deadmin ^= DEADMIN_POSITION_SECURITY
				if("toggle_deadmin_silicon")
					deadmin ^= DEADMIN_POSITION_SILICON
				//

				if("disable_antag")
					toggles ^= NO_ANTAG

				if("be_special")
					var/be_special_type = href_list["be_special_type"]
					if(be_special_type in be_special)
						if(be_special[be_special_type] >= 1)
							be_special -= be_special_type
						else
							be_special[be_special_type] = 1
					else
						be_special += be_special_type
						be_special[be_special_type] = 0

				if("name")
					be_random_name = !be_random_name

				if("all")
					be_random_body = !be_random_body

				if("hear_midis")
					toggles ^= SOUND_MIDI

				if("verb_consent") // Skyrat - ERP Mechanic Addition
					toggles ^= VERB_CONSENT // Skyrat - ERP Mechanic Addition

				if("ranged_verb_consent") // BLUEMOON ADD интеракты с расстояния
					toggles ^= RANGED_VERBS_CONSENT // BLUEMOON ADD END

				if("lewd_verb_sounds") // Skyrat - ERP Mechanic Addition
					toggles ^= LEWD_VERB_SOUNDS // Skyrat - ERP Mechanic Addition

				if("persistent_scars")
					persistent_scars = !persistent_scars

				if("clear_scars")
					to_chat(user, "<span class='notice'>All scar slots cleared. Please save character to confirm.</span>")
					scars_list["1"] = ""
					scars_list["2"] = ""
					scars_list["3"] = ""
					scars_list["4"] = ""
					scars_list["5"] = ""

				if("lobby_music")
					toggles ^= SOUND_LOBBY
					if((toggles & SOUND_LOBBY) && user.client && isnewplayer(user))
						user.client.playtitlemusic()
					else
						user.stop_sound_channel(CHANNEL_LOBBYMUSIC)

				if("ghost_ears")
					chat_toggles ^= CHAT_GHOSTEARS

				if("ghost_sight")
					chat_toggles ^= CHAT_GHOSTSIGHT

				if("ghost_whispers")
					chat_toggles ^= CHAT_GHOSTWHISPER

				if("ghost_radio")
					chat_toggles ^= CHAT_GHOSTRADIO

				if("ghost_pda")
					chat_toggles ^= CHAT_GHOSTPDA

				if("income_pings")
					chat_toggles ^= CHAT_BANKCARD

				if("pull_requests")
					chat_toggles ^= CHAT_PULLR

				if("allow_midround_antag")
					toggles ^= MIDROUND_ANTAG

				if("parallaxup")
					parallax = WRAP(parallax + 1, PARALLAX_DISABLE, PARALLAX_INSANE + 1)
					parent?.parallax_holder?.Reset()

				if("parallaxdown")
					parallax = WRAP(parallax - 1, PARALLAX_DISABLE, PARALLAX_INSANE + 1)
					parent?.parallax_holder?.Reset()

				// Citadel edit - Prefs don't work outside of this. :c

				if("genital_examine")
					cit_toggles ^= GENITAL_EXAMINE

				if("vore_examine")
					cit_toggles ^= VORE_EXAMINE

				if("hound_sleeper")
					cit_toggles ^= MEDIHOUND_SLEEPER

				if("toggleeatingnoise")
					cit_toggles ^= EATING_NOISES

				if("toggledigestionnoise")
					cit_toggles ^= DIGESTION_NOISES

				if("toggleforcefeedtrash")
					cit_toggles ^= TRASH_FORCEFEED

				if("breast_enlargement")
					cit_toggles ^= BREAST_ENLARGEMENT

				if("penis_enlargement")
					cit_toggles ^= PENIS_ENLARGEMENT

				if("butt_enlargement")
					cit_toggles ^= BUTT_ENLARGEMENT

				if("belly_inflation")
					cit_toggles ^= BELLY_INFLATION

				if("feminization")
					cit_toggles ^= FORCED_FEM

				if("masculinization")
					cit_toggles ^= FORCED_MASC

				if("hypno")
					cit_toggles ^= HYPNO

				if("never_hypno")
					cit_toggles ^= NEVER_HYPNO

				if("aphro")
					cit_toggles ^= NO_APHRO

				if("ass_slap")
					cit_toggles ^= NO_ASS_SLAP

				if("bimbo")
					cit_toggles ^= BIMBOFICATION

				if("auto_wag")
					cit_toggles ^= NO_AUTO_WAG

				if("disco_dance")
					cit_toggles ^= NO_DISCO_DANCE

				//END CITADEL EDIT

				if("sex_jitter") //By Gardelin0
					cit_toggles ^= SEX_JITTER

				if("ambientocclusion")
					ambientocclusion = !ambientocclusion
					if(parent && parent.screen && parent.screen.len)
						var/atom/movable/screen/plane_master/game_world/G = parent.mob.hud_used.plane_masters["[GAME_PLANE]"]
						var/atom/movable/screen/plane_master/above_wall/A = parent.mob.hud_used.plane_masters["[ABOVE_WALL_PLANE]"]
						var/atom/movable/screen/plane_master/wall/W = parent.mob.hud_used.plane_masters["[WALL_PLANE]"]
						G.backdrop(parent.mob)
						A.backdrop(parent.mob)
						W.backdrop(parent.mob)

				if("auto_fit_viewport")
					auto_fit_viewport = !auto_fit_viewport
					if(auto_fit_viewport && parent)
						parent.fit_viewport()

				if("hud_toggle_flash")
					hud_toggle_flash = !hud_toggle_flash

				if ("preferred_chaos_level")
					var/chaos_level = tgui_input_number(user, \
										"Выбирайте число в зависимости от своих предпочтений \
										к стилю игры.\n От предпочтений к Хаосу зависит режим Динамика, \
										который будет выбран. \n\
										0. - ничего не ожидайте от меня. Я убегу при первой же возможности. \n\
										1. - предпочитаю спокойную игру, но могу ввязаться в неприятности, если потребуется. \n\
										2. - не против Хаоса и неожиданных ситуаций, готов рисковать ради интереса. \n\
										3. - СЛАВА ХАОСУ НЕДЕЛИМОМУ. Готов к любым безумствам и опасностям.",\
										"Предпочитаемый Уровень Хаоса", 2, 3, 0, round_value = TRUE)

					if(isnum(chaos_level))
						preferred_chaos_level = chaos_level

				if("auto_capitalize_enabled")
					auto_capitalize_enabled = !auto_capitalize_enabled

				if("barkpreview")
					if(SSticker.current_state == GAME_STATE_STARTUP) //Timers don't tick at all during game startup, so let's just give an error message
						to_chat(user, "<span class='warning'>Bark previews can't play during initialization!</span>")
						return
					if(!COOLDOWN_FINISHED(src, bark_previewing))
						return
					if(!parent || !parent.mob)
						return
					COOLDOWN_START(src, bark_previewing, (5 SECONDS))
					var/atom/movable/barkbox = new(get_turf(parent.mob))
					barkbox.set_bark(bark_id)
					var/total_delay
					for(var/i in 1 to (round((32 / bark_speed)) + 1))
						addtimer(CALLBACK(barkbox, TYPE_PROC_REF(/atom/movable, bark), list(parent.mob), 7, 70, BARK_DO_VARY(bark_pitch, bark_variance)), total_delay)
						total_delay += rand(DS2TICKS(bark_speed/4), DS2TICKS(bark_speed/4) + DS2TICKS(bark_speed/4)) TICKS
					QDEL_IN(barkbox, total_delay)

				if("save")
					save_preferences()
					save_character()

				if("load")
					load_preferences()
					load_character()

				if("changeslot")
					if(char_queue)
						deltimer(char_queue) // Do not dare.
					if(!load_character(text2num(href_list["num"])))
						random_character()
						real_name = random_unique_name(gender)
						save_character()
					if(user.client?.prefs) //custom emote panel is attached to the character
						var/list/payload = user.client.prefs.custom_emote_panel
						user.client.tgui_panel?.window.send_message("emotes/setList", payload)

				if("tab")
					if(href_list["tab"])
						current_tab = text2num(href_list["tab"])
				//SPLURT edit
				// BLUEMOON REMOVE - Ищи в `modular_bluemoon/code/modules/client/preferences.dm`
				/*
				if("headshot")
					var/usr_input = input(user, "Input the image link: (For Discord links, try putting the file's type at the end of the link, after the '&'. for example '&.jpg/.png/.jpeg')", "Headshot Image", features["headshot_link"]) as text|null
					if(isnull(usr_input))
						return
					if(!usr_input)
						features["headshot_link"] = null
						return

					var/static/link_regex = regex("https://i.gyazo.com|https://static1.e621.net") //Do not touch the damn duplicates.
					var/static/end_regex = regex(".jpg|.jpg|.png|.jpeg|.jpeg") //Regex is terrible, don't touch the duplicate extensions

					if(!findtext(usr_input, link_regex))
						to_chat(usr, span_warning("You need a valid link!"))
						return
					if(!findtext(usr_input, end_regex))
						to_chat(usr, span_warning("You need either \".png\", \".jpg\", or \".jpeg\" in the link!"))
						return

					if(features["headshot_link"] != usr_input)
						to_chat(usr, span_notice("If the photo doesn't show up properly in-game, ensure that it's a direct image link that opens properly in a browser."))
						to_chat(usr, span_notice("Keep in mind that the photo will be downsized to 250x250 pixels, so the more square the photo, the better it will look."))
					features["headshot_link"] = usr_input
				*/
				// BLUEMOON REMOVE END

				if("character_preview")
					preview_pref = href_list["tab"]

				if("character_tab")
					if(href_list["tab"])
						var/new_tab = text2num(href_list["tab"])
						if(new_tab == QUIRKS_CHAR_TAB && !(findtext(charcreation_theme, "modern") && CONFIG_GET(flag/roundstart_traits)))
							new_tab = GENERAL_CHAR_TAB
						character_settings_tab = new_tab

				if("appearance_subtab")
					if(href_list["tab"])
						appearance_subtab = text2num(href_list["tab"])

				if("preferences_tab")
					if(href_list["tab"])
						preferences_tab = text2num(href_list["tab"])

				if("chastitypref")
					cit_toggles ^= CHASTITY
				if("stimulationpref")
					cit_toggles ^= STIMULATION
				if("edgingpref")
					cit_toggles ^= EDGING
				if("cumontopref")
					cit_toggles ^= CUM_ONTO
				//
				if("export_slot")
					var/savefile/S = save_character(export = TRUE)
					if(istype(S, /savefile))
						user.client.Export(S)
						tgui_alert_async(user, "Successfully saved character slot")
					else
						tgui_alert_async(user, "Failed saving character slot")
						return

				if("import_slot")
					var/savefile/S = new(user.client.Import())
					if(istype(S, /savefile))
						if(load_character(provided = S))
							tgui_alert_async(user, "Successfully loaded character slot.")
							save_character(TRUE)
						else
							tgui_alert_async(user, "Failed loading character slot")
							return
					else
						tgui_alert_async(user, "Failed loading character slot")
						return

				if("delete_local_copy")
					user.client.clear_export()
					tgui_alert_async(user, "Local save data erased.")

				if("give_slot")
					if(!QDELETED(offer))
						var/datum/character_offer_instance/offer_datum = LAZYACCESS(GLOB.character_offers, offer.redemption_code)
						if(!offer_datum)
							return
						qdel(offer_datum)
					else
						var/savefile/S = save_character(export = TRUE)
						if(istype(S, /savefile))
							var/datum/character_offer_instance/offer_datum = new(usr.ckey, S)
							if(QDELETED(offer_datum))
								tgui_alert_async(usr, "Could not set up offer, try again later")
								return
							offer_datum.RegisterSignal(usr, COMSIG_MOB_CLIENT_LOGOUT, TYPE_PROC_REF(/datum/character_offer_instance, on_quit))
							offer = offer_datum
							tgui_alert_async(usr, "The redemption code is [offer_datum.redemption_code], give it to the receiver")

				if("retrieve_slot")
					if(!LAZYLEN(GLOB.character_offers))
						tgui_alert_async(usr, "There are no active offers")
						return
					var/retrieve_code = input(usr, "Input the 5 digit redemption code") as text|null
					if(!retrieve_code)
						return
					if(!text2num(retrieve_code))
						tgui_alert_async(usr, "Only numbers allowed")
						return
					if(length(retrieve_code) != 5)
						tgui_alert_async(usr, "Exactly 5 digits, no less, no more, try again")
						return
					var/datum/character_offer_instance/offer_datum = LAZYACCESS(GLOB.character_offers, retrieve_code)
					if(!offer_datum)
						tgui_alert_async(usr, "This is an invalid code!")
						return
					if(offer == offer_datum)
						tgui_alert_async(usr, "You cannot accept your own offer")
						return
					var/savefile/savefile = offer_datum.character_savefile
					var/mob/living/the_owner = get_mob_by_ckey(offer_datum.owner_ckey)
					if(savefile_needs_update(savefile) == -2)
						tgui_alert_async(usr, "Something's wrong, this savefile is corrupted.")
						to_chat(the_owner, span_boldwarning("Something went wrong with the trade, it's been canceled."))
						qdel(offer_datum)
						return
					var/character_name = savefile["real_name"]
					if(alert(usr, "You are overwriting the currently selected slot with the character [character_name]", "Are you sure?", "Yes, load this character deleting the currently selected slot", "No") == "No")
						return
					if(QDELETED(offer_datum))
						tgui_alert_async(usr, "This character is no longer available, such a shame!")
						return
					to_chat(the_owner, span_boldwarning("[usr.key] has retrieved your character, [character_name]!"))
					if(!load_character(provided = savefile))
						tgui_alert_async(usr, "Something went wrong loading the savefile, even though it has already been checked, please report this issue!")
						to_chat(the_owner, span_boldwarning("Something went wrong at the final step of the trade, report this."))
						qdel(offer_datum)
						return
					tgui_alert_async(usr, "Successfully received [character_name]!")
					save_character(TRUE)
					qdel(offer_datum)

	if(href_list["preference"] == "gear")
		if(href_list["select_slot"])
			var/chosen = text2num(href_list["select_slot"])
			if(!chosen)
				return
			chosen = floor(chosen)
			if(chosen > MAXIMUM_LOADOUT_SAVES || chosen < 1)
				return
			loadout_slot = chosen
		if(href_list["clear_loadout"])
			loadout_data["SAVE_[loadout_slot]"] = list()
			save_preferences()
		// BLUEMOON ADD - переключатель лодаута
		if(href_list["toggle_loadout_enabled"])
			loadout_enabled = !loadout_enabled
			save_preferences()
		// BLUEMOON ADD END
		if(href_list["select_category"])
			gear_category = url_decode(href_list["select_category"])
			// BLUEMOON FIX - Add null check to prevent runtime when category doesn't exist
			var/list/subcategories = GLOB.loadout_categories[gear_category]
			if(length(subcategories))
				gear_subcategory = subcategories[1]
			else
				stack_trace("Loadout topic: Invalid category '[gear_category]' selected (user: [user?.ckey])")
				gear_subcategory = LOADOUT_SUBCATEGORY_NONE
		if(href_list["select_subcategory"])
			gear_subcategory = url_decode(href_list["select_subcategory"])
		if(href_list["toggle_gear_path"])
			var/name = url_decode(href_list["toggle_gear_path"])
			// BLUEMOON FIX - Add null check to prevent runtime when category/subcategory doesn't exist
			if(!GLOB.loadout_items[gear_category] || !GLOB.loadout_items[gear_category][gear_subcategory])
				stack_trace("Loadout toggle: Missing category '[gear_category]'/subcategory '[gear_subcategory]' for item '[name]' (user: [user?.ckey])")
				return
			var/datum/gear/G = GLOB.loadout_items[gear_category][gear_subcategory][name]
			if(!G)
				return
			var/toggle = text2num(href_list["toggle_gear"])
			if(!toggle && has_loadout_gear(loadout_slot, "[G.type]"))//toggling off and the item effectively is in chosen gear)
				var/gear = has_loadout_gear(loadout_slot, "[G.type]")
				// BLUEMOON EDIT START - выбор вещей из лодаута как family heirloom
				if (gear[LOADOUT_IS_HEIRLOOM])
					gear[LOADOUT_IS_HEIRLOOM] = FALSE
				// BLUEMOON EDIT END - выбор вещей из лодаута как family heirloom
				remove_gear_from_loadout(loadout_slot, "[G.type]")
			else if(toggle && !(has_loadout_gear(loadout_slot, "[G.type]")))
				if(!is_loadout_slot_available(G.category))
					to_chat(user, "<span class='danger'>You cannot take this loadout, as you've already chosen too many of the same category!</span>")
					return
				if(G.donoritem && !G.donator_ckey_check(user.ckey))
					to_chat(user, "<span class='danger'>This is an item intended for donator use only. You are not authorized to use this item.</span>")
					return
				if(istype(G, /datum/gear/unlockable) && !can_use_unlockable(G))
					to_chat(user, "<span class='danger'>To use this item, you need to meet the defined requirements!</span>")
					return
				if(gear_points >= initial(G.cost))
					var/list/new_loadout_data = list(LOADOUT_ITEM = "[G.type]")
					if(length(G.loadout_initial_colors))
						new_loadout_data[LOADOUT_COLOR] = G.loadout_initial_colors
					else
						new_loadout_data[LOADOUT_COLOR] = list("#FFFFFF")
					if(loadout_data["SAVE_[loadout_slot]"])
						loadout_data["SAVE_[loadout_slot]"] += list(new_loadout_data) //double packed because it does the union of the CONTENTS of the lists
					else
						loadout_data["SAVE_[loadout_slot]"] = list(new_loadout_data) //double packed because you somehow had no save slot in your loadout?
		if(href_list["clear_invalid_gear"])
			var/thing_to_remove = url_decode(href_list["clear_invalid_gear"])
			if(!thing_to_remove)
				return
			var/list/sanitize_current_slot = loadout_data["SAVE_[loadout_slot]"]
			for(var/list/entry in sanitize_current_slot)
				if(entry["loadout_item"] == thing_to_remove)
					sanitize_current_slot.Remove(list(entry))
					break

		if(href_list["loadout_color"] || href_list["loadout_color_polychromic"] || href_list["loadout_color_HSV"] || href_list["loadout_rename"] || href_list["loadout_redescribe"] || href_list["loadout_addheirloom"] || href_list["loadout_removeheirloom"] || href_list["loadout_tagname"] || href_list["loadout_examtooltip"])

			//if the gear doesn't exist, or they don't have it, ignore the request
			var/name = url_decode(href_list["loadout_gear_name"])
			// BLUEMOON FIX - Add null check to prevent runtime when category/subcategory doesn't exist
			if(!GLOB.loadout_items[gear_category] || !GLOB.loadout_items[gear_category][gear_subcategory])
				stack_trace("Loadout customize: Missing category '[gear_category]'/subcategory '[gear_subcategory]' for item '[name]' (user: [user?.ckey])")
				return
			var/datum/gear/G = GLOB.loadout_items[gear_category][gear_subcategory][name]
			if(!G)
				return
			var/user_gear = has_loadout_gear(loadout_slot, "[G.type]")
			if(!user_gear)
				return

			//possible requests: recolor, recolor (polychromic), rename, redescribe
			//always make sure the gear allows said request before proceeding

			//non-poly coloring can only be done by non-poly items
			if(href_list["loadout_color"] && !(G.loadout_flags & LOADOUT_CAN_COLOR_POLYCHROMIC))
				if(!length(user_gear[LOADOUT_COLOR]))
					user_gear[LOADOUT_COLOR] = list("#FFFFFF")
				var/current_color = user_gear[LOADOUT_COLOR][1]
				if(!istext(current_color))
					current_color = "#FFFFFF"
				var/new_color = input(user, "Polychromic options", "Choose Color", current_color) as color|null
				user_gear[LOADOUT_COLOR][1] = sanitize_hexcolor(new_color, 6, TRUE, current_color)

			// HSV Coloring (SPLURT EDIT)
			if(href_list["loadout_color_HSV"] && !(G.loadout_flags & LOADOUT_CAN_COLOR_POLYCHROMIC))
				var/hue = input(user, "Enter Hue (0-360)", "HSV options") as num|null
				var/saturation = input(user, "Enter Saturation (-10 to 10)", "HSV options") as num|null
				var/value = input(user, "Enter Value (-10 to 10)", "HSV options") as num|null
				if(hue && saturation && value)
					saturation = clamp(saturation, -10, 10)
					value = clamp(value, -10, 10)
					var/color_to_use = color_matrix_hsv(hue, saturation, value)
					user_gear[LOADOUT_COLOR][1] = color_to_use

			//poly coloring can only be done by poly items
			if(href_list["loadout_color_polychromic"] && (G.loadout_flags & LOADOUT_CAN_COLOR_POLYCHROMIC))
				var/list/color_options = list()
				for(var/i=1, i<=length(G.loadout_initial_colors), i++)
					color_options += "Color [i]"
				var/color_to_change = tgui_input_list(user, "Polychromic options", "Recolor [name]", color_options)
				if(color_to_change)
					var/color_index = text2num(copytext(color_to_change, 7))
					var/current_color = user_gear[LOADOUT_COLOR][color_index]
					if(!istext(current_color))
						current_color = "#FFFFFF"
					var/new_color = input(user, "Polychromic options", "Choose [color_to_change] Color", current_color) as color|null
					if(new_color)
						user_gear[LOADOUT_COLOR][color_index] = sanitize_hexcolor(new_color, 6, TRUE, current_color)

			//both renaming and redescribing strip the input to stop html injection

			//renaming is only allowed if it has the flag for it
			if(href_list["loadout_rename"] && (G.loadout_flags & LOADOUT_CAN_NAME))
				var/new_name = stripped_input(user, "Enter new name for item. Maximum [MAX_NAME_LEN] characters.", "Loadout Item Naming", null,  MAX_NAME_LEN)
				if(new_name)
					user_gear[LOADOUT_CUSTOM_NAME] = new_name

			//redescribing is only allowed if it has the flag for it
			if(href_list["loadout_redescribe"] && (G.loadout_flags & LOADOUT_CAN_DESCRIPTION)) //redescribe isnt a real word but i can't think of the right term to use
				var/new_description = stripped_input(user, "Enter new description for item. Maximum 500 characters.", "Loadout Item Redescribing", null, 500)
				if(new_description)
					user_gear[LOADOUT_CUSTOM_DESCRIPTION] = new_description
			// BLUEMOON ADD START - выбор вещей из лодаута как family heirloom
			if(href_list["loadout_addheirloom"])
				// Выбран ли предмет среди категории неприемлемых для реликвии?
				var/typepath = user_gear[LOADOUT_ITEM]
				// FIX: Проверяем существование типа перед созданием
				var/resolved_path = text2path(typepath)
				if(!ispath(resolved_path, /datum/gear))
					to_chat(user, "<font color='red'>Предмет лоадаута <b>[typepath]</b> повреждён. Удалите его из лоадаута через вкладку Errors.</font>")
					ShowChoices(user)
					return TRUE
				var/forbidden = FALSE
				var/datum/gear/temp_gear = new resolved_path()
				if (ispath_in_list(temp_gear.path, LOADOUT_IS_DISALLOWED_HEIRLOOM))
					forbidden = TRUE
				qdel(temp_gear) // На всякий случай, чтобы не засирало память лишними датумами
				// Выбран ли какой-либо другой предмет как семейная реликвия, и если да, то какой?
				var/existing = find_gear_with_property(loadout_slot, LOADOUT_IS_HEIRLOOM, TRUE)
				if(!existing && !forbidden)
					user_gear[LOADOUT_IS_HEIRLOOM] = TRUE
				else if(existing)
					to_chat(user, "<font color='red'>У вас уже выбрана ваша семейная реликвия!</font>")
				else if(forbidden)
					to_chat(user, "<font color ='red'>Это не подойдёт в качестве семейной реликвии!</font>")
			if(href_list["loadout_removeheirloom"])
				user_gear[LOADOUT_IS_HEIRLOOM] = FALSE
			// BLUEMOON ADD END

			//for collars with tagnames
			if(href_list["loadout_tagname"])
				var/new_tagname = stripped_input(user, "Would you like to change the name on the tag?", "Name your new pet", null, MAX_NAME_LEN)
				if(new_tagname)
					user_gear["loadout_custom_tagname"] = new_tagname
			if(href_list["loadout_examtooltip"])
				var/defaultinput = (islist(user_gear["loadout_examtooltip"])) ? user_gear["loadout_examtooltip"][1] : null
				var/examtooltip_usrinput = stripped_input(user, "Это описание предмета будет видно при осмотре персонажа, носящего предмет. Cancel - очистить.", "Дополнительное описание", defaultinput, MAX_MESSAGE_LEN)
				if(examtooltip_usrinput)
					user_gear["loadout_examtooltip"] = list(examtooltip_usrinput, TRUE)
					examtooltip_usrinput = alert(usr, "Оставлять описание даже после снятия предмета с персонажа?", "Постоянное описание", "Да", "Нет")
					if(examtooltip_usrinput == "Да")
						user_gear["loadout_examtooltip"][2] = FALSE
				else
					user_gear -= "loadout_examtooltip"

	ShowChoices(user)
	return TRUE


// ========== BlueMoon: Headshot link handling ==========
#define ACTION_HEADSHOT_LINK_NOOP 0
#define ACTION_HEADSHOT_LINK_REMOVE -1
#define HEADSHOT_LINK_MAX_LENGTH 100

/datum/preferences/process_link(mob/user, list/href_list)
	switch(href_list["preference"])
		if ("headshot")
			set_headshot_link(user, "headshot_link")
		if ("headshot1")
			set_headshot_link(user, "headshot_link1")
		if ("headshot2")
			set_headshot_link(user, "headshot_link2")
		if ("headshot_naked")
			set_headshot_link(user, "headshot_naked_link")
		if ("headshot_naked1")
			set_headshot_link(user, "headshot_naked_link1")
		if ("headshot_naked2")
			set_headshot_link(user, "headshot_naked_link2")
		if ("open_tattoo_manager")
			user.client?.open_tattoo_manager()

	return ..()

/datum/preferences/proc/set_headshot_link(mob/user, link_id)
	var/headshot_link = get_headshot_link(user, features[link_id])
	switch(headshot_link)
		if (ACTION_HEADSHOT_LINK_REMOVE)
			features[link_id] = null
			return
		if (ACTION_HEADSHOT_LINK_NOOP)
			return
		else
			if(features[link_id] == headshot_link)
				return

			to_chat(user, span_notice("Если картинка не отображается в игре должным образом, убедитесь, что это прямая ссылка на изображение, которая правильно открывается в обычном браузере."))
			to_chat(user, span_notice("Имейте в виду, что размер фотографии будет уменьшен до 256x256 пикселей, поэтому чем квадратнее фотография, тем лучше она будет выглядеть."))

			features[link_id] = headshot_link

/datum/preferences/proc/get_headshot_link(mob/user, old_link)
	var/usr_input = input(user, "Input the image link: (For Discord links, try putting the file's type at the end of the link, after the '&'. for example '&.jpg/.png/.jpeg')", "Headshot Image", old_link) as text|null
	if(isnull(usr_input))
		return ACTION_HEADSHOT_LINK_NOOP

	if(!usr_input)
		return ACTION_HEADSHOT_LINK_REMOVE

	var/static/link_regex = regex("^(https://i\\.gyazo\\.com|https://static1\\.e621\\.net|https://i\\.ibb\\.co/)")
	var/static/end_regex = regex("(\\.jpg|\\.png|\\.jpeg)$")

	if (length(usr_input) > HEADSHOT_LINK_MAX_LENGTH)
		to_chat(user, span_warning("The link is too long! Max length: [HEADSHOT_LINK_MAX_LENGTH] characters!"))
		return ACTION_HEADSHOT_LINK_NOOP

	if(!findtext(usr_input, link_regex))
		to_chat(user, span_warning("The link needs to be an unshortened Gyazo, iBB, E621 link!"))
		return ACTION_HEADSHOT_LINK_NOOP

	if(!findtext(usr_input, end_regex))
		to_chat(user, span_warning("You need either \".png\", \".jpg\", or \".jpeg\" in the end of the link!"))
		return ACTION_HEADSHOT_LINK_NOOP

	var/static/list/repl_chars = list("\n"="#","\t"="#","'"="","\""=""," "="")
	return sanitize(usr_input, repl_chars)

#undef HEADSHOT_LINK_MAX_LENGTH
#undef ACTION_HEADSHOT_LINK_NOOP
#undef ACTION_HEADSHOT_LINK_REMOVE
