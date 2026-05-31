## @deprecated: Use [LevelOrder]
@tool
extends Node2D
class_name Order

# @warning_ignore("unused_private_class_variable")
@export_tool_button("Update") var update_look_ = update_look

var mash_block_checker_ids: Array[MashBlockCheckerID]

var order_checker: PackedScene = preload("res://object/game/order_checker.tscn")
var mash_block_checker: PackedScene = preload("res://object/game/mash_block_checker.tscn")

# var nodes: Array[Node] = get_children()

func update_look():
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
	await get_tree().create_timer(0.1).timeout
	
	var oc: OrderChecker = order_checker.instantiate()
	
	for id: MashBlockCheckerID in mash_block_checker_ids:
		var m: MashBlockChecker = mash_block_checker.instantiate()
		
		m.corresponding_mash_block_id = id
		m.position = id.position
		m.attributes = id.attributes
		# m.is_mash_type = id.is_mash_type
		# m.is_build_type = id.is_build_type
		# m.is_golden = id.is_golden
		
		oc.add_child(m)
	
	oc.position = Vector2.ONE * 30.0
	
	GameMgr.current_level.add_child(oc)
	
