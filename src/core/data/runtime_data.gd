class_name GameData extends Node
static func get_star_count() -> int:
	var c: int = 0
	for i in range(1, Util.NUMBER_OF_LEVELS):
		if runtime_data[str(i)]["completed"] == true:
			c += 1
	return c
	
static var runtime_data: Dictionary = {
	"1": {
		"completed": false
	},
  "10": {
		"completed": false
	},
  "101": {
		"completed": false
	},
  "102": {
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
  "2": {
		"completed": false
	},
  "20": {
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
  "first_session": true,
  "last_level": 0,
	"op_sfx_muted": false,
	"op_music_muted": false,
	"op_a_on": false
}
static var medal_data: Dictionary = {

}
const DEFAULT_MEDAL_DATA = {
	# TODO: Possible issues with save data when versioning
	
	# Progression
	"bitten": false, # You Menace...
	"safe": false, # Good Ending
	"b1_comp": false, # First Bakery Complete!
	"b2_comp": false, # Second Bakery Complete!
	"game_comp": false, # Marshmallow Lady Approves
	
	# Level-specific
	"2_16_1": false, # Trespassing
	"2_16_2": false, # Leapfrog
	
	# Stats
	"50squat": false # 
	
	# Misc
	
}
const DEFAULT_GAME_DATA = {
	"1": {
		"completed": false
	},
  "10": {
		"completed": false
	},
  "101": {
		"completed": false
	},
  "102": {
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
  "2": {
		"completed": false
	},
  "20": {
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
  "first_session": true,
  "last_level": 0,
	"op_sfx_muted": false,
	"op_music_muted": false,
	"op_a_on": false,
}
# Dear data miners, be nice with the data :)
