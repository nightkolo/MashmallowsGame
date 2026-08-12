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
	"squats_made": 0,
	"mashes_made": 0,
	"op_sfx_muted": false,
	"op_music_muted": false,
	"op_a_on": false
}
static var medal_data: Dictionary = {
	# Progression
	"bitten": false, # You Menace... c
	# Choose "Eat Her Anyway" and devour the prey.
	"safe": false, # Good Ending c
	# Choose "Got it" and display mercy.
	"b1_comp": false, # First Bakery Complete! c
	# Complete all the Orders in the First Bakery.
	"b2_comp": false, # Second Bakery Complete! c
	# Complete all the Orders in the Second Bakery.
	"game_comp": false, # Marshmallow Lady Approves c
	# Complete all the Orders in the game.
	
	# Level-specific
	"1_2": false, # "An Order by the Book" c
	# Complete Order 1-2 without Unmashing.
	"1_6": false, # "Trespassing" c
	# Complete Order 1-6 without using the Green Cherry Bomb.
	"2_11": false, # "Nothing Hershey but us Chickens" c
	# Get on top of the Left Platform on Level 2-11.
	"2_13": false, # "Lofty Toffee" c
	# Complete Order 2-13 without mashing into the Grey Block. (Perform a mid-air jump.)
	"2_20": false, # "The Floor is Lava" c
	# Complete Order 2-20 without falling down (Completing the Side-Order is fine.)
 		
	# Stats
	"100squat": false, # "Big Butt" c
	# Press down to squat 100 times. (Life-time)
	"200mash": false, # "I Like to Mash" c
	# Mash 200 times. (Life-time)
	
	# Misc
	"midair": false, # "Pop and Lock" c
	# Mash into a Block after flying off of a Cherry Bomb explosion.
	"curiosity": false, # "Curiousity" c
	# Open the Credits screen.
}
const DEFAULT_MEDAL_DATA = {
	# TODO: Possible issues with save data when versioning
	
	# Progression
	"bitten": false, # You Menace... c
	# Choose "Eat Her Anyway" and devour the prey.
	"safe": false, # Good Ending c
	# Choose "Got it" and display mercy.
	"b1_comp": false, # First Bakery Complete! c
	# Complete all the Orders in the First Bakery.
	"b2_comp": false, # Second Bakery Complete! c
	# Complete all the Orders in the Second Bakery.
	"game_comp": false, # Marshmallow Lady Approves c
	# Complete all the Orders in the game.
	
	# Level-specific
	"1_2": false, # "An Order by the Book" c
	# Complete Order 1-2 without Unmashing.
	"1_6": false, # "Trespassing" c
	# Complete Order 1-6 without using the Green Cherry Bomb.
	"2_11": false, # "Nothing Hershey but us Chickens" c
	# Get on top of the Left Platform on Level 2-11.
	"2_13": false, # "Lofty Toffee" c
	# Complete Order 2-13 without mashing into the Grey Block. (Perform a mid-air jump.)
	"2_20": false, # "The Floor is Lava" c
	# Complete Order 2-20 without falling down (Completing the Side-Order is fine.)
 		
	# Stats
	"100squat": false, # "Big Butt" c
	# Press down to squat 100 times. (Life-time)
	"200mash": false, # "I Like to Mash" c
	# Mash 200 times. (Life-time)
	
	# Misc
	"midair": false, # "Pop and Lock" c
	# Mash into a Block after flying off of a Cherry Bomb explosion.
	"curiosity": false, # "Curiousity" c
	# Open the Credits screen.
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
	"squats_made": 0,
	"mashes_made": 0,
	"op_sfx_muted": false,
	"op_music_muted": false,
	"op_a_on": false
}
# Dear data miners, be nice with the data :)
