#define DATUMLESS "NO_DATUM"

SUBSYSTEM_DEF(sounds)
	name = "Sounds"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_SOUNDS
	var/static/using_channels_max = CHANNEL_HIGHEST_AVAILABLE
	var/static/random_channels_min = 50

	var/list/using_channels
	var/list/using_channels_by_datum
	var/list/channel_list
	var/list/reserved_channels
	var/channel_random_low
	var/channel_reserve_high

	var/list/all_sounds
	VAR_PRIVATE/list/sound_lengths
	VAR_PRIVATE/list/sounds_to_precache = list()
	VAR_PRIVATE/list/precache_errors = list()

	var/static/list/byond_sound_formats = list(
		"mid" = TRUE,
		"midi" = TRUE,
		"mod" = TRUE,
		"it" = TRUE,
		"s3m" = TRUE,
		"xm" = TRUE,
		"oxm" = TRUE,
		"wav" = TRUE,
		"ogg" = TRUE,
		"wma" = TRUE,
		"aiff" = TRUE,
		"mp3" = TRUE
	)

	var/static/list/safe_formats = list(
		"ogg" = TRUE,
		"mp3" = TRUE
	)

	VAR_PRIVATE/static/list/byond_sound_extensions = list(
		".ogg",
		".mp3",
		".mid",
		".midi",
		".mod",
		".it",
		".s3m",
		".oxm",
		".wav",
		".wma",
		".aiff"
	)

/datum/controller/subsystem/sounds/Initialize()
	setup_available_channels()
	find_all_available_sounds()
	init_sound_keys()

	if(RUST_G)
		precache_sounds()

	return ..()

/datum/controller/subsystem/sounds/proc/setup_available_channels()
	channel_list = list()
	reserved_channels = list()
	using_channels = list()
	using_channels_by_datum = list()
	for(var/i in 1 to using_channels_max)
		channel_list += i
	channel_random_low = 1
	channel_reserve_high = length(channel_list)

/datum/controller/subsystem/sounds/proc/find_all_available_sounds()
	all_sounds = list()
	all_sounds = pathwalk("sound/")

/datum/controller/subsystem/sounds/proc/free_sound_channel(channel)
	var/text_channel = num2text(channel)
	var/using = using_channels[text_channel]
	using_channels -= text_channel
	if(using != TRUE)
		using_channels_by_datum[using] -= channel
		if(!length(using_channels_by_datum[using]))
			using_channels_by_datum -= using
	free_channel(channel)

/datum/controller/subsystem/sounds/proc/free_datum_channels(datum/D)
	var/list/L = using_channels_by_datum[D]
	if(!L)
		return
	for(var/channel in L)
		using_channels -= num2text(channel)
		free_channel(channel)
	using_channels_by_datum -= D

/datum/controller/subsystem/sounds/proc/free_datumless_channels()
	free_datum_channels(DATUMLESS)

/datum/controller/subsystem/sounds/proc/reserve_sound_channel_datumless()
	. = reserve_channel()
	if(!.)
		return FALSE
	var/text_channel = num2text(.)
	using_channels[text_channel] = DATUMLESS
	LAZYINITLIST(using_channels_by_datum[DATUMLESS])
	using_channels_by_datum[DATUMLESS] += .

/datum/controller/subsystem/sounds/proc/reserve_sound_channel(datum/D)
	if(!D)
		CRASH("Attempted to reserve sound channel without datum using the managed proc.")
	.= reserve_channel()
	if(!.)
		return FALSE
	var/text_channel = num2text(.)
	using_channels[text_channel] = D
	LAZYINITLIST(using_channels_by_datum[D])
	using_channels_by_datum[D] += .

/datum/controller/subsystem/sounds/proc/reserve_channel()
	PRIVATE_PROC(TRUE)
	if(channel_reserve_high <= random_channels_min)
		return
	var/channel = channel_list[channel_reserve_high]
	reserved_channels[num2text(channel)] = channel_reserve_high--
	return channel

/datum/controller/subsystem/sounds/proc/free_channel(number)
	PRIVATE_PROC(TRUE)
	var/text_channel = num2text(number)
	var/index = reserved_channels[text_channel]
	if(!index)
		CRASH("Attempted to (internally) free a channel that wasn't reserved.")
	reserved_channels -= text_channel
	channel_reserve_high++
	channel_list.Swap(channel_reserve_high, index)
	var/text_reserved = num2text(channel_list[index])
	if(!reserved_channels[text_reserved])
		return
	reserved_channels[text_reserved] = index

/datum/controller/subsystem/sounds/proc/random_available_channel_text()
	if(channel_random_low > channel_reserve_high)
		channel_random_low = 1
	. = "[channel_list[channel_random_low++]]"

/datum/controller/subsystem/sounds/proc/random_available_channel()
	if(channel_random_low > channel_reserve_high)
		channel_random_low = 1
	. = channel_list[channel_random_low++]

/datum/controller/subsystem/sounds/proc/available_channels_left()
	return length(channel_list) - random_channels_min

/datum/controller/subsystem/sounds/proc/precache_sounds()
	if(!length(sounds_to_precache))
		return

	var/list/lengths = rustg_sound_length_list(sounds_to_precache)
	precache_errors = lengths[RUSTG_SOUNDLEN_ERRORS]
	sound_lengths = lengths[RUSTG_SOUNDLEN_SUCCESSES]
	for(var/sound_path in sound_lengths)
		sound_lengths[sound_path] = text2num(sound_lengths[sound_path])

	sounds_to_precache = null

/datum/controller/subsystem/sounds/proc/cache_sounds(list/paths)
	var/list/reconstructed = list()
	reconstructed.len = length(paths)
	for(var/i in 1 to length(paths))
		reconstructed[i] = "[paths[i]]"

	var/list/out = rustg_sound_length_list(paths)
	var/list/successes = out[RUSTG_SOUNDLEN_SUCCESSES]
	for(var/sound_path in successes)
		sound_lengths[sound_path] = text2num(successes[sound_path])

/datum/controller/subsystem/sounds/proc/get_sound_length(file_path)
	. = 0
	if(!istext(file_path))
		if(!isfile(file_path))
			CRASH("rustg_sound_length error: Passed non-text object")
		if(length("[file_path]"))
			file_path = "[file_path]"
		else
			CRASH("rustg_sound_length does not support non-static file refs.")

	var/cached_length = sound_lengths[file_path]
	if(!isnull(cached_length))
		return cached_length

	var/ret = RUSTG_CALL(RUST_G, "sound_len")(file_path)
	var/as_num = text2num(ret)
	if(isnull(ret))
		. = 0
		CRASH("rustg_sound_length error: [ret]")

	sound_lengths[file_path] = as_num
	return as_num

/datum/controller/subsystem/sounds/proc/init_sound_keys()
	for(var/datum/sound_effect/sfx as anything in subtypesof(/datum/sound_effect))
		if(!isnull(sfx.key))
			GLOB.sfx_datum_by_key[sfx.key] = new sfx()

#undef DATUMLESS
