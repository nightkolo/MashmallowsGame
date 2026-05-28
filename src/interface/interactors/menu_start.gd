extends Control

@onready var shade: Sprite2D = %Shade
@onready var loading: LoadingScreen = %Loading
@onready var authors_text: RichTextLabel = %Authors
@onready var start_text: RichTextLabel = %Text
@onready var particles: Array[CPUParticles2D] = [%Particles, %Particles2]

var _started: bool = false


func _ready() -> void:
	GameMgr.menu_entered.emit(GameMgr.MenuID.START)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("start_game"):
		start_game()


func start_game() -> void:
	if _started:
		return
	
	var file: String = Util.LEVEL_FILE_BEGIN + "0" + Util.LEVEL_FILE_END

	if !ResourceLoader.exists(file):
		push_error("First level data not found, cannot start :(")
		return

	_started = true

	Audio.game_start.play()

	start_text.pivot_offset_ratio = Vector2.ONE * 0.5
	authors_text.pivot_offset_ratio = Vector2.ONE * 0.5

	var tween := create_tween().set_parallel(true)

	tween.tween_property(shade, "self_modulate", Color(Color.WHITE, 0.0), 0.4)
	tween.tween_property(start_text, "scale", Vector2.ZERO, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(authors_text, "scale", Vector2.ZERO, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_callback(func():
		for p: CPUParticles2D in particles:
			p.position = get_viewport().get_visible_rect().size * 0.5
			p.emitting = true
		)
	await particles[0].finished
	# await tween.finished

	loading.visible = true
	loading.start_loading()
	# get_tree().change_scene_to_file("res://interface/menus/level_0_loading_screen.tscn")
		
