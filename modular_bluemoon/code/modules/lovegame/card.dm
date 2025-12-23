// Love game card decks: consolidated parent deck + singlecard subclass + child decks

// Parent deck for Love Cards. Child decks should live under /obj/item/toy/cards/deck/love_cards

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

// Override attack-hand so we avoid declaring draw_card duplicate with parent
/obj/item/toy/cards/deck/love_cards/on_attack_hand(mob/user, act_intent = user.a_intent, unarmed_attack_flags)
	if(user.lying)
		return
	if(cards.len == 0)
		to_chat(user, "<span class='warning'>There are no more cards to draw!</span>")
		return TRUE
	// spawn the love-specific singlecard so we can set card_desk
	var/obj/item/toy/cards/singlecard/love_card/H = new/obj/item/toy/cards/singlecard/love_card(user.loc)
	if(holo)
		holo.spawned += H
	var/choice = popleft(cards)
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


// subclass of singlecard for love cards - small subclass that only adds `card_desk`

/obj/item/toy/cards/singlecard/love_card
	// only add the deck link; inherit everything else from parent singlecard
	var/obj/item/toy/cards/deck/love_cards/card_desk = null
	icon = 'icons/obj/lovecard/pack_1.dmi'
	icon_state = "singlecard_down_lovecard"


/obj/item/toy/cards/singlecard/love_card/Flip()
	if(!ishuman(usr) || !usr.canUseTopic(src, BE_CLOSE))
		return
	if(!flipped)
		src.flipped = 1
		// Only three face sprites are allowed: vopros, kink, deystvie.
		if(card_desk && card_desk.card_group)
			if(card_desk.icon)
				src.icon = card_desk.icon
			// e.g. sc_vopros_lovecard, sc_kink_lovecard, sc_deystvie_lovecard
			src.icon_state = "sc_[card_desk.card_group]_[deckstyle]"
		else
			// default to vopros if no group set
			src.icon_state = "sc_vopros_[deckstyle]"
		// keep the readable card name but do not use it for sprite selection
		src.name = cardname ? src.cardname : "card"
		src.pixel_x = 5
	else
		src.flipped = 0
		// restore deck DMI and down state
		if(card_desk)
			src.icon = card_desk.icon
		src.icon_state = "singlecard_down_[deckstyle]"
		src.name = "card"
		src.pixel_x = -5

// Child decks that simply set `card_type`

/obj/item/toy/cards/deck/love_cards/truths
	name = "Deck of Truths"
	desc = "A deck filled with truth questions."
	icon = 'icons/obj/lovecard/pack_1.dmi'
	icon_state = "deck_lovecard_full"
	deckstyle = "lovecard"
	card_type = /datum/love_card/truths
	card_group = "vopros"



/obj/item/toy/cards/deck/love_cards/kinks
	name = "Deck of Flirty Prompts"
	desc = "A deck filled with flirty or romantic prompts."
	icon = 'icons/obj/lovecard/pack_1.dmi'
	icon_state = "deck_lovecard_full"
	deckstyle = "lovecard"
	card_type = /datum/love_card/kinks
	card_group = "kink"



/obj/item/toy/cards/deck/love_cards/actions
	name = "Deck of Actions"
	desc = "A deck filled with playful actions to perform."
	icon = 'icons/obj/lovecard/pack_1.dmi'
	icon_state = "deck_lovecard_full"
	deckstyle = "lovecard"
	card_type = /datum/love_card/actions
	card_group = "deystvie"


