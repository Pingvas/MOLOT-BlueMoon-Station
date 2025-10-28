/datum/job/fisher
	title = "Fishhook Office Fixer"
	flag = FISHING
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#8f6791"

	outfit = /datum/outfit/job/fishing

	display_order = JOB_DISPLAY_ORDER_FIXER
	departments = DEPARTMENT_SERVICE
	threat = 0.2

	access = list(ACCESS_JANITOR, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_JANITOR, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV

	job_important = "You are a fishing office fixer, hired by L-Corp. You're on this facility to get everyone fresh fish! To start fishing use the fishing rod on a body of water."
	job_notice = "To start fishing, use your fishing rod on a body of water."

	alt_titles = list()
	senior_title = "Kingfisher"
	ultra_senior_title = "The Fishmaster"
	roundstart_attributes = list(
								FORTITUDE_ATTRIBUTE = 20,
								PRUDENCE_ATTRIBUTE = 20,
								TEMPERANCE_ATTRIBUTE = 20,
								JUSTICE_ATTRIBUTE = 20
								)
	loadalways = FALSE
	maptype = "fishing"


/datum/job/fisher/after_spawn(mob/living/carbon/human/H, mob/M, latejoin = FALSE)
	H.set_attribute_limit(20)
	ADD_TRAIT(H, TRAIT_WORK_FORBIDDEN, JOB_TRAIT)

/datum/outfit/job/fishing
	name = "Fishhook Office Fixer"
	jobtype = /datum/job/fisher
	uniform = /obj/item/clothing/under/suit/lobotomy/fishhook
	l_hand = /obj/item/fishing_rod
	r_pocket = /obj/item/storage/bag/fish
	backpack_contents = list(
		/obj/item/book/fish_catalog = 1,
		/obj/item/storage/fish_case = 1,
		/obj/item/fish_feed = 1
		)
	implants = null
