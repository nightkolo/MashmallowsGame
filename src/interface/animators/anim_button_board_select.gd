extends Button
class_name BoardSelectButton

var tween: Tween
var board_id: int = 0


#@onready var com_star: Node2D = $Node2D/Bcheck
#@onready var uncom_star: Node2D = $Node2D/Bcheck2
#@onready var node_2d: Node2D = $Node2D

var com_texture: Texture = preload("res://assets/interface/level-star-com.png")
var uncom_texture: Texture = preload("res://assets/interface/level-star-uncom.png")

func _ready() -> void:
	display_data_once()
	
	GameMgr.game_data_saved.connect(stop_anim)
	GameMgr.game_data_saved.connect(display_data_once)
	
	#com_star.texture = com_texture

	#uncom_star.texture = uncom_texture
	#for s: Sprite2D in [com_star, uncom_star]:
		#s.self_modulate = Color(Color.WHITE, 1.0)
		#s.scale = Vector2.ONE * 0.5
#	
	self.add_to_group("UIBoardButton")
	
	pivot_offset = size / 2.0
	#node_2d.scale = Vector2.ONE * 0.75
	#node_2d.position = Vector2.ONE * 7.5
	
	pressed.connect(anim_pressed)
	mouse_entered.connect(anim_entered)
	mouse_exited.connect(anim_exited)
	focus_entered.connect(anim_entered)
	focus_exited.connect(anim_exited)

var node: Node2D
var sprite: Sprite2D

func display_data_once() -> void:
	board_id = self.name.to_int()
	
	var board_num: String = str(board_id)

	if !GameData.runtime_data.has(board_num):
		print_debug("Cannot display data. Key %s not found in GameData.runtime_data." % board_num)
		return
	
	if !(board_id >= 0 && board_id <= Util.NUMBER_OF_LEVELS):
		print_debug("Cannot display data. Key %s is out of bounds from GameUtil.NUMBER_OF_LEVELS." % board_num)
		return
	if node:
		node.queue_free()
	if sprite:
		sprite.queue_free()
	
	## TODO: Fix added twice
	if GameData.runtime_data[board_num]["completed"] == true:
		node = Node2D.new()
		sprite = Sprite2D.new()
		
		sprite.texture = com_texture
		sprite.self_modulate = Color(1.0, 1.0, 0.25, 1.0)
		sprite.scale = 0.75 * Vector2.ONE
		node.add_child(sprite)
		self.add_child(node)
	
	#await get_tree().process_frame
		anim_star()
	#com_star.visible = GameData.runtime_data[board_num]["completed"] == true
	#uncom_star.visible = GameData.runtime_data[board_num]["completed"] == false
var l_tween: Tween

func anim_star() -> void:
	if node == null:
		return
	
	anim_star_pulse()
	anim_star_rot()
	var spd := 0.25
	
	if l_tween:
		l_tween.kill()
		
	l_tween = create_tween().set_loops()
	
	l_tween.set_parallel(true)
	l_tween.set_ease(Tween.EASE_OUT)
	
	l_tween.tween_callback(anim_star_pulse)
	l_tween.tween_property(node, "position:y", -10.0, spd * 0.2)
	l_tween.tween_property(node, "scale", Vector2(0.8, 1.2), spd * 0.6)
	l_tween.chain().tween_property(node, "position:y", 0.0, spd * 0.35).set_trans(Tween.TRANS_SINE)
	
	l_tween.chain().tween_property(node, "scale", Vector2.ONE, 1.0).set_trans(Tween.TRANS_ELASTIC)
	#l_tween.tween_callback(func():
		#if randf() < 1.0 / 4.0:
			#anim_star_rot()
		#)
	l_tween.tween_interval(1.0)

var l_tween_2

func anim_star_rot():
	var dir := 1.0 if board_id % 2 == 0 else -1.0 
	
	if l_tween_2:
		l_tween_2.kill()
	l_tween_2 = create_tween().set_loops()
	l_tween_2.set_ease(Tween.EASE_OUT_IN)
	l_tween_2.tween_property(node, "rotation_degrees", dir * 5.5, 1.0).set_ease(Tween.EASE_OUT_IN)
	l_tween_2.tween_property(node, "rotation_degrees", dir * -5.5, 1.0).set_ease(Tween.EASE_OUT_IN)

var l_tween_3: Tween

func stop_anim():
	if l_tween_3:
		l_tween_3.kill()
	if l_tween:
		l_tween.kill()
	if l_tween_2:
		l_tween_2.kill()
	
func anim_star_pulse():
	if l_tween_3:
		l_tween_3.kill()
		
	l_tween_3 = create_tween()
	
	l_tween_3.tween_property(node, "modulate", Color(Color.WHITE * 2.0), 0.1)
	l_tween_3.tween_property(node, "modulate", Color(Color.WHITE, 1.0), 0.6)
	

func anim_pressed() -> void:
	var dur := 1.0
	
	#Audio.ui_button_click.play()
	
	scale = Vector2(1.2, 0.8)
	
	if tween:
		tween.kill()
		
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE, dur)


func anim_entered() -> void:
	var dur := 1.0
	var scale_to := Vector2.ONE * 1.2
	
	scale = Vector2.ZERO
	#self.rotation_degrees = randf_range(45.0,65.0) * signf(randf() - 0.5)
	#self.skew = randf_range(45.0,65.0) * signf(randf() - 0.5)
	
	play_aud()
	
	
	self_modulate = Color(Color.WHITE*1.2)
	
	if tween:
		tween.kill()
		
	tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", scale_to, dur).set_trans(Tween.TRANS_ELASTIC)
	#tween.tween_property(self,"rotation_degrees",0.0,dur * 0.6)
	#tween.tween_property(self,"skew",0.0,dur * 0.6)
	
		
func play_aud() -> void:
	var aud := Audio.ui_button_hover.duplicate() as AudioStreamPlayer
	add_child(aud)
	aud.pitch_scale = randf_range(0.8, 1.2)
	aud.play()
	
	await aud.finished
	aud.queue_free()


func anim_exited() -> void:
	var dur := 0.75
	
	self_modulate = Color(Color.WHITE*1.0)
	#self.rotation_degrees = 0.0
	
	if tween:
		tween.kill()
		
	tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE, dur).set_trans(Tween.TRANS_ELASTIC)
	
