/datum/looping_sound
	var/mid_sounds
	var/mid_length
	var/mid_length_vary = 0
	var/each_once = FALSE
	var/in_order = FALSE
	var/start_volume
	var/start_sound
	var/start_length
	var/end_volume
	var/end_sound
	var/chance
	var/volume = 100
	var/vary = FALSE
	var/max_loops
	var/direct
	var/extra_range = 0
	var/falloff_exponent
	var/falloff_distance
	var/pressure_affected = TRUE
	var/use_reverb = TRUE
	var/ignore_walls = TRUE
	var/skip_starting_sounds = FALSE

	var/atom/parent
	var/timer_id
	var/loop_started = FALSE
	var/list/cut_list
	var/audio_index = 0
	var/sound_channel
	var/reserve_random_channel = FALSE
	var/reserved_channel

/datum/looping_sound/New(_parent, start_immediately = FALSE, _direct = FALSE, _skip_starting_sounds = FALSE, sound_channel)
	if(!mid_sounds)
		WARNING("A looping sound datum was created without sounds to play.")
		return

	set_parent(_parent)
	direct = _direct
	skip_starting_sounds = _skip_starting_sounds
	if(sound_channel)
		src.sound_channel = sound_channel

	if(start_immediately)
		start()

/datum/looping_sound/Destroy()
	stop(TRUE)
	return ..()

/datum/looping_sound/proc/start(on_behalf_of)
	if(on_behalf_of)
		set_parent(on_behalf_of)
	if(timer_id)
		return

	if(!sound_channel && reserve_random_channel)
		sound_channel = SSsounds.reserve_sound_channel_datumless()
		reserved_channel = sound_channel

	on_start()

/datum/looping_sound/proc/stop(null_parent = FALSE)
	stop_current()
	if(null_parent)
		set_parent(null)
	if(!timer_id)
		return
	on_stop()
	deltimer(timer_id, SSsound_loops)
	timer_id = null
	loop_started = FALSE

	if(reserved_channel)
		sound_channel = null
		SSsounds.free_sound_channel(reserved_channel)

/datum/looping_sound/proc/start_sound_loop()
	loop_started = TRUE
	sound_loop()
	timer_id = addtimer(CALLBACK(src, PROC_REF(sound_loop), world.time), mid_length, TIMER_CLIENT_TIME | TIMER_STOPPABLE | TIMER_LOOP | TIMER_DELETE_ME, SSsound_loops)

/datum/looping_sound/proc/sound_loop(start_time)
	if(max_loops && world.time >= start_time + mid_length * max_loops)
		stop()
		return
	if(!chance || prob(chance))
		play(get_sound())

/datum/looping_sound/proc/set_mid_length(new_mid)
	mid_length = new_mid

/datum/looping_sound/proc/play(soundfile, volume_override)
	if(!parent)
		return
	var/sound/sound_to_play = sound(soundfile)
	sound_to_play.channel = sound_channel || SSsounds.random_available_channel()
	sound_to_play.volume = volume_override || volume
	if(direct)
		SEND_SOUND(parent, sound_to_play)
	else
		playsound(
			parent,
			sound_to_play,
			volume,
			vary,
			extra_range,
			falloff_exponent = falloff_exponent,
			channel = sound_to_play.channel,
			pressure_affected = pressure_affected,
			ignore_walls = ignore_walls,
			falloff_distance = falloff_distance,
			use_reverb = use_reverb,
		)

/datum/looping_sound/proc/get_sound(_mid_sounds)
	var/list/play_from = _mid_sounds || mid_sounds
	if(!each_once)
		. = play_from
		while(!isfile(.) && !isnull(.))
			. = pickweight(.)
		return .

	if(in_order)
		. = play_from
		audio_index++
		if(audio_index > length(play_from))
			audio_index = 1
		return .[audio_index]

	if(!length(cut_list))
		cut_list = shuffle(play_from.Copy())
	var/list/tree = list()
	. = cut_list
	while(!isfile(.) && !isnull(.))
		tree += list(.)
		. = pickweight(.)

	if(!isfile(.))
		return

	tree[length(tree)] -= .
	for(var/i in length(tree) to 2 step -1)
		var/list/branch = tree[i]
		if(length(branch))
			break
		tree[i - 1] -= list(branch)
	return .

/datum/looping_sound/proc/on_start()
	var/start_wait = 0
	if(start_sound && !skip_starting_sounds)
		play(start_sound, start_volume)
		start_wait = start_length
	if(start_wait)
		timer_id = addtimer(CALLBACK(src, PROC_REF(start_sound_loop)), start_wait, TIMER_CLIENT_TIME | TIMER_DELETE_ME | TIMER_STOPPABLE, SSsound_loops)
	else
		start_sound_loop()

/datum/looping_sound/proc/stop_current()
	if(!sound_channel || !ismob(parent))
		return
	var/mob/mob_parent = parent
	mob_parent.stop_sound_channel(sound_channel)

/datum/looping_sound/proc/on_stop()
	if(end_sound && loop_started)
		play(end_sound, end_volume)

/datum/looping_sound/proc/set_parent(new_parent)
	if(parent)
		UnregisterSignal(parent, COMSIG_PARENT_QDELETING)
	parent = new_parent
	if(parent)
		RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(handle_parent_del))

/datum/looping_sound/proc/is_active()
	return !!timer_id

/datum/looping_sound/proc/handle_parent_del(datum/source)
	SIGNAL_HANDLER
	set_parent(null)
