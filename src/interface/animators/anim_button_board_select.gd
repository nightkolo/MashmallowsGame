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
	display_data()
	
	GameMgr.game_data_saved.connect(display_data)
	
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

func display_data() -> void:
	board_id = self.name.to_int()
	
	var board_num: String = str(board_id)

	if !GameData.runtime_data.has(board_num):
		print_debug("Cannot display data. Key %s not found in GameData.runtime_data." % board_num)
		return
	
	if !(board_id >= 0 && board_id <= Util.NUMBER_OF_LEVELS):
		print_debug("Cannot display data. Key %s is out of bounds from GameUtil.NUMBER_OF_LEVELS." % board_num)
		return
	
	## TODO: Fix added twice
	if node == null && GameData.runtime_data[board_num]["completed"] == true:
		node = Node2D.new()
		var sprite := Sprite2D.new()
		
		sprite.texture = com_texture
		sprite.self_modulate = Color(1.0, 1.0, 0.25, 1.0)
		sprite.scale = 0.75 * Vector2.ONE
		node.add_child(sprite)
		self.add_child(node)
	#com_star.visible = GameData.runtime_data[board_num]["completed"] == true
	#uncom_star.visible = GameData.runtime_data[board_num]["completed"] == false


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
	self.rotation_degrees = randf_range(20.0,45.0) * signf(randf() - 0.5)
	
	play_aud()
	
	
	self_modulate = Color(Color.WHITE*1.2)
	
	if tween:
		tween.kill()
		
	tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", scale_to, dur).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self,"rotation_degrees",0.0,dur * 0.6)
	
		
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
	self.rotation_degrees = 0.0
	
	if tween:
		tween.kill()
		
	tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE, dur).set_trans(Tween.TRANS_ELASTIC)
	
