SUBSYSTEM_DEF(ambience)
	name = "Ambience"
	flags = SS_BACKGROUND|SS_NO_INIT
	priority = FIRE_PRIORITY_AMBIENCE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 1 SECONDS
	var/list/ambience_listening_clients = list()
	var/list/client_old_areas = list()
	var/list/currentrun = list()

/datum/controller/subsystem/ambience/fire(resumed)
	if(!resumed)
		currentrun = ambience_listening_clients.Copy()
	var/list/cached_clients = currentrun

	while(cached_clients.len)
		var/client/client_iterator = cached_clients[cached_clients.len]
		cached_clients.len--

		var/mob/client_mob = client_iterator?.mob
		if(isnull(client_iterator) || !client_mob || isnewplayer(client_mob))
			ambience_listening_clients -= client_iterator
			client_old_areas -= client_iterator
			continue

		if(HAS_TRAIT(client_mob, TRAIT_DEAF))
			continue

		var/area/current_area = get_area(client_mob)
		if(!current_area)
			stack_trace("[key_name(client_mob)] has somehow ended up in nullspace. WTF did you do")
			remove_ambience_client(client_iterator)
			continue

		if(ambience_listening_clients[client_iterator] > world.time)
			if(!(current_area.forced_ambience && (client_old_areas?[client_iterator] != current_area) && prob(5)))
				continue

		ambience_listening_clients[client_iterator] = world.time + current_area.play_ambience(client_mob)

		if(client_iterator)
			client_old_areas[client_iterator] = current_area

		if(MC_TICK_CHECK)
			return

/area/proc/play_ambience(mob/M, sound/override_sound, volume = 27)
	var/sound/new_sound = override_sound || pick(ambientsounds)
	if(!new_sound)
		return 1 MINUTES
	new_sound = sound(new_sound, repeat = 0, wait = 0, volume = volume, channel = CHANNEL_AMBIENCE)
	SEND_SOUND(M, new_sound)

	var/sound_length = SSsounds.get_sound_length(new_sound.file)
	if(!sound_length)
		stack_trace("play_ambience failed to get soundlength from [new_sound] with a file of [new_sound.file].")
	return sound_length + rand(min_ambience_cooldown, max_ambience_cooldown)

/datum/controller/subsystem/ambience/proc/remove_ambience_client(client/to_remove)
	ambience_listening_clients -= to_remove
	client_old_areas -= to_remove
	currentrun -= to_remove
