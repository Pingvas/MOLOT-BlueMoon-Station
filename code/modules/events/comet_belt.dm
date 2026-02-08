
/datum/round_event_control/comet_belt
	name = "Comet Belt"
	typepath = /datum/round_event/comet_belt
	max_occurrences = 2
	weight = 8
	earliest_start = 10 MINUTES
	category = EVENT_CATEGORY_FRIENDLY
	description = "A belt of comets passes near the station, creating a spectacular light show."

/datum/round_event_control/comet_belt/canSpawnEvent(players, gamemode)
	if(!CONFIG_GET(flag/starlight))
		return FALSE
	return ..()

/datum/round_event/comet_belt
	announce_when = 1
	start_when = 5
	end_when = 126
	var/current_phase = 0
	var/list/comet_overlays = list()
	var/list/dust_overlays = list()
	var/list/belt_stream_overlays = list()
	var/list/flash_overlays = list()
	var/list/glow_overlays = list()
	var/list/saved_parallax = list()
	var/finale_announced = FALSE

	var/static/list/choreography = list(\
		/* первые кометы*/\
		list(38,  8,  "#50C8FF", 0.6, 1.2,  -5,  -2.5),\
		list(40, 10,  "#40B0FF", 0.7, 1.5,  -5.5,-2.8),\
		list(42,  8,  "#60E0FF", 0.8, 1.4,  -5,  -2.5),\
		list(44, 12,  "#80F0FF", 0.9, 1.8,  -6,  -3),\
		/* спам*/\
		list(66, 15,  "#FFD040", 1.5, 3.0,  -8,  -4),\
		list(67, 12,  "#FFA830", 1.3, 2.8,  -7,  -3.5),\
		list(68, 18,  "#FF8020", 1.8, 3.5,  -8.5,-4.5),\
		list(69, 25,  "#FFE060", 2.0, 4.0,  -9,  -5),\
		list(71, 15,  "#FF6830", 1.5, 3.2,  -8,  -4),\
		list(73, 20,  "#FFCC40", 1.8, 3.8,  -8.5,-4.5),\
		list(75, 12,  "#60D8FF", 1.2, 2.5,  -6.5,-3),\
		list(77, 15,  "#FF9020", 1.4, 3.0,  -7,  -3.5),\
		list(79, 10,  "#E0C060", 1.0, 2.2,  -5.5,-2.8),\
		list(81,  8,  "#80C8FF", 0.9, 2.0,  -5,  -2.5),\
		list(83,  6,  "#60B0E8", 0.8, 1.8,  -5,  -2.5),\
		list(85,  5,  "#5098D8", 0.7, 1.5,  -4.5,-2.2),\
		/* конечная*/\
		list(86, 10,  "#5888D0", 0.8, 1.8,  -5.5,-2.8),\
		list(88,  8,  "#6898E0", 0.7, 1.5,  -5,  -2.5),\
		list(90, 12,  "#4878D0", 0.9, 2.0,  -6,  -3),\
		list(92,  6,  "#3868C0", 0.6, 1.3,  -4.5,-2.2),\
		list(94,  4,  "#3060B8", 0.5, 1.0,  -4,  -2)\
	)

	var/static/list/dust_color_gradient = list(\
		0,     "#180840",\
		0.08,  "#281868",\
		0.16,  "#2850A0",\
		0.24,  "#3888B8",\
		0.30,  "#48C0D8",\
		0.36,  "#58A8C0",\
		0.44,  "#7080A8",\
		0.51,  "#9090B0",\
		0.53,  "#FFE0A0",\
		0.56,  "#FFF8E0",\
		0.59,  "#FFFFFF",\
		0.62,  "#FFD880",\
		0.66,  "#C0B0A0",\
		0.69,  "#70A0C8",\
		0.76,  "#5080A0",\
		0.84,  "#382868",\
		0.96,  "#180838",\
		1,     "#0A0420"\
	)

// ═══════════════════ ИВЕНТ ═══════════════════

/datum/round_event/comet_belt/announce()
	priority_announce("[station_name()]: Наши радары фиксируют приближение кометного пояса. Столкновения со станцией не ожидается — кометы пройдут на безопасном расстоянии. Рекомендуем всем сотрудникам воспользоваться этим редким зрелищем и понаблюдать за космосом через ближайшие иллюминаторы.",\
	sound = 'sound/misc/notice2.ogg',\
	sender_override = "Отдел Астрономии NanoTrasen")
	for(var/V in GLOB.player_list)
		var/mob/M = V
		if((M.client?.prefs?.toggles & SOUND_MIDI) && is_station_level(M.z))
			M.playsound_local(M, 'sound/ambience/star.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/round_event/comet_belt/start()
	for(var/V in GLOB.player_list)
		var/mob/M = V
		ADD_TRAIT(M, TRAIT_PACIFISM, "comet_belt")
	// Эмбиент
	for(var/client/C in GLOB.clients)
		if(!C.mob || !is_station_level(C.mob.z))
			continue
		C.mob.stop_sound_channel(CHANNEL_AMBIENCE)
		C.mob.stop_sound_channel(CHANNEL_BUZZ)
		SSambience.ambience_listening_clients -= C
		// Замена параллакса сука я в ахуе
		if(C.prefs)
			saved_parallax[C] = C.prefs.parallax
			C.prefs.parallax = PARALLAX_INSANE
			if(C.parallax_holder)
				C.parallax_holder.Remove()
				C.parallax_holder.Apply()
		add_comet_overlays(C)
	transition_to_phase(1)

/datum/round_event/comet_belt/tick()
	var/new_phase
	switch(activeFor)
		if(5 to 37)
			new_phase = 1
		if(38 to 45)
			new_phase = 2
		if(46 to 65)
			new_phase = 3
		if(66 to 85)
			new_phase = 4
		if(86 to 95)
			new_phase = 5
		else
			new_phase = 6

	if(new_phase != current_phase)
		transition_to_phase(new_phase)

	var/progress = clamp((activeFor - 5) / 120.0, 0, 1)
	var/dust_col = get_gradient_color(progress, dust_color_gradient)
	update_all_dust_color(dust_col)
	update_belt_stream(dust_col, new_phase, activeFor)

	update_dust_dynamics(activeFor, new_phase)

	var/burst_fired = FALSE
	for(var/list/burst in choreography)
		if(burst[1] == activeFor)
			fire_comet_burst(burst)
			burst_fired = TRUE
			break
	if(!burst_fired)
		if(new_phase != 6)
			set_ambient_comets()
		else
			set_comet_spawning(0)

/datum/round_event/comet_belt/end()
	for(var/V in GLOB.player_list)
		var/mob/M = V
		REMOVE_TRAIT(M, TRAIT_PACIFISM, "comet_belt")
	for(var/client/C in GLOB.clients)
		if(!C.mob || !is_station_level(C.mob.z))
			continue
		SSambience.ambience_listening_clients[C] = world.time
	for(var/client/C in saved_parallax)
		if(C?.prefs)
			C.prefs.parallax = saved_parallax[C]
			if(C.parallax_holder)
				C.parallax_holder.Remove()
				C.parallax_holder.Apply()
	saved_parallax.Cut()
	fade_space_glow()
	comet_final_cleanup()

// ═══════════════════ ФАЗЫ ═══════════════════

/datum/round_event/comet_belt/proc/transition_to_phase(phase)
	current_phase = phase

	switch(phase)
		if(1)
			update_space_glow("#282050", 15)

		if(2)
			update_space_glow("#4888B8", 25)

		if(3)
			update_space_glow("#486080", 20)

		if(4)
			update_space_glow("#FFE898", 50)
			trigger_flash()
			addtimer(CALLBACK(src, PROC_REF(trigger_flash)), 60)

		if(5)
			update_space_glow("#6090B8", 35)

		if(6)
			if(!finale_announced)
				finale_announced = TRUE
				priority_announce("Кометный пояс удаляется за пределы видимости. Благодарим за внимание к этому астрономическому явлению. Возвращайтесь к своим обязанностям.",\
				sound = 'sound/misc/notice2.ogg',\
				sender_override = "Отдел Астрономии NanoTrasen")
			addtimer(CALLBACK(src, PROC_REF(start_fade_out)), 60)
			fade_space_glow()


// Запустить пачку комет с уникальными параметрами
/datum/round_event/comet_belt/proc/fire_comet_burst(list/burst)
	var/burst_spawning = burst[2]
	var/burst_color = burst[3]
	var/sc_min = burst[4]
	var/sc_max = burst[5]
	var/speed_min = abs(burst[7])
	var/speed_max = abs(burst[6])

	for(var/client/C in comet_overlays)
		var/atom/movable/screen/comet_overlay/comet = comet_overlays[C]
		if(!comet?.particles)
			continue
		comet.particles.spawning = burst_spawning
		comet.particles.color = burst_color
		comet.particles.scale = generator("num", sc_min, sc_max)
		comet.particles.icon_state = pick("star", "star1", "star2")
		// Случайное направление для разнообразия
		switch(rand(1, 10))
			if(1 to 4) // справа
				comet.particles.position = generator("box", list(380, -300, 0), list(520, 300, 0))
				comet.particles.velocity = generator("vector", list(-speed_max, -1.5, 0), list(-speed_min, 1.5, 0))
			if(5 to 6) // слева
				comet.particles.position = generator("box", list(-520, -300, 0), list(-380, 300, 0))
				comet.particles.velocity = generator("vector", list(speed_min, -1.5, 0), list(speed_max, 1.5, 0))
			if(7 to 8) // сверху
				comet.particles.position = generator("box", list(-350, 300, 0), list(350, 420, 0))
				comet.particles.velocity = generator("vector", list(-1.5, -speed_max, 0), list(1.5, -speed_min, 0))
			if(9 to 10) // снизу-справа по диагонали
				comet.particles.position = generator("box", list(200, -420, 0), list(520, -300, 0))
				comet.particles.velocity = generator("vector", list(-speed_max, speed_min * 0.5, 0), list(-speed_min * 0.5, speed_max * 0.5, 0))

// Выключить спавн комет
/datum/round_event/comet_belt/proc/set_comet_spawning(val)
	for(var/client/C in comet_overlays)
		var/atom/movable/screen/comet_overlay/comet = comet_overlays[C]
		if(comet?.particles)
			comet.particles.spawning = val

// Фоновый поток мелких комет между хореографическими пачками
/datum/round_event/comet_belt/proc/set_ambient_comets()
	for(var/client/C in comet_overlays)
		var/atom/movable/screen/comet_overlay/comet = comet_overlays[C]
		if(!comet?.particles)
			continue
		comet.particles.spawning = 2
		comet.particles.color = "#5898C8"
		comet.particles.scale = generator("num", 0.3, 0.7)
		comet.particles.icon_state = pick("star", "star1", "star2")
		// Разнообразие направлений для фоновых комет
		if(prob(60))
			comet.particles.position = generator("box", list(380, -300, 0), list(520, 300, 0))
			comet.particles.velocity = generator("vector", list(-3.5, -1, 0), list(-1.5, 0.5, 0))
		else if(prob(50))
			comet.particles.position = generator("box", list(-350, 300, 0), list(350, 420, 0))
			comet.particles.velocity = generator("vector", list(-1, -3.5, 0), list(0.5, -1.5, 0))
		else
			comet.particles.position = generator("box", list(-520, -300, 0), list(-380, 300, 0))
			comet.particles.velocity = generator("vector", list(1.5, -1, 0), list(3.5, 0.5, 0))

/datum/round_event/comet_belt/proc/update_dust_dynamics(aF, phase)
	var/target_spawning
	var/target_count
	var/target_alpha

	switch(phase)
		if(1)
			var/p = clamp((aF - 5) / 33.0, 0, 1)
			target_spawning = round(2 + p * 5)
			target_count = round(15 + p * 45)
			target_alpha = round(60 + p * 180)

		if(2)
			target_spawning = 7
			target_count = 60
			target_alpha = 240

		if(3)
			var/breath = sin((aF - 46) / 20.0 * 720)
			target_spawning = round(4 + breath * 3)
			target_count = 60
			target_alpha = round(180 + breath * 60)

		if(4)
			target_spawning = 8
			target_count = 60
			target_alpha = 255

		if(5)
			target_spawning = 5
			target_count = 60
			target_alpha = 220

		if(6)
			var/p = clamp((aF - 96) / 29.0, 0, 1)
			target_spawning = max(0, round(5 * (1 - p)))
			target_count = max(5, round(60 * (1 - p)))
			target_alpha = max(0, round(240 * (1 - p)))

	for(var/client/C in dust_overlays)
		var/atom/movable/screen/comet_dust_overlay/dust = dust_overlays[C]
		if(!dust)
			continue
		if(dust.particles)
			dust.particles.spawning = target_spawning
			dust.particles.count = target_count
		animate(dust, alpha = target_alpha, time = 15)

/// Обновить цвет пыли на всех клиентах
/datum/round_event/comet_belt/proc/update_all_dust_color(col)
	for(var/client/C in dust_overlays)
		var/atom/movable/screen/comet_dust_overlay/dust = dust_overlays[C]
		if(dust?.particles)
			dust.particles.color = col

/datum/round_event/comet_belt/proc/update_belt_stream(col, phase, aF)
	var/target_spawning
	var/target_alpha

	switch(phase)
		if(1) // нарастание
			var/p = clamp((aF - 5) / 33.0, 0, 1)
			target_spawning = round(2 + p * 4)
			target_alpha = round(60 + p * 140)
		if(2) // первые кометы
			target_spawning = 6
			target_alpha = 200
		if(3) // затишье
			target_spawning = 4
			target_alpha = 160
		if(4) // кульминация
			target_spawning = 8
			target_alpha = 230
		if(5) // угасание
			target_spawning = 5
			target_alpha = 180
		if(6) // финал
			var/p = clamp((aF - 96) / 29.0, 0, 1)
			target_spawning = max(0, round(5 * (1 - p)))
			target_alpha = max(0, round(200 * (1 - p)))

	for(var/client/C in belt_stream_overlays)
		var/atom/movable/screen/comet_belt_stream_overlay/belt = belt_stream_overlays[C]
		if(!belt)
			continue
		if(belt.particles)
			belt.particles.spawning = target_spawning
			belt.particles.color = col
		animate(belt, alpha = target_alpha, time = 15)

/datum/round_event/comet_belt/proc/trigger_flash()
	for(var/client/C in comet_overlays)
		if(!C)
			continue
		var/atom/movable/screen/comet_flash/flash = new
		flash_overlays[C] = flash
		C.screen += flash
		flash.do_flash()
		addtimer(CALLBACK(src, PROC_REF(remove_flash), C), 60)

/datum/round_event/comet_belt/proc/remove_flash(client/C)
	if(!C)
		return
	var/atom/movable/screen/comet_flash/flash = flash_overlays[C]
	if(flash)
		C.screen -= flash
		qdel(flash)
	flash_overlays -= C

/datum/round_event/comet_belt/proc/get_gradient_color(position, list/grad)
	position = clamp(position, 0, 1)
	var/prev_pos = grad[1]
	var/prev_color = grad[2]
	for(var/i in 3 to grad.len step 2)
		var/cur_pos = grad[i]
		var/cur_color = grad[i + 1]
		if(position <= cur_pos)
			if(cur_pos == prev_pos)
				return cur_color
			var/t = (position - prev_pos) / (cur_pos - prev_pos)
			return lerp_color(prev_color, cur_color, t)
		prev_pos = cur_pos
		prev_color = cur_color
	return prev_color

/datum/round_event/comet_belt/proc/lerp_color(hex_a, hex_b, t)
	t = clamp(t, 0, 1)
	var/ra = hex_to_num(copytext(hex_a, 2, 4))
	var/ga = hex_to_num(copytext(hex_a, 4, 6))
	var/ba = hex_to_num(copytext(hex_a, 6, 8))
	var/rb = hex_to_num(copytext(hex_b, 2, 4))
	var/gb = hex_to_num(copytext(hex_b, 4, 6))
	var/bb = hex_to_num(copytext(hex_b, 6, 8))
	return rgb(\
		clamp(round(ra + (rb - ra) * t), 0, 255),\
		clamp(round(ga + (gb - ga) * t), 0, 255),\
		clamp(round(ba + (bb - ba) * t), 0, 255)\
	)

/datum/round_event/comet_belt/proc/hex_to_num(hex_pair)
	var/static/list/hex_vals = list(\
		"0"=0, "1"=1, "2"=2, "3"=3, "4"=4, "5"=5, "6"=6, "7"=7,\
		"8"=8, "9"=9, "a"=10, "b"=11, "c"=12, "d"=13, "e"=14, "f"=15,\
		"A"=10, "B"=11, "C"=12, "D"=13, "E"=14, "F"=15\
	)
	return hex_vals[copytext(hex_pair, 1, 2)] * 16 + hex_vals[copytext(hex_pair, 2, 3)]


/datum/round_event/comet_belt/proc/update_space_glow(glow_color, glow_alpha)
	for(var/client/C in glow_overlays)
		var/atom/movable/screen/comet_space_glow/glow = glow_overlays[C]
		if(glow)
			glow.color = glow_color
			animate(glow, alpha = glow_alpha, time = 20)

/datum/round_event/comet_belt/proc/fade_space_glow()
	for(var/client/C in glow_overlays)
		var/atom/movable/screen/comet_space_glow/glow = glow_overlays[C]
		if(glow)
			animate(glow, alpha = 0, time = 60)

/datum/round_event/comet_belt/proc/add_comet_overlays(client/C)
	if(!C)
		return
	if(!comet_overlays[C])
		var/atom/movable/screen/comet_overlay/comet = new
		comet_overlays[C] = comet
		C.screen += comet
		comet.fade_in(20)		// быстрый fade-in — кометы сразу видны
	if(!dust_overlays[C])
		var/atom/movable/screen/comet_dust_overlay/dust = new
		dust_overlays[C] = dust
		C.screen += dust
	if(!belt_stream_overlays[C])
		var/atom/movable/screen/comet_belt_stream_overlay/belt = new
		belt_stream_overlays[C] = belt
		C.screen += belt
		belt.fade_in(40)
	if(!glow_overlays[C])
		var/atom/movable/screen/comet_space_glow/glow = new
		glow_overlays[C] = glow
		C.screen += glow

/datum/round_event/comet_belt/proc/start_fade_out()
	for(var/client/C in comet_overlays)
		var/atom/movable/screen/comet_overlay/comet = comet_overlays[C]
		if(comet)
			comet.fade_out(60)
	for(var/client/C in dust_overlays)
		var/atom/movable/screen/comet_dust_overlay/dust = dust_overlays[C]
		if(dust)
			dust.fade_out(80)
	for(var/client/C in belt_stream_overlays)
		var/atom/movable/screen/comet_belt_stream_overlay/belt = belt_stream_overlays[C]
		if(belt)
			belt.fade_out(80)

/datum/round_event/comet_belt/proc/comet_final_cleanup()
	for(var/client/C in comet_overlays)
		var/atom/movable/screen/comet_overlay/comet = comet_overlays[C]
		if(comet)
			C?.screen -= comet
			qdel(comet)
	comet_overlays.Cut()
	for(var/client/C in dust_overlays)
		var/atom/movable/screen/comet_dust_overlay/dust = dust_overlays[C]
		if(dust)
			C?.screen -= dust
			qdel(dust)
	dust_overlays.Cut()
	for(var/client/C in belt_stream_overlays)
		var/atom/movable/screen/comet_belt_stream_overlay/belt = belt_stream_overlays[C]
		if(belt)
			C?.screen -= belt
			qdel(belt)
	belt_stream_overlays.Cut()
	for(var/client/C in glow_overlays)
		var/atom/movable/screen/comet_space_glow/glow = glow_overlays[C]
		if(glow)
			C?.screen -= glow
			qdel(glow)
	glow_overlays.Cut()
	for(var/client/C in flash_overlays)
		var/atom/movable/screen/comet_flash/flash = flash_overlays[C]
		if(flash)
			C?.screen -= flash
			qdel(flash)
	flash_overlays.Cut()
