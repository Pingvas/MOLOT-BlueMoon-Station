
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
	start_when = 6
	end_when = 127
	var/current_phase = 0
	var/list/comet_overlays = list()
	var/list/dust_overlays = list()
	var/list/flash_overlays = list()
	var/finale_announced = FALSE

	var/static/list/choreography = list(\
		/* первые кометы*/\
		list(39,  8,  "#78C8E8", 0.6, 1.2,  -6,  -3),\
		list(41, 10,  "#60B8E0", 0.7, 1.5,  -7,  -3.5),\
		list(43,  8,  "#90D0F0", 0.8, 1.4,  -6.5,-3.2),\
		list(45, 12,  "#A0DBFF", 0.9, 1.8,  -7.5,-4),\
		/* спам*/\
		list(67, 15,  "#FFFFFF", 1.5, 3.0,  -10, -5),\
		list(68, 12,  "#FFE8C0", 1.3, 2.8,  -9,  -4.5),\
		list(69, 18,  "#FFD080", 1.8, 3.5,  -11, -5.5),\
		list(70, 25,  "#FFFFFF", 2.0, 4.0,  -12, -6),\
		list(72, 15,  "#FFC060", 1.5, 3.2,  -10, -5),\
		list(74, 20,  "#FFE0A0", 1.8, 3.8,  -11, -5.5),\
		list(76, 12,  "#C8E8FF", 1.2, 2.5,  -8,  -4),\
		list(78, 15,  "#FFB040", 1.4, 3.0,  -9,  -4.5),\
		list(80, 10,  "#E8D8B0", 1.0, 2.2,  -7,  -3.5),\
		list(82,  8,  "#A8D0F0", 0.9, 2.0,  -6.5,-3.2),\
		list(84,  6,  "#88BBE0", 0.8, 1.8,  -6,  -3),\
		list(86,  5,  "#70A0D0", 0.7, 1.5,  -5.5,-2.8),\
		/* конечная*/\
		list(87, 10,  "#6898C8", 0.8, 1.8,  -7,  -3.5),\
		list(89,  8,  "#78A8D8", 0.7, 1.5,  -6,  -3),\
		list(91, 12,  "#5090C0", 0.9, 2.0,  -7.5,-3.8),\
		list(93,  6,  "#4080B0", 0.6, 1.3,  -5.5,-2.8),\
		list(95,  4,  "#3070A0", 0.5, 1.0,  -5,  -2.5)\
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
	for(var/client/C in GLOB.clients)
		if(!C.mob || !is_station_level(C.mob.z))
			continue
		add_comet_overlays(C)
	transition_to_phase(1)

/datum/round_event/comet_belt/tick()
	var/new_phase
	switch(activeFor)
		if(6 to 38)
			new_phase = 1
		if(39 to 46)
			new_phase = 2
		if(47 to 66)
			new_phase = 3
		if(67 to 86)
			new_phase = 4
		if(87 to 96)
			new_phase = 5
		else
			new_phase = 6

	if(new_phase != current_phase)
		transition_to_phase(new_phase)

	var/progress = clamp((activeFor - 6) / 120.0, 0, 1)
	var/dust_col = get_gradient_color(progress, dust_color_gradient)
	update_all_dust_color(dust_col)

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
	comet_final_cleanup()
	fade_space_light()

// ═══════════════════ ФАЗЫ ═══════════════════

/datum/round_event/comet_belt/proc/transition_to_phase(phase)
	current_phase = phase

	switch(phase)
		if(1)
			update_space_light("#282050", 0.12)

		if(2)
			update_space_light("#4888B8", 0.3)

		if(3)
			update_space_light("#486080", 0.18)

		if(4)
			update_space_light("#FFE898", 0.85)
			trigger_flash()
			addtimer(CALLBACK(src, PROC_REF(trigger_flash)), 60)

		if(5)
			update_space_light("#6090B8", 0.4)

		if(6)
			if(!finale_announced)
				finale_announced = TRUE
				priority_announce("Кометный пояс удаляется за пределы видимости. Благодарим за внимание к этому астрономическому явлению. Возвращайтесь к своим обязанностям.",\
				sound = 'sound/misc/notice2.ogg',\
				sender_override = "Отдел Астрономии NanoTrasen")
			addtimer(CALLBACK(src, PROC_REF(start_fade_out)), 60)
			fade_space_light()


// Запустить пачку комет с уникальными параметрами
/datum/round_event/comet_belt/proc/fire_comet_burst(list/burst)
	var/burst_spawning = burst[2]
	var/burst_color = burst[3]
	var/sc_min = burst[4]
	var/sc_max = burst[5]
	var/vx_min = burst[6]
	var/vx_max = burst[7]

	for(var/client/C in comet_overlays)
		var/atom/movable/screen/comet_overlay/comet = comet_overlays[C]
		if(!comet?.particles)
			continue
		comet.particles.spawning = burst_spawning
		comet.particles.color = burst_color
		comet.particles.scale = generator("num", sc_min, sc_max)
		comet.particles.velocity = generator("vector", list(vx_min, vx_min * 0.3, 0), list(vx_max, vx_max * 0.15, 0))

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
		comet.particles.color = "#8AB8D8"
		comet.particles.scale = generator("num", 0.3, 0.7)
		comet.particles.velocity = generator("vector", list(-4, -1.2, 0), list(-2, -0.4, 0))

/datum/round_event/comet_belt/proc/update_dust_dynamics(aF, phase)
	var/target_spawning
	var/target_count
	var/target_alpha

	switch(phase)
		if(1)
			var/p = clamp((aF - 6) / 32.0, 0, 1)
			target_spawning = round(2 + p * 5)
			target_count = round(15 + p * 45)
			target_alpha = round(60 + p * 180)

		if(2)
			target_spawning = 7
			target_count = 60
			target_alpha = 240

		if(3)
			var/breath = sin((aF - 47) / 19.0 * 720)
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
			var/p = clamp((aF - 97) / 29.0, 0, 1)
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

/datum/round_event/comet_belt/proc/trigger_flash()
	for(var/client/C in comet_overlays)
		if(!C)
			continue
		var/atom/movable/screen/comet_flash/flash = new
		flash_overlays[C] = flash
		C.screen += flash
		flash.do_flash()
		addtimer(CALLBACK(src, PROC_REF(remove_flash), C), 40)

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


/datum/round_event/comet_belt/proc/update_space_light(light_color, light_pow)
	for(var/area in GLOB.sortedAreas)
		var/area/A = area
		if(initial(A.dynamic_lighting) == DYNAMIC_LIGHTING_IFSTARLIGHT)
			for(var/turf/open/space/S in A)
				S.set_light(2 + light_pow * 3, light_pow, light_color)

/datum/round_event/comet_belt/proc/fade_space_light()
	for(var/area in GLOB.sortedAreas)
		var/area/A = area
		if(initial(A.dynamic_lighting) == DYNAMIC_LIGHTING_IFSTARLIGHT)
			for(var/turf/open/space/S in A)
				fade_single_light(S)

/datum/round_event/comet_belt/proc/fade_single_light(turf/open/space/S)
	var/target = initial(S.light_range)
	var/steps = round((S.light_range - target) / 0.3)
	if(steps <= 0)
		S.set_light(target, initial(S.light_power), initial(S.light_color))
		return
	for(var/i in 1 to steps)
		addtimer(CALLBACK(S, TYPE_PROC_REF(/atom, set_light), S.light_range - 0.3 * i), i * 20)
	addtimer(CALLBACK(S, TYPE_PROC_REF(/atom, set_light), target, initial(S.light_power), initial(S.light_color)), (steps + 1) * 20)

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

/datum/round_event/comet_belt/proc/start_fade_out()
	for(var/client/C in comet_overlays)
		var/atom/movable/screen/comet_overlay/comet = comet_overlays[C]
		if(comet)
			comet.fade_out(60)
	for(var/client/C in dust_overlays)
		var/atom/movable/screen/comet_dust_overlay/dust = dust_overlays[C]
		if(dust)
			dust.fade_out(80)

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
	for(var/client/C in flash_overlays)
		var/atom/movable/screen/comet_flash/flash = flash_overlays[C]
		if(flash)
			C?.screen -= flash
			qdel(flash)
	flash_overlays.Cut()
