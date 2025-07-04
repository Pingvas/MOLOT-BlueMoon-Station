

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//////DRINKS BELOW, Beer is up there though, along with cola. Cap'n Pete's Cuban Spiced Rum//////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/consumable/orangejuice
	name = "Orange Juice"
	description = "Both delicious AND rich in Vitamin C, what more do you need?"
	color = "#E78108" // rgb: 231, 129, 8
	taste_description = "oranges"
	glass_icon_state = "glass_orange"
	glass_name = "glass of orange juice"
	glass_desc = "Vitamins! Yay!"
	pH = 3.3

/datum/reagent/consumable/orangejuice/on_mob_life(mob/living/carbon/M)
	if(M.getOxyLoss() && prob(30))
		M.adjustOxyLoss(-1, 0)
		. = 1
	..()

/datum/reagent/consumable/tomatojuice
	name = "Tomato Juice"
	description = "Tomatoes made into juice. What a waste of big, juicy tomatoes, huh?"
	color = "#731008" // rgb: 115, 16, 8
	taste_description = "tomatoes"
	glass_icon_state = "glass_red"
	glass_name = "glass of tomato juice"
	glass_desc = "Are you sure this is tomato juice?"

/datum/reagent/consumable/tomatojuice/on_mob_life(mob/living/carbon/M)
	if(M.getFireLoss() && prob(20))
		M.heal_bodypart_damage(0,1, 0)
		. = 1
	..()

/datum/reagent/consumable/limejuice
	name = "Lime Juice"
	description = "The sweet-sour juice of limes."
	color = "#365E30" // rgb: 54, 94, 48
	taste_description = "unbearable sourness"
	glass_icon_state = "glass_green"
	glass_name = "glass of lime juice"
	glass_desc = "A glass of sweet-sour lime juice."
	pH = 2.2

/datum/reagent/consumable/limejuice/on_mob_life(mob/living/carbon/M)
	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1*REM, 0)
		. = 1
	..()

/datum/reagent/consumable/carrotjuice
	name = "Carrot Juice"
	description = "It is just like a carrot but without crunching."
	color = "#973800" // rgb: 151, 56, 0
	taste_description = "carrots"
	glass_icon_state = "carrotjuice"
	glass_name = "glass of  carrot juice"
	glass_desc = "It's just like a carrot but without crunching."

/datum/reagent/consumable/carrotjuice/on_mob_life(mob/living/carbon/M)
	M.adjust_blurriness(-1)
	M.adjust_blindness(-1)
	switch(current_cycle)
		if(1 to 20)
			//nothing
		if(21 to INFINITY)
			if(prob(current_cycle-10))
				M.cure_nearsighted(list(EYE_DAMAGE))
	..()
	return

/datum/reagent/consumable/berryjuice
	name = "Berry Juice"
	description = "A delicious blend of several different kinds of berries."
	color = "#863333" // rgb: 134, 51, 51
	taste_description = "berries"
	glass_icon_state = "berryjuice"
	glass_name = "glass of berry juice"
	glass_desc = "Berry juice. Or maybe it's jam. Who cares?"

/datum/reagent/consumable/applejuice
	name = "Apple Juice"
	description = "The sweet juice of an apple, fit for all ages."
	color = "#ECFF56" // rgb: 236, 255, 86
	taste_description = "apples"
	pH = 3.2 // ~ 2.7 -> 3.7

/datum/reagent/consumable/poisonberryjuice
	name = "Poison Berry Juice"
	description = "A tasty juice blended from various kinds of very deadly and toxic berries."
	color = "#863353" // rgb: 134, 51, 83
	taste_description = "berries"
	glass_icon_state = "poisonberryjuice"
	glass_name = "glass of berry juice"
	glass_desc = "Berry juice. Or maybe it's poison. Who cares?"

/datum/reagent/consumable/poisonberryjuice/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(1, 0)
	. = 1
	..()

/datum/reagent/consumable/watermelonjuice
	name = "Watermelon Juice"
	description = "Delicious juice made from watermelon."
	color = "#863333" // rgb: 134, 51, 51
	taste_description = "juicy watermelon"
	glass_icon_state = "glass_red"
	glass_name = "glass of watermelon juice"
	glass_desc = "A glass of watermelon juice."

/datum/reagent/consumable/lemonjuice
	name = "Lemon Juice"
	description = "This juice is VERY sour."
	color = "#863333" // rgb: 175, 175, 0
	taste_description = "sourness"
	glass_icon_state  = "lemonglass"
	glass_name = "glass of lemon juice"
	glass_desc = "Sour..."
	pH = 2

/datum/reagent/consumable/banana
	name = "Banana Juice"
	description = "The raw essence of a banana. HONK"
	color = "#863333" // rgb: 175, 175, 0
	taste_description = "banana"
	glass_icon_state = "banana"
	glass_name = "glass of banana juice"
	glass_desc = "The raw essence of a banana. HONK."

/datum/reagent/consumable/banana/on_mob_life(mob/living/carbon/M)
	if((ishuman(M) && M.job == "Clown") || ismonkey(M))
		M.heal_bodypart_damage(1,1, 0)
		. = 1
	..()

/datum/reagent/consumable/strawberryjuice
	name = "Strawberry Juice"
	description = "Refreshing seasonal summer drink."
	color = "#E50D31"
	taste_description = "strawberry"
	glass_name = "glass of strawberry juice"
	glass_desc = "Refreshing seasonal summer drink."

/datum/reagent/consumable/nothing
	name = "Nothing"
	description = "Absolutely nothing."
	taste_description = "nothing"
	glass_icon_state = "nothing"
	glass_name = "nothing"
	glass_desc = "Absolutely nothing."
	shot_glass_icon_state = "shotglass"

/datum/reagent/consumable/nothing/on_mob_life(mob/living/carbon/M)
	if(ishuman(M) && M.job == "Mime")
		M.heal_bodypart_damage(1,1, 0)
		. = 1
	..()

/datum/reagent/consumable/laughter
	name = "Laughter"
	description = "Some say that this is the best medicine, but recent studies have proven that to be untrue."
	metabolization_rate = INFINITY
	color = "#FF4DD2"
	taste_description = "laughter"
	value = REAGENT_VALUE_VERY_COMMON

/datum/reagent/consumable/laughter/on_mob_life(mob/living/carbon/M)
	M.emote("laugh")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "chemical_laughter", /datum/mood_event/chemical_laughter)
	..()

/datum/reagent/consumable/superlaughter
	name = "Super Laughter"
	description = "Funny until you're the one laughing."
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	color = "#FF4DD2"
	taste_description = "laughter"
	value = REAGENT_VALUE_RARE

/datum/reagent/consumable/superlaughter/on_mob_life(mob/living/carbon/M)
	if(prob(30))
		M.visible_message("<span class='danger'>[M] bursts out into a fit of uncontrollable laughter!</span>", "<span class='userdanger'>You burst out in a fit of uncontrollable laughter!</span>")
		M.Stun(5)
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "chemical_laughter", /datum/mood_event/chemical_superlaughter)
	..()

/datum/reagent/consumable/potato_juice
	name = "Potato Juice"
	description = "Juice of the potato. Bleh."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "irish sadness"
	glass_icon_state = "glass_brown"
	glass_name = "glass of potato juice"
	glass_desc = "Bleh..."

/datum/reagent/consumable/grapejuice
	name = "Grape Juice"
	description = "The juice of a bunch of grapes. Guaranteed non-alcoholic."
	color = "#290029" // dark purple
	taste_description = "grape soda"

/datum/reagent/consumable/milk
	name = "Milk"
	description = "An opaque white liquid produced by the mammary glands of mammals."
	color = "#DFDFDF" // rgb: 223, 223, 223
	taste_description = "milk"
	glass_icon_state = "glass_white"
	glass_name = "glass of milk"
	glass_desc = "White and nutritious goodness!"
	pH = 6.5
	value = REAGENT_VALUE_VERY_COMMON
	var/decal_path = /obj/effect/decal/cleanable/milk

	// Milk is good for humans, but bad for plants. The sugars cannot be used by plants, and the milk fat harms growth. Not shrooms though. I can't deal with this now...
/datum/reagent/consumable/milk/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(type, 1))
		mytray.adjustWater(round(chems.get_reagent_amount(type) * 0.3))
		if(myseed)
			myseed.adjust_potency(-chems.get_reagent_amount(type) * 0.5)

/datum/reagent/consumable/milk/on_mob_life(mob/living/carbon/M)
	if(HAS_TRAIT(M, TRAIT_CALCIUM_HEALER))
		M.heal_bodypart_damage(1.5,0, 0)
		for(var/i in M.all_wounds)
			var/datum/wound/iter_wound = i
			iter_wound.on_xadone(2)
		. = 1
	else
		if(M.getBruteLoss() && prob(20))
			M.heal_bodypart_damage(1,0, 0)
			. = 1
	if(holder.has_reagent(/datum/reagent/consumable/capsaicin))
		holder.remove_reagent(/datum/reagent/consumable/capsaicin, 2)
	if(iscatperson(M)) //cats go purr
		if(prob(5))
			to_chat(M, "<span class = 'notice'>[pick("Mmmm~ milk~","Ahh~ fresh milk~","Milk is so tasty!")]</span>")
			M.emote("purr")
	..()

/datum/reagent/consumable/soymilk
	name = "Soy Milk"
	description = "An opaque white liquid made from soybeans."
	color = "#DFDFC7" // rgb: 223, 223, 199
	taste_description = "soy milk"
	glass_icon_state = "glass_white"
	glass_name = "glass of soy milk"
	glass_desc = "White and nutritious soy goodness!"
	value = REAGENT_VALUE_VERY_COMMON

/datum/reagent/consumable/soymilk/on_mob_life(mob/living/carbon/M)
	if(M.getBruteLoss() && prob(20))
		M.heal_bodypart_damage(1,0, 0)
		. = 1
	..()

/datum/reagent/consumable/coconutmilk
	name = "Coconut Milk"
	description = "A transparent white liquid extracted from coconuts. Rich in taste."
	color = "#DFDFDF" // rgb: 223, 223, 223
	taste_description = "sweet milk"
	quality = DRINK_GOOD
	glass_icon_state = "glass_white"
	glass_name = "glass of coconut milk"
	glass_desc = "White and nutritious goodness!"

/datum/reagent/consumable/coconutmilk/on_mob_life(mob/living/carbon/M)
	if(M.getBruteLoss() && prob(20))
		M.heal_bodypart_damage(2,0, 0)
		. = 1
	..()

/datum/reagent/consumable/cream
	name = "Cream"
	description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
	color = "#DFD7AF" // rgb: 223, 215, 175
	taste_description = "creamy milk"
	glass_icon_state  = "glass_white"
	glass_name = "glass of cream"
	glass_desc = "Ewwww..."

/datum/reagent/consumable/cream/on_mob_life(mob/living/carbon/M)
	if(M.getBruteLoss() && prob(20))
		M.heal_bodypart_damage(1,0, 0)
		. = 1
	..()

/datum/reagent/consumable/coffee
	name = "Coffee"
	description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
	color = "#482000" // rgb: 72, 32, 0
	nutriment_factor = 0
	overdose_threshold = 80
	taste_description = "bitterness"
	glass_icon_state = "glass_brown"
	glass_name = "glass of coffee"
	glass_desc = "Don't drop it, or you'll send scalding liquid and glass shards everywhere."

///datum/reagent/consumable/coffee/overdose_process(mob/living/M)
	//M.Jitter(5) // Убираем тряску от кофе
	////..()

/datum/reagent/consumable/coffee/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.AdjustSleeping(-40, FALSE)
	//310.15 is the normal bodytemp.
	M.adjust_bodytemperature(25 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	if(holder.has_reagent(/datum/reagent/consumable/frostoil))
		holder.remove_reagent(/datum/reagent/consumable/frostoil, 5)
	..()
	. = 1

/datum/reagent/consumable/tea
	name = "Tea"
	description = "Tasty black tea, it has antioxidants, it's good for you!"
	color = "#101000" // rgb: 16, 16, 0
	nutriment_factor = 0
	taste_description = "tart black tea"
	glass_icon_state = "teaglass"
	glass_name = "glass of tea"
	glass_desc = "Drinking it from here would not seem right."

/datum/reagent/consumable/tea/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-2)
	M.drowsyness = max(0,M.drowsyness-1)
	M.jitteriness = max(0,M.jitteriness-3)
	M.AdjustSleeping(-20, FALSE)
	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1, 0)
	M.adjust_bodytemperature(20 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	..()
	. = 1

/datum/reagent/consumable/tea/red
	name = "Red Tea"
	description = "Tasty red tea, helps the body digest food. Drink in moderation!"
	color = "#101000" // rgb: 16, 16, 0
	nutriment_factor = 0
	taste_description = "sweet red tea"
	glass_icon_state = "tea_red"
	glass_name = "glass of red tea"
	glass_desc = "A piping hot tea that helps with the digestion of food."

/datum/reagent/consumable/tea/red/on_mob_life(mob/living/carbon/M)
	if(M.nutrition > NUTRITION_LEVEL_HUNGRY)
		M.adjust_nutrition(-3)
	M.dizziness = max(0,M.dizziness-2)
	M.drowsyness = max(0,M.drowsyness-1)
	M.jitteriness = max(0,M.jitteriness-3)
	M.adjust_bodytemperature(23 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	..()
	. = 1

/datum/reagent/consumable/tea/green
	name = "Green Tea"
	description = "Tasty green tea, known to heal livers, it's good for you!"
	color = "#101000" // rgb: 16, 16, 0
	nutriment_factor = 0
	taste_description = "tart green tea"
	glass_icon_state = "tea_green"
	glass_name = "glass of tea"
	glass_desc = "A calming glass of green tea to help get you through the day."

/datum/reagent/consumable/tea/green/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, -0.5) //Detox!
	M.dizziness = max(0,M.dizziness-2)
	M.drowsyness = max(0,M.drowsyness-1)
	M.jitteriness = max(0,M.jitteriness-3)
	M.adjust_bodytemperature(15 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	..()
	. = 1

/datum/reagent/consumable/tea/forest
	name = "Forest Tea"
	description = "Tea mixed with honey, has both antitoxins and sweetness in one!"
	color = "#101000" // rgb: 16, 16, 0
	nutriment_factor = 0
	quality = DRINK_GOOD // BLUEMOON ADD
	taste_description = "sweet tea"
	glass_icon_state = "tea_forest"
	glass_name = "glass of forest tea"
	glass_desc = "A lovely glass of tea and honey."

/datum/reagent/consumable/tea/forest/on_mob_life(mob/living/carbon/M)
	if(M.getToxLoss() && prob(40))//Two anti-toxins working here
		M.adjustToxLoss(-1, 0, TRUE) //heals TOXINLOVERs
		//Reminder that honey heals toxin lovers
	M.dizziness = max(0,M.dizziness-2)
	M.drowsyness = max(0,M.drowsyness-1)
	M.jitteriness = max(0,M.jitteriness-3)
	M.adjust_bodytemperature(15 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	..()
	. = 1

/datum/reagent/consumable/tea/mush
	name = "Mush Tea"
	description = "Tea mixed with mushroom hallucinogen, used for fun rides or self reflection."
	color = "#101000" // rgb: 16, 16, 0
	nutriment_factor = 0
	quality = DRINK_NICE
	taste_description = "fungal infections"
	glass_icon_state = "tea_mush"
	glass_name = "glass of mush tea"
	glass_desc = "A cold merky brown tea."

/datum/reagent/consumable/tea/mush/on_mob_life(mob/living/carbon/M)
	M.set_drugginess(20) //Little better then space drugs
	if(prob(20))
		M.Dizzy(10)
	if(prob(10))
		M.disgust = 0
	..()
	. = 1

/datum/reagent/consumable/lemonade
	name = "Lemonade"
	description = "Sweet, tangy lemonade. Good for the soul."
	quality = DRINK_NICE
	taste_description = "sunshine and summertime"
	glass_icon_state = "lemonpitcher"
	glass_name = "pitcher of lemonade"
	glass_desc = "This drink leaves you feeling nostalgic for some reason."
	value = REAGENT_VALUE_VERY_COMMON

/datum/reagent/consumable/tea/arnold_palmer
	name = "Arnold Palmer"
	description = "Encourages the patient to go golfing."
	color = "#FFB766"
	quality = DRINK_NICE
	taste_description = "bitter tea"
	glass_icon_state = "arnold_palmer"
	glass_name = "Arnold Palmer"
	glass_desc = "You feel like taking a few golf swings after a few swigs of this."
	value = REAGENT_VALUE_VERY_COMMON

/datum/reagent/consumable/tea/arnold_palmer/on_mob_life(mob/living/carbon/M)
	if(prob(5))
		to_chat(M, "<span class = 'notice'>[pick("You remember to square your shoulders.","You remember to keep your head down.","You can't decide between squaring your shoulders and keeping your head down.","You remember to relax.","You think about how someday you'll get two strokes off your golf game.")]</span>")
	..()
	. = 1

/datum/reagent/consumable/icecoffee
	name = "Iced Coffee"
	description = "Coffee and ice, refreshing and cool."
	color = "#102838" // rgb: 16, 40, 56
	nutriment_factor = 0
	taste_description = "bitter coldness"
	glass_icon_state = "icedcoffeeglass"
	glass_name = "iced coffee"
	glass_desc = "A drink to perk you up and refresh you!"

/datum/reagent/consumable/icecoffee/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	//M.Jitter(5) // Убираем тряску
	..()
	. = 1

/datum/reagent/consumable/icetea
	name = "Iced Tea"
	description = "No relation to a certain rap artist/actor."
	color = "#104038" // rgb: 16, 64, 56
	nutriment_factor = 0
	taste_description = "sweet tea"
	glass_icon_state = "icedteaglass"
	glass_name = "iced tea"
	glass_desc = "All natural, antioxidant-rich flavour sensation."

/datum/reagent/consumable/icetea/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-2)
	M.drowsyness = max(0,M.drowsyness-1)
	M.AdjustSleeping(-40, FALSE)
	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1, 0)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = 1

/datum/reagent/consumable/space_cola
	name = "Cola"
	description = "A refreshing beverage."
	nutriment_factor = 0.5 * REAGENTS_METABOLISM
	color = "#100800" // rgb: 16, 8, 0
	taste_description = "cola"
	glass_icon_state  = "glass_brown"
	glass_name = "glass of Space Cola"
	glass_desc = "A glass of refreshing Space Cola."

/datum/reagent/consumable/space_cola/on_mob_life(mob/living/carbon/M)
	M.drowsyness = max(0,M.drowsyness-5)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/nuka_cola
	name = "Nuka Cola"
	description = "Cola, cola never changes."
	color = "#100800" // rgb: 16, 8, 0
	quality = DRINK_VERYGOOD
	taste_description = "the future"
	glass_icon_state = "nuka_colaglass"
	glass_name = "glass of Nuka Cola"
	glass_desc = "Don't cry, Don't raise your eye, It's only nuclear wasteland."
	value = REAGENT_VALUE_COMMON

/datum/reagent/consumable/nuka_cola/on_mob_metabolize(mob/living/carbon/M)
	M.add_movespeed_modifier(/datum/movespeed_modifier/reagent/nuka_cola)
	return ..()

/datum/reagent/consumable/nuka_cola/on_mob_end_metabolize(mob/living/carbon/M)
	M.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/nuka_cola)
	return ..()

/datum/reagent/consumable/nuka_cola/on_mob_life(mob/living/carbon/M)
	M.Jitter(20)
	M.set_drugginess(30)
	M.dizziness +=1.5
	M.drowsyness = 0
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = 1

/datum/reagent/consumable/spacemountainwind
	name = "SM Wind"
	description = "Blows right through you like a space wind."
	nutriment_factor = 0.5 * REAGENTS_METABOLISM
	color = "#102000" // rgb: 16, 32, 0
	taste_description = "sweet citrus soda"
	glass_icon_state = "Space_mountain_wind_glass"
	glass_name = "glass of Space Mountain Wind"
	glass_desc = "Space Mountain Wind. As you know, there are no mountains in space, only wind."

/datum/reagent/consumable/spacemountainwind/on_mob_life(mob/living/carbon/M)
	M.drowsyness = max(0,M.drowsyness-7)
	M.AdjustSleeping(-20, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	M.Jitter(5)
	..()
	. = 1

/datum/reagent/consumable/dr_gibb
	name = "Dr. Gibb"
	description = "A delicious blend of 42 different flavours."
	nutriment_factor = 0.5 * REAGENTS_METABOLISM
	color = "#102000" // rgb: 16, 32, 0
	taste_description = "cherry soda" // FALSE ADVERTISING
	glass_icon_state = "dr_gibb_glass"
	glass_name = "glass of Dr. Gibb"
	glass_desc = "Dr. Gibb. Not as dangerous as the glass_name might imply."

/datum/reagent/consumable/dr_gibb/on_mob_life(mob/living/carbon/M)
	M.drowsyness = max(0,M.drowsyness-6)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/space_up
	name = "Space-Up"
	description = "Tastes like a hull breach in your mouth."
	nutriment_factor = 0.5 * REAGENTS_METABOLISM
	color = "#00FF00" // rgb: 0, 255, 0
	taste_description = "cherry soda"
	glass_icon_state = "space-up_glass"
	glass_name = "glass of Space-Up"
	glass_desc = "Space-up. It helps you keep your cool."


/datum/reagent/consumable/space_up/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-8 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/lemon_lime
	name = "Lemon Lime"
	description = "A tangy substance made of 0.5% natural citrus!"
	nutriment_factor = 0.5 * REAGENTS_METABOLISM
	color = "#8CFF00" // rgb: 135, 255, 0
	taste_description = "tangy lime and lemon soda"
	glass_icon_state = "glass_yellow"
	glass_name = "glass of lemon-lime"
	glass_desc = "You're pretty certain a real fruit has never actually touched this."

/datum/reagent/consumable/lemon_lime/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-8 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/pwr_game
	name = "Pwr Game"
	description = "The only drink with the PWR that true gamers crave."
	nutriment_factor = 0.5 * REAGENTS_METABOLISM
	color = "#9385bf" // rgb: 58, 52, 75
	taste_description = "sweet and salty tang"
	glass_icon_state = "glass_red"
	glass_name = "glass of Pwr Game"
	glass_desc = "Goes well with a Vlad's salad."

/datum/reagent/consumable/pwr_game/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-8 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/shamblers
	name = "Shambler's Juice"
	description = "~Shake me up some of that Shambler's Juice!~"
	nutriment_factor = 0.5 * REAGENTS_METABOLISM
	color = "#f00060" // rgb: 94, 0, 38
	taste_description = "carbonated metallic soda"
	glass_icon_state = "glass_red"
	glass_name = "glass of Shambler's juice"
	glass_desc = "Mmm mm, shambly."
	quality = DRINK_NICE // BLUEMOON ADD

/datum/reagent/consumable/shamblers/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-8 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/buzz_fuzz
	name = "Buzz Fuzz"
	description = "~A Hive of Flavour!~ NOTICE: Addicting."
	nutriment_factor = 0
	addiction_threshold = 31 //A can and a sip
	color = "#8CFF00" // rgb: 135, 255, 0
	taste_description = "carbonated honey and pollen"
	glass_icon_state = "buzz_fuzz"
	glass_name = "honeycomb of Buzz Fuzz"
	glass_desc = "Stinging with flavour."

	//This drink seems to be just made for plants.. how curious.
/datum/reagent/consumable/buzz_fuzz/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(src,1))
		mytray.adjustPests(-rand(2,5))
		mytray.adjustHealth(round(chems.get_reagent_amount(src.type) * 0.1))
		if(myseed)
			myseed.adjust_potency(round(chems.get_reagent_amount(src.type) * 0.5))

/datum/reagent/consumable/buzz_fuzz/on_mob_life(mob/living/carbon/M)
	if(prob(33))
		M.reagents.add_reagent(/datum/reagent/consumable/sugar,1)
	if(prob(1))
		M.reagents.add_reagent(/datum/reagent/consumable/honey,1)
	..()

/datum/reagent/consumable/buzz_fuzz/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(iscarbon(M) && (method in list(TOUCH, VAPOR, PATCH)))
		var/mob/living/carbon/C = M
		for(var/s in C.surgeries)
			var/datum/surgery/S = s
			S.success_multiplier = max(0.1, S.success_multiplier) // +10% success probability on each step, compared to bacchus' blessing's ~46%
	..()

/datum/reagent/consumable/buzz_fuzz/addiction_act_stage1(mob/living/M)
	if(prob(5))
		to_chat(M, "<span class = 'notice'>[pick("Buzz Buzz.", "Stinging with flavour.", "A Hive of Flavour")]</span>")
	..()

/datum/reagent/consumable/buzz_fuzz/addiction_act_stage2(mob/living/M)
	if(prob(10))
		to_chat(M, "<span class = 'notice'>[pick("Buzz Buzz.", "Stinging with flavour.", "A Hive of Flavour", "The Queen approved it!")]</span>")
	..()

/datum/reagent/consumable/buzz_fuzz/addiction_act_stage3(mob/living/M)
	if(prob(15))
		to_chat(M, "<span class = 'notice'>[pick("Buzz Buzz.", "Stinging with flavour.", "Ideal of the worker drone", "A Hive of Flavour", "The Queen approved it!")]</span>")
	..()

/datum/reagent/consumable/buzz_fuzz/addiction_act_stage4(mob/living/M)
	if(prob(25))
		to_chat(M, "<span class = 'notice'>[pick("Buzz Buzz.", "Stinging with flavour.", "Ideal of the worker drone", "A Hive of Flavour", "Sap back that missing energy!", "Got Honey?", "The Queen approved it!")]</span>")
	..()

/datum/reagent/consumable/grey_bull
	name = "Grey Bull"
	description = "Grey Bull, it gives you gloves!"
	color = "#EEFF00" // rgb: 238, 255, 0
	quality = DRINK_VERYGOOD
	taste_description = "carbonated oil"
	glass_icon_state = "grey_bull_glass"
	glass_name = "glass of Grey Bull"
	glass_desc = "Surprisingly it isnt grey."
	value = REAGENT_VALUE_COMMON

/datum/reagent/consumable/grey_bull/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_SHOCKIMMUNE, type)

/datum/reagent/consumable/grey_bull/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_SHOCKIMMUNE, type)
	..()

/datum/reagent/consumable/grey_bull/on_mob_life(mob/living/carbon/M)
	M.Jitter(20)
	M.dizziness +=1
	M.drowsyness = 0
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/sodawater
	name = "Soda Water"
	description = "A can of club soda. Why not make a scotch and soda?"
	nutriment_factor = 0
	color = "#619494" // rgb: 97, 148, 148
	taste_description = "carbonated water"
	glass_icon_state = "glass_clear"
	glass_name = "glass of soda water"
	glass_desc = "Soda water. Why not make a scotch and soda?"


	// A variety of nutrients are dissolved in club soda, without sugar.
	// These nutrients include carbon, oxygen, hydrogen, phosphorous, potassium, sulfur and sodium, all of which are needed for healthy plant growth.
/datum/reagent/consumable/sodawater/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(type, 1))
		mytray.adjustWater(round(chems.get_reagent_amount(type) * 1))
		mytray.adjustHealth(round(chems.get_reagent_amount(type) * 0.1))

/datum/reagent/consumable/sodawater/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/tonic
	name = "Tonic Water"
	description = "It tastes strange but at least the quinine keeps the Space Malaria at bay."
	color = "#0064C8" // rgb: 0, 100, 200
	taste_description = "tart and fresh"
	glass_icon_state = "glass_clear"
	glass_name = "glass of tonic water"
	glass_desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."

/datum/reagent/consumable/tonic/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = 1

/datum/reagent/consumable/ice
	name = "Ice"
	description = "Frozen water, your dentist wouldn't like you chewing this."
	nutriment_factor = 0 //Its water why would this even geive nutriments?
	reagent_state = SOLID
	color = "#619494" // rgb: 97, 148, 148
	taste_description = "ice"
	glass_icon_state = "iceglass"
	glass_name = "glass of ice"
	glass_desc = "Generally, you're supposed to put something else in there too..."

/datum/reagent/consumable/ice/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/soy_latte
	name = "Soy Latte"
	description = "A nice and tasty beverage while you are reading your hippie books."
	color = "#664300" // rgb: 102, 67, 0
	quality = DRINK_NICE
	taste_description = "creamy coffee"
	glass_icon_state = "soy_latte"
	glass_name = "soy latte"
	glass_desc = "A nice and refreshing beverage while you're reading."
	value = REAGENT_VALUE_VERY_COMMON

/datum/reagent/consumable/soy_latte/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.SetSleeping(0, FALSE)
	M.adjust_bodytemperature(5 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	//M.Jitter(5) // Убираем тряску от латте
	if(M.getBruteLoss() && prob(20))
		M.heal_bodypart_damage(1,0, 0)
	..()
	. = 1

/datum/reagent/consumable/cafe_latte
	name = "Cafe Latte"
	description = "A nice, strong and tasty beverage while you are reading."
	color = "#664300" // rgb: 102, 67, 0
	quality = DRINK_NICE
	taste_description = "bitter cream"
	glass_icon_state = "cafe_latte"
	glass_name = "cafe latte"
	glass_desc = "A nice, strong and refreshing beverage while you're reading."
	value = REAGENT_VALUE_VERY_COMMON

/datum/reagent/consumable/cafe_latte/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.SetSleeping(0, FALSE)
	M.adjust_bodytemperature(5 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	//M.Jitter(5) // Убираем тряску от латте
	if(M.getBruteLoss() && prob(20))
		M.heal_bodypart_damage(1,0, 0)
	..()
	. = 1

/datum/reagent/consumable/doctor_delight
	name = "The Doctor's Delight"
	description = "A gulp a day keeps the Medibot away! A mixture of juices that heals most damage types fairly quickly at the cost of hunger."
	color = "#FF8CFF" // rgb: 255, 140, 255
	quality = DRINK_VERYGOOD
	taste_description = "homely fruit"
	glass_icon_state = "doctorsdelightglass"
	glass_name = "Doctor's Delight"
	glass_desc = "The space doctor's favorite. Guaranteed to restore bodily injury; side effects include cravings and hunger."
	value = REAGENT_VALUE_COMMON

/datum/reagent/consumable/doctor_delight/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-0.5, 0)
	M.adjustFireLoss(-0.5, 0)
	M.adjustToxLoss(-0.5, 0)
	M.adjustOxyLoss(-0.5, 0)
	if(!(M.mind && M.mind.assigned_role == "Medical Doctor")) //Drains the nutrition of the holder. Not medical doctors though, since it's the Doctor's Delight!
		M.adjust_nutrition(-2)
	..()
	. = 1

/datum/reagent/consumable/chocolatepudding
	name = "Chocolate Pudding"
	description = "A great dessert for chocolate lovers."
	color = "#800000"
	quality = DRINK_VERYGOOD
	nutriment_factor = 4 * REAGENTS_METABOLISM
	taste_description = "sweet chocolate"
	glass_icon_state = "chocolatepudding"
	glass_name = "chocolate pudding"
	glass_desc = "Tasty."
	value = REAGENT_VALUE_COMMON

/datum/reagent/consumable/vanillapudding
	name = "Vanilla Pudding"
	description = "A great dessert for vanilla lovers."
	color = "#FAFAD2"
	quality = DRINK_VERYGOOD
	nutriment_factor = 4 * REAGENTS_METABOLISM
	taste_description = "sweet vanilla"
	glass_icon_state = "vanillapudding"
	glass_name = "vanilla pudding"
	glass_desc = "Tasty."
	value = REAGENT_VALUE_UNCOMMON //real vanilla.

/datum/reagent/consumable/cherryshake
	name = "Cherry Shake"
	description = "A cherry flavored milkshake."
	color = "#FFB6C1"
	quality = DRINK_VERYGOOD
	nutriment_factor = 2 * REAGENTS_METABOLISM
	taste_description = "creamy cherry"
	glass_icon_state = "cherryshake"
	glass_name = "cherry shake"
	glass_desc = "A cherry flavored milkshake."
	value = REAGENT_VALUE_COMMON

/datum/reagent/consumable/bluecherryshake
	name = "Blue Cherry Shake"
	description = "An exotic milkshake."
	color = "#00F1FF"
	quality = DRINK_VERYGOOD
	nutriment_factor = 2 * REAGENTS_METABOLISM
	taste_description = "creamy blue cherry"
	glass_icon_state = "bluecherryshake"
	glass_name = "blue cherry shake"
	glass_desc = "An exotic blue milkshake."
	value = REAGENT_VALUE_UNCOMMON

/datum/reagent/consumable/pumpkin_latte
	name = "Pumpkin Latte"
	description = "A mix of pumpkin juice and coffee."
	color = "#F4A460"
	quality = DRINK_VERYGOOD
	nutriment_factor = 2 * REAGENTS_METABOLISM
	taste_description = "creamy pumpkin"
	glass_icon_state = "pumpkin_latte"
	glass_name = "pumpkin latte"
	glass_desc = "A mix of coffee and pumpkin juice."
	value = REAGENT_VALUE_COMMON

/datum/reagent/consumable/gibbfloats
	name = "Gibb Floats"
	description = "Ice cream on top of a Dr. Gibb glass."
	color = "#B22222"
	quality = DRINK_NICE
	nutriment_factor = 1 * REAGENTS_METABOLISM
	taste_description = "creamy cherry"
	glass_icon_state = "gibbfloats"
	glass_name = "Gibbfloat"
	glass_desc = "Dr. Gibb with ice cream on top."
	value = REAGENT_VALUE_VERY_COMMON

/datum/reagent/consumable/pumpkinjuice
	name = "Pumpkin Juice"
	description = "Juiced from real pumpkin."
	color = "#FFA500"
	taste_description = "pumpkin"

/datum/reagent/consumable/blumpkinjuice
	name = "Blumpkin Juice"
	description = "Juiced from real blumpkin."
	color = "#00BFFF"
	taste_description = "a mouthful of pool water"
	value = REAGENT_VALUE_VERY_COMMON

/datum/reagent/consumable/triple_citrus
	name = "Triple Citrus"
	description = "A solution."
	color = "#fff12b"
	quality = DRINK_NICE
	taste_description = "extreme bitterness"
	glass_icon_state = "triplecitrus" //needs own sprite mine are trash
	glass_name = "glass of triple citrus"
	glass_desc = "A mixture of citrus juices. Tangy, yet smooth."

/datum/reagent/consumable/grape_soda
	name = "Grape soda"
	description = "Beloved of children and teetotalers."
	color = "#E6CDFF"
	taste_description = "grape soda"
	glass_name = "glass of grape juice"
	glass_desc = "It's grape (soda)!"

/datum/reagent/consumable/grape_soda/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/milk/chocolate_milk
	name = "Chocolate Milk"
	description = "Milk for cool kids."
	color = "#7D4E29"
	quality = DRINK_NICE
	taste_description = "chocolate milk"
	value = REAGENT_VALUE_VERY_COMMON

/datum/reagent/consumable/menthol
	name = "Menthol"
	description = "Alleviates coughing symptoms one might have."
	color = "#80AF9C"
	taste_description = "mint"
	glass_icon_state = "glass_green"
	glass_name = "glass of menthol"
	glass_desc = "Tastes naturally minty, and imparts a very mild numbing sensation."

/datum/reagent/consumable/menthol/on_mob_life(mob/living/L)
	L.apply_status_effect(/datum/status_effect/throat_soothed)
	..()

/datum/reagent/consumable/grenadine
	name = "Grenadine"
	description = "Not cherry flavored!"
	color = "#EA1D26"
	taste_description = "sweet pomegranates"
	glass_name = "glass of grenadine"
	glass_desc = "Delicious flavored syrup."

/datum/reagent/consumable/parsnipjuice
	name = "Parsnip Juice"
	description = "Why..."
	color = "#FFA500"
	taste_description = "parsnip"
	glass_name = "glass of parsnip juice"
	value = REAGENT_VALUE_COMMON

/datum/reagent/consumable/peachjuice //Intended to be extremely rare due to being the limiting ingredients in the blazaam drink
	name = "Peach Juice"
	description = "Just peachy."
	color = "#E78108"
	taste_description = "peaches"
	glass_name = "glass of peach juice"

/datum/reagent/consumable/pineapplejuice
	name = "Pineapple Juice"
	description = "Tart, tropical, and hotly debated."
	color = "#F7D435"
	taste_description = "pineapple"
	glass_name = "glass of pineapple juice"
	glass_desc = "Tart, tropical, and hotly debated."

/datum/reagent/consumable/cream_soda
	name = "Cream Soda"
	description = "A classic space-American vanilla flavored soft drink."
	color = "#dcb137"
	quality = DRINK_VERYGOOD
	taste_description = "fizzy vanilla"
	glass_icon_state = "cream_soda"
	glass_name = "Cream Soda"
	glass_desc = "A classic space-American vanilla flavored soft drink."
	value = REAGENT_VALUE_VERY_COMMON //just a little vanilla

/datum/reagent/consumable/cream_soda/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/sol_dry
	name = "Sol Dry"
	description = "A soothing, mellow drink made from ginger."
	nutriment_factor = 0.5 * REAGENTS_METABOLISM
	color = "#f7d26a"
	quality = DRINK_NICE
	taste_description = "sweet ginger spice"
	glass_name = "Sol Dry"
	glass_desc = "A soothing, mellow drink made from ginger."

/datum/reagent/consumable/sol_dry/on_mob_life(mob/living/carbon/M)
	M.adjust_disgust(-5)
	..()

/datum/reagent/consumable/red_queen
	name = "Red Queen"
	description = "DRINK ME."
	color = "#e6ddc3"
	quality = DRINK_GOOD
	taste_description = "wonder"
	glass_icon_state = "red_queen"
	glass_name = "Red Queen"
	glass_desc = "DRINK ME."
	value = REAGENT_VALUE_COMMON //growth serum.
	var/current_size = RESIZE_DEFAULT_SIZE

/datum/reagent/consumable/red_queen/on_mob_life(mob/living/carbon/H)
	if(prob(75))
		return ..()
	var/newsize = pick(0.5, 0.75, 1, 1.50, 2)
	// BLUEMOON ADD START - нормализаторы не дружат с изменениями размера во время их ношения
	if(H.GetComponent(/datum/component/size_normalized))
		to_chat(H, span_warning("You normalization device fights any changes in size!"))
		return
	H.update_size(newsize)
	// BLUEMOON ADD END
	/* BLUEMOON REMOVAL START
	newsize *= RESIZE_DEFAULT_SIZE
	H.resize = newsize/current_size
	current_size = newsize
	H.update_transform()
	/ BLUEMOON REMOVAL END */
	if(prob(40))
		H.emote("sneeze")
	..()

/datum/reagent/consumable/red_queen/on_mob_end_metabolize(mob/living/M)
	/* BLUEMOON REMOVAL START
	M.resize = RESIZE_DEFAULT_SIZE/current_size
	current_size = RESIZE_DEFAULT_SIZE
	M.update_transform()
	/ BLUEMOON REMOVAL END */
	M.update_size(RESIZE_DEFAULT_SIZE) // BLUEMOON ADD
	..()

/datum/reagent/consumable/milk/pinkmilk
	name = "Strawberry Milk"
	description = "A drink of a bygone era of milk and artificial sweetener back on a rock."
	color = "#f76aeb"//rgb(247, 106, 235)
	glass_icon_state = "pinkmilk"
	quality = DRINK_VERYGOOD
	taste_description = "sweet strawberry and milk cream"
	glass_name = "tall glass of strawberry milk"
	glass_desc = "Delicious flavored strawberry syrup mixed with milk."
	value = REAGENT_VALUE_VERY_COMMON

/datum/reagent/consumable/milk/pinkmilk/on_mob_life(mob/living/carbon/M)
	if(prob(15))
		to_chat(M, "<span class = 'notice'>[pick("You cant help to smile.","You feel nostalgia all of sudden.","You remember to relax.")]</span>")
	..()
	. = 1

/datum/reagent/consumable/tea/pinktea //Tiny Tim song
	name = "Strawberry Tea"
	description = "A timeless classic!"
	color = "#f76aeb"//rgb(247, 106, 235)
	glass_icon_state = "pinktea"
	quality = DRINK_VERYGOOD
	taste_description = "sweet tea with a hint of strawberry"
	glass_name = "mug of strawberry tea"
	glass_desc = "Delicious traditional tea flavored with strawberries."

/datum/reagent/consumable/tea/pinktea/on_mob_life(mob/living/carbon/M)
	if(prob(10))
		to_chat(M, "<span class = 'notice'>[pick("Diamond skies where white deer fly.","Sipping strawberry tea.","Silver raindrops drift through timeless, Neverending June.","Crystal ... pearls free, with love!","Beaming love into me.")]</span>")
	..()
	. = 1

/datum/reagent/consumable/catnip_tea
	name = "Catnip Tea"
	description = "A sleepy and tasty catnip tea!"
	color = "#101000" // rgb: 16, 16, 0
	nutriment_factor = 0
	taste_description = "sugar and catnip"
	glass_icon_state = "teaglass"
	glass_name = "glass of catnip tea"
	glass_desc = "A purrfect drink for a cat."

/datum/reagent/consumable/catnip_tea/on_mob_life(mob/living/carbon/M)
	M.adjustStaminaLoss(min(50 - M.getStaminaLoss(), 3))
	if(iscatperson(M)) //"drugs" for felinids
		M.set_drugginess(15)
		if(prob(20))
			to_chat(M, "<span class = 'notice'>[pick("Headpats feel nice.", "The feeling of a hairball...", "Backrubs would be nice.", "Whats behind those doors?", "Wanna huuugs~", "Pat me pleeease~", "That corner looks suspicious...", "Rub my belly pleeease~")]</span>")
		if(prob(20))
			M.nextsoundemote = world.time - 10 //"too early BZHZHZH"
			M.emote(pick("nya","mewo","meow","purr","anyo","uwu","stare","spin"))
		if((istype(M) && M.dna && M.dna.species && M.dna.species.can_wag_tail(M)) && !M.dna.species.is_wagging_tail())
			M.emote("wag")
		if(prob(5))
			M.emote("spin")
			M.lay_down()
			to_chat(M, "<span class = 'notice'>[pick("Wanna reeest~","Waaaw~","Wanna plaaay!~","Play with meee~")]</span>")
	else
		if(prob(20))
			M.emote("nya")
		if(prob(20))
			to_chat(M, "<span class = 'notice'>[pick("Headpats feel nice.", "The feeling of a hairball...", "Backrubs would be nice.", "Whats behind those doors?")]</span>")
	if(ishuman(M) && !(M.client?.prefs.cit_toggles & NO_APHRO))
		var/mob/living/carbon/human/H = M
		var/list/adjusted = H.adjust_arousal(5,aphro = TRUE)
		for(var/g in adjusted)
			var/obj/item/organ/genital/G = g
			to_chat(M, "<span class='userlove'>You feel like playing with your [G.name]!</span>")
	..()

/datum/reagent/consumable/monkey_energy
	name = "Monkey Energy"
	description = "The only drink that will make you unleash the ape."
	color = "#f39b03" // rgb: 243, 155, 3
	taste_description = "barbecue and nostalgia"
	glass_icon_state = "monkey_energy_glass"
	glass_name = "glass of Monkey Energy"
	glass_desc = "You can unleash the ape, but without the pop of the can?"
	value = REAGENT_VALUE_COMMON

/datum/reagent/consumable/monkey_energy/on_mob_life(mob/living/carbon/M)
	M.Jitter(20)
	M.dizziness +=1
	M.drowsyness = 0
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/bungojuice
	name = "Bungo Juice"
	color = "#F9E43D"
	description = "Exotic! You feel like you are on vactation already."
	taste_description = "succulent bungo"
	glass_icon_state = "glass_yellow"
	glass_name = "glass of bungo juice"
	glass_desc = "Exotic! You feel like you are on vacation already."
	value = REAGENT_VALUE_COMMON

/datum/reagent/consumable/aloejuice
	name = "Aloe Juice"
	color = "#A3C48B"
	description = "A healthy and refreshing juice."
	taste_description = "vegetable"
	glass_icon_state = "glass_yellow"
	glass_name = "glass of aloe juice"
	glass_desc = "A healthy and refreshing juice."

/datum/reagent/consumable/aloejuice/on_mob_life(mob/living/M)
	if(M.getToxLoss() && prob(30))
		M.adjustToxLoss(-1, 0)
	..()
	. = TRUE

// i googled "natural coagulant" and a couple of results came up for banana peels, so after precisely 30 more seconds of research, i now dub grinding banana peels good for your blood
/datum/reagent/consumable/banana_peel
	name = "Pulped Banana Peel"
	description = "Okay, so you put a banana peel in a grinder... Why, exactly?"
	color = "#863333" // rgb: 175, 175, 0
	reagent_state = SOLID
	taste_description = "stringy, bitter pulp"
	glass_name = "glass of banana peel pulp"
	glass_desc = "Okay, so you put a banana peel in a grinder... Why, exactly?"

/datum/reagent/consumable/baked_banana_peel
	name = "Baked Banana Peel Powder"
	description = "You took a banana peel... pulped it... baked it... Where are you going with this?"
	color = "#863333" // rgb: 175, 175, 0
	reagent_state = SOLID
	taste_description = "bitter powder"
	glass_name = "glass of banana peel powder"
	description = "You took a banana peel... pulped it... baked it... Where are you going with this?"

/datum/reagent/consumable/eggnog
	name = "Eggnog"
	description = "A creamy, rich beverage made out of whisked eggs, milk and sugar, for when you feel like celebrating the winter holidays."
	color = "#fcfdc6" // rgb: 252, 253, 198
	nutriment_factor = 2 * REAGENTS_METABOLISM
	quality = DRINK_VERYGOOD
	taste_description = "custard"
	glass_icon_state = "nog3"
	glass_name = "eggnog"
	glass_desc = "You can't egg-nore the holiday cheer all around you"
