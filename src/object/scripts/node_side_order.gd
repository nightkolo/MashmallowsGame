@tool
extends Node2D
class_name SideOrder

signal sideorder_gain(amount: int)
signal sideorder_loss()
signal sideorder_complete()

@export var door_to_activate: Door
@export var anchor: Node2D = null
@export var panel: Node2D = null
@export var particles: CPUParticles2D
@export_tool_button("Update Appearance") var update_look_ = update_look
@export_category("Sprites")
@export var text_reg: Texture2D = preload("res://assets/objects/sideorder-block-eyes-01.png")
@export var text_happy: Texture2D = preload("res://assets/objects/sideorder-block-eyes-02.png")


var order_code: Array[Dictionary]
var mash_block_checker_ids: Array[MashBlockCheckerID]
var last_amount_satisfied: int = 1




func update_look() -> void:
	var surface: Array[Node] = anchor.get_children() if anchor else get_children()
	
	for id: MashBlockCheckerID in surface:
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
	if GameMgr.current_player == null || order_code.is_empty() || has_openned:
		return

	amount_satisfied = 0
	is_checking_sideorder_match = true
	
	var current_player_code: Array[Dictionary] = GameMgr.current_player.player_blocks_code
	
 	# Worst case -> O(n * m)
	# n = order_code.size(), m = current_player_code.size()
	for o_entry: Dictionary in order_code:
		var id_node: MashBlockCheckerID = o_entry["ref"] as MashBlockCheckerID
		
		if id_node == null:
			continue
			
		var match_found: bool = false
		
		for p_entry: Dictionary in current_player_code:
			## Issue: Floating-point precision error, stupid CPU
			#print_debug("%s: %s, %s, %s, %s" % [id_node, o_entry["type"], p_entry["type"], o_entry["pos"], p_entry["pos"]])
			if o_entry["type"] != p_entry["type"]:
				continue
			
			if !o_entry["pos"].is_equal_approx(p_entry["pos"]):
				continue
				
			# Match found
			match_found = true
			break
		
		id_node.anim_satisfied(match_found)
		print_debug(id_node.sprite_face)
		id_node.sprite_face.texture = text_happy if match_found else text_reg
		
		if match_found:
			amount_satisfied += 1
	
	if amount_satisfied > last_amount_satisfied:
		sideorder_gain.emit(amount_satisfied)
	elif amount_satisfied < last_amount_satisfied:
		sideorder_loss.emit()
	
	last_amount_satisfied = amount_satisfied
	
	if amount_satisfied == number_of_sideorder_blocks:
		sideorder_met()
		
	#order_checked.emit()
	is_checking_sideorder_match = false


func sideorder_met() -> void:
	sideorder_complete.emit()
	
	if door_to_activate:
		door_to_activate.interact(true)
		
	anim_something()


func anim_something() -> void:
	pass


func anim_open():
	if panel:
		var t := create_tween().set_parallel(true)
		
		t.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		
		t.tween_property(panel, "scale", Vector2.ONE, 0.75)
		t.tween_property(panel, "modulate", Color(Color.WHITE, 1.0), 0.6).set_trans(Tween.TRANS_LINEAR)
		


func _ready() -> void:
	if door_to_activate == null:
		push_warning("door_to_activate not assigned")
		return
		
	if panel && particles:
		particles.emitting = false
		panel.scale = Vector2.ONE * -0.5
		panel.modulate = Color(Color.WHITE, 0.0)
	
	door_to_activate.has_interacted.connect(func(on: bool):
		if on:
			has_openned = true
		)
	sideorder_gain.connect(func(_amount: int):
		if door_to_activate:
			var d: DoorBlock = door_to_activate.door_blocks.pick_random()
			
			d.anim_side_eye()
		)
	
	var surface: Array[Node] = anchor.get_children() if anchor else get_children()
	
	for id: Node in surface:
		if !(id is MashBlockCheckerID):
			return
		
		var id_node: MashBlockCheckerID = id
		
		if id_node.is_side_id == false:
			push_warning("Be sure to turn on MashBlockCheckerID.is_side_id")
			id_node.is_side_id = true
		
		var s: Sprite2D = Sprite2D.new()
		s.scale = Vector2.ONE * 0.5
		id.sprite_face = s
		id.add_child(s)
		
		mash_block_checker_ids.append(id_node)
	
	GameLogic.player_mashed.connect(check_sideorder_completion)
	GameLogic.player_unmashed.connect(check_sideorder_completion)
	
	order_code.clear()
	number_of_sideorder_blocks = 0
	
	for id: MashBlockCheckerID in mash_block_checker_ids:
		Util.set_block_code(order_code, id.attributes, id)
		number_of_sideorder_blocks += 1
		
		id.anim_satisfied(id.attributes.mash_type == Util.MashType.PLAYER)
	
	check_sideorder_completion()
	
	if panel && particles:
		await get_tree().create_timer(0.5).timeout
		
		particles.emitting = true
		
		await get_tree().create_timer(0.6).timeout
		
		anim_open()
	
	
