/obj/machinery/rnd/server
	name = "\improper R&D Server"
	desc = "A computer system running a deep neural network that processes arbitrary information to produce data useable in the development of new technologies. In layman's terms, it makes research points."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	req_access = list(ACCESS_RD) //ONLY THE R&D CAN CHANGE SERVER SETTINGS.
	circuit = /obj/item/circuitboard/machine/rdserver

	idle_power_usage = 500
	var/datum/techweb/stored_research
	//Code for point mining here.
	var/working = TRUE			//temperature should break it.
	var/server_id = 0
	var/list/base_mining_income = list(TECHWEB_POINT_TYPE_GENERIC = 2)
	var/heat_gen = 1
	var/income_gen = 1
	var/heating_power = 40000
	var/delay = 5
	var/temp_tolerance_low = 0
	var/temp_tolerance_high = T20C
	var/temp_penalty_coefficient = 0.5	//1 = -1 points per degree above high tolerance. 0.5 = -0.5 points per degree above high tolerance.

/obj/machinery/rnd/server/Initialize(mapload)
	. = ..()
	SSresearch.servers |= src
	stored_research = SSresearch.science_tech

/obj/machinery/rnd/server/process()
	if(!(machine_stat & NOPOWER))
		produce_heat(base_mining_income[1])

/obj/machinery/rnd/server/Destroy()
	SSresearch.servers -= src
	return ..()

/obj/machinery/rnd/server/RefreshParts()
	var/tot_rating = 0
	for(var/obj/item/stock_parts/SP in src.component_parts)
		tot_rating += SP.rating
	heat_gen = initial(src.heat_gen) / max(1, tot_rating)
	income_gen = 1 + ((tot_rating - 1) * 0.2)

/obj/machinery/rnd/server/power_change()
	. = ..()
	if(machine_stat & NOPOWER)
		working = FALSE
	else
		working = TRUE

/obj/machinery/rnd/server/proc/refresh_working()
	if(machine_stat & EMPED)
		working = FALSE
	else
		working = TRUE

/obj/machinery/rnd/server/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	machine_stat |= EMPED
	addtimer(CALLBACK(src, PROC_REF(unemp)), severity*9)
	refresh_working()

/obj/machinery/rnd/server/proc/unemp()
	machine_stat &= ~EMPED
	refresh_working()

/obj/machinery/rnd/server/proc/mine()
	. = base_mining_income.Copy()
	var/penalty = max((get_env_temp() - temp_tolerance_high), 0) * temp_penalty_coefficient
	for(var/i in .)
		.[i] = max((.[i] * income_gen) - penalty, 0)

/obj/machinery/rnd/server/proc/get_env_temp()
	var/datum/gas_mixture/environment = loc.return_air()
	return environment.return_temperature()

/obj/machinery/rnd/server/proc/produce_heat(perc)
	if(!(machine_stat & (NOPOWER|BROKEN))) //Blatently stolen from space heater.
		var/turf/L = loc
		if(istype(L))
			var/datum/gas_mixture/env = L.return_air()
			env.adjust_heat(heating_power * perc * heat_gen)
			air_update_turf()

/proc/fix_noid_research_servers()
	var/list/no_id_servers = list()
	var/list/server_ids = list()
	for(var/obj/machinery/rnd/server/S in GLOB.machines)
		switch(S.server_id)
			if(-1)
				continue
			if(0)
				no_id_servers += S
			else
				server_ids += S.server_id

	for(var/obj/machinery/rnd/server/S in no_id_servers)
		var/num = 1
		while(!S.server_id)
			if(num in server_ids)
				num++
			else
				S.server_id = num
				server_ids += num
		no_id_servers -= S


/obj/machinery/computer/rdservercontrol
	name = "R&D Server Controller"
	desc = "Used to manage access to research and manufacturing databases."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	var/screen = 0
	var/obj/machinery/rnd/server/temp_server
	var/list/servers = list()
	var/list/consoles = list()
	var/badmin = 0
	circuit = /obj/item/circuitboard/computer/rdservercontrol

/obj/machinery/computer/rdservercontrol/Topic(href, href_list)
	if(..())
		return

	add_fingerprint(usr)
	usr.set_machine(src)
	if(!src.allowed(usr) && !(obj_flags & EMAGGED))
		to_chat(usr, "<span class='danger'>You do not have the required access level.</span>")
		return

	if(href_list["main"])
		screen = 0

	updateUsrDialog()
	return

/obj/machinery/computer/rdservercontrol/ui_interact(mob/user)
	. = ..()
	var/dat = ""

	switch(screen)
		if(0) //Main Menu
			dat += "Connected Servers:<BR><BR>"

			for(var/obj/machinery/rnd/server/S in GLOB.machines)
				dat += "[S.name]<BR>"

		//Mining status here

	user << browse("<TITLE>R&D Server Control</TITLE><HR>[dat]", "window=server_control;size=575x400")
	onclose(user, "server_control")
	return

/obj/machinery/computer/rdservercontrol/attackby(obj/item/D, mob/user, params)
	. = ..()
	src.updateUsrDialog()

/obj/machinery/computer/rdservercontrol/emag_act(mob/user)
	. = ..()
	if(obj_flags & EMAGGED)
		return
	log_admin("[key_name(usr)] emagged [src] at [AREACOORD(src)]")
	playsound(src, "sparks", 75, 1)
	obj_flags |= EMAGGED
	to_chat(user, "<span class='notice'>You disable the security protocols.</span>")
	return TRUE
