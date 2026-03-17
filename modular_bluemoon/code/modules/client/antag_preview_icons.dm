// Antag preview icons for the character setup TGUI menu
// Adds preview_outfit and get_preview_icon() overrides for antag datums
// that display in GLOB.special_roles, ported from SPLURT style

// === TRAITOR ===
// No dedicated traitor outfit in our code, so we define a simple one
/datum/outfit/traitor_preview
	name = "Traitor Preview"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	belt = /obj/item/gun/ballistic/automatic/pistol
	l_hand = /obj/item/melee/transforming/energy/sword/saber

/datum/antagonist/traitor
	preview_outfit = /datum/outfit/traitor_preview

// === CHANGELING ===
/datum/antagonist/changeling
	preview_outfit = /datum/outfit/changeling

/datum/antagonist/changeling/get_preview_icon()
	var/icon/final_icon = render_preview_outfit(/datum/outfit/changeling)
	var/icon/split_icon = render_preview_outfit(/datum/outfit/job/engineer)
	final_icon.Shift(WEST, world.icon_size / 2)
	final_icon.Shift(EAST, world.icon_size / 2)
	split_icon.Shift(EAST, world.icon_size / 2)
	split_icon.Shift(WEST, world.icon_size / 2)
	final_icon.Blend(split_icon, ICON_OVERLAY)
	return finish_preview_icon(final_icon)

// === WIZARD ===
/datum/antagonist/wizard
	preview_outfit = /datum/outfit/wizard

// === NUCLEAR OPERATIVE ===
/datum/antagonist/nukeop
	preview_outfit = /datum/outfit/syndicate

/datum/antagonist/nukeop/get_preview_icon()
	if(!preview_outfit)
		return null
	var/icon/final_icon = render_preview_outfit(preview_outfit)
	var/icon/nuke = icon('icons/obj/machines/nuke.dmi', "nuclearbomb_base")
	nuke.Shift(SOUTH, 6)
	final_icon.Blend(nuke, ICON_OVERLAY)
	return finish_preview_icon(final_icon)

// === REVOLUTIONARY ===
/datum/outfit/revolutionary_preview
	name = "Revolutionary Preview"
	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/sneakers/black
	head = /obj/item/clothing/head/beret/black

/datum/antagonist/rev
	preview_outfit = /datum/outfit/revolutionary_preview

// === CULTIST ===
/datum/outfit/cultist_preview
	name = "Cultist Preview"
	uniform = /obj/item/clothing/under/color/red
	suit = /obj/item/clothing/suit/hooded/cultrobes
	shoes = /obj/item/clothing/shoes/cult

/datum/antagonist/cult
	preview_outfit = /datum/outfit/cultist_preview

// === HERETIC ===
/datum/outfit/heretic_preview
	name = "Heretic Preview"
	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/hooded/cultrobes/eldritch
	shoes = /obj/item/clothing/shoes/sneakers/black

/datum/antagonist/heretic
	preview_outfit = /datum/outfit/heretic_preview

// === SPACE NINJA ===
/datum/antagonist/ninja
	preview_outfit = /datum/outfit/ninja_pre

// === BLOB ===
/datum/antagonist/blob/get_preview_icon()
	var/icon/blob_icon = icon('icons/mob/blob.dmi', "blob_core")
	blob_icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)
	return blob_icon

// === REVENANT ===
/datum/antagonist/revenant/get_preview_icon()
	return finish_preview_icon(icon('icons/mob/mob.dmi', "revenant_idle"))

// === ABDUCTOR ===
/datum/antagonist/abductor/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/scientist = new
	var/mob/living/carbon/human/dummy/consistent/agent = new
	scientist.set_species(/datum/species/abductor)
	agent.set_species(/datum/species/abductor)
	var/icon/scientist_icon = render_preview_outfit(/datum/outfit/abductor/scientist, scientist)
	scientist_icon.Shift(WEST, 8)
	var/icon/agent_icon = render_preview_outfit(/datum/outfit/abductor/agent, agent)
	agent_icon.Shift(EAST, 8)
	var/icon/final_icon = scientist_icon
	final_icon.Blend(agent_icon, ICON_OVERLAY)
	SSatoms.prepare_deletion(scientist)
	SSatoms.prepare_deletion(agent)
	return finish_preview_icon(final_icon)

// === BLOOD BROTHER ===
/datum/antagonist/brother/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/brother1 = new
	var/mob/living/carbon/human/dummy/consistent/brother2 = new
	var/icon/brother1_icon = render_preview_outfit(/datum/outfit/job/assistant, brother1)
	var/icon/brother1_blood = icon('icons/effects/blood.dmi', "maskblood")
	brother1_icon.Blend(brother1_blood, ICON_OVERLAY)
	brother1_icon.Shift(WEST, 8)
	var/icon/brother2_icon = render_preview_outfit(/datum/outfit/job/assistant, brother2)
	var/icon/brother2_blood = icon('icons/effects/blood.dmi', "uniformblood")
	brother2_icon.Blend(brother2_blood, ICON_OVERLAY)
	brother2_icon.Shift(EAST, 8)
	var/icon/final_icon = brother1_icon
	final_icon.Blend(brother2_icon, ICON_OVERLAY)
	SSatoms.prepare_deletion(brother1)
	SSatoms.prepare_deletion(brother2)
	return finish_preview_icon(final_icon)

// === SPACE DRAGON ===
/datum/antagonist/space_dragon/get_preview_icon()
	var/icon/dragon_icon = icon('icons/mob/spacedragon.dmi', "spacedragon")
	var/icon/overlay = icon('icons/mob/spacedragon.dmi', "spacedragon_overlay_base")
	dragon_icon.Blend(overlay, ICON_OVERLAY)
	dragon_icon.Crop(10, 9, 54, 53)
	dragon_icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)
	return dragon_icon

// === XENOMORPH ===
/datum/antagonist/xeno/get_preview_icon()
	return finish_preview_icon(icon('icons/mob/alien.dmi', "alienh"))

// === TERROR SPIDER ===
// Use terrorspider.dmi directly - queen is the most iconic
/datum/antagonist/terror_spiders/get_preview_icon()
	var/icon/spider_icon = icon('icons/mob/terrorspider.dmi', "terror_queen")
	spider_icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)
	return spider_icon
