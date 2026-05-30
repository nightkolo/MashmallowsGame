class_name GameData extends Node
static func get_star_count() -> int:
	var c: int = 0
	for i in range(1, Util.NUMBER_OF_LEVELS):
		if runtime_data[str(i)]["completed"] == true:
			c += 1
	return c
	
static var runtime_data: Dictionary = {
	"first_session": true,
	"101": {
		"completed": false
	},
	"102": {
		"completed": false
	},
	"1": {
		"completed": false
	},
	"2": {
		"completed": false
	},
	"3": {
		"completed": false
	},
	"4": {
		"completed": false
	},
	"5": {
		"completed": false
	},
	"6": {
		"completed": false
	},
	"7": {
		"completed": false
	},
	"8": {
		"completed": false
	},
	"9": {
		"completed": false
	},
	"10": {
		"completed": false
	},
	"11": {
		"completed": false
	},
	"12": {
		"completed": false
	},
	"13": {
		"completed": false
	},
	"14": {
		"completed": false
	},
	"15": {
		"completed": false
	},
	"16": {
		"completed": false
	},
	"17": {
		"completed": false
	},
	"18": {
		"completed": false
	},
	"19": {
		"completed": false
	},
	"20": {
		"completed": false
	}
}
static var medal_data: Dictionary = {
	# NOTE: HARD-CODED, DO NOT MODIFY UNLESS YOU KNOW WHAT YOU'RE DOING.
	
	# TODO: Possible issues with save data when versioning
	
	# Progression
	"wake": false,
	"cb1_comp": false,
	"cb2_comp": false,
	"game_comp": false,
	
	# Board-specific
	"4_1": false,
	"5_1": false,
	"6_1": false,
	"14_1": false,
	"15_1": false,
	"20_1": false,
	
	# Stats
	"200moves": false,
	"600moves": false,
	
	# Misc
	"poke": false,
	"curiosity": false,
	"halls": false
}
const DEFAULT_MEDAL_DATA = {
	# NOTE: HARD-CODED, DO NOT MODIFY UNLESS YOU KNOW WHAT YOU'RE DOING.
	
	# TODO: Possible issues with save data when versioning
	
	# Progression
	"wake": false,
	"cb1_comp": false,
	"cb2_comp": false,
	"game_comp": false,
	
	# Board-specific
	"4_1": false,
	"5_1": false,
	"6_1": false,
	"14_1": false,
	"15_1": false,
	"20_1": false,
	
	# Stats
	"200moves": false,
	"600moves": false,
	
	# Misc
	"poke": false,
	"curiosity": false,
	"halls": false
}
const DEFAULT_GAME_DATA = {
	"first_session": true,
	"101": {
		"completed": false
	},
	"102": {
		"completed": false
	},
	"1": {
		"completed": false
	},
	"2": {
		"completed": false
	},
	"3": {
		"completed": false
	},
	"4": {
		"completed": false
	},
	"5": {
		"completed": false
	},
	"6": {
		"completed": false
	},
	"7": {
		"completed": false
	},
	"8": {
		"completed": false
	},
	"9": {
		"completed": false
	},
	"10": {
		"completed": false
	},
	"11": {
		"completed": false
	},
	"12": {
		"completed": false
	},
	"13": {
		"completed": false
	},
	"14": {
		"completed": false
	},
	"15": {
		"completed": false
	},
	"16": {
		"completed": false
	},
	"17": {
		"completed": false
	},
	"18": {
		"completed": false
	},
	"19": {
		"completed": false
	},
	"20": {
		"completed": false
	}
}
# Dear data miners, be nice with the data :)
