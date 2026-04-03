/proc/get_modern_text(key, datum/preferences/prefs, fallback = "")
	if(!GLOB.modern_strings || !length(GLOB.modern_strings))
		init_modern_strings()
	if(!key)
		return fallback
	if(!GLOB.modern_strings || !GLOB.modern_strings[key])
		return fallback ? fallback : key
	var/list/entry = GLOB.modern_strings[key]
	if(!islist(entry))
		return fallback ? fallback : key
	var/lang = "en"
	if(prefs?.modern_ui_language)
		lang = "ru"
	if(entry[lang])
		return entry[lang]
	if(entry["en"])
		return entry["en"]
	return fallback ? fallback : key

/proc/get_modern_language_selector(datum/preferences/prefs)
	if(!prefs)
		return ""
	var/lang_ru = prefs.modern_ui_language ? "linkOn" : ""
	var/lang_en = prefs.modern_ui_language ? "" : "linkOn"
	var/html = ""
	html += "<a class='[lang_ru]' href='?_src_=prefs;preference=modern_theme_settings;action=set_language;lang=ru'>Русский</a>"
	html += "<a class='[lang_en]' href='?_src_=prefs;preference=modern_theme_settings;action=set_language;lang=en'>English</a>"
	return html

// "ключ" = list("ru" = "...", "en" = "...")
/proc/init_modern_strings()
	if(GLOB.modern_strings && length(GLOB.modern_strings))
		return
	GLOB.modern_strings = list(
	// Main interface tabs
	"tab_character_settings" = list("ru" = "Настройки персонажа",   "en" = "Character Settings"),
	"tab_preferences"        = list("ru" = "Настройки",             "en" = "Preferences"),
	"tab_keybindings"        = list("ru" = "Горячие клавиши",       "en" = "Keybindings"),

	// Theme and UI settings
	"themes"             = list("ru" = "Темы",                      "en" = "Themes"),
	"settings"           = list("ru" = "Настройки",                 "en" = "Settings"),
	"button_shape"       = list("ru" = "Рамка кнопок",              "en" = "Button Shape"),
	"shape_rect"         = list("ru" = "Квадрат",                   "en" = "Rectangular"),
	"shape_round"        = list("ru" = "Круг",                      "en" = "Round"),
	"shape_soft"         = list("ru" = "Мягкая",                    "en" = "Soft"),
	"interface_language" = list("ru" = "Язык интерфейса",           "en" = "Interface Language"),
	"lang_ru"            = list("ru" = "Русский",                   "en" = "Русский"),
	"lang_en"            = list("ru" = "English",                   "en" = "English"),
	"collapse_hint"      = list("ru" = "Развернуть меню тем",       "en" = "Collapse theme menu"),
	"settings_gear"      = list("ru" = "Настройки (WIP)",           "en" = "Settings (WIP)"),

	// UI Decoration Level
	"ui_decoration_title"   = list("ru" = "Оформление интерфейса",  "en" = "UI Decoration"),
	"ui_decoration_hint"    = list("ru" = "Влияет на производительность", "en" = "Affects performance"),
	"ui_decoration_minimal" = list("ru" = "Минимальное",            "en" = "Minimal"),
	"ui_decoration_standard"= list("ru" = "Стандартное",            "en" = "Standard"),
	"ui_decoration_enhanced"= list("ru" = "Улучшенное",             "en" = "Enhanced"),

	// Theme names
	"theme_classic"   = list("ru" = "Классик",           "en" = "Classic"),
	"theme_dark_blue" = list("ru" = "Темный (Синий)",    "en" = "Dark (Blue)"),
	"theme_purple"    = list("ru" = "Фиолетовый",        "en" = "Purple"),
	"theme_green"     = list("ru" = "Зеленый",           "en" = "Green"),
	"theme_neutral"   = list("ru" = "Нейтральный",       "en" = "Neutral"),
	"theme_custom"    = list("ru" = "Пользовательский",  "en" = "Custom"),

	// Character preview options
	"preview_title"         = list("ru" = "Предпросмотр",    "en" = "Preview"),
	"preview_job"           = list("ru" = "Работа",          "en" = "Job"),
	"preview_loadout"       = list("ru" = "Снаряжение",      "en" = "Loadout"),
	"preview_naked"         = list("ru" = "Нагота",          "en" = "Naked"),
	"preview_naked_aroused" = list("ru" = "Возбужденный",    "en" = "Naked (aroused)"),

	// Character creation tabs
	"char_tab_general"     = list("ru" = "Основное",     "en" = "General"),
	"char_tab_background"  = list("ru" = "Досье",        "en" = "Background"),
	"char_tab_appearance"  = list("ru" = "Внешность",    "en" = "Appearance"),
	"char_tab_markings"    = list("ru" = "Отметины",     "en" = "Markings"),
	"char_tab_speech"      = list("ru" = "Речь",         "en" = "Speech"),
	"char_tab_loadout"     = list("ru" = "Снаряжение",   "en" = "Loadout"),
	"char_tab_quirks"      = list("ru" = "Особенности",  "en" = "Quirks"),

	// Quirks tab labels
	"quirks_disabled" = list("ru" = "Особенности отключены на этом сервере.", "en" = "Quirks are disabled on this server."),

	// Character slots
	"local_storage"    = list("ru" = "Локальное хранилище",                       "en" = "Local storage"),
	"empty_slot_label" = list("ru" = "Персонаж",                                  "en" = "Character"),
	"export_slot"      = list("ru" = "Экспорт слота",                             "en" = "Export slot"),
	"import_slot"      = list("ru" = "Импорт слота",                              "en" = "Import into current slot"),
	"delete_local"     = list("ru" = "Удалить локально сохраненного персонажа",   "en" = "Delete locally saved character"),
	"delete_slot_label"= list("ru" = "Удалить текущего персонажа",                "en" = "Delete current character"),
	"offer_slot"       = list("ru" = "Предложить слот",                           "en" = "Offer slot"),
	"cancel_offer"     = list("ru" = "Отменить предложение",                      "en" = "Cancel offer"),
	"retrieve_offered" = list("ru" = "Получить предложенного персонажа",          "en" = "Retrieve offered character"),
	"redemption_code"  = list("ru" = "Код слота",                                 "en" = "Redemption code"),
	"empty_label"      = list("ru" = "Пусто",                                     "en" = "Empty"),
	"offer_auto_cancel"= list("ru" = "Предложение автоматически будет отменено при ошибке или если кто-то его примет", "en" = "The offer will automatically be cancelled if there is an error, or if someone takes it"),

	// Background tab labels
	"flavor_text"            = list("ru" = "Описание персонажа",                "en" = "Flavor Text"),
	"flavor_text_header"     = list("ru" = "Описание персонажа",                "en" = "Flavor Text"),
	"set_examine_text"       = list("ru" = "Изменить",                          "en" = "Set Examine Text"),
	"set_flavor_text"        = list("ru" = "Изменить",                          "en" = "Set Examine Text"),
	"naked_flavor_text"      = list("ru" = "Описание голого персонажа",         "en" = "Naked Flavor Text"),
	"set_naked_examine_text" = list("ru" = "Изменить",                          "en" = "Set Naked Examine Text"),
	"set_naked_flavor_text"  = list("ru" = "Изменить",                          "en" = "Set Naked Examine Text"),
	"custom_deathgasp"       = list("ru" = "Описание смерти",                   "en" = "Custom Deathgasp"),
	"set_custom_deathgasp"   = list("ru" = "Изменить",                          "en" = "Set Custom Deathgasp"),
	"custom_deathsound"      = list("ru" = "Пользовательский звук смерти",      "en" = "Custom Deathsound"),
	"set_custom_deathsound"  = list("ru" = "Изменить",                          "en" = "Set Custom Deathsound"),
	"preview_deathsound"     = list("ru" = "Предпросмотр звука",                "en" = "Preview Deathsound"),
	"silicon_flavor_text"    = list("ru" = "Описание силикона",                 "en" = "Silicon Flavor Text"),
	"set_silicon_examine_text" = list("ru" = "Изменить",                        "en" = "Set Silicon Examine Text"),
	"set_silicon_flavor_text"= list("ru" = "Изменить",                          "en" = "Set Silicon Examine Text"),
	"custom_species_lore"    = list("ru" = "Предистория вида",				    "en" = "Custom Species Lore"),
	"set_custom_species_lore"= list("ru" = "Изменить",                          "en" = "Set Custom Species Lore Text"),
	"ooc_notes"              = list("ru" = "OOC заметки",                       "en" = "OOC notes"),
	"set_ooc_notes"          = list("ru" = "Изменить",                          "en" = "Set OOC notes"),
	"records"                = list("ru" = "Записи",                            "en" = "Records"),
	"records_header"         = list("ru" = "Записи",                            "en" = "Records"),
	"security_records"       = list("ru" = "Записи безопасности",               "en" = "Security Records"),
	"set_security_records"   = list("ru" = "Установить записи безопасности",    "en" = "Security Records"),
	"medical_records"        = list("ru" = "Медицинские записи",                "en" = "Medical Records"),
	"set_medical_records"    = list("ru" = "Установить медицинские записи",     "en" = "Medical Records"),
	"headshots"              = list("ru" = "Фотографии",                        "en" = "Headshots"),
	"set_headshot_1"         = list("ru" = "Установить фотографию 1",           "en" = "Set Headshot 1 Image"),
	"set_headshot_2"         = list("ru" = "Установить фотографию 2",           "en" = "Set Headshot 2 Image"),
	"set_headshot_3"         = list("ru" = "Установить фотографию 3",           "en" = "Set Headshot 3 Image"),
	"naked_headshots"        = list("ru" = "Портреты (NSFW)",                   "en" = "Naked (NSFW) Headshots"),
	"set_naked_headshot_1"   = list("ru" = "Установить фотографию 1",           "en" = "Set Headshot 1 Image"),
	"set_naked_headshot_2"   = list("ru" = "Установить фотографию 2",           "en" = "Set Headshot 2 Image"),
	"set_naked_headshot_3"   = list("ru" = "Установить фотографию 3",           "en" = "Set Headshot 3 Image"),
	"set_headshot_image"     = list("ru" = "Установить изображение",            "en" = "Set Headshot Image"),

	// Identity section
	"identity"               = list("ru" = "Личность",                          "en" = "Identity"),
	"gender"                 = list("ru" = "Пол",                               "en" = "Gender"),
	"name_label"             = list("ru" = "Имя",                               "en" = "Name"),
	"name"                   = list("ru" = "Имя",                               "en" = "Name"),
	"default_designation"    = list("ru" = "Обозначение по умолчанию",          "en" = "Default designation"),
	"set_name"               = list("ru" = "Установить имя",                    "en" = "Set name"),
	"random_name"            = list("ru" = "Случайное имя",                     "en" = "Random name"),
	"random_name_title"      = list("ru" = "Рандомное имя",                     "en" = "Random name"),
	"hide_ckey"              = list("ru" = "Скрыть ckey",                       "en" = "Hide ckey"),
	"be_nameless"            = list("ru" = "Без имени",                         "en" = "Be nameless"),
	"yes"                    = list("ru" = "Да",                                "en" = "Yes"),
	"no"                     = list("ru" = "Нет",                               "en" = "No"),
	"always_random_name"     = list("ru" = "Случайное имя",                     "en" = "Always Random Name"),
	"points_left"            = list("ru" = "очков осталось",                    "en" = "points left"),
	"lawset_not_found"       = list("ru" = "Не удалось найти законы для вашего набора, извините  <font style='translate: rotate(90deg)'>:(</font>", "en" = "I was unable to find the laws for your lawset, sorry  <font style='translate: rotate(90deg)'>:(</font>"),
	"hardsuit_with_tail"     = list("ru" = "Харсьют с хвостом",                 "en" = "Hardsuit With Tail"),
	"age_label"              = list("ru" = "Возраст",                           "en" = "Age"),
	"set_age"                = list("ru" = "Установить возраст",                "en" = "Set age"),

	// Blood and appearance
	"custom_blood_color"     = list("ru" = "Кастомный цвет крови",              "en" = "Custom blood color"),
	"blood_color"            = list("ru" = "Цвет крови",                        "en" = "Blood color"),
	"blood_color_label"      = list("ru" = "Цвет крови",                        "en" = "Blood color"),

	// Special names
	"special_names"          = list("ru" = "Специальные имена",                 "en" = "Special Names"),

	// Job preferences
	"occupation_choices"     = list("ru" = "Выбор профессии",                   "en" = "Occupation Choices"),
	"set_occupation_prefs"   = list("ru" = "Установить приоритет профессий",    "en" = "Set Occupation Preferences"),
	"set_occupation_preferences" = list("ru" = "Установить приоритет профессий","en" = "Set Occupation Preferences"),
	"custom_job_preferences" = list("ru" = "Предпочтения профессий",            "en" = "Custom job preferences"),
	"preferred_security_dept"= list("ru" = "Предпочтительный отдел безопасности","en" = "Preferred Security Department"),
	"preferred_ai_core"      = list("ru" = "Предпочтительное отображение ядра ИИ","en" = "Preferred AI Core Display"),
	"preferred_ai_core_display" = list("ru" = "Предпочтительное отображение ядра ИИ","en" = "Preferred AI Core Display"),

	// PDA section
	"pda_preferences"        = list("ru" = "Настройки PDA",                     "en" = "PDA Preferences"),
	"pda_color"              = list("ru" = "Цвет PDA",                          "en" = "PDA Color"),
	"set_pda_color"          = list("ru" = "Установить цвет PDA",               "en" = "Set PDA color"),
	"pda_style"              = list("ru" = "Стиль PDA",                         "en" = "PDA Style"),
	"set_pda_style"          = list("ru" = "Интерфейс PDA",                     "en" = "Set PDA style"),
	"pda_reskin"             = list("ru" = "Корпус PDA",                     	"en" = "PDA Reskin"),
	"set_pda_reskin"         = list("ru" = "Вид PDA",                           "en" = "Set PDA reskin"),
	"pda_ringtone"           = list("ru" = "Рингтон PDA",                       "en" = "PDA Ringtone"),
	"set_pda_ringtone"       = list("ru" = "Установить рингтон PDA",            "en" = "Set PDA ringtone"),

	// Silicon preferences
	"silicon_preferences"    = list("ru" = "Предпочтения силиконов",            "en" = "Silicon preferences"),
	"starting_lawset"        = list("ru" = "Начальный набор законов",           "en" = "Starting lawset"),
	"server_default"         = list("ru" = "По умолчанию сервера",              "en" = "Server Default"),
	"server_has_disabled_laws" = list("ru" = "Сервер отключил выбор собственных законов, но вы все еще можете выбирать и сохранять.", "en" = "The server has disabled choosing your own laws, you can still choose and save, but it won't do anything in-game."),
	"you_are_banned"         = list("ru" = "Вам запрещено использовать собственные имена и внешность. Вы можете продолжить настройку персонажей, но будете рандомизированы при входе в игру.", "en" = "You are forbidden to use custom names and appearance. You can continue to set up your characters, but you will be randomized upon joining the game."),

	// Quirks section
	"quirk_balance_remaining"= list("ru" = "Очков особенностей осталось:",      "en" = "Quirk balance remaining:"),
	"current_quirks"         = list("ru" = "Текущие особенности",               "en" = "Current Quirks"),
	"current"                = list("ru" = "Текущие:",                          "en" = "Current:"),
	"configure_quirks"       = list("ru" = "Настроить особенности",             "en" = "Configure Quirks"),
	"open_quirks_tab"        = list("ru" = "Открыть вкладку квирков",           "en" = "Open Quirks Tab"),
	"quirk_setup"            = list("ru" = "Настройка особенностей",            "en" = "Quirk setup"),
	"none"                   = list("ru" = "Нет",                               "en" = "None"),

	// Notifications
	"no_account_message"     = list("ru" = "Пожалуйста, создайте аккаунт для сохранения предпочтений", "en" = "Please create an account to save your preferences"),
	"saved_preferences"      = list("ru" = "Предпочтения сохранены!",           "en" = "Saved preferences!"),
	"saving_preferences"     = list("ru" = "Сохранение предпочтений за",        "en" = "Saving preferences in"),
	"second"                 = list("ru" = "секунду",                           "en" = "second"),
	"seconds"                = list("ru" = "секунд",                            "en" = "seconds"),

	// Genders
	"male"                   = list("ru" = "Мужчина",                           "en" = "Male"),
	"female"                 = list("ru" = "Женщина",                           "en" = "Female"),
	"non_binary"             = list("ru" = "Небинарный",                        "en" = "Non-binary"),
	"plural"                 = list("ru" = "Множественное",                     "en" = "Plural"),
	"object"                 = list("ru" = "Объект",                            "en" = "Object"),

	// Points
	"point"                  = list("ru" = "очко",                              "en" = "point"),
	"points"                 = list("ru" = "очков",                             "en" = "points"),
	"remaining"              = list("ru" = "осталось",                          "en" = "remaining"),

	// Appearance tab subtabs
	"app_sub_body"           = list("ru" = "Тело",                              "en" = "Body"),
	"app_sub_hair"           = list("ru" = "Волосы",                            "en" = "Hair"),
	"app_sub_mutparts"       = list("ru" = "Мутпарты",                          "en" = "Mutant Parts"),
	"app_sub_intimacy"       = list("ru" = "Интимное",                          "en" = "Intimacy"),

	// Appearance body section
	"body"                   = list("ru" = "Тело",                              "en" = "Body"),
	"body_model"             = list("ru" = "Модель тела",                       "en" = "Body Model"),
	"body_model_masc"        = list("ru" = "Маскулинная",                       "en" = "Masculine"),
	"body_model_fem"         = list("ru" = "Фемининная",                        "en" = "Feminine"),
	"advanced_colors"        = list("ru" = "Расширенные цвета",                 "en" = "Advanced Colors"),
	"advanced_colors_hint"   = list("ru" = "Включает расширенную раскраску отдельных частей тела (если поддерживается видом).", "en" = "Enables advanced coloring of individual body parts (if supported by species)."),
	"mismatched_parts"       = list("ru" = "Несоответствующие части",           "en" = "Mismatched Parts"),
	"mismatched_parts_hint"  = list("ru" = "Показывать части/маркинги, которые не подходят текущему виду.", "en" = "Show parts/markings that don't match the current species."),
	"show_mismatched"        = list("ru" = "Показать несовместимые части",      "en" = "Show Mismatched Parts"),
	"limb_modification"      = list("ru" = "Модификация конечностей",           "en" = "Limb Modification"),
	"modify_limbs"           = list("ru" = "Модифицировать конечности",         "en" = "Modify Limbs"),
	"species"                = list("ru" = "Вид",                               "en" = "Species"),
	"species_label"          = list("ru" = "Вид",                               "en" = "Species"),
	"custom_species_name"    = list("ru" = "Пользовательское имя вида",         "en" = "Custom Species Name"),
	"random_body"            = list("ru" = "Случайное тело",                    "en" = "Random Body"),
	"randomize"              = list("ru" = "Рандомизировать",                   "en" = "Randomize"),
	"always_random_body"     = list("ru" = "Всегда случайное тело",             "en" = "Always Random Body"),
	"cycle_background"       = list("ru" = "Цикл фона",                         "en" = "Cycle Background"),

	// Skin and body colors
	"skin_tone"              = list("ru" = "Тон кожи",                          "en" = "Skin Tone"),
	"set_skin_tone"          = list("ru" = "Установить тон кожи",               "en" = "Set Skin Tone"),
	"body_colors"            = list("ru" = "Цвета тела",                        "en" = "Body Colors"),
	"primary_color"          = list("ru" = "Основной цвет",                     "en" = "Primary Color"),
	"secondary_color"        = list("ru" = "Вторичный цвет",                    "en" = "Secondary Color"),
	"tertiary_color"         = list("ru" = "Третичный цвет",					"en" = "Tertiary Color"),
	"change"                 = list("ru" = "Изменить",							"en" = "Change"),
	"invalid_label"          = list("ru" = "НЕДОПУСТИМО",						"en" = "INVALID"),
	"genitals_use_skintone"  = list("ru" = "Гениталии используют тон кожи",		"en" = "Genitals Use Skin Tone"),

	// Body size
	"body_size"              = list("ru" = "Размер тела",						"en" = "Body Size"),
	"normalized_size"        = list("ru" = "Нормализованный размер",			"en" = "Normalized Size"),
	"scaled_appearance"      = list("ru" = "Масштабированное появление",		"en" = "Scaled Appearance"),
	"fuzzy"                  = list("ru" = "Размытый",							"en" = "Fuzzy"),
	"sharp"                  = list("ru" = "Резкий",							"en" = "Sharp"),
	"weight"                 = list("ru" = "Вес",								"en" = "Weight"),

	// Eyes
	"eye_type"               = list("ru" = "Тип глаз",                          "en" = "Eye Type"),
	"set_eye_type"           = list("ru" = "Установить тип глаз",               "en" = "Set Eye Type"),
	"heterochromia"          = list("ru" = "Гетерохромия",                      "en" = "Heterochromia"),
	"heterochromia_hint"     = list("ru" = "Глаза с особой гетерохромией: wide, big, bigcyclops, skrell, third, thirdbig.",
									"en" = "Eyes with special heterochromia: wide, big, bigcyclops, skrell, third, thirdbig."),
	"eye_color"              = list("ru" = "Цвет глаз",                         "en" = "Eye Color"),
	"set_eye_color"          = list("ru" = "Установить цвет глаз",              "en" = "Set Eye Color"),
	"left_eye_color"         = list("ru" = "Цвет левого глаза",                 "en" = "Left Eye Color"),
	"set_left_eye_color"     = list("ru" = "Установить цвет левого глаза",      "en" = "Set Left Eye Color"),
	"right_eye_color"        = list("ru" = "Цвет правого глаза",                "en" = "Right Eye Color"),
	"set_right_eye_color"    = list("ru" = "Установить цвет правого глаза",     "en" = "Set Right Eye Color"),
	"custom_label"           = list("ru" = "польз.",                            "en" = "custom"),

	// Hair
	"hair_style"             = list("ru" = "Стиль волос",                       "en" = "Hair Style"),
	"set_hair_style"         = list("ru" = "Установить стиль волос",            "en" = "Set Hair Style"),
	"hair_color"             = list("ru" = "Цвет волос",                        "en" = "Hair Color"),
	"set_hair_color"         = list("ru" = "Установить цвет волос",             "en" = "Set Hair Color"),
	"facial_hair_style"      = list("ru" = "Стиль бороды",                      "en" = "Facial Hair Style"),
	"set_facial_hair"        = list("ru" = "Установить бороду",                 "en" = "Set Facial Hair"),
	"facial_hair_color"      = list("ru" = "Цвет бороды",                       "en" = "Facial Hair Color"),
	"set_facial_hair_color"  = list("ru" = "Установить цвет бороды",            "en" = "Set Facial Hair Color"),
	"hair_gradient"          = list("ru" = "Градиент волос",                    "en" = "Hair Gradient"),
	"set_gradient"           = list("ru" = "Установить градиент",               "en" = "Set Gradient"),
	"gradient_color"         = list("ru" = "Цвет градиента",                    "en" = "Gradient Color"),
	"set_gradient_color"     = list("ru" = "Установить цвет градиента",         "en" = "Set Gradient Color"),

	// Body sprite
	"body_sprite"            = list("ru" = "Спрайт тела",                       "en" = "Body Sprite"),
	"set_body_sprite"        = list("ru" = "Установить спрайт тела",            "en" = "Set Body Sprite"),
	"be_slime"               = list("ru" = "Быть слизью?",                      "en" = "Be Slime?"),

	// Clothing and equipment
	"clothing_equipment"     = list("ru" = "Одежда и оборудование",             "en" = "Clothing & Equipment"),
	"backpack"               = list("ru" = "Рюкзак",                            "en" = "Backpack"),
	"set_backpack"           = list("ru" = "Установить рюкзак",                 "en" = "Set Backpack"),
	"jumpsuit"               = list("ru" = "Комбинезон",                        "en" = "Jumpsuit"),
	"set_jumpsuit"           = list("ru" = "Установить комбинезон",             "en" = "Set Jumpsuit"),
	"temporal_scarring"      = list("ru" = "Временные шрамы",                   "en" = "Temporal Scarring"),
	"persistent_scars"       = list("ru" = "Стойкие шрамы",                     "en" = "Persistent Scars"),
	"toggle_scars"           = list("ru" = "Переключить шрамы",                 "en" = "Toggle Scars"),
	"clear_scars"            = list("ru" = "Очистить слоты шрамов",             "en" = "Clear Scar Slots"),
	"clear_scar_slots"       = list("ru" = "Очистить слоты рубцов",             "en" = "Clear Scar Slots"),
	"uplink_location"        = list("ru" = "Местоположение восходящей ссылки",  "en" = "Uplink Location"),
	"set_uplink_location"    = list("ru" = "Установить расположение анлинка",   "en" = "Set Uplink Location"),
	"enabled"                = list("ru" = "Включено",                          "en" = "Enabled"),
	"disabled"               = list("ru" = "Отключено",                         "en" = "Disabled"),

	// Consent preferences
	"consent_preferences"    = list("ru" = "Предпочтения согласия",             "en" = "Consent Preferences"),
	"erp_preference"         = list("ru" = "ERP",                               "en" = "ERP"),
	"erp_pref"               = list("ru" = "ERP",                               "en" = "ERP"),
	"noncon_preference"      = list("ru" = "Non-Con",                           "en" = "Non-Con"),
	"noncon_pref"            = list("ru" = "Несогласие",                        "en" = "Non-Con"),
	"vore_preference"        = list("ru" = "Vore",                              "en" = "Vore"),
	"vore_pref"              = list("ru" = "Вор",                               "en" = "Vore"),
	"mobsex_pref"            = list("ru" = "Мобовый секс",                      "en" = "Mob Sex"),
	"hornyantags_pref"       = list("ru" = "Похотливые антаги",                 "en" = "Horny Antags"),

	// Lewd preferences
	"lewd_preferences"       = list("ru" = "Развратные предпочтения",           "en" = "Lewd Preferences"),
	"lust_tolerance"         = list("ru" = "Допуск похоти",                     "en" = "Lust Tolerance"),
	"sexual_potency"         = list("ru" = "Сексуальная потенция",              "en" = "Sexual Potency"),

	// Pregnancy preferences
	"pregnancy_preferences"  = list("ru" = "Предпочтения беременности",         "en" = "Pregnancy Preferences"),
	"chance_impregnation"    = list("ru" = "Шанс оплодотворения",               "en" = "Chance of Impregnation"),
	"chance_pregnant"        = list("ru" = "Шанс забеременеть",                 "en" = "Chance to Get Pregnant"),
	"lay_inert_eggs"         = list("ru" = "Откладывать инертные яйца",         "en" = "Lay Inert Eggs"),
	"pregnancy_inflation"    = list("ru" = "Вздутие при беременности",          "en" = "Pregnancy Inflation"),
	"pregnancy_breast_growth"= list("ru" = "Рост груди при беременности",       "en" = "Pregnancy Breast Growth"),
	"egg_shell"              = list("ru" = "Скорлупа яйца",                     "en" = "Egg Shell"),
	"set_egg_shell"          = list("ru" = "Установить скорлупу яйца",          "en" = "Set Egg Shell"),

	// Genitals - Penis
	"penis"                  = list("ru" = "Пенис",                             "en" = "Penis"),
	"has_penis"              = list("ru" = "Иметь пенис",                       "en" = "Has Penis"),
	"penis_color"            = list("ru" = "Цвет пениса",                       "en" = "Penis Color"),
	"set_penis_color"        = list("ru" = "Установить цвет пениса",            "en" = "Set Penis Color"),
	"penis_shape"            = list("ru" = "Форма пениса",                      "en" = "Penis Shape"),
	"set_penis_shape"        = list("ru" = "Установить форму пениса",           "en" = "Set Penis Shape"),
	"penis_length"           = list("ru" = "Длина пениса",                      "en" = "Penis Length"),
	"set_penis_length"       = list("ru" = "Установить длину пениса",           "en" = "Set Penis Length"),
	"penis_max_length"       = list("ru" = "Максимальная длина пениса",         "en" = "Max Penis Length"),
	"set_penis_max_length"   = list("ru" = "Установить макс длину пениса",      "en" = "Set Max Penis Length"),
	"penis_min_length"       = list("ru" = "Минимальная длина пениса",          "en" = "Min Penis Length"),
	"set_penis_min_length"   = list("ru" = "Установить мин длину пениса",       "en" = "Set Min Penis Length"),
	"penis_diameter"         = list("ru" = "Диаметр пениса",                    "en" = "Penis Diameter"),
	"set_penis_diameter"     = list("ru" = "Установить диаметр пениса",         "en" = "Set Penis Diameter"),
	"penis_visibility"       = list("ru" = "Видимость пениса",                  "en" = "Penis Visibility"),
	"set_penis_visibility"   = list("ru" = "Установить видимость пениса",       "en" = "Set Penis Visibility"),
	"penis_accessible"       = list("ru" = "Пенис всегда доступен",             "en" = "Penis Always Accessible"),
	"penis_stuffing"         = list("ru" = "Игрушки и пополнение",              "en" = "Toys & Stuffing"),

	// Genitals - Testicles
	"testicles"              = list("ru" = "Яички",                             "en" = "Testicles"),
	"has_testicles"          = list("ru" = "Иметь яички",                       "en" = "Has Testicles"),
	"testicles_color"        = list("ru" = "Цвет яичек",                        "en" = "Testicles Color"),
	"set_testicles_color"    = list("ru" = "Установить цвет яичек",             "en" = "Set Testicles Color"),
	"testicles_shape"        = list("ru" = "Форма яичек",                       "en" = "Testicles Shape"),
	"set_testicles_shape"    = list("ru" = "Установить форму яичек",            "en" = "Set Testicles Shape"),
	"testicles_size"         = list("ru" = "Размер яичек",                      "en" = "Testicles Size"),
	"set_testicles_size"     = list("ru" = "Установить размер яичек",           "en" = "Set Testicles Size"),
	"testicles_visibility"   = list("ru" = "Видимость яичек",                   "en" = "Testicles Visibility"),
	"set_testicles_visibility"= list("ru" = "Установить видимость яичек",       "en" = "Set Testicles Visibility"),
	"testicles_accessible"   = list("ru" = "Яички всегда доступны",             "en" = "Testicles Always Accessible"),
	"testicles_stuffing"     = list("ru" = "Игрушки и пополнение",              "en" = "Toys & Stuffing"),
	"testicles_max_size"     = list("ru" = "Макс размер яичек",                 "en" = "Max Testicles Size"),
	"set_testicles_max_size" = list("ru" = "Установить макс размер яичек",      "en" = "Set Max Testicles Size"),
	"testicles_min_size"     = list("ru" = "Мин размер яичек",                  "en" = "Min Testicles Size"),
	"set_testicles_min_size" = list("ru" = "Установить мин размер яичек",       "en" = "Set Min Testicles Size"),
	"testicles_fluid"        = list("ru" = "Произведено",                       "en" = "Produced"),
	"set_testicles_fluid"    = list("ru" = "Установить жидкость",               "en" = "Set Fluid"),

	// Genitals - Vagina
	"vagina"                 = list("ru" = "Влагалище",                         "en" = "Vagina"),
	"has_vagina"             = list("ru" = "Иметь влагалище",                   "en" = "Has Vagina"),
	"vagina_type"            = list("ru" = "Тип влагалища",                     "en" = "Vagina Type"),
	"set_vagina_type"        = list("ru" = "Установить тип влагалища",          "en" = "Set Vagina Type"),
	"vagina_color"           = list("ru" = "Цвет влагалища",                    "en" = "Vagina Color"),
	"set_vagina_color"       = list("ru" = "Установить цвет влагалища",         "en" = "Set Vagina Color"),
	"vagina_visibility"      = list("ru" = "Видимость влагалища",               "en" = "Vagina Visibility"),
	"set_vagina_visibility"  = list("ru" = "Установить видимость влагалища",    "en" = "Set Vagina Visibility"),
	"vagina_accessible"      = list("ru" = "Влагалище всегда доступно",         "en" = "Vagina Always Accessible"),
	"vagina_stuffing"        = list("ru" = "Игрушки и пополнение",              "en" = "Toys & Stuffing"),
	"has_womb"               = list("ru" = "Иметь матку",                       "en" = "Has Womb"),
	"womb_fluid"             = list("ru" = "Произведено",                       "en" = "Produced"),
	"set_womb_fluid"         = list("ru" = "Установить жидкость матки",         "en" = "Set Womb Fluid"),

	// Genitals - Breasts
	"breasts"                = list("ru" = "Грудь",                             "en" = "Breasts"),
	"has_breasts"            = list("ru" = "Иметь грудь",                       "en" = "Has Breasts"),
	"breast_color"           = list("ru" = "Цвет груди",                        "en" = "Breast Color"),
	"set_breast_color"       = list("ru" = "Установить цвет груди",             "en" = "Set Breast Color"),
	"breast_cup_size"        = list("ru" = "Размер чашечки",                    "en" = "Cup Size"),
	"set_breast_cup_size"    = list("ru" = "Установить размер чашечки",         "en" = "Set Cup Size"),
	"breast_shape"           = list("ru" = "Форма груди",                       "en" = "Breast Shape"),
	"set_breast_shape"       = list("ru" = "Установить форму груди",            "en" = "Set Breast Shape"),
	"breast_visibility"      = list("ru" = "Видимость груди",                   "en" = "Breast Visibility"),
	"set_breast_visibility"  = list("ru" = "Установить видимость груди",        "en" = "Set Breast Visibility"),
	"breast_accessible"      = list("ru" = "Грудь всегда доступна",             "en" = "Breasts Always Accessible"),
	"breast_lactates"        = list("ru" = "Лактирует",                         "en" = "Lactates"),
	"breast_stuffing"        = list("ru" = "Игрушки и пополнение",              "en" = "Toys & Stuffing"),
	"breast_max_size"        = list("ru" = "Макс размер",                       "en" = "Max Size"),
	"set_breast_max_size"    = list("ru" = "Установить макс размер",            "en" = "Set Max Size"),
	"breast_min_size"        = list("ru" = "Мин размер",                        "en" = "Min Size"),
	"set_breast_min_size"    = list("ru" = "Установить мин размер",             "en" = "Set Min Size"),
	"breast_fluid"           = list("ru" = "Произведено",                       "en" = "Produced"),
	"set_breast_fluid"       = list("ru" = "Установить жидкость",               "en" = "Set Fluid"),

	// Genitals - Butt
	"butt"                   = list("ru" = "Попа",                              "en" = "Butt"),
	"has_butt"               = list("ru" = "Иметь попу",                        "en" = "Has Butt"),
	"butt_color"             = list("ru" = "Цвет попы",                         "en" = "Butt Color"),
	"set_butt_color"         = list("ru" = "Установить цвет попы",              "en" = "Set Butt Color"),
	"butt_size"              = list("ru" = "Размер попы",                       "en" = "Butt Size"),
	"set_butt_size"          = list("ru" = "Установить размер попы",            "en" = "Set Butt Size"),
	"butt_visibility"        = list("ru" = "Видимость попы",                    "en" = "Butt Visibility"),
	"set_butt_visibility"    = list("ru" = "Установить видимость попы",         "en" = "Set Butt Visibility"),
	"butt_accessible"        = list("ru" = "Попа всегда доступна",              "en" = "Butt Always Accessible"),
	"butt_stuffing"          = list("ru" = "Игрушки и пополнение",              "en" = "Toys & Stuffing"),
	"butt_max_size"          = list("ru" = "Макс размер",                       "en" = "Max Size"),
	"set_butt_max_size"      = list("ru" = "Установить макс размер",            "en" = "Set Max Size"),
	"butt_min_size"          = list("ru" = "Мин размер",                        "en" = "Min Size"),
	"set_butt_min_size"      = list("ru" = "Установить мин размер",             "en" = "Set Min Size"),

	// Genitals - Anus
	"anus"                   = list("ru" = "Анус",                              "en" = "Anus"),
	"has_anus"               = list("ru" = "Иметь анус",                        "en" = "Has Anus"),
	"anus_color"             = list("ru" = "Цвет ануса",                        "en" = "Anus Color"),
	"set_anus_color"         = list("ru" = "Установить цвет ануса",             "en" = "Set Anus Color"),
	"anus_shape"             = list("ru" = "Форма ануса",                       "en" = "Anus Shape"),
	"set_anus_shape"         = list("ru" = "Установить форму ануса",            "en" = "Set Anus Shape"),
	"anus_visibility"        = list("ru" = "Видимость ануса",                   "en" = "Anus Visibility"),
	"set_anus_visibility"    = list("ru" = "Установить видимость ануса",        "en" = "Set Anus Visibility"),
	"anus_accessible"        = list("ru" = "Анус всегда доступен",              "en" = "Anus Always Accessible"),
	"anus_stuffing"          = list("ru" = "Игрушки и пополнение",              "en" = "Toys & Stuffing"),

	// Genitals - Belly
	"belly"                  = list("ru" = "Живот",                             "en" = "Belly"),
	"has_belly"              = list("ru" = "Иметь живот",                       "en" = "Has Belly"),
	"belly_color"            = list("ru" = "Цвет живота",                       "en" = "Belly Color"),
	"set_belly_color"        = list("ru" = "Установить цвет живота",            "en" = "Set Belly Color"),
	"belly_size"             = list("ru" = "Размер живота",                     "en" = "Belly Size"),
	"set_belly_size"         = list("ru" = "Установить размер живота",          "en" = "Set Belly Size"),
	"belly_max_size"         = list("ru" = "Макс размер живота",                "en" = "Max Belly Size"),
	"set_belly_max_size"     = list("ru" = "Установить макс размер живота",     "en" = "Set Max Belly Size"),
	"belly_min_size"         = list("ru" = "Мин размер живота",                 "en" = "Min Belly Size"),
	"set_belly_min_size"     = list("ru" = "Установить мин размер живота",      "en" = "Set Min Belly Size"),
	"belly_visibility"       = list("ru" = "Видимость живота",                  "en" = "Belly Visibility"),
	"set_belly_visibility"   = list("ru" = "Установить видимость живота",       "en" = "Set Belly Visibility"),
	"belly_stuffing"         = list("ru" = "Игрушки и пополнение",              "en" = "Toys & Stuffing"),
	"belly_accessible"       = list("ru" = "Живот всегда доступен",             "en" = "Belly Always Accessible"),

	// Genitals - Neckfire
	"neckfire"               = list("ru" = "Огонь шеи",                         "en" = "Neckfire"),
	"has_neckfire"           = list("ru" = "Иметь огонь шеи",                   "en" = "Has Neckfire"),
	"neckfire_color"         = list("ru" = "Цвет огня",                         "en" = "Fire Color"),
	"set_neckfire_color"     = list("ru" = "Установить цвет огня",              "en" = "Set Fire Color"),

	// Taur
	"taur"                   = list("ru" = "Тауровое тело",                     "en" = "Taur Body"),
	"tail_lizard"            = list("ru" = "Хвост ящера",                       "en" = "Lizard Tail"),
	"tail_human"             = list("ru" = "Хвост человека",                    "en" = "Human Tail"),
	"hardsuit_with_tail"     = list("ru" = "Хардсьют с хвостом",                "en" = "Hardsuit With Tail"),

	// Speech tab
	"speech_preferences"     = list("ru" = "Настройки речи",                    "en" = "Speech preferences"),
	"custom_speech_verb"     = list("ru" = "Пользовательский глагол речи",      "en" = "Custom Speech Verb"),
	"custom_tongue"          = list("ru" = "Пользовательский язык",             "en" = "Custom Tongue"),
	"laugh"                  = list("ru" = "Смех",                              "en" = "Laugh"),
	"preview_laugh"          = list("ru" = "Предпросмотр смеха",                "en" = "Preview Laugh"),
	"additional_language"    = list("ru" = "Дополнительный язык",               "en" = "Additional Language"),
	"custom_runechat_color"  = list("ru" = "Пользовательский цвет чата",        "en" = "Custom runechat color"),
	"vocal_bark_preferences" = list("ru" = "Настройки голосового лая",          "en" = "Vocal Bark preferences"),
	"vocal_bark_sound"       = list("ru" = "Звук голоса",                       "en" = "Vocal Bark Sound"),
	"vocal_bark_speed"       = list("ru" = "Скорость голоса",                   "en" = "Vocal Bark Speed"),
	"vocal_bark_pitch"       = list("ru" = "Высота голоса",                     "en" = "Vocal Bark Pitch"),
	"vocal_bark_variance"    = list("ru" = "Вариация голоса",                   "en" = "Vocal Bark Variance"),
	"preview_bark"           = list("ru" = "Предпросмотр голоса",               "en" = "Preview Bark"),

	// Markings tab
	"character_tattoos"      = list("ru" = "Татуировки персонажа",              "en" = "Character Tattoos"),
	"view_delete_tattoos"    = list("ru" = "Просмотр/удаление татуировок",      "en" = "View / Delete Tattoos"),
	"marking"                = list("ru" = "Маркинг",                           "en" = "Marking"),
	"markings"               = list("ru" = "Маркинги",                          "en" = "Markings"),
	"add_marking"            = list("ru" = "Добавить маркинг",                  "en" = "Add Marking"),
	"remove_marking"         = list("ru" = "Удалить маркинг",                   "en" = "Remove Marking"),
	"remove_all_markings"    = list("ru" = "Удалить все маркинги",              "en" = "Remove All Markings"),
	"danger_zone"            = list("ru" = "Опасная зона",                      "en" = "Danger Zone"),
	"limb_head"              = list("ru" = "Голова",                            "en" = "Head"),
	"limb_chest"             = list("ru" = "Грудь",                             "en" = "Chest"),
	"limb_groin"             = list("ru" = "Пах",                               "en" = "Groin"),
	"limb_left_arm"          = list("ru" = "Левая рука",                        "en" = "Left Arm"),
	"limb_right_arm"         = list("ru" = "Правая рука",                       "en" = "Right Arm"),
	"limb_left_leg"          = list("ru" = "Левая нога",                        "en" = "Left Leg"),
	"limb_right_leg"         = list("ru" = "Правая нога",                       "en" = "Right Leg"),

	// Loadout tab
	"loadout_slot"           = list("ru" = "Слот снаряжения",                   "en" = "Loadout slot"),
	"loadout_enabled_label"  = list("ru" = "Заменить одежду на снаряжение",     "en" = "Replace clothing with loadout"),
	"clear_loadout"          = list("ru" = "Очистить снаряжение",               "en" = "Clear loadout"),
	"loadout_category"       = list("ru" = "Категория снаряжения",              "en" = "Loadout Category"),
	"loadout_points_label"   = list("ru" = "Очки снаряжения",                   "en" = "Loadout Points"),
	"loadout_item_add"       = list("ru" = "Добавить",                          "en" = "Add"),
	"loadout_item_remove"    = list("ru" = "Убрать",                            "en" = "Remove"),
	"loadout_item_customize" = list("ru" = "Настроить",                         "en" = "Customize"),
	"loadout_spawn_in"       = list("ru" = "Появится в",                        "en" = "Spawns in"),

	// Mutant parts tab
	"mutant_parts"           = list("ru" = "Мутантные части",                   "en" = "Mutant Parts"),
	"ears"                   = list("ru" = "Уши",                               "en" = "Ears"),
	"tail"                   = list("ru" = "Хвост",                             "en" = "Tail"),
	"wings"                  = list("ru" = "Крылья",                            "en" = "Wings"),
	"horns"                  = list("ru" = "Рога",                              "en" = "Horns"),
	"snout"                  = list("ru" = "Морда",                             "en" = "Snout"),
	"frills"                 = list("ru" = "Оборки",                            "en" = "Frills"),
	"spines"                 = list("ru" = "Шипы",                              "en" = "Spines"),
	"antenna"                = list("ru" = "Антенны",                           "en" = "Antenna"),
	"legs"                   = list("ru" = "Ноги",                              "en" = "Legs"),
	"digitigrade"            = list("ru" = "Дигитиградные ноги",                "en" = "Digitigrade Legs"),
	"plantigrade"            = list("ru" = "Планоходящие ноги",                 "en" = "Plantigrade Legs"),
	"moth_antennae"          = list("ru" = "Антенны мотылька",                  "en" = "Moth Antennae"),
	"moth_wings"             = list("ru" = "Крылья мотылька",                   "en" = "Moth Wings"),
	"moth_markings"          = list("ru" = "Маркинги мотылька",                 "en" = "Moth Markings"),
	"insect_type"            = list("ru" = "Тип насекомого",                    "en" = "Insect Type"),
	"pod_hair"               = list("ru" = "Волосы подлюдей",                   "en" = "Pod Hair"),
	"xenomorph_type"         = list("ru" = "Тип ксеноморфа",                    "en" = "Xenomorph Type"),
	"ipc_screen"             = list("ru" = "Экран IPC",                         "en" = "IPC Screen"),
	"ipc_chassis"            = list("ru" = "Шасси IPC",                         "en" = "IPC Chassis"),
	"ipc_antenna"            = list("ru" = "Антенна IPC",                       "en" = "IPC Antenna"),
	"arachnid_legs"          = list("ru" = "Лапы арахнида",                     "en" = "Arachnid Legs"),
	"arachnid_spinneret"     = list("ru" = "Паутинная железа",                  "en" = "Arachnid Spinneret"),
	"arachnid_mandibles"     = list("ru" = "Жвалы арахнида",                    "en" = "Arachnid Mandibles"),
	"set_color"              = list("ru" = "Установить цвет",                   "en" = "Set Color"),
	"set_type"               = list("ru" = "Установить тип",                    "en" = "Set Type"),
	"set_style"              = list("ru" = "Установить стиль",                  "en" = "Set Style"),

	// OOC Preferences
	"ooc_preferences"        = list("ru" = "OOC настройки",                     "en" = "OOC Preferences"),
	"server_name"            = list("ru" = "Имя сервера",                       "en" = "Server Name"),
	"fps"                    = list("ru" = "FPS",                               "en" = "FPS"),
	"parallax"               = list("ru" = "Параллакс",                         "en" = "Parallax"),
	"parallax_off"           = list("ru" = "Выкл",                              "en" = "Off"),
	"parallax_low"           = list("ru" = "Низкий",                            "en" = "Low"),
	"parallax_medium"        = list("ru" = "Средний",                           "en" = "Medium"),
	"parallax_high"          = list("ru" = "Высокий",                           "en" = "High"),
	"parallax_insane"        = list("ru" = "Безумный",                          "en" = "Insane"),
	"pixel_size_mode"        = list("ru" = "Режим размера пикселей",            "en" = "Pixel Size Mode"),
	"scaling_method"         = list("ru" = "Метод масштабирования",             "en" = "Scaling Method"),
	"auto_fit_viewport"      = list("ru" = "Авто подгонка вьюпорта",            "en" = "Auto Fit Viewport"),
	"widescreen"             = list("ru" = "Широкий экран",                     "en" = "Widescreen"),
	"chat_on_map"            = list("ru" = "Рунчат",                     		"en" = "Runechat"),
	"chat_on_map_looc"       = list("ru" = "LOOC Рунчат",                     	"en" = "LOOC Runechat"),
	"ambient_occlusion"      = list("ru" = "Окружающая окклюзия",               "en" = "Ambient Occlusion"),
	"tgui_fancy"             = list("ru" = "Стильный TGUI",                     "en" = "Fancy TGUI"),
	"tgui_lock"              = list("ru" = "Блокировка TGUI",                   "en" = "TGUI Lock"),
	"tooltips"               = list("ru" = "Подсказки",                         "en" = "Tooltips"),
	"ghost_vision"           = list("ru" = "Зрение призрака",                   "en" = "Ghost Vision"),
	"afk_catatonic"          = list("ru" = "AFK кататония",                     "en" = "AFK Catatonic"),
	"play_title_music"       = list("ru" = "Музыка главного меню",              "en" = "Play Title Music"),
	"play_lobby_music"       = list("ru" = "Музыка лобби",                      "en" = "Play Lobby Music"),
	"play_admin_midis"       = list("ru" = "Админские MIDI",                    "en" = "Play Admin Midis"),
	"mute_when_unfocused"    = list("ru" = "Заглушить при сворачивании",        "en" = "Mute When Unfocused"),

	// Game Preferences
	"game_preferences"       = list("ru" = "Игровые настройки",                 "en" = "Game Preferences"),
	"ui_style"               = list("ru" = "Стиль UI",                          "en" = "UI Style"),
	"hud_toggle"             = list("ru" = "Переключатель HUD",                 "en" = "HUD Toggle"),
	"see_chat_non_mob"       = list("ru" = "Видеть чат не-мобов",               "en" = "See Chat Non-Mob"),
	"combat_mode"            = list("ru" = "Режим боя",                         "en" = "Combat Mode"),
	"auto_stand"             = list("ru" = "Авто вставание",                    "en" = "Auto Stand"),
	"auto_resist"            = list("ru" = "Авто сопротивление",                "en" = "Auto Resist"),
	"enable_camera_exposure" = list("ru" = "Включить экспозицию камеры",        "en" = "Enable Camera Exposure"),
	"window_flashing"        = list("ru" = "Мигание окна",                      "en" = "Window Flashing"),
	"hotkey_mode"            = list("ru" = "Режим горячих клавиш",              "en" = "Hotkey Mode"),
	"intent_style"           = list("ru" = "Стиль намерения",                   "en" = "Intent Style"),
	"clientfps"              = list("ru" = "Клиентский FPS",                    "en" = "Client FPS"),
	"ghost_hud"              = list("ru" = "HUD призрака",                      "en" = "Ghost HUD"),
	"ghost_others"           = list("ru" = "Отображение других призраков",      "en" = "Ghost Others"),
	"ghost_roles"            = list("ru" = "Роли призрака",                     "en" = "Ghost Roles"),
	"ghost_spawns"           = list("ru" = "Спавны призрака",                   "en" = "Ghost Spawns"),

	// Content Preferences
	"content_preferences"    = list("ru" = "Настройки контента",                "en" = "Content Preferences"),
	"show_lewd_examine"      = list("ru" = "Показывать развратное описание",    "en" = "Show Lewd Examine"),
	"genital_examine_in_verbs" = list("ru" = "Гениталии в глаголах",            "en" = "Genital Examine in Verbs"),
	"verb_consent"           = list("ru" = "Согласие на глаголы",               "en" = "Verb Consent"),
	"ranged_verb_pref"       = list("ru" = "Дистанционные глаголы",             "en" = "Ranged Verb Pref"),
	"lewd_verb_sounds"       = list("ru" = "Звуки развратных глаголов",         "en" = "Lewd Verb Sounds"),
	"arousable"              = list("ru" = "Возбудимость",                      "en" = "Arousable"),
	"genital_examine"        = list("ru" = "Осмотр гениталий",                  "en" = "Genital Examine"),
	"vore_examine"           = list("ru" = "Осмотр vore",                       "en" = "Vore Examine"),
	"medihound_sleeper"      = list("ru" = "Спящий медигончий",                 "en" = "Medihound Sleeper"),
	"eating_noises"          = list("ru" = "Звуки еды",                         "en" = "Eating Noises"),
	"digestion_noises"       = list("ru" = "Звуки пищеварения",                 "en" = "Digestion Noises"),
	"trash_forcefeed"        = list("ru" = "Принудительное кормление мусором",  "en" = "Trash Forcefeed"),
	"forced_fem"             = list("ru" = "Принудительная феминизация",        "en" = "Forced Fem"),
	"forced_masc"            = list("ru" = "Принудительная маскулинизация",     "en" = "Forced Masc"),
	"hypno"                  = list("ru" = "Гипноз",                            "en" = "Hypno"),
	"bimbofication"          = list("ru" = "Бимбофикация",                      "en" = "Bimbofication"),
	"breast_enlargement"     = list("ru" = "Увеличение груди",                  "en" = "Breast Enlargement"),
	"penis_enlargement"      = list("ru" = "Увеличение пениса",                 "en" = "Penis Enlargement"),
	"butt_enlargement"       = list("ru" = "Увеличение попы",                   "en" = "Butt Enlargement"),
	"belly_inflation"        = list("ru" = "Надувание живота",                  "en" = "Belly Inflation"),
	"never_hypno"            = list("ru" = "Никогда не гипноз",                 "en" = "Never Hypno"),
	"no_aphro"               = list("ru" = "Без афродизиаков",                  "en" = "No Aphro"),
	"no_ass_slap"            = list("ru" = "Без шлепков по попе",               "en" = "No Ass Slap"),
	"no_auto_wag"            = list("ru" = "Без авто виляния",                  "en" = "No Auto Wag"),
	"chastity_pref"          = list("ru" = "Предпочтение целомудрия",           "en" = "Chastity Pref"),
	"stimulation_pref"       = list("ru" = "Предпочтение стимуляции",           "en" = "Stimulation Pref"),

	// Preferences tab — top subtabs
	"pref_general"           = list("ru" = "Основное",                          "en" = "General"),
	"pref_ooc"               = list("ru" = "OOC",                               "en" = "OOC"),
	"pref_content"           = list("ru" = "Контент",                           "en" = "Content"),

	// Preferences section headers
	"pref_sec_interface"     = list("ru" = "Интерфейс",                         "en" = "Interface"),
	"pref_sec_chat"          = list("ru" = "Чат",                               "en" = "Chat"),
	"pref_sec_ghost"         = list("ru" = "Призрак",                           "en" = "Ghost"),
	"pref_sec_misc"          = list("ru" = "Прочее",                            "en" = "Other"),
	"pref_sec_antag"         = list("ru" = "Антагонисты",                       "en" = "Antagonists"),
	"pref_sec_sound"         = list("ru" = "Звук",                              "en" = "Sound"),
	"pref_sec_notify"        = list("ru" = "Уведомления",                       "en" = "Notifications"),
	"pref_sec_ooc"           = list("ru" = "OOC",                               "en" = "OOC"),
	"pref_sec_admin"         = list("ru" = "Администратор",                     "en" = "Administrator"),
	"pref_sec_screen"        = list("ru" = "Экран",                             "en" = "Screen"),
	"pref_sec_hud"           = list("ru" = "HUD",                               "en" = "HUD"),
	"pref_sec_gameplay"      = list("ru" = "Геймплей",                          "en" = "Gameplay"),
	"pref_sec_map"           = list("ru" = "Карта",                             "en" = "Map"),

	// Interface section
	"outline"                = list("ru" = "Обводка",                           "en" = "Outline"),
	"outline_color"          = list("ru" = "Цвет обводки",                      "en" = "Outline Color"),
	"outline_color_theme_based" = list("ru" = "Цвет темы",                      "en" = "Theme-based (null)"),
	"screentip"              = list("ru" = "Подсказка при наведении",           "en" = "Screentip"),
	"screentip_color"        = list("ru" = "Цвет подсказки курсора",            "en" = "Screentip Color"),
	"screentip_images_label" = list("ru" = "Подсказки с иконками",              "en" = "Screentip context with images"),
	"screentip_images_tooltip" = list("ru" = "Настройка доступности: если отключено, показывается только текст без иконок.", "en" = "Accessibility preference: if disabled, fallbacks to text-only which is easier for colorblind players."),
	"allowed"                = list("ru" = "Разрешено",                         "en" = "Allowed"),
	"disallowed"             = list("ru" = "Запрещено",                         "en" = "Disallowed"),
	"tgui_input_mode"        = list("ru" = "Строка ввода",                      "en" = "Input Framework"),
	"tgui_input_verbs"       = list("ru" = "Вербы ввода (SAY, ME, OOC...)",     "en" = "Input Verbs (SAY, ME, OOC, etc.) Framework"),
	"tgui_monitors"          = list("ru" = "Мониторы tgui",                     "en" = "tgui Monitors"),
	"tgui_monitor_primary"   = list("ru" = "Основной",                          "en" = "Primary"),
	"tgui_monitor_all"       = list("ru" = "Все",                               "en" = "All"),
	"tgui_style"             = list("ru" = "Стиль tgui",                        "en" = "tgui Style"),
	"tgui_style_fancy"       = list("ru" = "Улучшенный",                        "en" = "Fancy"),
	"tgui_style_no_frills"   = list("ru" = "Базовый",                           "en" = "No Frills"),

	// Chat section
	"runechat_bubbles"       = list("ru" = "Текст над головой",                 "en" = "Show Chat Bubbles"),
	"runechat_looc_bubbles"  = list("ru" = "Текст LOOC над головой",            "en" = "Show LOOC Chat Bubbles"),
	"runechat_char_limit"    = list("ru" = "Лимит символов над головой",        "en" = "Chat bubble char limit"),
	"runechat_non_mobs"      = list("ru" = "Текст от объектов",                 "en" = "See chat for non-mobs"),
	"runechat_emotes"        = list("ru" = "Эмоции над головой",                "en" = "See emotes in chat bubbles"),
	"pixelshift_view"        = list("ru" = "Смещение вида при пиксель-сдвиге",  "en" = "Shift view when pixelshifting"),

	// Ghost section
	"ghost_ears"             = list("ru" = "Слух призрака",                     "en" = "Ghost Ears"),
	"ghost_radio"            = list("ru" = "Радио призрака",                    "en" = "Ghost Radio"),
	"ghost_sight"            = list("ru" = "Зрение призрака",                   "en" = "Ghost Sight"),
	"ghost_whispers"         = list("ru" = "Шёпот призрака",                    "en" = "Ghost Whispers"),
	"ghost_pda"              = list("ru" = "PDA призрака",                      "en" = "Ghost PDA"),
	"ghost_all_speech"       = list("ru" = "Все речи",                          "en" = "All Speech"),
	"ghost_nearest_creatures"= list("ru" = "Ближайшие существа",                "en" = "Nearest Creatures"),
	"ghost_all_messages"     = list("ru" = "Все сообщения",                     "en" = "All Messages"),
	"ghost_no_messages"      = list("ru" = "Без сообщений",                     "en" = "No Messages"),
	"ghost_all_emotes"       = list("ru" = "Все эмоции",                        "en" = "All Emotes"),
	"ghost_form"             = list("ru" = "Форма призрака",                    "en" = "Ghost Form"),
	"ghost_orbit"            = list("ru" = "Орбит призрака",                   "en" = "Ghost Orbit"),
	"ghost_accessories"      = list("ru" = "Аксессуары призрака",               "en" = "Ghost Accessories"),
	"ghosts_of_others"       = list("ru" = "Призраки других",                   "en" = "Ghosts of Others"),

	// Other / Misc section
	"auto_capitalize"        = list("ru" = "Авто-заглавные буквы в речи",       "en" = "Auto-Capitalize Speech"),
	"preferred_chaos_level"  = list("ru" = "Предпочитаемый уровень хаоса",      "en" = "Preferred Chaos Level"),

	// Antagonists section
	"antag_banned"           = list("ru" = "Вы забанены от ролей антагонистов.", "en" = "You are banned from antagonist roles."),
	"disable_all_antag"      = list("ru" = "ОТКЛЮЧИТЬ АНТАГОНИЗМ",              "en" = "DISABLE ALL ANTAGONISM"),
	"be_role"                = list("ru" = "Играть",                            "en" = "Be"),
	"banned"                 = list("ru" = "ЗАБАНЕН",                           "en" = "BANNED"),
	"in_label"               = list("ru" = "ЧЕРЕЗ",                             "en" = "IN"),
	"days_label"             = list("ru" = "ДНЕЙ",                              "en" = "DAYS"),
	"allow_midround_antag"   = list("ru" = "Быть мидраунд-антагонистом",        "en" = "Allow Midround Antagonist Roll"),

	// Sound section (OOC tab)
	"play_admin_midis"       = list("ru" = "Админ MIDI",            			"en" = "Play Admin MIDIs"),
	"play_lobby_music"       = list("ru" = "Музыка лобби",                      "en" = "Play Lobby Music"),

	// Notifications section
	"window_noise"           = list("ru" = "Звук окна",                         "en" = "Window Noise"),
	"see_pull_requests"      = list("ru" = "Pull Request'ы",                    "en" = "See Pull Requests"),

	// OOC Colors section
	"byond_membership_publicity" = list("ru" = "Членство BYOND",            	"en" = "BYOND Membership Publicity"),
	"public"                 = list("ru" = "Публично",                          "en" = "Public"),
	"hidden"                 = list("ru" = "Скрыто",                            "en" = "Hidden"),
	"custom_color_ooc"       = list("ru" = "Свой цвет OOC",                     "en" = "Custom OOC Color"),
	"ooc_color"              = list("ru" = "Цвет OOC",                          "en" = "OOC Color"),
	"custom_color_aooc"      = list("ru" = "Свой цвет AOOC",                    "en" = "Custom AOOC Color"),
	"antag_ooc_color"        = list("ru" = "Цвет OOC антагониста",              "en" = "Antag OOC Color"),

	// Administrator section
	"adminhelp_sounds"       = list("ru" = "Звук adminhelp",                    "en" = "Adminhelp Sounds"),
	"announce_login"         = list("ru" = "Объявлять о входе",                 "en" = "Announce Login"),
	"combo_hud_lighting"     = list("ru" = "Освещение комбо HUD",               "en" = "Combo HUD Lighting"),
	"full_bright"            = list("ru" = "Полная яркость",                    "en" = "Full-bright"),
	"no_change"              = list("ru" = "Без изменений",                     "en" = "No Change"),
	"deadmin_while_playing"  = list("ru" = "Деадмин во время игры",             "en" = "Deadmin While Playing"),
	"onlogin_deadmin"        = list("ru" = "Деадмин при входе",                 "en" = "Deadmin On Login"),
	"onspawn_deadmin"        = list("ru" = "Деадмин при спавне",                "en" = "Deadmin On Spawn"),
	"forced"                 = list("ru" = "ОБЯЗАТЕЛЬНО",                       "en" = "FORCED"),
	"as_antag"               = list("ru" = "Как антаг",                         "en" = "As Antag"),
	"as_command"             = list("ru" = "Как командование",                  "en" = "As Command"),
	"as_security"            = list("ru" = "Как охрана",                        "en" = "As Security"),
	"as_silicon"             = list("ru" = "Как силикон",                       "en" = "As Silicon"),
	"deadmin"                = list("ru" = "Деадмин",                           "en" = "Deadmin"),
	"keep_admin"             = list("ru" = "Оставить права",                    "en" = "Keep Admin"),

	// Screen section
	"widescreen"             = list("ru" = "Широкоформат",                   	"en" = "Widescreen"),
	"fullscreen"             = list("ru" = "На весь экран",                     "en" = "Fullscreen"),
	"fps"                    = list("ru" = "FPS",                               "en" = "FPS"),
	"fit_viewport"           = list("ru" = "Корректировка камеры",              "en" = "Fit Viewport"),
	"auto"                   = list("ru" = "Авто",                              "en" = "Auto"),
	"manual"                 = list("ru" = "Вручную",                           "en" = "Manual"),
	"parallax"               = list("ru" = "Параллакс",                         "en" = "Parallax (Fancy Space)"),
	"low"                    = list("ru" = "Низкий",                            "en" = "Low"),
	"medium"                 = list("ru" = "Средний",                           "en" = "Medium"),
	"high"                   = list("ru" = "Высокий",                           "en" = "High"),
	"insane"                 = list("ru" = "Безумный",                          "en" = "Insane"),
	"screen_shake"           = list("ru" = "Тряска экрана",                     "en" = "Screen Shake"),
	"damage_screen_shake"    = list("ru" = "Тряска от урона",                   "en" = "Damage Screen Shake"),
	"recoil_screen_push"     = list("ru" = "Отдача экрана",                     "en" = "Recoil Screen Push"),
	"full"                   = list("ru" = "Полная",                            "en" = "Full"),
	"on"                     = list("ru" = "Вкл",                               "en" = "On"),
	"off"                    = list("ru" = "Выкл",                              "en" = "Off"),
	"only_when_down"         = list("ru" = "Только лёжа",                       "en" = "Only when down"),

	// HUD section
	"long_strip_menu"        = list("ru" = "Длинное меню раздевания",           "en" = "Long strip menu"),
	"modern_accent"          = list("ru" = "Модерн акцент",                     "en" = "Modern Accent"),
	"hud_button_flashes"     = list("ru" = "Мигание кнопок HUD",                "en" = "HUD Button Flashes"),
	"hud_flash_color"        = list("ru" = "Цвет мигания кнопок HUD",           "en" = "HUD Button Flash Color"),
	"income_updates"         = list("ru" = "Уведомления о обновлениях",         "en" = "Income Updates"),
	"muted"                  = list("ru" = "Заглушено",                         "en" = "Muted"),
	"playerpanel_style"      = list("ru" = "Стиль панели игрока",               "en" = "Player Panel Style"),
	"tg_label"               = list("ru" = "TG",                                "en" = "TG"),
	"old_label"              = list("ru" = "Старый",                            "en" = "Old"),
	"force_slot_storage"     = list("ru" = "HUD хранилища слотов",              "en" = "Force Slot Storage HUD"),

	// Gameplay section
	"auto_ooc"               = list("ru" = "Авто OOC",                          "en" = "Auto OOC"),
	"be_victim"              = list("ru" = "Быть жертвой антагониста",          "en" = "Be Antagonist Victim"),
	"disable_combat_cursor"  = list("ru" = "Откл. курсор боевого режима",       "en" = "Disable combat mode cursor"),
	"disable_combat_mouse_lock" = list("ru" = "Откл. блокировку мыши в бою",    "en" = "Disable combat mode mouse lock"),

	// Map section
	"preferred_map"          = list("ru" = "Предпочтительная карта",            "en" = "Preferred Map"),
	"default"                = list("ru" = "По умолчанию",                      "en" = "Default")
)
