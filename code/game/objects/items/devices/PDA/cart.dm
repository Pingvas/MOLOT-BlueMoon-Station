#define CART_SECURITY			(1<<0)
#define CART_ENGINE				(1<<1)
#define CART_ATMOS				(1<<2)
#define CART_MEDICAL			(1<<3)
#define CART_MANIFEST			(1<<4)
#define CART_CLOWN				(1<<5)
#define CART_MIME				(1<<6)
#define CART_JANITOR			(1<<7)
#define CART_REAGENT_SCANNER	(1<<8)
#define CART_NEWSCASTER			(1<<9)
#define CART_REMOTE_DOOR		(1<<10)
#define CART_STATUS_DISPLAY		(1<<11)
#define CART_QUARTERMASTER		(1<<12)
#define CART_HYDROPONICS		(1<<13)
#define CART_DRONEPHONE			(1<<14)
#define CART_BARTENDER			(1<<15)
#define CART_CHEMISTRY			(1<<16)


/obj/item/cartridge
	name = "generic cartridge"
	desc = "Картридж с данными для портативных микрокомпьютеров."
	icon = 'icons/obj/pda.dmi'
	icon_state = "cart"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	rad_flags = RAD_PROTECT_CONTENTS

	var/obj/item/integrated_signaler/radio = null
	var/access = 0
	var/remote_door_id = ""
	var/bot_access_flags = 0
	var/spam_enabled = 0
	var/obj/item/modular_computer/pda/host_pda = null

/obj/item/cartridge/Destroy()
	host_pda = null
	return ..()

/obj/item/cartridge/Initialize(mapload)
	. = ..()
	host_pda = loc

/obj/item/cartridge/civil
	name = "\improper Civil cartridge"
	icon_state = "cart"
	access = CART_MANIFEST

/obj/item/cartridge/engineering
	name = "\improper Power-ON cartridge"
	icon_state = "cart-e"
	access = CART_ENGINE | CART_DRONEPHONE | CART_MANIFEST
	bot_access_flags = FLOOR_BOT

/obj/item/cartridge/atmos
	name = "\improper BreatheDeep cartridge"
	icon_state = "cart-a"
	access = CART_ATMOS | CART_DRONEPHONE | CART_MANIFEST
	bot_access_flags = FLOOR_BOT | FIRE_BOT

/obj/item/cartridge/medical
	name = "\improper Med-U cartridge"
	icon_state = "cart-m"
	access = CART_MEDICAL | CART_MANIFEST
	bot_access_flags = MED_BOT

/obj/item/cartridge/chemistry
	name = "\improper ChemWhiz cartridge"
	icon_state = "cart-chem"
	access = CART_REAGENT_SCANNER | CART_CHEMISTRY | CART_MANIFEST
	bot_access_flags = MED_BOT

/obj/item/cartridge/security
	name = "\improper R.O.B.U.S.T. cartridge"
	icon_state = "cart-s"
	access = CART_SECURITY | CART_MANIFEST
	bot_access_flags = SEC_BOT

/obj/item/cartridge/detective
	name = "\improper D.E.T.E.C.T. cartridge"
	icon_state = "cart-eye"
	access = CART_SECURITY | CART_MEDICAL | CART_MANIFEST
	bot_access_flags = SEC_BOT

/obj/item/cartridge/janitor
	name = "\improper CustodiPRO cartridge"
	desc = "Ультимативен в решениях очисток помещений."
	icon_state = "cart-j"
	access = CART_JANITOR | CART_DRONEPHONE | CART_MANIFEST
	bot_access_flags = CLEAN_BOT

/obj/item/cartridge/lawyer
	name = "\improper S.P.A.M. cartridge"
	desc = "Представляем вам картридж программы Station Public Announcement Messenger, с уникальной функцией вещания сообщениями, спроектировано для агентов внутренних дел Nanotrasen для рекламы их нужных и важных услуг."
	icon_state = "cart-law"
	access = CART_SECURITY | CART_MANIFEST
	spam_enabled = 1

/obj/item/cartridge/curator
	name = "\improper Lib-Tweet cartridge"
	icon_state = "cart-lib"
	access = CART_NEWSCASTER | CART_MANIFEST

/obj/item/cartridge/roboticist
	name = "\improper B.O.O.P. Remote Control cartridge"
	desc = "Снабжен тяжеловесным интерлинком связи с ботами и дронами!"
	icon_state = "cart-robo"
	bot_access_flags = FLOOR_BOT | CLEAN_BOT | MED_BOT | FIRE_BOT | SEC_BOT | MULE_BOT
	access = CART_DRONEPHONE | CART_MANIFEST

/obj/item/cartridge/signal
	name = "generic signaler cartridge"
	icon_state = "cart-sig"
	desc = "Дата-картридж со встроенным радиосигналером."

/obj/item/cartridge/signal/toxins
	name = "\improper Signal Ace 2 cartridge"
	desc = "Полноценен со встроенным радиосигналером!"
	icon_state = "cart-tox"
	access = CART_REAGENT_SCANNER | CART_ATMOS | CART_MANIFEST

/obj/item/cartridge/signal/Initialize(mapload)
	. = ..()
	radio = new(src)

/obj/item/cartridge/quartermaster
	name = "space parts & space vendors cartridge"
	desc = "Идеален для квартирмейстера тут и там!"
	icon_state = "cart-q"
	access = CART_QUARTERMASTER | CART_MANIFEST
	bot_access_flags = MULE_BOT

/obj/item/cartridge/head
	name = "\improper Easy-Record DELUXE cartridge"
	icon_state = "cart-h"
	access = CART_MANIFEST | CART_STATUS_DISPLAY

/obj/item/cartridge/hop
	name = "\improper HumanResources9001 cartridge"
	icon_state = "cart-h"
	access = CART_MANIFEST | CART_STATUS_DISPLAY | CART_JANITOR | CART_SECURITY | CART_NEWSCASTER | CART_QUARTERMASTER | CART_DRONEPHONE
	bot_access_flags = MULE_BOT | CLEAN_BOT

/obj/item/cartridge/hos
	name = "\improper R.O.B.U.S.T. DELUXE cartridge"
	icon_state = "cart-hos"
	access = CART_MANIFEST | CART_STATUS_DISPLAY | CART_SECURITY
	bot_access_flags = SEC_BOT

/obj/item/cartridge/ce
	name = "\improper Power-On DELUXE cartridge"
	icon_state = "cart-ce"
	access = CART_MANIFEST | CART_STATUS_DISPLAY | CART_ENGINE | CART_ATMOS | CART_DRONEPHONE
	bot_access_flags = FLOOR_BOT | FIRE_BOT

/obj/item/cartridge/cmo
	name = "\improper Med-U DELUXE cartridge"
	icon_state = "cart-cmo"
	access = CART_MANIFEST | CART_STATUS_DISPLAY | CART_REAGENT_SCANNER | CART_MEDICAL
	bot_access_flags = MED_BOT

/obj/item/cartridge/rd
	name = "\improper Signal Ace DELUXE cartridge"
	icon_state = "cart-rd"
	access = CART_MANIFEST | CART_STATUS_DISPLAY | CART_REAGENT_SCANNER | CART_ATMOS | CART_DRONEPHONE
	bot_access_flags = FLOOR_BOT | CLEAN_BOT | MED_BOT | FIRE_BOT

/obj/item/cartridge/rd/Initialize(mapload)
	. = ..()
	radio = new(src)

/obj/item/cartridge/captain
	name = "\improper Value-PAK cartridge"
	desc = "Теперь полезнее на 350%!"
	icon_state = "cart-c"
	access = ~(CART_CLOWN | CART_MIME | CART_REMOTE_DOOR)
	bot_access_flags = SEC_BOT | MULE_BOT | FLOOR_BOT | CLEAN_BOT | MED_BOT | FIRE_BOT
	spam_enabled = 1

/obj/item/cartridge/captain/Initialize(mapload)
	. = ..()
	radio = new(src)

/obj/item/cartridge/bartender
	name = "\improper B.O.O.Z.E cartridge"
	desc = "Теперь с 12%-м содержанием спирта!"
	icon_state = "cart-bar"
	access = CART_BARTENDER | CART_MANIFEST

/obj/item/cartridge/chaplain
	name = "holy cartridge"
	desc = "Аминь!"
	icon_state = "cart-q"
	access = CART_MANIFEST

/obj/item/cartridge/proc/post_status(command, data1, data2)
	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)
	if(!frequency)
		return
	var/datum/signal/status_signal = new(list("command" = command))
	switch(command)
		if("message")
			status_signal.data["msg1"] = data1
			status_signal.data["msg2"] = data2
		if("alert")
			status_signal.data["picture_state"] = data1
	frequency.post_signal(src, status_signal)
