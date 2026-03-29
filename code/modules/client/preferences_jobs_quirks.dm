/datum/preferences/proc/SetChoices(mob/user, limit = 17, list/splitJobs = list("Research Director", "Head of Personnel"), widthPerColumn = 295, height = 620) // BLUEMOON CHANGES - splitjob
	if(!SSjob)
		return

	//limit - The amount of jobs allowed per column. Defaults to 17 to make it look nice.
	//splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads. Defaults to CE to make it look nice.
	//widthPerColumn - Screen's width for every column.
	//height - Screen's height.

	var/width = widthPerColumn

	var/HTML = "<center>"
	if(SSjob.occupations.len <= 0)
		HTML += "The job SSticker is not yet finished creating jobs, please try again later"
		HTML += "<center><a href='?_src_=prefs;preference=job;task=close'>Done</a></center><br>" // Easier to press up here.

	else
		HTML += "<b>Choose occupation chances</b><br>"
		HTML += "<div align='center'>Left-click to raise an occupation preference, right-click to lower it.<br></div>"
		HTML += "<center><a href='?_src_=prefs;preference=job;task=close'>Done</a></center><br>" // Easier to press up here.
		HTML += "<script type='text/javascript'>function setJobPrefRedirect(level, rank) { window.location.href='?_src_=prefs;preference=job;task=setJobLevel;level=' + level + ';text=' + encodeURIComponent(rank); return false; }</script>"
		HTML += "<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more colomns.
		HTML += "<table width='100%' cellpadding='1' cellspacing='0'>"
		var/index = -1

		//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
		var/datum/job/lastJob

		for(var/datum/job/job in sort_list(SSjob.occupations, GLOBAL_PROC_REF(cmp_job_display_asc)))

			index += 1
			if((index >= limit) || (job.title in splitJobs))
				width += widthPerColumn
				if((index < limit) && (lastJob != null))
					//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
					//the last job's selection color. Creating a rather nice effect.
					for(var/i = 0, i < (limit - index), i += 1)
						HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"
				HTML += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
				index = 0

			HTML += "<tr bgcolor='[job.selection_color]'><td width='60%' align='right'>"
			var/rank = job.title
			var/displayed_rank = rank
			if(job.alt_titles.len && (rank in alt_titles_preferences))
				displayed_rank = alt_titles_preferences[rank]
			lastJob = job
			if(jobban_isbanned(user, rank))
				HTML += "<font color=\"#000000\">[rank]</font></td><td><a href='?_src_=prefs;bancheck=[rank]'> BANNED</a></td></tr>"
				continue
			var/required_playtime_remaining = job.required_playtime_remaining(user.client)
			if(required_playtime_remaining)
				HTML += "<font color=\"#000000\">[rank]</font></td><td><font color=\"#000000\"> \[ [get_exp_format(required_playtime_remaining)] as [job.get_exp_req_type()] \] </font></td></tr>"
				continue
			if(!job.player_old_enough(user.client))
				var/available_in_days = job.available_in_days(user.client)
				HTML += "<font color=\"#000000\">[rank]</font></td><td><font color=\"#000000\"> \[IN [(available_in_days)] DAYS\]</font></td></tr>"
				continue
			if(!user.client.prefs.pref_species.qualifies_for_rank(rank, user.client.prefs.features))
				if(user.client.prefs.pref_species.id == "human")
					HTML += "<font color=\"#000000\">[rank]</font></td><td><font color=\"#000000\"><b> \[MUTANT\]</b></font></td></tr>"
				else
					HTML += "<font color=\"#000000\">[rank]</font></td><td><font color=\"#000000\"><b> \[NON-HUMAN\]</b></font></td></tr>"
				continue
			//BLUE MOON ADDITION - XENO SUPREMACY - START
			if(job.is_species_blacklisted(user.client))
				HTML += "<font color=\"#000000\">[rank]</font></td><td><font color=\"#000000\"><b> \[SPECIES BLACKLISTED\]</b></font></td></tr>"
				continue
			//BLUE MOON ADDITION - XENO SUPREMACY - END
			if((job_preferences["[SSjob.overflow_role]"] == JP_LOW) && (rank != SSjob.overflow_role) && !jobban_isbanned(user, SSjob.overflow_role))
				HTML += "<font color=\"#000000\">[rank]</font></td><td></td></tr>"
				continue
			var/rank_title_line = "[displayed_rank]"
			if((rank in GLOB.command_positions) || (rank == "AI"))//Bold head jobs
				rank_title_line = "<b>[rank_title_line]</b>"
			if(job.alt_titles.len)
				rank_title_line = "<a href='?_src_=prefs;preference=job;task=alt_title;job_title=[job.title]'>[rank_title_line]</a>"

			else
				rank_title_line = "<span class='dark'>[rank_title_line]</span>" //Make it dark if we're not adding a button for alt titles
			HTML += rank_title_line

			HTML += "</td><td width='40%'>"

			var/prefLevelLabel = "ERROR"
			var/prefLevelColor = "pink"
			var/prefUpperLevel = -1 // level to assign on left click
			var/prefLowerLevel = -1 // level to assign on right click

			switch(job_preferences["[job.title]"])
				if(JP_HIGH)
					prefLevelLabel = "High"
					prefLevelColor = "slateblue"
					prefUpperLevel = 4
					prefLowerLevel = 2
				if(JP_MEDIUM)
					prefLevelLabel = "Medium"
					prefLevelColor = "green"
					prefUpperLevel = 1
					prefLowerLevel = 3
				if(JP_LOW)
					prefLevelLabel = "Low"
					prefLevelColor = "orange"
					prefUpperLevel = 2
					prefLowerLevel = 4
				else
					prefLevelLabel = "NEVER"
					prefLevelColor = "red"
					prefUpperLevel = 3
					prefLowerLevel = 1

			HTML += "<a class='white' href='?_src_=prefs;preference=job;task=setJobLevel;level=[prefUpperLevel];text=[rank]' oncontextmenu='javascript:return setJobPrefRedirect([prefLowerLevel], \"[rank]\");'>"

			if(rank == SSjob.overflow_role)//Overflow is special
				if(job_preferences["[SSjob.overflow_role]"] == JP_LOW)
					HTML += "<font color=green>Yes</font>"
				else
					HTML += "<font color=red>No</font>"
				HTML += "</a></td></tr>"
				continue

			HTML += "<font color=[prefLevelColor]>[prefLevelLabel]</font>"
			HTML += "</a></td></tr>"

		for(var/i = 1, i < (limit - index), i += 1) // Finish the column so it is even
			HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"

		HTML += "</td'></tr></table>"
		HTML += "</center></table>"

		var/message = "Be an [SSjob.overflow_role] if preferences unavailable"
		if(joblessrole == BERANDOMJOB)
			message = "Get random job if preferences unavailable"
		else if(joblessrole == RETURNTOLOBBY)
			message = "Return to lobby if preferences unavailable"
		HTML += "<center><br><a href='?_src_=prefs;preference=job;task=random'>[message]</a></center>"
		HTML += "<center><a href='?_src_=prefs;preference=job;task=reset'>Reset Preferences</a></center>"

	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Occupation Preferences</div>", width, height)
	popup.set_window_options("can_close=0")
	popup.set_content(HTML)
	popup.open(FALSE)

/datum/preferences/proc/SetJobPreferenceLevel(datum/job/job, level)
	if (!job)
		return FALSE

	if (level == JP_HIGH) // to high
		//Set all other high to medium
		for(var/j in job_preferences)
			if(job_preferences["[j]"] == JP_HIGH)
				job_preferences["[j]"] = JP_MEDIUM
				//technically break here

	job_preferences["[job.title]"] = level
	return TRUE

/datum/preferences/proc/UpdateJobPreference(mob/user, role, desiredLvl)
	if(!SSjob || SSjob.occupations.len <= 0)
		return
	var/datum/job/job = SSjob.GetJob(role)

	if(!job)
		user << browse(null, "window=mob_occupation")
		ShowChoices(user)
		return

	if (!isnum(desiredLvl))
		to_chat(user, "<span class='danger'>UpdateJobPreference - desired level was not a number. Please notify coders!</span>")
		ShowChoices(user)
		return

	var/jpval = null
	switch(desiredLvl)
		if(3)
			jpval = JP_LOW
		if(2)
			jpval = JP_MEDIUM
		if(1)
			jpval = JP_HIGH

	if(role == SSjob.overflow_role)
		if(job_preferences["[job.title]"] == JP_LOW)
			jpval = null
		else
			jpval = JP_LOW

	SetJobPreferenceLevel(job, jpval)
	SetChoices(user)

	return TRUE


/datum/preferences/proc/ResetJobs()
	job_preferences = list()

/datum/preferences/proc/SetQuirks(mob/user)
	if(!SSquirks)
		to_chat(user, "<span class='danger'>The quirk subsystem is still initializing! Try again in a minute.</span>")
		return

	var/list/dat = list()
	if(!SSquirks.quirks.len)
		dat += "The quirk subsystem hasn't finished initializing, please hold..."
		dat += "<center><a href='?_src_=prefs;preference=trait;task=close'>Done</a></center><br>"

	else
		dat += "<center><b>Choose quirk setup</b></center><br>"
		// BLUEMOON ADD START - настройки для отдельных квирков
		dat += "Настройки для отдельных квирков. Если нужный квирк не будет выставлен, то они работать не будут.<br>"
		dat += "<a href='?_src_=prefs;preference=traits_setup;task=change_shriek_option'>([BLUEMOON_TRAIT_NAME_SHRIEK]) Тип Крика: [shriek_type]</a>"
		dat += "<a href='?_src_=prefs;preference=traits_setup;task=lewd_summon_nickname'>([TRAIT_LEWD_SUMMON]) Прозвище для призываемого[summon_nickname ? ": " : ""][html_encode(summon_nickname)]</a>"
		dat += "<hr>"
		// BLUEMOON ADD END
		dat += "<div align='center'>Left-click to add or remove quirks. You need negative quirks to have positive ones.<br>\
		Quirks are applied at roundstart and cannot normally be removed.</div>"
		dat += "<center><a href='?_src_=prefs;preference=trait;task=close'>Done</a></center>"
		dat += "<hr>"
		dat += "<center><b>Current quirks:</b> [all_quirks.len ? all_quirks.Join(", ") : "None"]</center>"
		dat += "<center>[GetPositiveQuirkCount()] / [MAX_QUIRKS] max positive quirks<br>\
		<b>Quirk balance remaining:</b> [GetQuirkBalance(user)]<br>"
		dat += " <a href='?_src_=prefs;quirk_category=[QUIRK_POSITIVE]' [quirk_category == QUIRK_POSITIVE ? "class='linkOn'" : ""]>[QUIRK_POSITIVE]</a> "
		dat += " <a href='?_src_=prefs;quirk_category=[QUIRK_NEUTRAL]' [quirk_category == QUIRK_NEUTRAL ? "class='linkOn'" : ""]>[QUIRK_NEUTRAL]</a> "
		dat += " <a href='?_src_=prefs;quirk_category=[QUIRK_NEGATIVE]' [quirk_category == QUIRK_NEGATIVE ? "class='linkOn'" : ""]>[QUIRK_NEGATIVE]</a> "
		dat += "</center><br>"
		for(var/V in SSquirks.quirks)
			var/datum/quirk/T = SSquirks.quirks[V]
			var/value = initial(T.value)
			if((value > 0 && quirk_category != QUIRK_POSITIVE) || (value < 0 && quirk_category != QUIRK_NEGATIVE) || (value == 0 && quirk_category != QUIRK_NEUTRAL))
				continue

			var/quirk_name = initial(T.name)
			var/has_quirk
			var/quirk_cost = initial(T.value) * -1
			var/lock_reason = "This trait is unavailable."
			var/quirk_conflict = FALSE
			for(var/_V in all_quirks)
				if(_V == quirk_name)
					has_quirk = TRUE
			if(initial(T.mood_quirk) && CONFIG_GET(flag/disable_human_mood))
				lock_reason = "Mood is disabled."
				quirk_conflict = TRUE
			if(has_quirk)
				if(quirk_conflict)
					all_quirks -= quirk_name
					has_quirk = FALSE
				else
					quirk_cost *= -1 //invert it back, since we'd be regaining this amount
			if(quirk_cost > 0)
				quirk_cost = "+[quirk_cost]"
			var/font_color = "#AAAAFF"
			if(initial(T.value) != 0)
				font_color = value > 0 ? "#AAFFAA" : "#FFAAAA"
			if(quirk_conflict)
				dat += "<font color='[font_color]'>[quirk_name]</font> - [initial(T.desc)] \
				<font color='red'><b>LOCKED: [lock_reason]</b></font><br>"
			else
				if(has_quirk)
					dat += "<a href='?_src_=prefs;preference=trait;task=update;trait=[quirk_name]'>[has_quirk ? "Remove" : "Take"] ([quirk_cost] pts.)</a> \
					<b><font color='[font_color]'>[quirk_name]</font></b> - [initial(T.desc)]<br>"
				else
					dat += "<a href='?_src_=prefs;preference=trait;task=update;trait=[quirk_name]'>[has_quirk ? "Remove" : "Take"] ([quirk_cost] pts.)</a> \
					<font color='[font_color]'>[quirk_name]</font> - [initial(T.desc)]<br>"
		dat += "<br><center><a href='?_src_=prefs;preference=trait;task=reset'>Reset Quirks</a></center>"

	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Quirk Preferences</div>", 900, 600) //no reason not to reuse the occupation window, as it's cleaner that way
	popup.set_window_options("can_close=0")
	popup.set_content(dat.Join())
	popup.open(FALSE)

/datum/preferences/proc/GetInlineQuirksMarkup(mob/user)
	if(!SSquirks)
		return "<center><i>Quirks are disabled on this server.</i></center>"

	var/list/dat = list()
	if(!SSquirks.quirks.len)
		dat += "<center><i>The quirk subsystem hasn't finished initializing, please hold...</i></center>"
		return dat.Join()

	dat += "<div class='csetup-quirks'>"
	var/quirk_balance = GetQuirkBalance(user)

	// BLUEMOON: per-quirk settings (kept inline)
	dat += "<h3>Настройки квирков</h3>"
	var/display_summon_nickname = summon_nickname ? html_encode(summon_nickname) : "—"
	dat += "<div class='csetup-quirk-settings'>"
	dat += "<a class='csetup-quirk-setting' href='?_src_=prefs;preference=traits_setup;task=change_shriek_option'>Тип крика: <b>[shriek_type]</b></a>"
	dat += "<a class='csetup-quirk-setting' href='?_src_=prefs;preference=traits_setup;task=lewd_summon_nickname'>Прозвище: <b>[display_summon_nickname]</b></a>"
	dat += "</div>"

	dat += "<h3>Текущие квирки</h3>"
	var/display_current_quirks = english_list(all_quirks, "None")
	var/positive_quirk_count = GetPositiveQuirkCount()
	dat += "<div class='notice csetup-quirks-summary'>"
	dat += "<div class='csetup-quirks-summary-current'><b>Current:</b> " + display_current_quirks + "</div>"
	dat += "<div class='csetup-quirks-summary-meta'><b>Positive:</b> [positive_quirk_count] / [MAX_QUIRKS]<br><b>Points left:</b> [quirk_balance]</div>"
	dat += "</div>"
	dat += "<div class='csetup-quirk-tabs'>"
	dat += "<a href='?_src_=prefs;quirk_category=[QUIRK_POSITIVE]' " + (quirk_category == QUIRK_POSITIVE ? "class='linkOn'" : "") + ">[QUIRK_POSITIVE]</a>"
	dat += "<a href='?_src_=prefs;quirk_category=[QUIRK_NEUTRAL]' " + (quirk_category == QUIRK_NEUTRAL ? "class='linkOn'" : "") + ">[QUIRK_NEUTRAL]</a>"
	dat += "<a href='?_src_=prefs;quirk_category=[QUIRK_NEGATIVE]' " + (quirk_category == QUIRK_NEGATIVE ? "class='linkOn'" : "") + ">[QUIRK_NEGATIVE]</a>"
	dat += "</div>"

	dat += "<div class='csetup-quirk-list'>"
	var/list/selected_rows = list()
	var/list/other_rows = list()

	for(var/V in SSquirks.quirks)
		var/datum/quirk/T = SSquirks.quirks[V]
		var/value = initial(T.value)
		if((value > 0 && quirk_category != QUIRK_POSITIVE) || (value < 0 && quirk_category != QUIRK_NEGATIVE) || (value == 0 && quirk_category != QUIRK_NEUTRAL))
			continue

		var/quirk_name = initial(T.name)
		var/has_quirk = (quirk_name in all_quirks)
		var/quirk_cost = value * -1
		var/lock_reason = "This trait is unavailable."
		var/quirk_conflict = FALSE
		if(initial(T.mood_quirk) && CONFIG_GET(flag/disable_human_mood))
			lock_reason = "Mood is disabled."
			quirk_conflict = TRUE

		// Conflict with currently selected quirks (blacklist)
		if(!has_quirk)
			var/list/blacklist_conflicts = list()
			for(var/_V in SSquirks.quirk_blacklist) // _V is a list
				var/list/L = _V
				if(!(quirk_name in L))
					continue
				for(var/Q in all_quirks)
					if(Q == quirk_name)
						continue
					if(Q in L)
						if(!(Q in blacklist_conflicts))
							blacklist_conflicts += Q
			if(blacklist_conflicts.len)
				lock_reason = "Incompatible with: " + english_list(blacklist_conflicts)
				quirk_conflict = TRUE

		if(has_quirk)
			if(quirk_conflict)
				all_quirks -= quirk_name
				has_quirk = FALSE
			else
				quirk_cost *= -1
		var/quirk_cost_text = "[quirk_cost]"
		if(quirk_cost > 0)
			quirk_cost_text = "+[quirk_cost]"

		var/value_class = "neutral"
		if(value > 0)
			value_class = "positive"
		else if(value < 0)
			value_class = "negative"

		var/row_classes = "csetup-quirk-row is-[value_class]"
		if(has_quirk)
			row_classes += " is-selected"
		if(quirk_conflict)
			row_classes += " is-locked"

		var/title_html = "<span class='csetup-quirk-title'>[quirk_name]</span>"
		var/cost_html = "<span class='csetup-quirk-cost is-[value_class]'>[quirk_cost_text] pts</span>"

		if(quirk_conflict)
			var/safe_lock_reason = html_encode(lock_reason)
			var/row_html = "<div class='[row_classes]' title='[safe_lock_reason]'>"
			row_html += "<div class='csetup-quirk-head'>[title_html][cost_html]</div>"
			row_html += "<div class='csetup-quirk-desc'>[initial(T.desc)]</div>"
			row_html += "<div class='csetup-quirk-lock-reason'>&#128274; [safe_lock_reason]</div>"
			row_html += "</div>"
			other_rows += row_html
			continue

		var/row_action_href = "?_src_=prefs;preference=trait;task=update;trait=[quirk_name]"
		var/row_html = "<div class='[row_classes]'>"
		row_html += "<a class='csetup-quirk-hitbox' href='[row_action_href]'></a>"
		row_html += "<div class='csetup-quirk-head'>[title_html][cost_html]</div>"
		row_html += "<div class='csetup-quirk-desc'>[initial(T.desc)]</div>"
		row_html += "</div>"
		if(has_quirk)
			selected_rows += row_html
		else
			other_rows += row_html

	dat += selected_rows
	dat += other_rows

	dat += "</div>" // csetup-quirk-list
	dat += "<br><center><a href='?_src_=prefs;preference=trait;task=reset'>Reset Quirks</a></center>"
	dat += "</div>" // csetup-quirks
	return dat.Join()

/datum/preferences/proc/GetQuirkBalance(mob/user)
	var/bal = 0
	for(var/V in all_quirks)
		var/datum/quirk/T = SSquirks.quirks[V]
		if(!T)
			all_quirks -= V
			continue
		bal -= initial(T.value)
	for(var/modification in modified_limbs)
		if(modified_limbs[modification][1] == LOADOUT_LIMB_PROSTHETIC)
			bal += 1 //max 1 point regardless of how many prosthetics
			break
	bal -= mob_size_name_to_quirk_cost(body_weight) //BLUEMOON ADD вес влияет на доступные квирки
	if(bal < 0)
		to_chat(user, "<span class='danger'>Something goes wrong and quirk balance goes to [bal], quirks and character weight reseted.</span>") //BLUEMOON ADD
		all_quirks = list()
		body_weight = NAME_WEIGHT_NORMAL //BLUEMOON ADD сброс всего сбрасывает и вес
		return FALSE
	return bal

/datum/preferences/proc/GetPositiveQuirkCount()
	. = 0
	for(var/q in all_quirks)
		if(SSquirks.quirk_points[q] > 0)
			.++

