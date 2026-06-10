/proc/playsound(atom/source, soundin, vol as num, vary, extrarange as num, falloff_exponent = SOUND_FALLOFF_EXPONENT, frequency = null, channel = 0, pressure_affected = TRUE, ignore_walls = TRUE, falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE, use_reverb = TRUE, distance_multiplier = SOUND_DEFAULT_DISTANCE_MULTIPLIER, distance_multiplier_min_range = SOUND_DEFAULT_MULTIPLIER_EFFECT_RANGE, envwet = -10000, envdry = 0)
	if(isarea(source))
		CRASH("playsound(): source is an area")
	if(islist(soundin))
		CRASH("playsound(): soundin attempted to pass a list! Consider using pick()")
	if(!soundin)
		return
	if(vol < SOUND_AUDIBLE_VOLUME_MIN)
		CRASH("playsound(): volume below SOUND_AUDIBLE_VOLUME_MIN. [vol] < [SOUND_AUDIBLE_VOLUME_MIN]")

	var/turf/turf_source = get_turf(source)
	if(!turf_source)
		return

	channel = channel || SSsounds.random_available_channel()
	var/sound/S = isdatum(soundin) ? soundin : sound(get_sfx(soundin))
	var/maxdistance = SOUND_RANGE + extrarange

	if(falloff_distance >= maxdistance)
		CRASH("playsound(): falloff_distance is equal to or higher than maxdistance! Bump up extrarange or reduce the falloff_distance.")

	if(vary && !frequency)
		frequency = get_rand_frequency()

	var/audible_distance = CALCULATE_MAX_SOUND_AUDIBLE_DISTANCE(vol, maxdistance, falloff_distance, falloff_exponent)
	var/source_z = turf_source.z

	var/list/listeners
	var/turf/above_turf = SSmapping.get_turf_above(turf_source)
	var/turf/below_turf = SSmapping.get_turf_below(turf_source)

	if(ignore_walls)
		listeners = get_hearers_in_range(audible_distance, turf_source)
		if(above_turf && istransparentturf(above_turf))
			listeners += get_hearers_in_range(audible_distance, above_turf)
		if(below_turf && istransparentturf(turf_source))
			listeners += get_hearers_in_range(audible_distance, below_turf)
	else
		listeners = get_hearers_in_view(audible_distance, turf_source)
		if(above_turf && istransparentturf(above_turf))
			listeners += get_hearers_in_view(audible_distance, above_turf)
		if(below_turf && istransparentturf(turf_source))
			listeners += get_hearers_in_view(audible_distance, below_turf)
		for(var/mob/listening_ghost as anything in SSmobs.dead_players_by_zlevel[source_z])
			if(get_dist(listening_ghost, turf_source) <= audible_distance)
				listeners += listening_ghost

	for(var/mob/listening_mob in listeners)
		var/dist = get_dist(listening_mob, turf_source)
		listening_mob.playsound_local(turf_source, soundin, vol, vary, frequency, falloff_exponent, channel, pressure_affected, S, maxdistance, falloff_distance, dist <= distance_multiplier_min_range ? 1 : distance_multiplier, use_reverb, envwet, envdry)

	return listeners

/mob/proc/playsound_local(turf/turf_source, soundin, vol as num, vary, frequency, falloff_exponent = SOUND_FALLOFF_EXPONENT, channel = 0, pressure_affected = TRUE, sound/S, max_distance, falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE, distance_multiplier = SOUND_DEFAULT_DISTANCE_MULTIPLIER, use_reverb = TRUE, envwet = -10000, envdry = 0)
	if(QDELETED(src))
		return
	if(audiovisual_redirect)
		audiovisual_redirect.playsound_local(turf_source, soundin, vol, vary, frequency, falloff_exponent, channel, pressure_affected, S, max_distance, falloff_distance, distance_multiplier, use_reverb, max(0, envwet), -10000)
	if(!client || HAS_TRAIT(src, TRAIT_DEAF))
		return

	if(!S)
		S = sound(get_sfx(soundin))

	S.wait = 0
	S.channel = channel || SSsounds.random_available_channel()
	S.volume = vol

	if(vary)
		if(frequency)
			S.frequency = frequency
		else
			S.frequency = get_rand_frequency()

	var/distance = 0

	if(isturf(turf_source))
		var/turf/turf_loc = get_turf(src)

		distance = get_dist(turf_loc, turf_source) * distance_multiplier

		if(max_distance)
			S.volume -= CALCULATE_SOUND_VOLUME(vol, distance, max_distance, falloff_distance, falloff_exponent)

		if(pressure_affected)
			var/pressure_factor = 1
			var/datum/gas_mixture/hearer_env = turf_loc.return_air()
			var/datum/gas_mixture/source_env = turf_source.return_air()

			if(hearer_env && source_env)
				var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())
				if(pressure < ONE_ATMOSPHERE)
					pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
			else
				pressure_factor = 0

			if(distance <= 1)
				pressure_factor = max(pressure_factor, 0.15)

			S.volume *= pressure_factor

		if(S.volume < SOUND_AUDIBLE_VOLUME_MIN)
			return

		var/dx = turf_source.x - turf_loc.x
		S.x = dx * distance_multiplier
		var/dz = turf_source.y - turf_loc.y
		S.z = dz * distance_multiplier
		var/dy = (turf_source.z - turf_loc.z) * 5 * distance_multiplier
		S.y = dy

		S.falloff = max_distance || 1

		if(sound_environment_override != SOUND_ENVIRONMENT_NONE)
			S.environment = sound_environment_override
		else
			var/area/A = get_area(src)
			S.environment = A.sound_environment

		if(!use_reverb || S.environment == SOUND_ENVIRONMENT_NONE)
			S.echo ||= new /list(18)
			S.echo[3] = -10000
			S.echo[4] = -10000

	if(HAS_TRAIT(src, TRAIT_SOUND_DEBUGGED))
		to_chat(src, span_admin("Max Range-[max_distance] Distance-[distance] Vol-[round(S.volume, 0.01)] Sound-[S.file]"))

	if(HAS_TRAIT(src, TRAIT_AWOO) && iscarbon(src))
		if((S.file == 'modular_citadel/sound/voice/awoo.ogg' || S.file == 'modular_splurt/sound/voice/wolfhowl.ogg') && (distance > 0))
			var/mob/living/carbon/C = src
			var/datum/quirk/awoo/quirk_target = locate() in C.roundstart_quirks
			quirk_target?.do_awoo()

	SEND_SOUND(src, S)

/proc/sound_to_playing_players(soundin, volume = 100, vary = FALSE, frequency = 0, channel = 0, pressure_affected = FALSE, sound/S)
	if(!S)
		S = sound(get_sfx(soundin))
	for(var/m in GLOB.player_list)
		if(ismob(m) && !isnewplayer(m))
			var/mob/M = m
			M.playsound_local(M, null, volume, vary, frequency, null, channel, pressure_affected, S)

/mob/proc/stop_sound_channel(chan)
	if(QDELETED(src) || !isnum(chan) || chan <= 0)
		return
	SEND_SOUND(src, sound(null, repeat = 0, wait = 0, channel = chan))

/mob/proc/set_sound_channel_volume(channel, volume)
	if(QDELETED(src) || !isnum(channel) || channel <= 0)
		return
	var/sound/S = sound(null, FALSE, FALSE, channel, volume)
	S.status = SOUND_UPDATE
	SEND_SOUND(src, S)

/client/proc/playtitlemusic(vol = 85)
	set waitfor = FALSE
	UNTIL(SSticker.login_music)

	if(prefs && (prefs.toggles & SOUND_LOBBY))
		SEND_SOUND(src, sound(SSticker.login_music, repeat = 0, wait = 0, volume = vol, channel = CHANNEL_LOBBYMUSIC))

/proc/get_rand_frequency()
	return rand(32000, 55000)

/proc/get_rand_frequency_low_range()
	return rand(38000, 45000)

/proc/get_sfx(soundin)
	if(!istext(soundin))
		return soundin
	var/datum/sound_effect/sfx = GLOB.sfx_datum_by_key[soundin]
	return sfx?.return_sfx() || soundin
