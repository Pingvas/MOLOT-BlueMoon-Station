// PDA ringtone definitions
GLOBAL_LIST_INIT(pda_ringtones, list(
	"Beep" = 'sound/machines/twobeep.ogg',
	"Boom" = 'sound/effects/explosion1.ogg',
	"Honk" = 'sound/items/bikehorn.ogg',
	"SKREE" = 'sound/voice/shriek1.ogg',
	"Xeno" = 'sound/voice/hiss2.ogg',
	"Clown" = 'sound/items/AirHorn2.ogg',
	"Bzzt" = 'sound/machines/buzz-sigh.ogg',
	"Ding" = 'sound/machines/ding.ogg',
	"Chirp" = 'sound/machines/chime.ogg',
	"Pew" = 'sound/weapons/laser.ogg',
	"Boop" = 'sound/machines/terminal_select.ogg',
	"Ping" = 'sound/machines/ping.ogg',
	"Synth" = 'sound/misc/interference.ogg',
	"Stalker" = 'sound/items/PDA/stalk1.ogg',
	"NewQuest" = 'sound/items/PDA/stalk2.ogg'
))

GLOBAL_LIST_INIT(pda_ringtone_list, list(
	"Beep",
	"Boom",
	"Honk",
	"SKREE",
	"Xeno",
	"Clown",
	"Bzzt",
	"Ding",
	"Chirp",
	"Pew",
	"Boop",
	"Ping",
	"Synth",
	"Stalker",
	"NewQuest"
))

// PDA scanner modes
#define PDA_SCANNER_NONE		0
#define PDA_SCANNER_MEDICAL		1
#define PDA_SCANNER_FORENSICS	2
#define PDA_SCANNER_REAGENT		3
#define PDA_SCANNER_HALOGEN		4
#define PDA_SCANNER_GAS			5
