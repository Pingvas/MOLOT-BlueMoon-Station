GLOBAL_LIST_EMPTY(preferences_datums)
// Файл расформирован на несколько частей, с модулей удалены хвосты.
// Теперь суть такова Preferences - все var/ деклорации
// (game prefs, character prefs, UI state, loadout, все модульные vars (body_weight, fuzzy, favorite_interactions, arousal_multiplier и т.д.)
// Preferences_ui - Рендер интерфейса ShowChoices и все в этом духе.
// Preferences_jobs_quirks - Выбор профессии и квирков
// Prefenences_handlers - Обработчик кликов (ссылки href и process_link`и + Хедшоты)
// Preferences_copy_to - Применение настроек к персонажу (внешка персов)
// Preferences_savefile - Ну понятно все, ничего не изменилось в целом.
// Preferences_toggles - Верб тогглы настроек.

/datum/preferences
	var/client/parent
	var/path
	var/vr_path
	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
	var/max_save_slots = 40
	var/last_ip
	/// Last CID the person was seen on
	var/last_id
	/// Do we log their clicks to disk?
	var/log_clicks = FALSE
	/// Characters they have joined the round under - Lazylist of names
	var/list/characters_joined_as
	/// Slots they have joined the round under - Lazylist of numbers
	var/list/slots_joined_as
	/// Are we currently subject to respawn restrictions? Usually set by us using the "respawn" verb, but can be lifted by admins.
	var/respawn_restrictions_active = FALSE
	/// time of death we consider for respawns
	var/respawn_time_of_death = -INFINITY
	/// did they DNR? used to prevent respawns.
	var/dnr_triggered = FALSE
	/// did they cryo on their last ghost?
	var/respawn_did_cryo = FALSE

	// Intra-round persistence end

	var/icon/custom_holoform_icon
	var/list/cached_holoform_icons
	var/last_custom_holoform = 0

	// Character Directory
	var/show_in_directory = 1	//Show in Character Directory
	var/directory_tag = "Unset" //Sorting tag to use in character directory
	var/directory_erptag = "Unset"	//ditto, but for non-vore scenes
	var/directory_gendertag = "Unset"	//Gender tag for character directory
	var/directory_ad = ""		//Advertisement stuff to show in character directory.

	//Cooldowns for saving/loading. These are four are all separate due to loading code calling these one after another
	COOLDOWN_DECLARE(saveprefcooldown)
	COOLDOWN_DECLARE(loadprefcooldown)
	COOLDOWN_DECLARE(savecharcooldown)
	COOLDOWN_DECLARE(loadcharcooldown)

	//game-preferences
	var/lastchangelog = ""				//Saved changlog filesize to detect if there was a change
	var/custom_colors = TOGGLES_DEFAULT_CUSTOM_COLORS
	var/ooccolor = "#c43b23"
	var/aooccolor = "#ce254f"
	var/enable_tips = TRUE
	var/tip_delay = 500 //tip delay in milliseconds

	//Antag preferences
	var/list/be_special = list()		//Special role selection. ROLE_INTEQ being missing means they will never be antag!
	var/tmp/old_be_special = 0			//Bitflag version of be_special, used to update old savefiles and nothing more
										//If it's 0, that's good, if it's anything but 0, the owner of this prefs file's antag choices were,
										//autocorrected this round, not that you'd need to check that.

	var/UI_style = null
	var/outline_enabled = TRUE
	var/outline_color = COLOR_THEME_MIDNIGHT
	var/screentip_pref = SCREENTIP_PREFERENCE_ENABLED
	var/screentip_color = "#ffd391"
	var/screentip_images = TRUE
	var/hotkeys = TRUE

	///Runechat preference. If true, certain messages will be displayed on the map, not ust on the chat area. Boolean.
	var/chat_on_map = TRUE
	///Runechat preference for looc
	var/chat_on_map_looc = TRUE
	///Limit preference on the size of the message. Requires chat_on_map to have effect.
	var/max_chat_length = CHAT_MESSAGE_MAX_LENGTH
	///Whether non-mob messages will be displayed, such as machine vendor announcements. Requires chat_on_map to have effect. Boolean.
	var/see_chat_non_mob = TRUE
	///Whether emotes will be displayed on runechat. Requires chat_on_map to have effect. Boolean.
	var/see_rc_emotes = TRUE

	/// Custom Keybindings
	var/list/key_bindings = list()
	/// List with a key string associated to a list of keybindings. Unlike key_bindings, this one operates on raw key, allowing for binding a key that triggers regardless of if a modifier is depressed as long as the raw key is sent.
	var/list/modless_key_bindings = list()

	var/tgui_fancy = TRUE
	var/tgui_lock = TRUE
	var/tgui_input_mode = TRUE			// All the Input Boxes (Text,Number,List,Alert)
	var/tgui_input_verbs = TRUE 		// Все частоиспользуемые вербы: SAY, ME, OOC и т.д.
	var/tgui_large_buttons = TRUE
	var/tgui_swapped_buttons = FALSE
	var/tgui_panel_theme = "default"
	var/tgui_panel_state = ""
	var/list/ui_zoom_preferences = list()
	var/windowflashing = TRUE
	var/windownoise = TRUE
	var/toggles = TOGGLES_DEFAULT
	/// A separate variable for deadmin toggles, only deals with those.
	var/deadmin = NONE
	var/db_flags
	var/chat_toggles = TOGGLES_DEFAULT_CHAT
	/// Bitfield for chat mutes (MUTE_* flags).
	var/muted = NONE
	var/ghost_form = "ghost"
	var/ghost_orbit = GHOST_ORBIT_CIRCLE
	var/ghost_accs = GHOST_ACCS_DEFAULT_OPTION
	var/ghost_others = GHOST_OTHERS_DEFAULT_OPTION
	var/ghost_hud = 1
	var/inquisitive_ghost = 1
	var/allow_midround_antag = 1
	var/preferred_map = null
	var/be_victim = null
	var/disable_combat_cursor = FALSE
	var/disable_combat_mouse_lock = FALSE
	var/tg_playerpanel = "TG"
	var/pda_style = MONO
	var/pda_color = "#808000"
	var/pda_skin = PDA_SKIN_ALT
	var/pda_ringtone = "beep"
	var/list/alt_titles_preferences = list()

	// Modern UI translations
	var/modern_ui_language = 0				// 0 = English, 1 = Russian

	var/hardsuit_tail_style = null // Пока не используется. Вскоре нужно будет бахнуть новых спрайтов.
	var/custom_blood_color = FALSE
	var/blood_color = BLOOD_COLOR_UNIVERSAL

	var/uses_glasses_colour = 0
	var/surgical_disable_radial = FALSE 		// BLUEMOON ADD
	var/chem_dispenser_classic_view = TRUE		// BLUEMOON ADD - classic flat grid vs categorized view
	var/chem_dispenser_use_reagent_color = TRUE	// BLUEMOON ADD - show reagent color vs pH color on buttons
	var/chem_dispenser_show_icons = TRUE		// BLUEMOON ADD - show/hide reagent icons on buttons
	var/chem_dispenser_alphabetical_sort = TRUE	// BLUEMOON ADD - alphabetical vs declaration order in classic view

	// BLUEMOON ADD START || Colormate presets
	// Листы состоят из ключа, типа предмета и листа с именами престов и настройками цвета
	var/list/color_presets_tint = list() // Пример: list(/obj/item/clothing = list("Стандарт" = "#ffffff"))
	var/list/color_presets_hsv = list() // Пример: list(/obj/item/clothing = list("Стандарт" = list("hue" = 0, "sat" = 1, "val" = 1)))
	var/list/color_presets_matrix = list() // Пример: list(/obj/item/clothing = list("Стандарт" = list(1,0,0,0,1,0,0,0,1,0,0,0)))
	// BLUEMOON ADD END

	//character preferences
	var/real_name							//our character's name
	var/nameless = FALSE					//whether or not our character is nameless
	var/be_random_name = FALSE				//whether we'll have a random name every round
	var/be_random_body = FALSE				//whether we'll have a random body every round
	var/gender = MALE						//gender of character (well duh)
	var/age = 30							//age of character
	//Sandstorm CHANGES BEGIN
	var/erppref = "Ask"
	var/nonconpref = "Ask"
	var/vorepref = "Ask"
	var/mobsexpref = "No" 					//Added by Gardelin0 - Sex(mostly non-con) with hostile mobs(tentacles)
	var/hornyantagspref = "No" 				//Added by Gardelin0 - Interactions(mostly non-con) with horny antags(Qareen)
	var/tattoopref = "Ask"					//BLUEMOON ADD - Tattoo consent preference
	var/extremepref = "No" 					//This is for extreme shit, maybe even literal shit, better to keep it on no by default
	var/extremeharm = "No" 					//If "extreme content" is enabled, this option serves as a toggle for the related interactions to cause damage or not
	var/see_chat_emotes = TRUE
	var/view_pixelshift = FALSE
	var/eorg_enabled = TRUE
	var/enable_personal_chat_color = FALSE
	var/personal_chat_color = "#ffffff"
	var/lust_tolerance = 100
	var/sexual_potency = 15
	//Sandstorm CHANGES END
	var/underwear = "Nude"				//underwear type
	var/undie_color = "FFFFFF"
	var/undershirt = "Nude"				//undershirt type
	var/shirt_color = "FFFFFF"
	var/socks = "Nude"					//socks type
	var/socks_color = "FFFFFF"
	var/backbag = DBACKPACK				//backpack type
	var/jumpsuit_style = PREF_SUIT		//suit/skirt
	var/hair_style = "Bald"				//Hair type
	var/hair_color = "000000"				//Hair color
	var/facial_hair_style = "Shaved"	//Face hair type
	var/facial_hair_color = "000000"		//Facial hair color
	var/grad_style						//Hair gradient style
	var/grad_color = "FFFFFF"			//Hair gradient color
	var/skin_tone = "caucasian1"		//Skin color
	var/use_custom_skin_tone = FALSE
	var/left_eye_color = "000000"		//Eye color
	var/right_eye_color = "000000"
	var/eye_type = DEFAULT_EYES_TYPE	//Eye type
	var/split_eye_colors = FALSE
	var/datum/species/pref_species = new /datum/species/human()	//Mutant race
	var/list/features = list(
"mcolor" = "FFFFFF",
"mcolor2" = "FFFFFF",
"mcolor3" = "FFFFFF",
"tail_lizard" = "Smooth",
"tail_human" = "None",
"snout" = "Round",
"horns" = "None",
"horns_color" = "85615a",
"ears" = "None",
"wings" = "None",
"wings_color" = "FFF",
"frills" = "None",
"deco_wings" = "None",
"spines" = "None",
"legs" = "Plantigrade",
"insect_wings" = "Plain",
"insect_fluff" = "None",
"insect_markings" = "None",
"arachnid_legs" = "Plain",
"arachnid_spinneret" = "Plain",
"arachnid_mandibles" = "Plain",
"mam_body_markings" = list(),
"mam_ears" = "None",
"mam_snouts" = "None",
"mam_tail" = "None",
"mam_tail_animated" = "None",
"xenodorsal" = "Standard",
"xenohead" = "Standard",
"xenotail" = "Xenomorph Tail",
"taur" = "None",
"hardsuit_with_tail" = FALSE,
"genitals_use_skintone" = FALSE,
"has_cock" = FALSE,
"cock_shape" = DEF_COCK_SHAPE,
"cock_length" = COCK_SIZE_DEF,
"cock_diameter_ratio" = COCK_DIAMETER_RATIO_DEF,
"cock_color" = "ffffff",
"cock_taur" = FALSE,
"has_balls" = FALSE,
"balls_color" = "ffffff",
"balls_shape" = DEF_BALLS_SHAPE,
"balls_size" = BALLS_SIZE_DEF,
"balls_cum_rate" = CUM_RATE,
"balls_cum_mult" = CUM_RATE_MULT,
"balls_fluid" = /datum/reagent/consumable/semen,
"balls_efficiency" = CUM_EFFICIENCY,
"has_breasts" = FALSE,
"breasts_color" = "ffffff",
"breasts_size" = BREASTS_SIZE_DEF,
"breasts_shape" = DEF_BREASTS_SHAPE,
"breasts_fluid" = /datum/reagent/consumable/milk,
"breasts_producing" = FALSE,
"has_vag" = FALSE,
"vag_shape" = DEF_VAGINA_SHAPE,
"vag_color" = "ffffff",
"has_womb" = FALSE,
"womb_fluid" = /datum/reagent/consumable/semen/femcum,
"has_butt" = FALSE,
"butt_color" = "ffffff",
"butt_size" = BUTT_SIZE_DEF,
"has_belly" = FALSE,
"has_anus" = FALSE,
"anus_color" = "ffffff",
"anus_shape" = DEF_ANUS_SHAPE,
"belly_color" = "ffffff",
"belly_size" = BELLY_SIZE_DEF,
"balls_visibility"  = GEN_VISIBLE_NO_UNDIES,
"breasts_visibility"= GEN_VISIBLE_NO_UNDIES,
"cock_visibility" = GEN_VISIBLE_NO_UNDIES,
"vag_visibility"   = GEN_VISIBLE_NO_UNDIES,
"butt_visibility" = GEN_VISIBLE_NO_UNDIES,
"belly_visibility" = GEN_VISIBLE_NO_UNDIES,
"anus_visibility" = GEN_VISIBLE_NO_UNDIES,
"breasts_accessible" = FALSE,
"cock_accessible" = FALSE,
"balls_accessible" = FALSE,
"vag_accessible" = FALSE,
"butt_accessible" = FALSE,
"anus_accessible" = FALSE,
"belly_accessible" = FALSE,
"cock_stuffing" = FALSE,
"balls_stuffing" = FALSE,
"vag_stuffing" = FALSE,
"breasts_stuffing" = FALSE,
"butt_stuffing" = FALSE,
"belly_stuffing" = FALSE,
"anus_stuffing" = FALSE,
"inert_eggs" = FALSE,
"ipc_screen" = "Sunburst",
"ipc_antenna" = "None",
"flavor_text" = "",
"naked_flavor_text" = "", //SPLURT edit
"silicon_flavor_text" = "",
"custom_species_lore" = "",
"custom_deathgasp" = "застывает и падает без сил, глаза мертвы и безжизненны...", // BLUEMOON ADD - пользовательский эмоут смерти
"custom_deathsound" = "По умолчанию", // BLUEMOON ADD - пользовательский эмоут смерти
"ooc_notes" = "",
"meat_type" = "Mammalian",
"body_model" = MALE,
"body_size" = RESIZE_DEFAULT_SIZE,
"fuzzy" = FALSE,
"color_scheme" = OLD_CHARACTER_COLORING,
"neckfire" = FALSE,
"neckfire_color" = "ffffff",
"puddle_slime_fea" = FALSE
)

	var/list/custom_emote_panel = list() //user custom emote panel

	var/custom_speech_verb = "default" //if your say_mod is to be something other than your races
	var/custom_tongue = "default" //if your tongue is to be something other than your races
	var/list/language = list() //additional language your character has
	var/modified_limbs = list() //prosthetic/amputated limbs
	var/chosen_limb_id //body sprite selected to load for the users limbs, null means default, is sanitized when loaded

	// Vocal bark prefs
	var/bark_id = "mutedc3"
	var/bark_speed = 4
	var/bark_pitch = 1
	var/bark_variance = 0.2
	COOLDOWN_DECLARE(bark_previewing)
	COOLDOWN_DECLARE(deathsound_preview)	// BLUEMOON ADD - пользовательский эмоут смерти
	COOLDOWN_DECLARE(laugh_preview)			// BLUEMOON ADD - выбор своего смеха

	/// Security record note section
	var/security_records
	/// Medical record note section
	var/medical_records

	var/list/custom_names = list()
	var/preferred_ai_core_display = "Blue"
	var/prefered_security_department = SEC_DEPT_RANDOM
	var/custom_species = null

	//Quirk list
	var/list/all_quirks = list()

	//Quirk category currently selected
	var/quirk_category = QUIRK_POSITIVE // defaults to positive, the first tab!

	//Job preferences 2.0 - indexed by job title , no key or value implies never
	var/list/job_preferences = list()

	// Want randomjob if preferences already filled - Donkie
	var/joblessrole = RETURNTOLOBBY  //defaults to 1 for fewer assistants // BLUEMOON EDIT - было BERANDOMJOB, выставил возвращение в лобби, чтобы не ливали в крио

	// 0 = character settings, 1 = game preferences
	var/current_tab = SETTINGS_TAB

	var/unlock_content = 0

	var/list/ignoring = list()

	var/clientfps = 120

	var/parallax = PARALLAX_INSANE

	var/fullscreen = TRUE

	var/ambientocclusion = TRUE
	var/lighting_blur = LIGHTING_BLUR_DEFAULT
	///Should we automatically fit the viewport?
	var/auto_fit_viewport = FALSE
	///Should we be in the widescreen mode set by the config?
	var/widescreenpref = TRUE
	///Strip menu style
	var/long_strip_menu = TRUE
	///What size should pixels be displayed as? 0 is strech to fit
	var/pixel_size = 0
	///What scaling method should we use?
	var/scaling_method = "normal"
	var/uplink_spawn_loc = UPLINK_PDA
	///The playtime_reward_cloak variable can be set to TRUE from the prefs menu only once the user has gained over 5K playtime hours. If true, it allows the user to get a cool looking roundstart cloak.
	var/playtime_reward_cloak = FALSE

	var/hud_toggle_flash = TRUE
	var/hud_toggle_color = "#ffffff"

	var/list/exp = list()
	var/list/menuoptions

	var/action_buttons_screen_locs = list()

	//bad stuff
	var/vore_flags = 0
	var/list/belly_prefs = list()
	var/vore_taste = "nothing in particular"
	var/vore_smell = null
	var/toggleeatingnoise = TRUE
	var/toggledigestionnoise = TRUE
	var/hound_sleeper = TRUE
	var/cit_toggles = TOGGLES_CITADEL

	//backgrounds
	var/mutable_appearance/character_background
	var/icon/bgstate = "steel"
	var/list/bgstate_options = list("000", "midgrey", "FFF", "white", "steel", "techmaint", "dark", "plating", "reinforced")

	var/show_mismatched_markings = FALSE //determines whether or not the markings lists should show markings that don't match the currently selected species. Intentionally left unsaved.

	var/character_settings_tab = GENERAL_CHAR_TAB
	var/appearance_subtab = APPEARANCE_SUBTAB_BODY
	var/preferences_tab = GAME_PREFS_TAB
	var/preview_pref = PREVIEW_PREF_JOB
	var/preview_direction = SOUTH
	var/preview_icon64 = null
	// Guard flag — TRUE пока ассинхронная генерация работает.
	var/preview_generating = FALSE

	var/no_tetris_storage = FALSE

	///loadout stuff
	var/gear_points = 20 // Больше очков - сочнее персонажи.
	var/list/gear_categories
	var/list/loadout_data = list()
	var/list/unlockable_loadout_data = list()
	var/loadout_slot = 1 //goes from 1 to MAXIMUM_LOADOUT_SAVES
	var/loadout_enabled = TRUE // BLUEMOON ADD - переключатель: спавниться с лодаутом или нет
	var/gear_category
	var/gear_subcategory

	var/screenshake = 100
	var/damagescreenshake = 2
	var/recoil_screenshake = 100
	var/arousable = TRUE
	var/sexknotting = FALSE // BLUEMOON ADD
	var/autostand = TRUE
	var/auto_ooc = FALSE

	///This var stores the amount of points the owner will get for making it out alive.
	var/hardcore_survival_score = 0

	///Someone thought we were nice! We get a little heart in OOC until we join the server past the below time (we can keep it until the end of the round otherwise)
	var/hearted
	///If we have a hearted commendations, we honor it every time the player loads preferences until this time has been passed
	var/hearted_until
	/// If we have persistent scars enabled
	var/persistent_scars = TRUE
	///If we want to broadcast deadchat connect/disconnect messages
	var/broadcast_login_logout = TRUE
	///What outfit typepaths we've favorited in the SelectEquipment menu
	var/list/favorite_outfits = list()
	/// We have 5 slots for persistent scars, if enabled we pick a random one to load (empty by default) and scars at the end of the shift if we survived as our original person
	var/list/scars_list = list("1" = "", "2" = "", "3" = "", "4" = "", "5" = "")
	/// Which of the 5 persistent scar slots we randomly roll to load for this round, if enabled. Actually rolled in [/datum/preferences/proc/load_character(slot)]
	var/scars_index = 1

	var/hide_ckey = FALSE //pref for hiding if your ckey shows round-end or not

	var/list/tcg_cards = list()
	var/list/tcg_decks = list()

	//SPLURT EDIT - gregnancy
	/// Does john spaceman's cum actually impregnate people?
	var/virility = 0
	/// Can john spaceman get gregnant if all conditions are right? (has a womb and is not on contraceptives)
	var/fertility = 0
	/// Does john spaceman look like a gluttonous slob if he pregent?
	var/pregnancy_inflation = FALSE
	/// Self explanitory
	var/pregnancy_breast_growth = FALSE

	var/egg_shell = "chicken"
	//SPLURT END

	var/loadout_errors = 0

	var/pref_queue
	var/char_queue

	var/silicon_lawset

	var/preferred_chaos_level = 2
	var/auto_capitalize_enabled = FALSE

	var/charcreation_theme = "modern"

	/// Modern character creator: button shape preset (persisted).
	/// Supported values: "rect", "soft", "round".
	var/modern_button_shape = "round"

	/// Modern custom theme (player-configurable palette).
	var/modern_custom_enabled = FALSE
	var/modern_custom_bg_primary = "121212"
	var/modern_custom_bg_secondary = "1c1c1c"
	var/modern_custom_text_primary = "e6e6e6"
	var/modern_custom_text_secondary = "a8a8a8"
	var/modern_custom_button_bg = "1f1f1f"
	var/modern_custom_button_hover = "2a2a2a"
	var/modern_custom_button_active = "4da3ff"
	var/modern_custom_button_text = "0b1c2f"
	var/modern_custom_border_color = "2f2f2f"
	var/modern_custom_accent_color = "4da3ff"
	/// 0 = none, 1 = subtle stripes
	var/modern_custom_bg_pattern = 0
	/// UI-only state (not persisted)
	var/tmp/modern_custom_editor_open = FALSE
	/// UI-only state (not persisted): collapse the top-right theme picker
	var/tmp/modern_theme_picker_collapsed = TRUE /// UI tweak
	/// UI-only state (not persisted): play a one-shot collapse/expand animation on next render
	var/tmp/modern_theme_picker_animate = FALSE
	/// UI-only state (not persisted): open/close the quick settings popover (WIP)
	var/tmp/modern_theme_settings_open = FALSE
	/// UI state: collapse empty character slots in the top slot list (persisted in preferences)
	var/collapse_empty_character_slots = FALSE
	/// UI decoration level for modern theme: "minimal" (performance), "standard" (current), "enhanced" (gradients)
	var/ui_decoration_level = "enhanced"

	// Splurt extras
	var/unholypref = "No" //Goin 2 hell fo dis one
	var/list/gfluid_blacklist = list() //Stuff you don't want people to cum into you
	var/fuzzy = FALSE //Fuzzy scaling

	// BlueMoon extras
	var/body_weight = NAME_WEIGHT_NORMAL
	var/normalized_size = RESIZE_NORMAL
	var/custom_laugh = "Default"

	// Sand extras
	/// My favorites! they show up in their own tab inside the ui.
	var/list/favorite_interactions
	/// Enable the 'arousal_multiplier' to be applied to lust amount
	var/use_arousal_multiplier = FALSE
	/// A separate arousal multiplier that the user has control of (although we could just tap into lust or replace it.)
	var/arousal_multiplier = 100
	/// Enable the 'moaning_multiplier' to be used as a % chance of moaning instead of default calculation.
	var/use_moaning_multiplier = FALSE
	/// Chance of moaning during an interaction
	var/moaning_multiplier = 65
	var/datum/character_offer_instance/offer

	// BlueMoon jukebox
	var/list/favorite_tracks = list()
	/// Ключем будет имя плейлиста, а значением, лист с треками.
	var/list/playlists = list()
	var/list/favorite_paintings_md5 = list()

/datum/preferences/New(client/C)
	// Build readable fluids list if needed
	if(!GLOB.genital_fluids_list)
		build_genital_fluids_list()
	// Set save slot count from config
	max_save_slots = CONFIG_GET(number/base_save_slots)

	parent = C

	for(var/custom_name_id in GLOB.preferences_custom_names)
		custom_names[custom_name_id] = get_default_name(custom_name_id)

	UI_style = GLOB.available_ui_styles[1]
	if(istype(C))
		// Donator save slot bonus
		if(IS_CKEY_DONATOR_GROUP(C.key, DONATOR_GROUP_TIER_3))
			max_save_slots += 30
		else if(IS_CKEY_DONATOR_GROUP(C.key, DONATOR_GROUP_TIER_2))
			max_save_slots += 20
		else if(IS_CKEY_DONATOR_GROUP(C.key, DONATOR_GROUP_TIER_1))
			max_save_slots += 10
		if(!IsGuestKey(C.key))
			load_path(C.ckey)
			unlock_content = C.IsByondMember() || IS_CKEY_DONATOR_GROUP(C.key, DONATOR_GROUP_TIER_1)
			if(unlock_content)
				max_save_slots += 8 //SPLURT EDIT
	var/loaded_preferences_successfully = load_preferences()
	if(loaded_preferences_successfully)
		if(load_character())
			return
	//we couldn't load character data so just randomize the character appearance + name
	random_character()		//let's create a random character then - rather than a fat, bald and naked man.
	key_bindings = deepCopyList(GLOB.hotkey_keybinding_list_by_key) // give them default keybinds and update their movement keys
	C?.ensure_keys_set(src)
	real_name = pref_species.random_name(gender,1)
	if(!loaded_preferences_successfully)
		save_preferences()
	save_character()		//let's save this new random character so it doesn't keep generating new ones.
	menuoptions = list()
	return

#define SETUP_START_NODE(L)  		  	 		 	 		"<div class='csetup_character_node'><div class='csetup_character_label'>[L]</div><div class='csetup_character_input'>"

#define SETUP_GET_LINK(pref, task, task_type, value) 		"<a href='?_src_=prefs;preference=[pref][task ? ";[task_type]=[task]" : ""]'>[value]</a>"
#define SETUP_GET_LINK_RANDOM(random_type) 		  	 		"<a href='?_src_=prefs;preference=toggle_random;random_type=[random_type]'>[randomise[random_type] ? "🎲" : "🔒"]</a>"
#define SETUP_COLOR_BOX(color) 				  	 	 		"<span style='border: 1px solid #161616; background-color: #[color];'>&nbsp;&nbsp;&nbsp;</span>"

#define SETUP_NODE_SWITCH(label, pref, value)		  		"[SETUP_START_NODE(label)][SETUP_GET_LINK(pref, null, null, value)][SETUP_CLOSE_NODE]"
#define SETUP_NODE_INPUT(label, pref, value)		  		"[SETUP_START_NODE(label)][SETUP_GET_LINK(pref, "input", "task", value)][SETUP_CLOSE_NODE]"
#define SETUP_NODE_COLOR(label, pref, color, random)  		"[SETUP_START_NODE(label)][SETUP_COLOR_BOX(color)][SETUP_GET_LINK(pref, "input", "task", "Изменить")][random ? "[SETUP_GET_LINK_RANDOM(random)]" : ""][SETUP_CLOSE_NODE]"
#define SETUP_NODE_RANDOM(label, random)		  	  		"[SETUP_START_NODE(label)][SETUP_GET_LINK_RANDOM(random)][SETUP_CLOSE_NODE]"
#define SETUP_NODE_INPUT_RANDOM(label, pref, value, random) "[SETUP_START_NODE(label)][SETUP_GET_LINK(pref, "input", "task", value)][SETUP_GET_LINK_RANDOM(random)][SETUP_CLOSE_NODE]"
#define SETUP_NODE_COLOR_RANDOM(label, pref, color, random) "[SETUP_START_NODE(label)][SETUP_COLOR_BOX(color)][SETUP_GET_LINK(pref, "input", "task", "Изменить")][SETUP_GET_LINK_RANDOM(random)][SETUP_CLOSE_NODE]"

#define SETUP_CLOSE_NODE 	  			  			  		"</div></div>"

#define APPEARANCE_CATEGORY_COLUMN "<td valign='top' width='17%'>"
#define MAX_MUTANT_ROWS 5

/datum/preferences/proc/T(key, fallback = "")
	var/result = get_modern_text(key, src, fallback)
	return result

/// Возвращает палитру для Modern Character Setup (конкретные цвета, без CSS variables).
/datum/preferences/proc/get_character_setup_palette_modern()
	var/list/theme_colors = list()

	switch(charcreation_theme)
		if("modern_custom")
			// Player-configurable palette (saved in preferences).
			// The enable toggle controls whether saved custom values are applied.
			var/use_custom = !!modern_custom_enabled
			var/bg_primary = use_custom ? modern_custom_bg_primary : initial(modern_custom_bg_primary)
			var/bg_secondary = use_custom ? modern_custom_bg_secondary : initial(modern_custom_bg_secondary)
			var/text_primary = use_custom ? modern_custom_text_primary : initial(modern_custom_text_primary)
			var/text_secondary = use_custom ? modern_custom_text_secondary : initial(modern_custom_text_secondary)
			var/button_bg = use_custom ? modern_custom_button_bg : initial(modern_custom_button_bg)
			var/button_hover = use_custom ? modern_custom_button_hover : initial(modern_custom_button_hover)
			var/button_active = use_custom ? modern_custom_button_active : initial(modern_custom_button_active)
			var/button_text = use_custom ? modern_custom_button_text : initial(modern_custom_button_text)
			var/border_color = use_custom ? modern_custom_border_color : initial(modern_custom_border_color)
			var/accent_color = use_custom ? modern_custom_accent_color : initial(modern_custom_accent_color)

			theme_colors["bg_primary"] = "#[bg_primary]"
			theme_colors["bg_secondary"] = "#[bg_secondary]"
			if(use_custom && modern_custom_bg_pattern)
				theme_colors["bg_pattern"] = "repeating-linear-gradient(90deg, rgba(255,255,255,0.06) 0px, rgba(255,255,255,0.06) 10px, rgba(0,0,0,0.06) 10px, rgba(0,0,0,0.06) 20px)"
			else
				theme_colors["bg_pattern"] = "none"
			theme_colors["text_primary"] = "#[text_primary]"
			theme_colors["text_secondary"] = "#[text_secondary]"
			theme_colors["button_bg"] = "#[button_bg]"
			theme_colors["button_hover"] = "#[button_hover]"
			theme_colors["button_active"] = "#[button_active]"
			theme_colors["button_text"] = "#[button_text]"
			theme_colors["border_color"] = "#[border_color]"
			theme_colors["accent_color"] = "#[accent_color]"

		if("modern_classic")
			// PR theme: "classic" (BYOND-ish palette)
			theme_colors["bg_primary"] = "#272727"
			theme_colors["bg_secondary"] = "#1a1a1a"
			theme_colors["bg_pattern"] = "none"
			theme_colors["text_primary"] = "#ffffff"
			theme_colors["text_secondary"] = "#c0c0c0"
			theme_colors["button_bg"] = "#40628a"
			theme_colors["button_hover"] = "#2f943c"
			theme_colors["button_active"] = "#2f943c"
			theme_colors["button_text"] = "#ffffff"
			theme_colors["border_color"] = "#161616"
			theme_colors["accent_color"] = "#40628a"

		if("modern_neutral")
			// PR theme: "neutral"
			theme_colors["bg_primary"] = "#f2f2f2"
			theme_colors["bg_secondary"] = "#ffffff"
			theme_colors["bg_pattern"] = "repeating-linear-gradient(90deg, rgba(255,255,255,0.32) 0px, rgba(255,255,255,0.32) 10px, rgba(0,0,0,0.035) 10px, rgba(0,0,0,0.035) 20px)"
			theme_colors["text_primary"] = "#222222"
			theme_colors["text_secondary"] = "#555555"
			theme_colors["button_bg"] = "#e4e4e4"
			theme_colors["button_hover"] = "#d9d9d9"
			theme_colors["button_active"] = "#e0e7ff"
			theme_colors["button_text"] = "#1f2b4d"
			theme_colors["border_color"] = "#cccccc"
			theme_colors["accent_color"] = "#6a8cff"

		if("modern_purple")
			theme_colors["bg_primary"] = "#251a33"
			theme_colors["bg_secondary"] = "#2f2141"
			theme_colors["bg_pattern"] = "none"
			theme_colors["text_primary"] = "#f7f1ff"
			theme_colors["text_secondary"] = "#e1d1f5"
			theme_colors["button_bg"] = "#36244b"
			theme_colors["button_hover"] = "#422b5e"
			theme_colors["button_active"] = "#c19bff"
			theme_colors["button_text"] = "#1a0b2f"
			theme_colors["border_color"] = "#4a3562"
			theme_colors["accent_color"] = "#c19bff"

		if("modern_green")
			theme_colors["bg_primary"] = "#12261a"
			theme_colors["bg_secondary"] = "#193322"
			theme_colors["bg_pattern"] = "none"
			theme_colors["text_primary"] = "#effff6"
			theme_colors["text_secondary"] = "#cdefdc"
			theme_colors["button_bg"] = "#1f3e2a"
			theme_colors["button_hover"] = "#275036"
			theme_colors["button_active"] = "#8bffb1"
			theme_colors["button_text"] = "#062014"
			theme_colors["border_color"] = "#2a4f37"
			theme_colors["accent_color"] = "#8bffb1"

		else
			// PR theme: "dark" (default)
			theme_colors["bg_primary"] = "#121212"
			theme_colors["bg_secondary"] = "#1c1c1c"
			theme_colors["bg_pattern"] = "none"
			theme_colors["text_primary"] = "#e6e6e6"
			theme_colors["text_secondary"] = "#a8a8a8"
			theme_colors["button_bg"] = "#1f1f1f"
			theme_colors["button_hover"] = "#2a2a2a"
			theme_colors["button_active"] = "#4da3ff"
			theme_colors["button_text"] = "#0b1c2f"
			theme_colors["border_color"] = "#2f2f2f"
			theme_colors["accent_color"] = "#4da3ff"

	return theme_colors

/datum/preferences/proc/reset_modern_custom_theme()
	modern_custom_bg_primary = initial(modern_custom_bg_primary)
	modern_custom_bg_secondary = initial(modern_custom_bg_secondary)
	modern_custom_text_primary = initial(modern_custom_text_primary)
	modern_custom_text_secondary = initial(modern_custom_text_secondary)
	modern_custom_button_bg = initial(modern_custom_button_bg)
	modern_custom_button_hover = initial(modern_custom_button_hover)
	modern_custom_button_active = initial(modern_custom_button_active)
	modern_custom_button_text = initial(modern_custom_button_text)
	modern_custom_border_color = initial(modern_custom_border_color)
	modern_custom_accent_color = initial(modern_custom_accent_color)
	modern_custom_bg_pattern = initial(modern_custom_bg_pattern)

/datum/preferences/proc/set_modern_custom_color(color_key, raw_value)
	if(isnull(raw_value))
		return FALSE
	var/value = "[raw_value]"
	value = replacetext(value, "#", "")
	// normalize short forms like FFF -> FFFFFF
	if(length(value) == 3)
		value = "[copytext(value,1,2)][copytext(value,1,2)][copytext(value,2,3)][copytext(value,2,3)][copytext(value,3,4)][copytext(value,3,4)]"
	value = sanitize_hexcolor(value, 6, FALSE, null)
	if(!value)
		return FALSE
	color_key = "[color_key]"
	switch(color_key)
		if("bg_primary")
			modern_custom_bg_primary = value
			return TRUE
		if("bg_secondary")
			modern_custom_bg_secondary = value
			return TRUE
		if("text_primary")
			modern_custom_text_primary = value
			return TRUE
		if("text_secondary")
			modern_custom_text_secondary = value
			return TRUE
		if("button_bg")
			modern_custom_button_bg = value
			return TRUE
		if("button_hover")
			modern_custom_button_hover = value
			return TRUE
		if("button_active")
			modern_custom_button_active = value
			return TRUE
		if("button_text")
			modern_custom_button_text = value
			return TRUE
		if("border_color")
			modern_custom_border_color = value
			return TRUE
		if("accent_color")
			modern_custom_accent_color = value
			return TRUE
	return FALSE

