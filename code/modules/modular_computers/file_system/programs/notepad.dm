/datum/computer_file/program/notepad
	filename = "notepad"
	filedesc = "Notepad"
	category = PROGRAM_CATEGORY_DEVICE
	program_icon_state = "generic"
	extended_desc = "Jot down your work-safe thoughts and what not."
	size = 2
	tgui_id = "NtosNotepad"
	program_icon = "book"
	usage_flags = PROGRAM_ALL

	var/written_note = "Поздравляем, вашу станцию избрали для поддержки программой Thinktronic 5230 Personal Data Assistant! \
		Для помощи в навигации, мы приложили словарь направлений станции как судна. \
		Север: нос. Юг: корма. Запад: левый борт. Восток: правый борт. Диагональ есть диагональ."

/datum/computer_file/program/notepad/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	switch(action)
		if("UpdateNote")
			written_note = params["newnote"]
			return TRUE

/datum/computer_file/program/notepad/ui_data(mob/user)
	var/list/data = list()
	data["note"] = written_note
	return data
