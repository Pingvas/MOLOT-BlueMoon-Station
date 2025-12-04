
// Love game card decks: create deck types that populate from love_card datums

/obj/item/toy/cards/deck/love_truths
	name = "Deck of Truths"
	desc = "A deck filled with truth questions."
	icon = 'icons/obj/lovecard/pack_1.dmi'
	icon_state = "deck_lovecard_full"
	deckstyle = "lovecard"
	var/list/card_map = list()

/obj/item/toy/cards/deck/love_truths/Initialize(mapload)
	. = ..()
	populate_deck()

/obj/item/toy/cards/deck/love_truths/populate_deck()
	cards = list()
	card_map = list()
	for(var/typ in typecacheof(/datum/love_card/truths, TRUE))
		var/datum/love_card/truths/D = new typ()
		cards += D.name
		card_map[D.name] = list(type = typ, desc = D.desc, pack = D.pack)
		qdel(D)

/obj/item/toy/cards/deck/love_truths/draw_card(mob/user)
	if(user.lying)
		return
	if(cards.len == 0)
		to_chat(user, "<span class='warning'>There are no more cards to draw!</span>")
		return
	var/obj/item/toy/cards/singlecard/H = new/obj/item/toy/cards/singlecard(user.loc)
	if(holo)
		holo.spawned += H
	var/choice = popleft(cards)
	H.cardname = choice
	H.parentdeck = src
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


/obj/item/toy/cards/deck/love_kinks
	name = "Deck of Flirty Prompts"
	desc = "A deck filled with flirty or romantic prompts."
	icon = 'icons/obj/lovecard/pack_1.dmi'
	icon_state = "deck_lovecard_full"
	deckstyle = "lovecard"
	var/list/card_map = list()

/obj/item/toy/cards/deck/love_kinks/Initialize(mapload)
	. = ..()
	populate_deck()

/obj/item/toy/cards/deck/love_kinks/populate_deck()
	cards = list()
	card_map = list()
	for(var/typ in typecacheof(/datum/love_card/kinks, TRUE))
		var/datum/love_card/kinks/D = new typ()
		cards += D.name
		card_map[D.name] = list(type = typ, desc = D.desc, pack = D.pack)
		qdel(D)

/obj/item/toy/cards/deck/love_kinks/draw_card(mob/user)
	if(user.lying)
		return
	if(cards.len == 0)
		to_chat(user, "<span class='warning'>There are no more cards to draw!</span>")
		return
	var/obj/item/toy/cards/singlecard/H = new/obj/item/toy/cards/singlecard(user.loc)
	if(holo)
		holo.spawned += H
	var/choice = popleft(cards)
	H.cardname = choice
	H.parentdeck = src
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


/obj/item/toy/cards/deck/love_actions
	name = "Deck of Actions"
	desc = "A deck filled with playful actions to perform."
	icon = 'icons/obj/lovecard/pack_1.dmi'
	icon_state = "deck_lovecard_full"
	deckstyle = "lovecard"
	var/list/card_map = list()

/obj/item/toy/cards/deck/love_actions/Initialize(mapload)
	. = ..()
	populate_deck()

/obj/item/toy/cards/deck/love_actions/populate_deck()
	cards = list()
	card_map = list()
	for(var/typ in typecacheof(/datum/love_card/actions, TRUE))
		var/datum/love_card/actions/D = new typ()
		cards += D.name
		card_map[D.name] = list(type = typ, desc = D.desc, pack = D.pack)
		qdel(D)

/obj/item/toy/cards/deck/love_actions/draw_card(mob/user)
	if(user.lying)
		return
	if(cards.len == 0)
		to_chat(user, "<span class='warning'>There are no more cards to draw!</span>")
		return
	var/obj/item/toy/cards/singlecard/H = new/obj/item/toy/cards/singlecard(user.loc)
	if(holo)
		holo.spawned += H
	var/choice = popleft(cards)
	H.cardname = choice
	H.parentdeck = src
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
