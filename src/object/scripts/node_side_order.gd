@tool
extends Node2D
class_name SideOrder

@export var door_to_activate: Door
@export_tool_button("Update Appearance") var update_look_ = update_look


var order_code: Array[Dictionary]
var mash_block_checker_ids: Array[MashBlockCheckerID]

func update_look() -> void:
	for id: MashBlockCheckerID in get_children():
		if !(id is MashBlockCheckerID):
			return

		var sprite: Sprite2D = id.get_node_or_null("Sprite2D")

		if sprite == null || id.attributes == null:
			break

		sprite.texture = Util.get_order_block_texture(id.attributes.mash_type, id.attributes.build_type)

		if !id.is_node_ready():
			continue

var is_checking_sideorder_match: int = 0
var amount_satisfied: int = 0
var number_of_sideorder_blocks: int = 0
var has_openned: bool = false

func check_sideorder_completion() -> void:
	if GameMgr.current_main_player == null || order_code.is_empty() || has_openned:
		return

	amount_satisfied = 0
	is_checking_sideorder_match = true
	
	var current_player_code: Array[Dictionary] = GameMgr.current_main_player.player_blocks_code
	
 	# Worst case -> O(n * m)
	# n = order_code.size(), m = current_player_code.size()
	for o_entry: Dictionary in order_code:
		var match_found: bool = false
		
		for p_entry: Dictionary in current_player_code:
			if o_entry["type"] != p_entry["type"]:
				continue
			
			if o_entry["pos"] != p_entry["pos"]:
				continue
				
			# Match found
			match_found = true
			break
		
		#id_node.anim_satisfied(match_found)
		if match_found:
			amount_satisfied += 1
	
	print_debug("amount_satisfied: %d" % amount_satisfied)
	
	print_debug("number_of_sideorder_blocks: %d" % number_of_sideorder_blocks)
	
	if amount_satisfied == number_of_sideorder_blocks:
		sideorder_met()
		
	#order_checked.emit()
	is_checking_sideorder_match = false



func sideorder_met():
	if door_to_activate && !has_openned:
		door_to_activate.interact(true)
		
		has_openned = true


func _ready() -> void:
	if door_to_activate == null:
		push_warning("door_to_activate not assigned")
		return
		
	for id: Node in get_children():
		if !(id is MashBlockCheckerID):
			return
		
		if (id as MashBlockCheckerID).is_side_id == false:
			push_warning("Be sure to turn on MashBlockCheckerID.is_side_id")
			(id as MashBlockCheckerID).is_side_id = true
			
		mash_block_checker_ids.append(id as MashBlockCheckerID)
	
	GameLogic.player_mashed.connect(check_sideorder_completion)
	GameLogic.player_unmashed.connect(check_sideorder_completion)
	
	order_code.clear()
	number_of_sideorder_blocks = 0
	
	for id: MashBlockCheckerID in mash_block_checker_ids:
		Util.set_block_code(order_code, id.attributes, id)
		number_of_sideorder_blocks += 1
	
	
	print_debug("number_of_sideorder_blocks: %d" % number_of_sideorder_blocks)
	#for o: Dictionary in order_code:
		#print_debug(o)
		
	#GameLogic.current_level_order_object = self
	
