extends Node2D
class_name UIOrderPreview

var current_level_focussed: int = 0:
	set(value):
		current_level_focussed = value
		#print_debug(value)
		_try_update()

var tween: Tween

var last_dir: Vector2
var current_pos: Vector2

var timer: Timer = Timer.new()

func anim_preview():
	if center_sprite == null:
		return
	center_sprite.visible = true
	
	if tween:
		tween.kill()
	
	tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	tween.tween_property(center_sprite, "position", current_pos, 0.5).set_trans(Tween.TRANS_BACK)
	tween.tween_property(center_sprite, "scale", Vector2.ONE, 1.2)


func _try_update():
	if timer == null || !timer.is_inside_tree():
		return
	
	if !timer.is_stopped():
		timer.stop()

	timer.start()
	

func read_level_data_and_update(p_lvl: int) -> int:
	var lvl: String = str(p_lvl)
	
	if !LevelData.order_data.has(lvl):
		return 1 # Failed
	
	for child: Node in get_children():
		if child is Sprite2D:
			child.queue_free()
	
	var oc: Array = LevelData.order_data[lvl]["order_code"]
	
	await get_tree().create_timer(0.1).timeout # Process frame
	
	reposition_sprites(oc)
	if center_sprite:
		center_sprite.visible = false
		center_sprite.scale = Vector2(
			1.0 + (last_dir.y * 0.25 * signf(randf() - 0.5)),
			1.0 + (last_dir.x * 0.25 * signf(randf() - 0.5))
		)
	add_preview_sprites(oc, lvl)
	anim_preview()
	
	return 0 # OK

func add_preview_sprites(oc: Array, p_lvl: String):
	if oc.is_empty():
		return
	
	var stat: bool = GameData.runtime_data[p_lvl]["completed"]
	
	for entry: Dictionary in oc:
		var sprite := Sprite2D.new()
		sprite.texture = Util.get_order_block_texture(entry["type"], entry["build"], stat)
		sprite.position = Util.BLOCK_SIZE * Vector2(
			entry["pos"]["x"],
			entry["pos"]["y"]
			)
		sprite.scale = Vector2.ONE * 0.5
		center_sprite.add_child(sprite)


var center_sprite: Sprite2D
#
## TODO memory leak if get_children() array contains non-Node2D.
func reposition_sprites(order_code: Array):
	#var children: Array[Node] = get_children()
	
	if order_code.is_empty():
		return
	
	var max_x: float = order_code[0]["pos"]["x"]
	var min_x: float = order_code[0]["pos"]["x"]
	var max_y: float = order_code[0]["pos"]["y"]
	var min_y: float = order_code[0]["pos"]["y"]
	
	for entry: Dictionary in order_code:
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
		
	current_pos = -1 * ((origin * Util.BLOCK_SIZE) + (Util.BLOCK_SIZE * length * 0.5))
	center_sprite.position = current_pos + (last_dir * 150.0)
	#center_sprite.texture = preload("res://assets/world/particle_circle_01.png")
	
	#print_debug("current_level_forder_codeussed: %s" % current_level_focussed)
	#print_debug("max_x: %s" % max_x)
	#print_debug("min_x: %s" % min_x)
	#print_debug("max_y: %s" % max_y)
	#print_debug("min_y: %s" % min_y)
	#print_debug("l_repos: %s" % l_repos)
	
	#center_sprite.position = Vector2.ZERO

func _ready() -> void:
	var s: Vector2 = (get_parent() as Control).size
	
	position = Vector2(300.0, 410.0)
	scale = Vector2.ONE * 1.5
	
	timer.wait_time = 0.15
	timer.one_shot = true
	add_child(timer)
	
	timer.timeout.connect(func():
		read_level_data_and_update(current_level_focussed)
		)
	
	
