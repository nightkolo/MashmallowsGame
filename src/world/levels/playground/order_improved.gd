@tool
extends Node2D
class_name LevelOrder

@export_tool_button("Update") var update_look_ = update_look
@export_tool_button("Create order code") var update_code_ = update_code

var mash_block_checker_ids: Array[MashBlockCheckerID]
@export var order_code: Array[Dictionary]


func update_code() -> void:
	for id: MashBlockCheckerID in get_children():
		if !(id is MashBlockCheckerID):
			return
		
		Util.set_block_code(order_code, id.attributes, id)


func update_look() -> void:
	for id: MashBlockCheckerID in get_children():
		if !(id is MashBlockCheckerID):
			return

		var sprite: Sprite2D = id.get_node_or_null("Sprite2D")

		if sprite == null || id.attributes == null:
			break

		sprite.texture = Util.get_order_block_texture(id.attributes.mash_type, id.attributes.build_type)
		sprite.texture = Util.get_order_block_texture(id.attributes.mash_type, id.attributes.build_type)

		if !id.is_node_ready():
			continue

		if id.attributes.is_golden:
			sprite.self_modulate = Color(Color.WHITE * 0.5,1.0)
		elif !id.attributes.is_golden:
			sprite.self_modulate = Color(Color.WHITE)


func _ready() -> void:
	GameLogic.current_level_order_object = self
	
	await get_tree().create_timer(0.1).timeout
	
	order_code.clear()
		
		
	for id: MashBlockCheckerID in mash_block_checker_ids:
		Util.set_block_code(order_code, id.attributes, id)
	
	#for o: Dictionary in order_code:
		#print_debug(o)
	
