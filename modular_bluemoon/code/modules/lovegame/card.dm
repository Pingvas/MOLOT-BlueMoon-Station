/obj/item/toy/cards/deck/love_cards
	var/card_type = null
	var/card_group = null
	var/list/card_map = list()

/obj/item/toy/cards/deck/love_cards/Initialize(mapload)
	. = ..()
	if(!card_type)
		return INITIALIZE_HINT_QDEL
	populate_deck()

/obj/item/toy/cards/deck/love_cards/populate_deck()
	cards = list()
	card_map = list()
	icon_state = "deck_[deckstyle]_full"
	for(var/typ in typecacheof(card_type, TRUE))
		var/datum/love_card/D = new typ()
		cards += D.name
		card_map[D.name] = list(type = typ, desc = D.desc, pack = D.pack, face_state = D.icon_state)
		qdel(D)

/obj/item/toy/cards/deck/love_cards/on_attack_hand(mob/user, act_intent = user.a_intent, unarmed_attack_flags)
	if(user.lying)
		return
	if(cards.len == 0)
		to_chat(user, "<span class='warning'>There are no more cards to draw!</span>")
		return TRUE
	var/obj/item/toy/cards/singlecard/love_card/H = new/obj/item/toy/cards/singlecard/love_card(user.loc)
	if(holo)
		holo.spawned += H
	var/choice = pick(cards)
	cards -= choice
	H.cardname = choice
	H.parentdeck = src
	H.card_desk = src
	var/list/entry = card_map[choice]
	if(entry)
		if(entry["desc"])
			H.desc = entry["desc"]
		if(entry["pack"])
			H.icon = entry["pack"]
	H.apply_card_vars(H, src)
	H.pickup(user)
	user.put_in_hands(H)
	playsound(src, 'sound/items/carddraw.ogg', 50, 1)
	user.visible_message("[user] draws a card from the deck.", "<span class='notice'>You draw a card from the deck.</span>")
	update_icon()
	return TRUE



/obj/item/toy/cards/singlecard/love_card
	var/obj/item/toy/cards/deck/love_cards/card_desk = null
	icon = 'icons/obj/lovecard/pack_1.dmi'
	icon_state = "singlecard_down_lovecard"


/obj/item/toy/cards/singlecard/love_card/Flip()
	if(!ishuman(usr) || !usr.canUseTopic(src, BE_CLOSE))
		return
	if(!flipped)
		src.flipped = 1
		if(card_desk && card_desk.card_group)
			if(card_desk.icon)
				src.icon = card_desk.icon
			src.icon_state = "sc_[card_desk.card_group]_[deckstyle]"
		else
			src.icon_state = "sc_vopros_[deckstyle]"
		src.name = cardname ? src.cardname : "card"
		src.pixel_x = 5
	else
		src.flipped = 0
		if(card_desk)
			src.icon = card_desk.icon
		src.icon_state = "singlecard_down_[deckstyle]"
		src.name = "card"
		src.pixel_x = -5

/obj/item/toy/cards/singlecard/love_card/attackby(obj/item/I, mob/living/user, params)
	// Disable combining love cards into a hand or merging with other cards
	if(istype(I, /obj/item/toy/cards/singlecard) || istype(I, /obj/item/toy/cards/cardhand))
		to_chat(user, "<span class='warning'>These cards can't be combined into a hand.</span>")
		return
	return ..()

/obj/item/toy/cards/deck/love_cards/truths
	name = "Deck of Truths"
	desc = "Колода вопросов."
	icon = 'icons/obj/lovecard/pack_1.dmi'
	icon_state = "deck_lovecardvopros_full"
	deckstyle = "lovecardvopros"
	card_type = /datum/love_card/truths
	card_group = "vopros"

/obj/item/toy/cards/deck/love_cards/kinks
	name = "Deck of Kinks"
	desc = "Колода с сексуальными действиями и вопросами."
	icon = 'icons/obj/lovecard/pack_1.dmi'
	icon_state = "deck_lovecard_full"
	deckstyle = "lovecard"
	card_type = /datum/love_card/kinks
	card_group = "kink"

/obj/item/toy/cards/deck/love_cards/actions
	name = "Deck of Actions"
	desc = "Колода с игровыми действиями."
	icon = 'icons/obj/lovecard/pack_1.dmi'
	icon_state = "deck_lovecarddeystvie_full"
	deckstyle = "lovecarddeystvie"
	card_type = /datum/love_card/actions
	card_group = "deystvie"
