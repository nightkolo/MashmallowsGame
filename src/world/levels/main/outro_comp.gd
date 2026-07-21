extends Node
class_name OutroComponent


@export var player: Player
@export var camera: Cam

@export var level: Level

@export var monolog: MonologSystem

var tween_cam: Tween
var tween_area: Tween

#var cam_pos: Vector2

func _unhandled_input(event: InputEvent) -> void:
	pass
	#if event.is_action_pressed("debug_next"):
		#GameLogic.intro_order_complete.emit()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	monolog.monolog_finished.connect(func():
		await get_tree().create_timer(1.5).timeout

		await player.animator.anim_zoom_in()
		player.is_active = true

		#Trans.instant_to_scene(Util.LEVEL_FILE_BEGIN + "1" + Util.LEVEL_FILE_END)
		

	)
	player.has_mashed.connect(func(a, b):
		if player.child_blocks.size() == GameLogic.number_of_blocks:
			GameLogic.intro_order_complete.emit()
	)

	## CAMERA ZOOM
	GameMgr.monolog_activated.connect(func(active: bool):
		if tween_cam:
			tween_cam.kill()
			
		tween_cam = create_tween().set_parallel(true)
		tween_cam.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		
		# TODO remove fixed values
		if active:
			#tween_cam.tween_property(camera, "position", Vector2(750.0, 424.0), 1.0)
			tween_cam.tween_property(camera, "zoom", Vector2.ONE * 1.4, 1.0)
			# tween_cam.tween_property(camera, "zoom", Vector2.ONE * 1.2, 1.0)
		else:
			#tween_cam.tween_property(camera, "position", cam_pos, 1.0)
			tween_cam.tween_property(camera, "zoom", Vector2.ONE * 1.1, 1.0)
		)
