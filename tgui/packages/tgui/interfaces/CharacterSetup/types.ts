export type CharacterSetupData = {
  // Tab state
  current_tab: number;
  character_settings_tab: number;
  preferences_tab: number;
  preview_pref: string;

  // Character slots
  slots: CharacterSlot[];
  active_slot: number;
  collapse_empty_slots: boolean;
  max_save_slots: number;

  // General tab
  real_name: string;
  gender: string;
  age: number;
  be_random_name: boolean;
  be_random_body: boolean;
  nameless: boolean;
  hide_ckey: boolean;
  custom_blood_color: boolean;
  blood_color: string;
  custom_names: Record<string, string>;

  // Species
  species_name: string;
  species_id: string;
  custom_species: string;
  species_has_sexes: boolean;
  species_list: SpeciesInfo[];

  // Silicon/AI
  preferred_ai_core_display: string;
  silicon_lawset: string;
  prefered_security_department: string;

  // PDA
  pda_color: string;
  pda_style: string;
  pda_skin: string;
  pda_ringtone: string;

  // Misc general
  hardsuit_with_tail: boolean;

  // Appearance
  body_model: string;
  body_size: number;
  normalized_size: number;
  body_weight: string;
  color_scheme: string;
  show_mismatched_markings: boolean;
  fuzzy: boolean;
  bgstate: string;

  // Skin tone
  skin_tone: string;
  use_custom_skin_tone: boolean;
  use_skintones: boolean;

  // Body colors
  mcolor: string;
  mcolor2: string;
  mcolor3: string;
  has_mutcolors: boolean;
  genitals_use_skintone: boolean;

  // Eyes
  eye_type: string;
  left_eye_color: string;
  right_eye_color: string;
  split_eye_colors: boolean;
  has_eyes: boolean;
  has_eyecolor: boolean;

  // Hair
  hair_style: string;
  hair_color: string;
  facial_hair_style: string;
  facial_hair_color: string;
  grad_style: string;
  grad_color: string;
  has_hair: boolean;

  // Underwear
  underwear: string;
  undie_color: string;
  undershirt: string;
  shirt_color: string;
  socks: string;
  socks_color: string;
  backbag: string;
  jumpsuit_style: string;
  persistent_scars: boolean;
  uplink_spawn_loc: string;

  // Mutant parts
  mutant_values: Record<string, string>;
  mutant_colors: Record<string, string>;
  available_mutant_parts: string[];

  // Limb modifications
  modified_limbs: LimbModification[];

  // Background
  flavor_text: string;
  naked_flavor_text: string;
  custom_deathgasp: string;
  custom_deathsound: string;
  silicon_flavor_text: string;
  custom_species_lore: string;
  ooc_notes: string;
  security_records: string;
  medical_records: string;

  // Headshots
  headshot_link: string;
  headshot_link1: string;
  headshot_link2: string;
  headshot_naked_link: string;
  headshot_naked_link1: string;
  headshot_naked_link2: string;

  // Speech
  speech_verb: string;
  bark_id: string;
  bark_pitch: number;
  bark_speed: number;
  bark_variance: number;
  custom_tongue: string;
  custom_laugh: string;
  languages: string[];
  available_languages: LanguageInfo[];
  max_languages: number;
  enable_personal_chat_color: boolean;
  personal_chat_color: string;

  // Quirks
  all_quirks: string[];
  quirk_balance: number;

  // Game preferences
  UI_style: string;
  outline_enabled: boolean;
  outline_color: string;
  screentip_pref: number;
  screentip_color: string;
  screentip_images: boolean;
  hotkeys: boolean;
  tgui_fancy: boolean;
  tgui_lock: boolean;
  chat_on_map: boolean;
  max_chat_length: number;
  see_chat_non_mob: boolean;
  see_rc_emotes: boolean;
  clientfps: number;
  toggles: number;
  widescreenpref: boolean;
  fullscreen: boolean;
  long_strip_menu: boolean;
  autostand: boolean;
  auto_ooc: boolean;
  auto_capitalize_enabled: boolean;
  no_tetris_storage: boolean;
  screenshake: number;
  damagescreenshake: number;
  recoil_screenshake: number;
  parallax: number;
  ambientocclusion: boolean;
  auto_fit_viewport: boolean;
  hud_toggle_flash: boolean;
  hud_toggle_color: string;
  view_pixelshift: boolean;
  disable_combat_cursor: boolean;
  disable_combat_mouse_lock: boolean;
  be_victim: string;

  // OOC preferences
  ooccolor: string;
  aooccolor: string;
  chat_toggles: number;
  custom_colors: number;
  ghost_form: string;
  ghost_orbit: string;
  windowflashing: boolean;
  windownoise: boolean;
  ghost_accs: number;
  ghost_others: number;

  // Content preferences
  erppref: string;
  nonconpref: string;
  vorepref: string;
  extremepref: string;
  unholypref: string;
  tattoopref: string;
  mobsexpref: string;
  hornyantagspref: string;
  extremeharm: string;
  arousable: boolean;
  sexknotting: boolean;
  cit_toggles: number;
  lust_tolerance: number;
  sexual_potency: number;

  // Character preview (ByondUi map view ID)
  character_preview_view: string;

  // Static data
  hair_styles: string[];
  facial_hair_styles: string[];
  grad_styles: string[];
  underwear_list: string[];
  undershirt_list: string[];
  socks_list: string[];
  bg_list: string[];
  custom_name_types: CustomNameType[];
  eye_types: string[];
  mutant_parts: MutantPartInfo[];
  bark_list: string[];
  roundstart_traits: boolean;
  allow_silicon_choosing_laws: boolean;
};

export type CharacterSlot = {
  index: number;
  name: string;
  is_empty: boolean;
};

export type SpeciesInfo = {
  id: string;
  name: string;
  sexes: boolean;
  use_skintones: boolean;
};

export type CustomNameType = {
  id: string;
  label: string;
  group: string;
};

export type MutantPartInfo = {
  id: string;
  label: string;
  styles: string[];
  color_type: string | null;
};

export type LimbModification = {
  limb: string;
  type: string;
  detail: string | null;
};

export type LanguageInfo = {
  name: string;
  desc: string;
  icon_b64: string;
  selected: boolean;
};
