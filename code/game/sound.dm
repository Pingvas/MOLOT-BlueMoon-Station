/*! playsound

playsound is a proc used to play a 3D sound in a specific range. This uses SOUND_RANGE + extra_range to determine that.

source - Origin of sound
soundin - Either a file, or a string that can be used to get an SFX
vol - The volume of the sound, excluding falloff and pressure affection.
vary - bool that determines if the sound changes pitch every time it plays
extrarange - modifier for sound range. This gets added on top of SOUND_RANGE
falloff_exponent - Rate of falloff for the audio. Higher means quicker drop to low volume.
frequency - playback speed of audio
channel - The channel the sound is played at
pressure_affected - Whether or not difference in pressure affects the sound (E.g. if you can hear in space)
ignore_walls - Whether or not the sound can pass through walls.
falloff_distance - Distance at which falloff begins.

*/

/proc/playsound(atom/source, soundin, vol as num, vary, extrarange as num, falloff_exponent = SOUND_FALLOFF_EXPONENT, frequency = null, channel = 0, pressure_affected = TRUE, ignore_walls = TRUE,
	falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE, envwet = -10000, envdry = 0, priority = SOUND_PRIORITY_NORMAL)
	if(isarea(source))
		CRASH("playsound(): source is an area")

	var/turf/turf_source = get_turf(source)

	if(!turf_source)
		return

	channel = channel || SSsounds.random_available_channel()

	var/sound/premade_sound
	var/resolved_sound
	if(istype(soundin, /sound))
		premade_sound = soundin
	else
		resolved_sound = get_sfx(soundin)

	var/maxdistance = SOUND_RANGE + extrarange
	var/source_z = turf_source.z
	var/turf/above_turf = SSmapping.get_turf_above(turf_source)
	var/turf/below_turf = SSmapping.get_turf_below(turf_source)

	// Кэш звуков давления
	var/datum/gas_mixture/cached_source_air = pressure_affected ? turf_source.return_air() : null

	var/list/listeners
	var/list/extra_listeners_1
	var/list/extra_listeners_2

	if(!ignore_walls)
		listeners = SSmobs.clients_by_zlevel[source_z].Copy()
		listeners = listeners & hearers(maxdistance,turf_source)

		if(above_turf && istransparentturf(above_turf))
			listeners += hearers(maxdistance,above_turf)

		if(below_turf && istransparentturf(turf_source))
			listeners += hearers(maxdistance,below_turf)

	else
		listeners = SSmobs.clients_by_zlevel[source_z]

		if(above_turf && istransparentturf(above_turf))
			extra_listeners_1 = SSmobs.clients_by_zlevel[above_turf.z]

		if(below_turf && istransparentturf(turf_source))
			extra_listeners_2 = SSmobs.clients_by_zlevel[below_turf.z]

	for(var/mob/M as anything in listeners)
		var/dist = get_dist(M, turf_source)
		if(dist <= maxdistance)
			M.playsound_local(turf_source, resolved_sound, vol, vary, frequency, falloff_exponent, channel, pressure_affected, premade_sound, maxdistance, falloff_distance, envwet, envdry, null, cached_source_air, priority)
	for(var/mob/M as anything in extra_listeners_1)
		var/dist = get_dist(M, turf_source)
		if(dist <= maxdistance)
			M.playsound_local(turf_source, resolved_sound, vol, vary, frequency, falloff_exponent, channel, pressure_affected, premade_sound, maxdistance, falloff_distance, envwet, envdry, null, cached_source_air, priority)
	for(var/mob/M as anything in extra_listeners_2)
		var/dist = get_dist(M, turf_source)
		if(dist <= maxdistance)
			M.playsound_local(turf_source, resolved_sound, vol, vary, frequency, falloff_exponent, channel, pressure_affected, premade_sound, maxdistance, falloff_distance, envwet, envdry, null, cached_source_air, priority)
	for(var/mob/M as anything in SSmobs.dead_players_by_zlevel[source_z])
		var/dist = get_dist(M, turf_source)
		if(dist <= maxdistance)
			M.playsound_local(turf_source, resolved_sound, vol, vary, frequency, falloff_exponent, channel, pressure_affected, premade_sound, maxdistance, falloff_distance, envwet, envdry, null, cached_source_air, priority)

/*! playsound_local

playsound_local is a proc used to play a sound directly on a mob from a specific turf.
This is called by playsound to send sounds to players, in which case it also gets the max_distance of that sound.

turf_source - Origin of sound
soundin - Either a file, or a string that can be used to get an SFX
vol - The volume of the sound, excluding falloff
vary - bool that determines if the sound changes pitch every time it plays
frequency - playback speed of audio
falloff_exponent - Rate of falloff for the audio
channel - The channel the sound is played at
pressure_affected - Whether or not difference in pressure affects the sound
max_distance - The max range of the sound
falloff_distance - Distance at which falloff begins

*/

/mob/proc/playsound_local(turf/turf_source, soundin, vol as num, vary, frequency, falloff_exponent = SOUND_FALLOFF_EXPONENT, channel = 0, pressure_affected = TRUE, sound/S, max_distance,
	falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE, envwet = -10000, envdry = 0, virtual_hearer, datum/gas_mixture/cached_source_air, priority = SOUND_PRIORITY_NORMAL, use_reverb = TRUE)
	if(QDELETED(src))
		return
	if(audiovisual_redirect)
		virtual_hearer = get_turf(src)
		audiovisual_redirect.playsound_local(turf_source, soundin, vol, vary, frequency, falloff_exponent, channel, pressure_affected, S, max_distance, falloff_distance, max(0, envwet), -10000, virtual_hearer, null, priority, use_reverb)
	if(!client)
		return

	if(!S)
		if(!soundin)
			return
		if(istype(soundin, /sound))
			S = soundin
		else
			S = sound(get_sfx(soundin))

	if(!can_hear() && !(S.status & SOUND_UPDATE))
		return

	S.wait = 0
	if(!isnum(channel) || channel <= 0)
		channel = SSsounds.random_available_channel()
	if(!channel)
		return
	S.channel = channel
	S.volume = vol

	if(vary)
		if(frequency)
			S.frequency = frequency
		else
			S.frequency = get_rand_frequency()

	if(isturf(turf_source))
		var/turf/T = virtual_hearer || get_turf(src)
		var/distance = get_dist(T, turf_source)

		// Pressure affects base volume (atmospheric attenuation)
		if(pressure_affected)
			var/pressure_factor = 1
			var/datum/gas_mixture/hearer_env = T.return_air()
			var/datum/gas_mixture/source_env = cached_source_air || turf_source.return_air()

			if(hearer_env && source_env)
				var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())
				if(pressure < ONE_ATMOSPHERE)
					pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
			else
				pressure_factor = 0

			if(distance <= 1)
				pressure_factor = max(pressure_factor, 0.15)

			S.volume *= pressure_factor

		if(S.volume <= 0)
			return

		// 3д позиционирование
		var/dx = turf_source.x - T.x
		S.x = dx
		var/dy = turf_source.y - T.y
		S.y = dy
		var/dz = (turf_source.z - T.z) * 5
		S.z = dz

		if(max_distance > 0)
			S.falloff = max(vol, 0) / max(max_distance, 1)
		else
			S.falloff = FALLOFF_SOUNDS

		// Зависимость зон к ревербу
		var/area/source_area = get_area(turf_source)
		var/area_environment = source_area?.sound_environment
		if(!isnum(area_environment) || area_environment == SOUND_ENVIRONMENT_NONE)
			var/area/hearer_area = get_area(T)
			area_environment = hearer_area?.sound_environment
		if(!isnum(area_environment) || area_environment == SOUND_ENVIRONMENT_NONE)
			area_environment = SOUND_ENVIRONMENT_GENERIC

		S.environment = area_environment

		// Овверайды к эху зон
		if(envwet == -10000 && envdry == 0)
			S.echo = get_sound_environment_echo(area_environment, distance, max_distance)
		else
			S.echo = list(envdry, null, envwet, null, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7)

		if(HAS_TRAIT(src, TRAIT_AWOO)  && iscarbon(src))
			if((S.file == 'modular_citadel/sound/voice/awoo.ogg' || S.file == 'modular_splurt/sound/voice/wolfhowl.ogg') && (distance > 0))
				var/mob/living/carbon/C = src
				var/datum/quirk/awoo/quirk_target = locate() in C.roundstart_quirks
				quirk_target.do_awoo()

	SEND_SOUND(src, S)

/proc/sound_to_playing_players(soundin, volume = 100, vary = FALSE, frequency = 0, channel = 0, pressure_affected = FALSE, sound/S)
	if(!S)
		S = sound(get_sfx(soundin))
	for(var/mob/M as anything in GLOB.player_list)
		if(!isnewplayer(M))
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

/// Echo presets for each sound environment
/// echo = list(direct, directHF, room, roomHF, obstruction, obstructionLFRatio, occlusion, occlusionLFRatio,
///             occlusionRoomRatio, occlusionDirectRatio, exclusion, exclusionLFRatio, outsideVolumeHF,
///             dopplerFactor, rolloffFactor, roomRolloffFactor, airAbsorptionFactor, flags)
GLOBAL_LIST_INIT(sound_environment_echo, list(
	// SOUND_ENVIRONMENT_NONE — minimal processing
	"-1" = list(0, null, -5000, null, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	"0"  = list(0, null, -10000, null, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_PADDED_CELL — глухая комната, почти без реверберации
	"1"  = list(0, null, -6000, -3000, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_ROOM — небольшая комната, лёгкое эхо
	"2"  = list(0, null, -800, -150, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_BATHROOM — кафель, звонкое эхо
	"3"  = list(0, null, -400, -30, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_LIVINGROOM — мягкая мебель, тёплое эхо
	"4"  = list(0, null, -1000, -400, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_STONEROOM — камень, среднее эхо
	"5"  = list(0, null, -500, -100, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_AUDITORIUM — большое помещение, длинное эхо
	"6"  = list(0, null, -300, -200, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_CONCERT_HALL — очень длинное чистое эхо
	"7"  = list(0, null, -150, -300, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_CAVE — длинное тёмное эхо
	"8"  = list(0, null, -500, -600, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_ARENA — огромное пространство
	"9"  = list(0, null, -200, -400, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_HANGAR — сильный металлический ревербератор (тех-зоны)
	"10" = list(0, null, -250, -50, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_CARPETED_HALLWAY — мягкий коридор
	"11" = list(0, null, -800, -400, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_HALLWAY — жёсткий коридор
	"12" = list(0, null, -500, -150, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_STONE_CORRIDOR — каменный коридор
	"13" = list(0, null, -400, -300, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_ALLEY — узкая улица, небольшое эхо
	"14" = list(0, null, -1500, -400, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_FOREST — открытая природа, минимум эха
	"15" = list(0, null, -4000, -1500, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_CITY — городская среда
	"16" = list(0, null, -1500, -800, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_MOUNTAINS — большое открытое пространство, отчётливое эхо
	"17" = list(0, null, -500, -600, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_QUARRY — индустриальный карьер (тех-зоны)
	"18" = list(0, null, -500, -200, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_PLAIN — открытое поле
	"19" = list(0, null, -6000, null, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_PARKING_LOT — открытое бетонное пространство (тех-зоны)
	"20" = list(0, null, -1500, -500, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_SEWER_PIPE — металлическая труба, звонкое эхо (тех-зоны)
	"21" = list(0, null, -350, -30, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_UNDERWATER — под водой, глухо
	"22" = list(0, null, -6000, null, null, null, null, null, null, null, null, null, null, 1, 0.3, 0.3, null, 7),
	// SOUND_ENVIRONMENT_DRUGGED — странное эхо
	"23" = list(0, null, -300, -800, null, null, null, null, null, null, null, null, null, 1, 2, 1, null, 7),
	// SOUND_ENVIRONMENT_DIZZY — дезориентирующее эхо
	"24" = list(0, null, -300, -1500, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
	// SOUND_ENVIRONMENT_PSYCHOTIC — экстремальное эхо
	"25" = list(0, null, -100, -3000, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7),
))

/proc/get_sound_environment_echo(environment, distance = 0, max_distance = 0)
	var/list/echo = GLOB.sound_environment_echo[num2text(environment)]
	if(!echo)
		return list(0, null, -10000, null, null, null, null, null, null, null, null, null, null, 1, 1, 1, null, 7)

	if(!max_distance || !distance)
		return echo

	var/distance_ratio = min(distance / max(max_distance, 1), 1)
	var/list/copy = echo.Copy()
	if(length(copy) >= 3)
		var/room_val = copy[3]
		if(isnum(room_val) && room_val < 0)
			copy[3] = round(room_val + (room_val * distance_ratio * 0.3))
	return copy

/proc/get_rand_frequency()
	return rand(32000, 55000)

///get_rand_frequency but lower range.
/proc/get_rand_frequency_low_range()
	return rand(38000, 45000)

///Used to convert a SFX define into a .ogg so we can add some variance to sounds. If soundin is already a .ogg, we simply return it
/proc/get_sfx(soundin)
	if(!istext(soundin))
		return soundin
	var/datum/sound_effect/sfx = GLOB.sfx_datum_by_key[soundin]
	return sfx?.return_sfx() || soundin
