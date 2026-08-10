extends Node
class_name OutroComponent


@export var player: Player
@export var camera: Cam

@export var level: Level

@export var monolog: MonologSystem
@export var monolog_Area: MonologArea

@export var millie : Millie

@export var ground_1: TileMapLayer

@export var player_spawner: PlayerSpawner
@export var flow_reg: MonologFlow = preload("res://core/resources/game_dialog/monolog_outro.tres")
@export var flow_safe: MonologFlow = preload("res://core/resources/game_dialog/monolog_outro_safe.tres")

var tween_cam: Tween
var tween_area: Tween

var lvl_index: int 

#var cam_pos: Vector2

func _unhandled_input(event: InputEvent) -> void:
	pass
	#if event.is_action_pressed("debug_next"):
		#GameLogic.intro_order_complete.emit()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameLogic.has_won = true
	
	lvl_index = Util.NUMBER_OF_LEVELS - 1
	
	if player_spawner:
		player_spawner.zoomed_in.connect(func():
			Trans.slide_to_credits()
			)
	
	monolog.flow = flow_safe if GameMgr.get_adult_filter_on_setting() else flow_reg
	
	monolog.monolog_finished.connect(func():
		ground_1.queue_free()
		monolog_Area.queue_free()
		
		var p: Player = GameMgr.current_player
		
		p.auto_controlled = true
		p.idle_direction = Vector2.RIGHT
		p.random_jumping = true
		camera.dynamic_cam = false
		millie.look_at_player = true
		millie.player = GameMgr.current_player
		
		if player_spawner:
			while lvl_index > 0:
				await get_tree().create_timer(1.25).timeout
				
				player_spawner.spawn_config = lvl_index
				player_spawner.spawn(lvl_index < 2, 8.0)
				
				lvl_index -= 2
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
