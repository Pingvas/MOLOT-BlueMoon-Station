/// Этапы для fire loop.
#define SSMACHINES_POWERNETS 1
#define SSMACHINES_MACHINES_EARLY 2
#define SSMACHINES_APCS 3
#define SSMACHINES_MACHINES 4
#define SSMACHINES_MACHINES_LATE 5

SUBSYSTEM_DEF(machines)
	name = "Machines"
	init_order = INIT_ORDER_MACHINES
	flags = SS_KEEP_TIMING
	wait = 2 SECONDS

	/// Assosciative list of all machines that exist.
	VAR_PRIVATE/list/machines_by_type = list()

	/// All machines, not just those that are processing.
	VAR_PRIVATE/list/all_machines = list()

	var/list/processing = list()
	var/list/processing_early = list()
	var/list/processing_late = list()
	var/list/processing_apcs = list()
	var/list/currentrun = list()
	var/current_part = SSMACHINES_POWERNETS
	///List of all powernets on the server.
	var/list/datum/powernet/powernets = list()
	var/static/list/bluespaceminer_by_zlevel[][] //BLUEMOON ADD счётчик бс майнеров на z уровне

/datum/controller/subsystem/machines/Initialize()
	makepowernets()
	fire()
	return ..()

//BLUEMOON ADD счётчик бс майнеров на z уровне
/datum/controller/subsystem/machines/proc/MaxZChanged()
	if (!islist(bluespaceminer_by_zlevel))
		bluespaceminer_by_zlevel = new /list(world.maxz,0)
	while (SSmachines.bluespaceminer_by_zlevel.len < world.maxz)
		SSmachines.bluespaceminer_by_zlevel.len++
		SSmachines.bluespaceminer_by_zlevel[bluespaceminer_by_zlevel.len] = list()
//BLUEMOON ADD END

/datum/controller/subsystem/machines/proc/makepowernets()
	for(var/datum/powernet/power_network as anything in powernets)
		qdel(power_network)
	powernets.Cut()

	for(var/obj/structure/cable/power_cable as anything in GLOB.cable_list)
		if(!power_cable.powernet)
			var/datum/powernet/new_powernet = new()
			new_powernet.add_cable(power_cable)
			propagate_network(power_cable, power_cable.powernet)

/datum/controller/subsystem/machines/fire(resumed = FALSE)
	if (!resumed)
		current_part = SSMACHINES_POWERNETS
		for(var/datum/powernet/powernet as anything in powernets)
			if(!powernet.is_empty())
				powernet.reset()
		src.currentrun = processing_early.Copy()
		current_part = SSMACHINES_MACHINES_EARLY
		if (MC_TICK_CHECK)
			return

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	//Early processing machines
	if(current_part == SSMACHINES_MACHINES_EARLY)
		while(currentrun.len)
			var/obj/machinery/thing = currentrun[currentrun.len]
			currentrun.len--
			if(QDELETED(thing) || thing.process_early(wait * 0.1) == PROCESS_KILL)
				processing_early -= thing
				if (!QDELETED(thing))
					thing.datum_flags &= ~DF_ISPROCESSING
			if(!QDELETED(thing) && thing.use_power != thing.static_power_mode)
				thing.update_current_power_usage()
			if (MC_TICK_CHECK)
				return
		current_part = SSMACHINES_APCS
		currentrun = processing_apcs.Copy()
		src.currentrun = currentrun
		if (MC_TICK_CHECK)
			return

	//APC processing stage
	if(current_part == SSMACHINES_APCS)
		while(currentrun.len)
			var/obj/machinery/power/apc/apc = currentrun[currentrun.len]
			currentrun.len--
			if(QDELETED(apc) || apc.process(wait * 0.1) == PROCESS_KILL)
				processing_apcs -= apc
				if (!QDELETED(apc))
					apc.datum_flags &= ~DF_ISPROCESSING
			else if(apc.use_power != apc.static_power_mode)
				apc.update_current_power_usage()
			if (MC_TICK_CHECK)
				return
		current_part = SSMACHINES_MACHINES
		currentrun = processing.Copy()
		src.currentrun = currentrun
		if (MC_TICK_CHECK)
			return

	//Main machine processing
	if(current_part == SSMACHINES_MACHINES)
		while(currentrun.len)
			var/obj/machinery/thing = currentrun[currentrun.len]
			currentrun.len--
			if(QDELETED(thing) || thing.process(wait * 0.1) == PROCESS_KILL)
				processing -= thing
				if (!QDELETED(thing))
					thing.datum_flags &= ~DF_ISPROCESSING
			if(!QDELETED(thing) && thing.use_power != thing.static_power_mode)
				thing.update_current_power_usage()
			if (MC_TICK_CHECK)
				return
		current_part = SSMACHINES_MACHINES_LATE
		currentrun = processing_late.Copy()
		src.currentrun = currentrun
		if (MC_TICK_CHECK)
			return

	//Late processing machines
	if(current_part == SSMACHINES_MACHINES_LATE)
		while(currentrun.len)
			var/obj/machinery/thing = currentrun[currentrun.len]
			currentrun.len--
			if(QDELETED(thing) || thing.process_late(wait * 0.1) == PROCESS_KILL)
				processing_late -= thing
				if (!QDELETED(thing))
					thing.datum_flags &= ~DF_ISPROCESSING
			if(!QDELETED(thing) && thing.use_power != thing.static_power_mode)
				thing.update_current_power_usage()
			if (MC_TICK_CHECK)
				return

/// Registers a machine with the machine subsystem; should only be called by the machine itself during its creation.
/datum/controller/subsystem/machines/proc/register_machine(obj/machinery/machine)
	LAZYADD(machines_by_type[machine.type], machine)
	all_machines |= machine

/// Removes a machine from the machine subsystem; should only be called by the machine itself inside Destroy.
/datum/controller/subsystem/machines/proc/unregister_machine(obj/machinery/machine)
	var/list/existing = machines_by_type[machine.type]
	existing -= machine
	if(!length(existing))
		machines_by_type -= machine.type
	all_machines -= machine

/// Add a machine to the early procesing queue.
/datum/controller/subsystem/machines/proc/start_processing_early(obj/machinery/machine)
	if(!(machine.datum_flags & DF_ISPROCESSING))
		machine.datum_flags |= DF_ISPROCESSING
		processing_early += machine

/// Add a machine to the late processing queue.
/datum/controller/subsystem/machines/proc/start_processing_late(obj/machinery/machine)
	if(!(machine.datum_flags & DF_ISPROCESSING))
		machine.datum_flags |= DF_ISPROCESSING
		processing_late += machine

/// Add an APC to the dedicated APC processing queue.
/datum/controller/subsystem/machines/proc/start_processing_apc(obj/machinery/power/apc/apc)
	if(!(apc.datum_flags & DF_ISPROCESSING))
		apc.datum_flags |= DF_ISPROCESSING
		processing_apcs += apc

/// Remove machine from all processing queues.
/datum/controller/subsystem/machines/proc/stop_processing(obj/machinery/machine)
	machine.datum_flags &= ~DF_ISPROCESSING
	processing -= machine
	processing_early -= machine
	processing_late -= machine
	processing_apcs -= machine
	currentrun -= machine

/// Gets a list of all machines that are either the passed type or a subtype.
/datum/controller/subsystem/machines/proc/get_machines_by_type_and_subtypes(obj/machinery/machine_type)
	if(!ispath(machine_type))
		machine_type = machine_type.type
	if(!ispath(machine_type, /obj/machinery))
		CRASH("called get_machines_by_type_and_subtypes with a non-machine type [machine_type]")
	var/list/machines = list()
	for(var/next_type in typesof(machine_type))
		var/list/found_machines = machines_by_type[next_type]
		if(found_machines)
			machines += found_machines
	return machines

/// Gets a list of all machines that are the exact passed type.
/datum/controller/subsystem/machines/proc/get_machines_by_type(obj/machinery/machine_type)
	if(!ispath(machine_type))
		machine_type = machine_type.type
	if(!ispath(machine_type, /obj/machinery))
		CRASH("called get_machines_by_type with a non-machine type [machine_type]")

	var/list/machines = machines_by_type[machine_type]
	return machines?.Copy() || list()

/datum/controller/subsystem/machines/proc/get_all_machines()
	return all_machines.Copy()

/datum/controller/subsystem/machines/proc/get_machine_count()
	return length(all_machines)

/datum/controller/subsystem/machines/proc/get_machine_type_count()
	return length(machines_by_type)

/datum/controller/subsystem/machines/stat_entry(msg)
	msg = "M:[length(all_machines)]|MT:[length(machines_by_type)]|PM:[length(processing)]|PE:[length(processing_early)]|PA:[length(processing_apcs)]|PL:[length(processing_late)]|PN:[length(powernets)]"
	return ..()

/datum/controller/subsystem/machines/proc/setup_template_powernets(list/cables)
	var/obj/structure/cable/PC
	for(var/A in 1 to cables.len)
		PC = cables[A]
		if(!PC.powernet)
			var/datum/powernet/NewPN = new()
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)

/datum/controller/subsystem/machines/Recover()
	if(islist(SSmachines.processing))
		processing = SSmachines.processing
	if(islist(SSmachines.processing_early))
		processing_early = SSmachines.processing_early
	if(islist(SSmachines.processing_late))
		processing_late = SSmachines.processing_late
	if(islist(SSmachines.processing_apcs))
		processing_apcs = SSmachines.processing_apcs
	if(islist(SSmachines.powernets))
		powernets = SSmachines.powernets
	if(islist(SSmachines.all_machines))
		all_machines = SSmachines.all_machines
	if(islist(SSmachines.machines_by_type))
		machines_by_type = SSmachines.machines_by_type
