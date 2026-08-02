# Game Logic
extends Node

# To avoid player null checks
signal player_mashed() 
signal player_unmashed() 
signal player_interacted_monolog_area(entered: bool)
signal cherry_bomb_exploded()
#
signal order_gain(amount: int)
signal order_loss()
signal order_complete()
signal order_checked()
signal completion_percentage_updated(perc: float)

# INTRO SEQUENCE
signal intro_order_complete()


var is_checking_order_match: bool = false
var has_won: bool = false
var is_stuck: bool = false

var number_of_order_blocks: int
var number_of_blocks: int
var completion_percentage: float:
	set(value):
		if value != completion_percentage:
			completion_percentage_updated.emit(value)
		completion_percentage = value

var current_order_code: Array[Dictionary] = []
var current_level_order_object: LevelOrder:
	set(value):
		current_order_code = value.order_code
		current_level_order_object = value

var amount_satisfied: int = 1
var last_amount_satisfied: int = 1


func reset_game_logic() -> void:
	number_of_order_blocks = 0
	number_of_blocks = 0
	completion_percentage = 0.0
	last_amount_satisfied = 1
	amount_satisfied = 1
	
	is_stuck = false
	has_won = false
	is_checking_order_match = false


func _ready() -> void:
	player_mashed.connect(check_order_completion)
	player_unmashed.connect(check_order_completion)
	
	intro_order_complete.connect(level_won)

	order_checked.connect(func():
		is_checking_order_match = false
		)
	
	order_complete.connect(func():
		GameMgr.game_just_ended.emit()
		)


func order_met() -> void:
	order_complete.emit()
	has_won = true


func level_won() -> void:
	has_won = true
	print("Game over.")


func check_order_completion() -> void:
	if GameMgr.current_level:
		if GameMgr.current_level.ignore_order:
			return
	
	if GameMgr.current_player == null || current_order_code.is_empty():
		return
			
	print_debug("Checking...")

	amount_satisfied = 0
	is_checking_order_match = true
	
	var current_player_code: Array[Dictionary] = GameMgr.current_player.player_blocks_code
	
 	# Worst case -> O(n * m)
	# n = current_order_code.size(), m = current_player_code.size()
	for o_entry: Dictionary in current_order_code:
		var id_node: MashBlockCheckerID = o_entry["ref"] as MashBlockCheckerID
		
		if id_node == null:
			continue
		
		var match_found: bool = false
		
		for p_entry: Dictionary in current_player_code:
			if o_entry["type"] != p_entry["type"]:
				continue
			
			if !o_entry["pos"].is_equal_approx(p_entry["pos"]):
				continue
				
			# Match found
			match_found = true
			break
		#print_debug(
			#"%s: %s" % [id_node, match_found]
			#)
		
		id_node.anim_satisfied(match_found)
		if match_found:
			amount_satisfied += 1

	completion_percentage = (float(amount_satisfied - 1.0) / number_of_order_blocks)
	
	if amount_satisfied > last_amount_satisfied:
		order_gain.emit(amount_satisfied)
	elif amount_satisfied < last_amount_satisfied:
		order_loss.emit()
	
	last_amount_satisfied = amount_satisfied
	
	#print_debug("amount_satisfied: %d" % amount_satisfied)
	#
	#print_debug("number_of_order_blocks: %d" % number_of_order_blocks)
	
	if amount_satisfied - 1 == number_of_order_blocks:
		order_met()
	
	order_checked.emit()

	
func setup_mash_block(sprite: Sprite2D, type: Util.MashType, build: Util.BuildType = Util.BuildType.SQUARE) -> void:
	sprite.texture = Util.get_order_block_texture(type, build)
	

func setup_mash(sprite: Sprite2D, type: Util.MashType, build: Util.BuildType = Util.BuildType.SQUARE) -> void:
	sprite.texture = Util.get_mash_type_texture(type, build)
	
