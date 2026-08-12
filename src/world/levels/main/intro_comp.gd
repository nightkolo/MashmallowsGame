extends Node
class_name IntroComponent2


@export var player: Player
@export var camera: Cam
@export var player_spawn_pos: Marker2D

@export var logo: Sprite2D

@export var area_text: Area2D
@export var node_text: Node2D
@export var text_1: RichTextLabel
@export var text_2: RichTextLabel

@export var scene_1: Node2D
@export var scene_2: Node2D

@export var level: Level

@export var monolog: MonologSystem

@export var disc_interface: Control
@export var on_btn: Button
@export var off_btn: Button
@export var skip_interface: Control
@export var skip_btn: Button

var tween_cam: Tween
var tween_area: Tween

var cam_pos: Vector2

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_skip"):
		goto_menus()


func skip_intro() -> void:
	if skip_interface.visible && !monolog.monolog_has_happened:
		Trans.slide_to_scene("res://world/levels/main/level_1.tscn")
		
		skip_interface.visible = false


func goto_menus() -> void:
	if skip_interface.visible:
		GameMgr.menu_entered.emit(GameMgr.MenuID.MENUS)
		
		Trans.slide_to_scene("res://interface/menus/main_menus_scene.tscn")
		
		skip_interface.visible = false


func return_run() -> void:
	GameMgr.current_ui_handler.allow_input = true
	get_tree().paused = false
	disc_interface.visible = false


func _unlock_safe_medal() -> void:
	await MedalMgr.unlock_a_medal("safe", NewgroundsIds.MedalId.YouMenace)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if logo:
		logo.visible = false
	
	if skip_interface && skip_btn && on_btn && off_btn && disc_interface:
		
		skip_interface.modulate = Color(Color.WHITE, 0.0)
		skip_interface.visible = false
		disc_interface.visible = false
		
		if GameData.runtime_data.has("first_session"):
				
			if GameData.runtime_data["first_session"] == false:
				GameMgr.game_pause_toggled.connect(func(paused: bool):
					skip_interface.visible = !paused
					)
					
				skip_interface.visible = true
				
				skip_btn.pressed.connect(goto_menus)
				#pause_btn.pressed.connect(goto_menus)
				
				var t := create_tween()
				
				t.tween_property(skip_interface, "modulate", Color(Color.WHITE, 1.0), 1.0).set_delay(1.0)
			elif !GameMgr.ON_NEWGROUNDS_MIRROR:
				get_tree().paused = true
				disc_interface.visible = true
				GameMgr.current_ui_handler.allow_input = false
				
				on_btn.grab_focus()
				on_btn.pressed.connect(func():
					GameMgr.set_adult_filter_on(false)
					return_run()
					)
				off_btn.pressed.connect(func():
					GameMgr.set_adult_filter_on(true)
					return_run()
					)

	area_text.body_entered.connect(func(body: Node2D):
		if body is Player:
			if tween_area:
				tween_area.kill()
			tween_area = create_tween()
			tween_area.tween_property(node_text, "modulate", Color(Color.WHITE, 0.25), 0.4)
		)
	area_text.body_exited.connect(func(body: Node2D):
		if body is Player:
			if tween_area:
				tween_area.kill()
			tween_area = create_tween()
			tween_area.tween_property(node_text, "modulate", Color(Color.WHITE, 1.0), 0.4)
		)
		

	# Engine.time_scale = 1.0/8.0
	# player.sprite_player_zoom_in.visible = true
	text_1.visible = false
	text_2.visible = false
	text_1.self_modulate = Color(Color.WHITE, 0.0)
	text_2.self_modulate = Color(Color.WHITE, 0.0)
	# text_1.pivot_offset_ratio = Vector2.ONE * 0.5
	# text_1.scale = Vector2(0.0, -0.5)
	# text_2.pivot_offset_ratio = Vector2.ONE * 0.5
	# text_2.scale = Vector2(0.0, -0.5)
	monolog.choice_1_pressed.connect(func():
		await MedalMgr.unlock_a_medal("bitten", NewgroundsIds.MedalId.YouMenace)
		)
	monolog.choice_2_pressed.connect(func():
		await MedalMgr.unlock_a_medal("safe", NewgroundsIds.MedalId.GoodEnding)
		)

	monolog.monolog_finished.connect(func():
		skip_interface.visible = false
		
		await get_tree().create_timer(1.5).timeout

		await player.animator.anim_zoom_in()
		player.is_active = true

		if GameData.runtime_data.has("first_session"):
			GameData.runtime_data["first_session"] = false

		if logo && camera:
			logo.scale = Vector2.ZERO
			logo.global_position = camera.global_position
			logo.visible = true

			var tween := create_tween()
			tween.set_trans(Tween.TRANS_BACK)
			tween.tween_property(logo, "scale", Vector2.ONE, 0.4).set_ease(Tween.EASE_OUT)
			tween.set_ease(Tween.EASE_IN)
			tween.tween_property(logo, "scale", Vector2.ZERO, 0.4).set_delay(0.8)
			await tween.finished
			logo.visible = false
			await get_tree().create_timer(0.1).timeout

		Trans.instant_to_scene(Util.LEVEL_FILE_BEGIN + "1" + Util.LEVEL_FILE_END)
		

	)
	player.has_waken_up.connect(func():
		anim_text_popping_up()
	)
	player.has_mashed.connect(func(a, b):
		if player.child_blocks.size() == GameLogic.number_of_blocks:
			GameLogic.intro_order_complete.emit()
	)

	GameLogic.intro_order_complete.connect(func():
		await get_tree().create_timer(1.0).timeout

		await player.animator.anim_zoom_in()

		scene_1.position.x -= 1380.0

		scene_2.position.x -= 1380.0

		# player.scale = Vector2.ONE * 0.7
		player.global_position = player_spawn_pos.global_position
		# var tween := create_tween()
		# tween.tween_property(player, "scale", Vector2.ONE, 0.2)

		camera.set_process(false)
		camera.zoom = Vector2.ONE * 1.1
		# camera.position.x += 100.0
		cam_pos = camera.position

		player.animator.anim_zoom_out()
	)

	## CAMERA ZOOM
	GameMgr.monolog_activated.connect(func(active: bool):
		if tween_cam:
			tween_cam.kill()
			
		tween_cam = create_tween().set_parallel(true)
		tween_cam.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		
		if active:
			tween_cam.tween_property(camera, "position", Vector2(750.0, 424.0), 1.0)
			tween_cam.tween_property(camera, "zoom", Vector2.ONE * 1.4, 1.0)
		else:
			tween_cam.tween_property(camera, "position", cam_pos, 1.0)
			tween_cam.tween_property(camera, "zoom", Vector2.ONE * 1.1, 1.0)
		)

var start_up_finished: bool = false

func anim_text_popping_up():
	if start_up_finished:
		return
		
	start_up_finished = true
	
	var dur := 1.0
	await get_tree().create_timer(1.0).timeout

	anim_text(text_1, dur, 0.9)

	await get_tree().create_timer(dur * 2.0).timeout

	level.spawn_blocks()
	anim_text(text_2, dur, 1.0)

# var _t_text: Tween

func anim_text(text: RichTextLabel, p_dur: float = 1.0, pitch: float = 1.0):
	Audio.text_01.pitch_scale = pitch
	Audio.text_01.play()
	var dur := p_dur
	text.pivot_offset_ratio = Vector2.ONE * 0.5
	text.position.x = (get_viewport().get_visible_rect().size.x / 2.0) - (text.size.x / 2.0)
	text.scale = Vector2(0.0, -2.0)
	text.scale.y = 0.0
	text.visible = true 	

	var _t_text = create_tween().set_parallel(true)
	_t_text.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_t_text.tween_property(text, "self_modulate", Color(Color.WHITE, 1.0), dur)
	_t_text.tween_property(text, "scale:x", 1.0, dur)
	_t_text.tween_property(text, "scale:y", 1.0, dur*1.5).set_delay(dur / 6.66)
	await _t_text.finished
	_t_text.kill()

	# await get_tree().create_timer(0.2).timeout
