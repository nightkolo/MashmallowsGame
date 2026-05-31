# Game Logic
extends Node

signal ready_to_check()
signal player_mashed()
signal player_unmashed()
signal player_touched_flame()
signal player_interacted_monolog_area(entered: bool)
signal order_gain(amount: int)
signal order_loss()
signal order_complete()
signal order_checked()

# INTRO SEQUENCE
signal intro_order_complete()
signal intro_orders_ended()

signal cherry_bomb_exploded()

signal completion_percentage_updated(perc: float)

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

var current_level_order_object: LevelOrder
var order_check_ori_pos: Vector2

var amount_satisfied: int = 1
var last_amount_satisfied: int = 1

## TODO: Analyze execution structure, minimize race conditions


func reset_game_logic() -> void:
	number_of_order_blocks = 0
	number_of_blocks = 0
	completion_percentage = 0.0
	last_amount_satisfied = 1
	amount_satisfied = 1
	
	is_stuck = false
	has_won = false
	is_checking_order_match = false
	order_check_ori_pos = Vector2.ZERO


func _ready() -> void:
	ready_to_check.connect(check_order_completion)
	# player_mashed.connect(check_order_completion)
	player_unmashed.connect(check_order_completion)
	player_touched_flame.connect(func():
		# await get_tree().create_timer(0.1).timeout
		check_order_completion()
		)
	
	intro_order_complete.connect(level_won)

	order_checked.connect(func():
		is_checking_order_match = false
		
		# GameMgr.current_order_checker.global_position = order_check_ori_pos
		)
	
	order_complete.connect(func():
		GameMgr.game_just_ended.emit()
		)


func order_met() -> void:
	order_complete.emit()
	has_won = true


func level_won():
	has_won = true
	print("Game over.")


func check_order_completion() -> void:
	if current_level_order_object == null || GameMgr.current_level.ignore_order:
		return
	
	print_debug("Checking...")

	amount_satisfied = 0
	is_checking_order_match = true
	
	var order_code: Array[Dictionary] = current_level_order_object.order_code
	var player_code: Array[Dictionary] = GameMgr.current_player.player_blocks_code
	
 	# Worst case -> O(n * m)
	# n = order_code.size(), m = player_code.size()
	for o_entry: Dictionary in order_code:
		var id_node: MashBlockCheckerID = o_entry["ref"] as MashBlockCheckerID
		
		if id_node == null:
			continue
		
		var match_found: bool = false
		
		for p_entry: Dictionary in player_code:
			if o_entry["type"] != p_entry["type"]:
				continue
			
			if o_entry["pos"] != p_entry["pos"]:
				continue
				
			# Match found
			match_found = true
			break
		
		id_node.anim_satisfied(match_found)
		if match_found:
			amount_satisfied += 1

	completion_percentage = (float(amount_satisfied - 1.0) / number_of_order_blocks)
	
	print_debug("completion_percentage: %s" % completion_percentage )
	
	if amount_satisfied > last_amount_satisfied:
		order_gain.emit(amount_satisfied)
	elif amount_satisfied < last_amount_satisfied:
		order_loss.emit()
	
	last_amount_satisfied = amount_satisfied
	
	if amount_satisfied - 1 == number_of_order_blocks:
		order_met()
	
	order_checked.emit()


## 0.05s waittime
# TODO: Rework game logic
#func check_order_completion() -> void: # Ok -> O(n), Worst case -> O(n^2)
	#if GameMgr.current_order_checker == null || GameMgr.current_level.ignore_order:
		#return
	#
	#print_debug("Checking...")
#
	#is_checking_order_match = true
	#GameMgr.current_order_checker.global_position = GameMgr.current_player.position
	#
	#await get_tree().create_timer(0.05).timeout
	#
	#amount_satisfied = GameMgr.current_order_checker.check_satisfaction_full()
	#
	#completion_percentage = (float(amount_satisfied - 1.0) / number_of_order_blocks)
	#
	#if amount_satisfied > last_amount_satisfied:
		#order_gain.emit(amount_satisfied)
	#elif amount_satisfied < last_amount_satisfied:
		#order_loss.emit()
	#
	#last_amount_satisfied = amount_satisfied
#
	#
	#if amount_satisfied - 1 == number_of_order_blocks:
		#order_met()
	#
	#order_checked.emit()
	
	
func setup_mash_block(sprite: Sprite2D, type: Util.MashType, build: Util.BuildType = Util.BuildType.SQUARE) -> void:
	sprite.texture = Util.get_order_block_texture(type, build)
	

func setup_mash(sprite: Sprite2D, type: Util.MashType, build: Util.BuildType = Util.BuildType.SQUARE, golden: bool = false) -> void:

	sprite.texture = Util.get_mash_type_texture(type, build)
	if golden:
		sprite.self_modulate = Color(Color.WHITE * 0.5,1.0)
	else:
		sprite.self_modulate = Color(Color.WHITE)
	
