// ═══════════════════════════════════════════════════
//  NtosTetris — Тетрис для планшетов / компьютеров
//  Вся игровая логика на стороне клиента (TGUI / JS).
//  Сервер обрабатывает звуки, рекорды и начисление
//  очков исследований (RnD) при наличии доступа.
// ═══════════════════════════════════════════════════

/// Порог подозрительного счёта
#define NTOS_TETRIS_SCORE_HIGH 50000
/// Максимально допустимый счёт
#define NTOS_TETRIS_SCORE_MAX 100000
/// Максимум research points
#define NTOS_TETRIS_SCORE_MAX_SCI 5000
/// Кулдаун между начислениями RnD (deciseconds)
#define NTOS_TETRIS_COOLDOWN 600

/datum/computer_file/program/tetris
	filename = "nttetris"
	filedesc = "T.E.T.R.I.S."
	extended_desc = "Классическая головоломка «Тетрис». Складывайте фигуры, собирайте линии, набирайте очки!"
	requires_ntnet = FALSE
	size = 5
	tgui_id = "NtosTetris"
	program_icon = "th"
	category = PROGRAM_CATEGORY_MISC
	available_on_ntnet = TRUE

	/// Лучший счёт за сессию
	var/high_score = 0
	/// Кулдаун начисления RnD
	COOLDOWN_DECLARE(reward_cooldown)
	/// Защита от дурочков с href
	var/game_active = FALSE

/datum/computer_file/program/tetris/ui_data(mob/user)
	var/list/data = get_header_data()
	data["high_score"] = high_score
	if(user?.client)
		data["personal_best"] = user.client.get_award_status(/datum/award/score/highscore/tetris) || 0
	else
		data["personal_best"] = 0
	return data

/datum/computer_file/program/tetris/ui_static_data(mob/user)
	. = ..()
	// Передаём глобальную таблицу лидеров (топ-50)
	var/datum/award/score/highscore/tetris/S = SSachievements.scores[/datum/award/score/highscore/tetris]
	if(S && S.high_scores.len)
		var/list/leaderboard = list()
		var/rank = 0
		for(var/ckey in S.high_scores)
			rank++
			leaderboard += list(list("rank" = rank, "ckey" = ckey, "score" = S.high_scores[ckey]))
		.["leaderboard"] = leaderboard
	else
		.["leaderboard"] = list()

/datum/computer_file/program/tetris/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("gameStart")
			game_active = TRUE
			return TRUE
		if("sfx")
			if(!computer)
				return
			var/sfx_type = params["type"]
			switch(sfx_type)
				if("move")
					playsound(computer.loc, 'modular_bluemoon/sound/machines/tetris/move_piece.ogg', 20, TRUE, extrarange = -5)
				if("rotate")
					playsound(computer.loc, 'modular_bluemoon/sound/machines/tetris/rotate_piece.ogg', 25, TRUE, extrarange = -5)
				if("drop")
					playsound(computer.loc, 'modular_bluemoon/sound/machines/tetris/piece_falling_after_line_clear.ogg', 30, TRUE, extrarange = -4)
				if("line_clear")
					playsound(computer.loc, 'modular_bluemoon/sound/machines/tetris/line_clear.ogg', 40, TRUE, extrarange = -3)
				if("tetris")
					playsound(computer.loc, 'modular_bluemoon/sound/machines/tetris/player_sending_blocks.ogg', 50, TRUE, extrarange = -3)
				if("level_up")
					playsound(computer.loc, 'modular_bluemoon/sound/machines/tetris/level_up_jingle.ogg', 45, TRUE, extrarange = -3)
				if("game_over")
					playsound(computer.loc, 'modular_bluemoon/sound/machines/tetris/game_over.ogg', 50, TRUE, extrarange = -2)
				if("high_score")
					playsound(computer.loc, 'modular_bluemoon/sound/machines/tetris/game_over.ogg', 55, TRUE, extrarange = -2)
			return TRUE
		if("submitScore")
			if(!game_active)
				return FALSE
			game_active = FALSE
			var/temp_score = clamp(text2num(params["score"]) || 0, 0, NTOS_TETRIS_SCORE_MAX)
			if(temp_score > high_score)
				high_score = temp_score

			if(usr?.client && SSachievements.achievements_enabled)
				usr.client.give_award(/datum/award/score/highscore/tetris, usr, temp_score)

			// Проверка подозрительного счёта
			if(temp_score > NTOS_TETRIS_SCORE_HIGH)
				message_admins("[ADMIN_LOOKUPFLW(usr)] набрал [temp_score] очков в планшетном тетрисе.")

			if(!computer)
				return TRUE

			computer.say("ВАШИ ОЧКИ: [temp_score]!")

			// Начисление очков исследований (только очки, без предметов)
			if(SSresearch.science_tech && COOLDOWN_FINISHED(src, reward_cooldown))
				var/obj/item/card/id/user_id = usr?.get_idcard()
				if(istype(user_id) && (ACCESS_RESEARCH in user_id.access))
					COOLDOWN_START(src, reward_cooldown, NTOS_TETRIS_COOLDOWN)
					var/science_points = clamp(temp_score, 0, NTOS_TETRIS_SCORE_MAX_SCI)
					SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = science_points))
					computer.say("Обнаружен исследовательский персонал. +[science_points] очков исследований.")

			return TRUE

#undef NTOS_TETRIS_SCORE_HIGH
#undef NTOS_TETRIS_SCORE_MAX
#undef NTOS_TETRIS_SCORE_MAX_SCI
#undef NTOS_TETRIS_COOLDOWN
