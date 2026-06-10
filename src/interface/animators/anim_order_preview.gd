extends Node2D
class_name UIOrderPreview

var current_level_focussed: int = 0:
	set(value):
		print_debug(value)
		read_level_data(value)
		current_level_focussed = value


func read_level_data(p_lvl: int):
	var lvl: String = str(p_lvl)
	
	if !LevelData.order_data.has(lvl):
		return
	
	for child: Node in get_children():
		child.queue_free()
	
	var oc: Array = LevelData.order_data[lvl]["order_code"]
	
	
	await get_tree().create_timer(0.1).timeout
	repos(oc)
	
	add_preview_sprites(oc, lvl)

func add_preview_sprites(oc: Array, p_lvl: String):
	if oc.is_empty():
		return
	
	var stat: bool = GameData.runtime_data[p_lvl]["completed"]
	

	for entry: Dictionary in oc:
		var sprite := Sprite2D.new()
		sprite.texture = Util.get_order_block_texture(entry["type"], entry["build"], stat)
		sprite.position = Util.BLOCK_SIZE * Vector2( entry["pos"]["x"], entry["pos"]["y"] )
		sprite.scale = Vector2.ONE * 0.5
		center_sprite.add_child(sprite)


var center_sprite: Sprite2D
#
## TODO memory leak if get_children() array contains non-Node2D.
func repos(oc: Array):
	#var children: Array[Node] = get_children()
	
	if oc.is_empty():
		return
	
	var max_x: float = oc[0]["pos"]["x"]
	var min_x: float = oc[0]["pos"]["x"]
	var max_y: float = oc[0]["pos"]["y"]
	var min_y: float = oc[0]["pos"]["y"]
	
	for entry: Dictionary in oc:
		var pos: Vector2 = Vector2(entry["pos"]["x"], entry["pos"]["y"])
		
		if pos.x > max_x:
			max_x = pos.x 
		elif pos.x < min_x:
			min_x = pos.x 
			
		if pos.y > max_y:
			max_y = pos.y 
		elif pos.y < min_y:
			min_y = pos.y 
	
	var origin: Vector2 = Vector2(min_x, min_y)
	var length: Vector2 = Vector2(
		absf(min_x) + absf(max_x), 
		absf(min_y) + absf(max_y)
		)
	
	if center_sprite == null:
		center_sprite = Sprite2D.new()
		add_child(center_sprite)
		
	var l_repos: Vector2 = (origin * Util.BLOCK_SIZE) + (Util.BLOCK_SIZE * length * 0.5)
	center_sprite.position = -l_repos
	center_sprite.texture = preload("res://assets/world/particle_circle_01.png")
	
	print_debug("current_level_focussed: %s" % current_level_focussed)
	print_debug("max_x: %s" % max_x)
	print_debug("min_x: %s" % min_x)
	print_debug("max_y: %s" % max_y)
	print_debug("min_y: %s" % min_y)
	print_debug("l_repos: %s" % l_repos)
	
	#center_sprite.position = Vector2.ZERO

func _ready() -> void:
	var s: Vector2 = (get_parent() as Control).size
	
	position = Vector2(300.0, 350.0)
	scale = Vector2.ONE * 1.5
