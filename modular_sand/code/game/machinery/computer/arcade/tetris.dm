// Configuration defines
#define TETRIS_REWARD_DIVISOR CONFIG_GET(number/tetris_reward_divisor)
#define TETRIS_PRIZES_MAX CONFIG_GET(number/tetris_prizes_max)
#define TETRIS_SCORE_HIGH CONFIG_GET(number/tetris_score_high)
#define TETRIS_SCORE_MAX CONFIG_GET(number/tetris_score_max)
#define TETRIS_SCORE_MAX_SCI CONFIG_GET(number/tetris_score_max_sci)
#define TETRIS_TIME_COOLDOWN CONFIG_GET(number/tetris_time_cooldown)
#define TETRIS_NO_SCIENCE CONFIG_GET(flag/tetris_no_science)

// Cooldown defines
#define TETRIS_COOLDOWN_MAIN cooldown_timer

/obj/machinery/computer/arcade/tetris
	name = "T.E.T.R.I.S."
	desc = "The pinnacle of human technology."
	circuit = /obj/item/circuitboard/computer/arcade/tetris
	COOLDOWN_DECLARE(TETRIS_COOLDOWN_MAIN)

/obj/machinery/computer/arcade/tetris/ui_interact(mob/user, datum/tgui/ui)
	if(!isliving(user))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ArcadeTetris", name)
		ui.open()

/obj/machinery/computer/arcade/tetris/ui_data(mob/user)
	var/list/data = list()
	data["cooldownReady"] = COOLDOWN_FINISHED(src, TETRIS_COOLDOWN_MAIN)
	return data

/obj/machinery/computer/arcade/tetris/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("submitScore")
			// Sanitize score as an integer
			// Restricts maximum score to (default) 100,000
			var/temp_score = sanitize_num_clamp(text2num(params["score"]), max=TETRIS_SCORE_MAX)

			// Check for high score
			if(temp_score > TETRIS_SCORE_HIGH)
				// Alert admins
				message_admins("[ADMIN_LOOKUPFLW(usr)] [ADMIN_KICK(usr)] has achieved a score of [temp_score] on [src] in [get_area(src.loc)]! Score exceeds configured suspicion threshold.")

			// Round and clamp prize count from 0 to (default) 5
			var/reward_count = clamp(round(temp_score/TETRIS_REWARD_DIVISOR), 0, TETRIS_PRIZES_MAX)

			// Define score text
			var/score_text = (reward_count ? temp_score : "PATHETIC! TRY HARDER")

			// Display normal message
			say("YOUR SCORE: [score_text]!")

			// Check if any prize would be vended
			if(!reward_count)
				return TRUE

			// Check cooldown
			if(!COOLDOWN_FINISHED(src, TETRIS_COOLDOWN_MAIN))
				playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)
				visible_message(span_notice("[src] sputters for a moment before going quiet."))
				return TRUE

			// Set cooldown time
			COOLDOWN_START(src, TETRIS_COOLDOWN_MAIN, TETRIS_TIME_COOLDOWN)

			// Vend prizes
			prizevend(usr, reward_count)

			// Check if science points are possible and allowed
			if((!SSresearch.science_tech) || TETRIS_NO_SCIENCE)
				return TRUE

			// Define user ID card
			var/obj/item/card/id/user_id = usr.get_idcard()

			// Check if ID exists and has science access
			if(istype(user_id) && (ACCESS_RESEARCH in user_id.access))
				// Limit maximum research points to (default) 10,000
				var/score_research_points = clamp(temp_score, 0, TETRIS_SCORE_MAX_SCI)

				// Add science points based on score
				SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = score_research_points))

				// Announce points earned
				say("Research personnel detected. Applying gathered data to algorithms...")

	add_fingerprint(usr)
	. = TRUE

// Remove defines
#undef TETRIS_REWARD_DIVISOR
#undef TETRIS_PRIZES_MAX
#undef TETRIS_SCORE_HIGH
#undef TETRIS_SCORE_MAX
#undef TETRIS_SCORE_MAX_SCI
#undef TETRIS_TIME_COOLDOWN
#undef TETRIS_NO_SCIENCE
#undef TETRIS_COOLDOWN_MAIN
