/mob/living/silicon/pai/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiSoftware")
		ui.set_autoupdate(TRUE)
		ui.open()

/mob/living/silicon/pai/ui_data(mob/user)
	var/list/data = list()
	data["screen"] = screen
	data["subscreen"] = subscreen
	data["ram"] = ram
	data["software"] = software
	data["available_software"] = available_software
	data["master"] = master
	data["master_dna"] = master_dna
	data["laws_zeroth"] = laws?.zeroth
	data["laws_supplied"] = laws?.supplied
	data["temp"] = temp
	data["stat"] = stat
	data["secHUD"] = secHUD
	data["medHUD"] = medHUD
	data["encryptmod"] = encryptmod
	data["radio_short"] = radio_short
	data["signaler_frequency"] = signaler ? signaler.frequency : null
	data["signaler_code"] = signaler ? signaler.code : null
	data["hackprogress"] = hackprogress
	data["hacking"] = hacking
	data["cable_extended"] = cable ? TRUE : FALSE
	data["cable_connected"] = (cable?.machine) ? TRUE : FALSE
	data["pda_installed"] = pda ? TRUE : FALSE
	data["heartbeat_sensor"] = heartbeat_sensor
	data["emitterhealth"] = emitterhealth
	data["emittermaxhealth"] = emittermaxhealth
	data["holoform"] = holoform
	// Unread messages from PDA messenger
	data["messenger_unread"] = 0
	if(pda)
		var/datum/computer_file/program/messenger/messenger = locate() in pda.get_all_files()
		if(messenger)
			for(var/chat_ref in messenger.saved_chats)
				var/datum/pda_chat/chat = messenger.saved_chats[chat_ref]
				data["messenger_unread"] += chat.unread_messages

	var/datum/language_holder/H = get_language_holder()
	data["translator_on"] = H?.omnitongue ? TRUE : FALSE

	// Crew manifest
	data["crew_manifest"] = list()
	if(GLOB.data_core.general)
		for(var/datum/data/record/t in sortRecord(GLOB.data_core.general))
			data["crew_manifest"] += list(list(
				"name" = t.fields["name"],
				"rank" = t.fields["rank"],
			))

	// Medical records list
	data["medical_records"] = list()
	if(GLOB.data_core.general)
		for(var/datum/data/record/R in sortRecord(GLOB.data_core.general))
			data["medical_records"] += list(list(
				"id" = R.fields["id"],
				"name" = R.fields["name"],
				"rank" = R.fields["rank"],
			))

	// Security records list
	data["security_records"] = list()
	if(GLOB.data_core.general)
		for(var/datum/data/record/R in sortRecord(GLOB.data_core.general))
			data["security_records"] += list(list(
				"id" = R.fields["id"],
				"name" = R.fields["name"],
				"rank" = R.fields["rank"],
			))

	// Active medical record
	data["medical_active1"] = null
	data["medical_active2"] = null
	if(medicalActive1)
		data["medical_active1"] = list(
			"name" = medicalActive1.fields["name"],
			"id" = medicalActive1.fields["id"],
			"gender" = medicalActive1.fields["gender"],
			"age" = medicalActive1.fields["age"],
			"fingerprint" = medicalActive1.fields["fingerprint"],
			"p_stat" = medicalActive1.fields["p_stat"],
			"m_stat" = medicalActive1.fields["m_stat"],
		)
	if(medicalActive2)
		data["medical_active2"] = list(
			"blood_type" = medicalActive2.fields["blood_type"],
			"b_dna" = medicalActive2.fields["b_dna"],
			"mi_dis" = medicalActive2.fields["mi_dis"],
			"mi_dis_d" = medicalActive2.fields["mi_dis_d"],
			"ma_dis" = medicalActive2.fields["ma_dis"],
			"ma_dis_d" = medicalActive2.fields["ma_dis_d"],
			"alg" = medicalActive2.fields["alg"],
			"alg_d" = medicalActive2.fields["alg_d"],
			"cdi" = medicalActive2.fields["cdi"],
			"cdi_d" = medicalActive2.fields["cdi_d"],
			"notes" = medicalActive2.fields["notes"],
		)

	// Active security record
	data["security_active1"] = null
	data["security_active2"] = null
	if(securityActive1)
		data["security_active1"] = list(
			"name" = securityActive1.fields["name"],
			"id" = securityActive1.fields["id"],
			"gender" = securityActive1.fields["gender"],
			"age" = securityActive1.fields["age"],
			"rank" = securityActive1.fields["rank"],
			"fingerprint" = securityActive1.fields["fingerprint"],
			"p_stat" = securityActive1.fields["p_stat"],
			"m_stat" = securityActive1.fields["m_stat"],
		)
	if(securityActive2)
		data["security_active2"] = list(
			"criminal" = securityActive2.fields["criminal"],
			"mi_crim" = securityActive2.fields["mi_crim"],
			"mi_crim_d" = securityActive2.fields["mi_crim_d"],
			"ma_crim" = securityActive2.fields["ma_crim"],
			"ma_crim_d" = securityActive2.fields["ma_crim_d"],
			"notes" = securityActive2.fields["notes"],
		)

	// Atmosphere
	var/turf/T = get_turf(loc)
	if(!isnull(T))
		var/datum/gas_mixture/environment = T.return_air()
		if(environment)
			data["atmo_pressure"] = round(environment.return_pressure(), 0.1)
			data["atmo_temp"] = round(environment.return_temperature() - T0C)
			data["atmo_gases"] = list()
			var/total_moles = environment.total_moles()
			if(total_moles)
				for(var/id in environment.get_gases())
					var/gas_level = environment.get_moles(id)/total_moles
					if(gas_level > 0.01)
						data["atmo_gases"] += list(list(
							"name" = GLOB.gas_data.names[id],
							"percent" = round(gas_level*100),
						))
		else
			data["atmo_pressure"] = null
	else
		data["atmo_pressure"] = null

	// Bioscan data
	data["bioscan"] = null
	if(subscreen == 1 && screen == "medicalhud")
		var/mob/living/M = card.loc
		var/count = 0
		while(!isliving(M))
			if(!M || !M.loc || count >= 6)
				data["bioscan"] = list("error" = "Биологический носитель не найден.")
				break
			M = M.loc
			count++
		if(isliving(M) && !data["bioscan"])
			var/list/bioscan = list()
			bioscan["name"] = M.name
			bioscan["stat"] = M.stat > 1 ? "мертв" : "[M.health]% здоровья"
			bioscan["oxy"] = M.getOxyLoss()
			bioscan["tox"] = M.getToxLoss()
			bioscan["burn"] = M.getFireLoss()
			bioscan["brute"] = M.getBruteLoss()
			bioscan["temp_c"] = M.bodytemperature - T0C
			bioscan["diseases"] = list()
			for(var/thing in M.diseases)
				var/datum/disease/D = thing
				bioscan["diseases"] += list(list(
					"name" = D.name,
					"spread" = D.spread_text,
					"stage" = D.stage,
					"max_stages" = D.max_stages,
					"cure" = D.cure_text,
				))
			data["bioscan"] = bioscan

	return data

/mob/living/silicon/pai/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("set_screen")
			var/new_screen = params["screen"]
			screen = new_screen
			subscreen = text2num(params["sub"]) || 0
			return TRUE
		if("buy")
			var/target = params["buy"]
			if(available_software.Find(target) && !software.Find(target))
				var/cost = available_software[target]
				if(ram >= cost)
					software.Add(target)
					ram -= cost
				else
					temp = "Недостаточно ОЗУ."
			else
				temp = "Модуль \"[target]\" не найден."
			return TRUE
		if("radio")
			radio.attack_self(src)
			return TRUE
		if("image")
			var/newImage = tgui_input_list(src, "Выберите новое изображение экрана.", "Изображение экрана", list("Happy", "Cat", "Extremely Happy", "Face", "Laugh", "Off", "Sad", "Angry", "What", "Exclamation", "Question", "Sunglasses", "Mal-0"))
			if(!newImage)
				return
			var/pID = 1
			switch(newImage)
				if("Happy")
					pID = 1
				if("Cat")
					pID = 2
				if("Extremely Happy")
					pID = 3
				if("Face")
					pID = 4
				if("Laugh")
					pID = 5
				if("Off")
					pID = 6
				if("Sad")
					pID = 7
				if("Angry")
					pID = 8
				if("What")
					pID = 9
				if("Null")
					pID = 10
				if("Exclamation")
					pID = 11
				if("Question")
					pID = 12
				if("Sunglasses")
					pID = 13
				if("Mal-0")
					pID = 14
			card.setEmotion(pID)
			return TRUE
		if("signaller_send")
			signaler.send_activation()
			audible_message("[icon2html(src, hearers(src))] *beep* *beep* *beep*")
			playsound(src, 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
			return TRUE
		if("signaller_freq")
			var/new_frequency = signaler.frequency + text2num(params["freq"])
			if(new_frequency < MIN_FREE_FREQ || new_frequency > MAX_FREE_FREQ)
				new_frequency = sanitize_frequency(new_frequency)
			signaler.set_frequency(new_frequency)
			return TRUE
		if("signaller_code")
			signaler.code += text2num(params["code"])
			signaler.code = round(signaler.code)
			signaler.code = min(100, signaler.code)
			signaler.code = max(1, signaler.code)
			return TRUE
		if("directive_dna")
			var/mob/living/M = card.loc
			var/count = 0
			while(!isliving(M))
				if(!M || !M.loc)
					return FALSE
				M = M.loc
				count++
				if(count >= 6)
					to_chat(src, "Вас никто не носит!")
					return FALSE
			INVOKE_ASYNC(src, PROC_REF(CheckDNA), M)
			return TRUE
		if("medicalrecord_select")
			medicalActive1 = GLOB.data_core.general_by_id[params["id"]]
			if(medicalActive1)
				medicalActive2 = GLOB.data_core.medical_by_id[params["id"]]
			if(!medicalActive2)
				medicalActive1 = null
				temp = "Не удалось найти запрошенную мед. карту."
			subscreen = 1
			return TRUE
		if("securityrecord_select")
			securityActive1 = GLOB.data_core.general_by_id[params["id"]]
			if(securityActive1)
				securityActive2 = GLOB.data_core.security_by_id[params["id"]]
			if(!securityActive2)
				securityActive1 = null
				temp = "Не удалось найти запрошенную служ. карту."
			subscreen = 1
			return TRUE
		if("toggle_sec_hud")
			secHUD = !secHUD
			if(secHUD)
				var/datum/atom_hud/sec = GLOB.huds[sec_hud]
				sec.add_hud_to(src)
			else
				var/datum/atom_hud/sec = GLOB.huds[sec_hud]
				sec.remove_hud_from(src)
			return TRUE
		if("toggle_med_hud")
			medHUD = !medHUD
			if(medHUD)
				var/datum/atom_hud/med = GLOB.huds[med_hud]
				med.add_hud_to(src)
			else
				var/datum/atom_hud/med = GLOB.huds[med_hud]
				med.remove_hud_from(src)
			return TRUE
		if("toggle_encrypt")
			encryptmod = TRUE
			return TRUE
		if("toggle_translator")
			grant_all_languages(source = LANGUAGE_SOFTWARE)
			return TRUE
		if("doorjack_start")
			if(cable && cable.machine)
				hackdoor = cable.machine
				hackloop()
			return TRUE
		if("doorjack_cancel")
			hackdoor = null
			return TRUE
		if("doorjack_cable")
			var/turf/T = get_turf(loc)
			cable = new /obj/item/pai_cable(T)
			T.visible_message("<span class='warning'>Порт на [src] открывается, оттуда высыпается [cable] и падает на пол.</span>", "<span class='italics'>Ты слышишь лёгкий щелчок чего-то твёрдого, падающего на землю.</span>")
			return TRUE
		if("camerajack_start")
			if(cable && cable.machine && istype(cable.machine, /obj/machinery/camera))
				hackcamera = cable.machine
				hackloop()
			return TRUE
		if("camerajack_cancel")
			hackcamera = null
			return TRUE
		if("toggle_heartbeat")
			heartbeat_sensor = !heartbeat_sensor
			if(heartbeat_sensor)
				to_chat(src, "<span class='notice'>Сенсор пульса активирован.</span>")
			else
				to_chat(src, "<span class='notice'>Сенсор пульса деактивирован.</span>")
			return TRUE
		if("toggle_projection")
			if(holoform)
				fold_in()
			else
				fold_out()
			return TRUE
		if("messenger")
			if(pda)
				var/datum/computer_file/program/messenger/messenger = locate() in pda.get_all_files()
				if(messenger)
					messenger.run_program(src)
					pda.active_program = messenger
					messenger.ui_interact(src)
				else
					to_chat(src, "<span class='warning'>Мессенджер не найден!</span>")
			else
				to_chat(src, "<span class='warning'>PDA не установлен!</span>")
			return TRUE
		if("quick_reply")
			if(pda)
				var/datum/computer_file/program/messenger/messenger = locate() in pda.get_all_files()
				if(messenger)
					var/datum/pda_chat/target_chat = null
					for(var/chat_ref in messenger.saved_chats)
						var/datum/pda_chat/chat = messenger.saved_chats[chat_ref]
						if(chat.unread_messages > 0)
							target_chat = chat
							break
					if(target_chat)
						messenger.quick_reply_prompt(src, target_chat)
					else
						messenger.run_program(src)
						pda.active_program = messenger
						messenger.ui_interact(src)
				else
					to_chat(src, "<span class='warning'>Мессенджер не найден!</span>")
			else
				to_chat(src, "<span class='warning'>PDA не установлен!</span>")
			return TRUE
		if("loudness_open")
			if(!internal_instrument)
				internal_instrument = new(src)
			internal_instrument.ui_interact(src)
			return TRUE
		if("medical_bioscan")
			subscreen = 1
			return TRUE
		if("clear_temp")
			temp = null
			return TRUE
		if("refresh")
			return TRUE

/mob/living/silicon/pai/proc/paiInterface()
	ui_interact(src)
