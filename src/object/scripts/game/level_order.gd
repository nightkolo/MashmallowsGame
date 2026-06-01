@tool
extends Node2D
class_name LevelOrder

@export var level_id_to_modify: int
@export var order_code: Array[Dictionary]

@export_tool_button("Update Appearance") var update_look_ = update_look
@export_tool_button("Create order code") var update_code_ = update_code
@export_tool_button("Save order code data (File-only)") var update_g_code_ = update_global_code


var mash_block_checker_ids: Array[MashBlockCheckerID]


func update_global_code() -> void:
	if level_id_to_modify == 0:
		print("Set level_id_to_modify correctly first!!")
		return
	
	if order_code.is_empty():
		print("Create the order code first!!")
		return
		
	var lvl_id := level_id_to_modify
	
	var data := {}
	
	var file: FileAccess = FileAccess.open(SaverLoader.LEVEL_SAVE_LOCATION, FileAccess.READ)
	
	data = JSON.parse_string(file.get_as_text())

	file.close()
	
	if data == null:
		data = {}

	if not data.has(str(lvl_id)):
		data[str(lvl_id)] = {}
	
	var arr: Array[Dictionary] = []
	
	for entry in order_code:
		arr.append({
			"type": entry["type"],
			"pos": {
				"x": entry["pos"].x,
				"y": entry["pos"].y
			}
		})
		
	data[str(lvl_id)]["order_code"] = arr
	
	var write_file := FileAccess.open(SaverLoader.LEVEL_SAVE_LOCATION, FileAccess.WRITE)
	write_file.store_string(JSON.stringify(data, "\t"))
	write_file.close()
	
	print("Order code save successful! :D")


func update_code() -> void:
	for id: MashBlockCheckerID in get_children():
		if !(id is MashBlockCheckerID):
			return
		
		Util.set_block_code(order_code, id.attributes, id)
	
	GameLogic.current_level_order_object = self


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
	
	# Wait for assignment
	await get_tree().create_timer(0.1).timeout
	
	order_code.clear()
		
	for id: MashBlockCheckerID in mash_block_checker_ids:
		Util.set_block_code(order_code, id.attributes, id)
	
	#for o: Dictionary in order_code:
		#print_debug(o)
		
	GameLogic.current_level_order_object = self
	
