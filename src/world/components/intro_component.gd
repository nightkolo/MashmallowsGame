extends Node
class_name IntroComponent

@export var cam: Cam
@export var NPC: NPCBoard
@export var level_goal: LevelGoal
@export var terrain: Terrain
@export var player: Player
@export var sprite_black_out: Sprite2D
@export var unmashed_blocks: Array[UnmashedSpawner]
@export_category("Monolog")
@export var monolog_1: MonologSystem
@export var monolog_2: MonologSystem
@export_category("Monolog Areas")
@export var monolog_area_1: MonologArea
@export var monolog_area_2: MonologArea
@export_category("TileMaps")
@export var ground_1: TileMapLayer
@export var ground_2: TileMapLayer

var tween_cam: Tween

## TODO: Clean-up code

func setup():
	await get_tree().create_timer(0.1).timeout
	player.sprite_player_zoom_in.visible = true
	(player.sprite_player_zoom_in.texture as GradientTexture2D).fill_to = Vector2(0.5, 0.501)
	player.is_active = true
	NPC.millie.visual_root.modulate = Color(Color.WHITE * 0.2, 1.0)
	#NPC.board.modulate = Color(Color.WHITE * 0.75, 1.0)
	NPC.millie.show_outline = true
	
	await get_tree().create_timer(1.0).timeout
	player.animator.anim_tease_zoom_out()
	player.is_active = false


func set_monolog() -> void:
	var cond: bool = GameMgr.current_player.child_blocks.size() == GameLogic.number_of_blocks
	
	monolog_area_2.enabled = cond
	monolog_area_1.enabled = !cond


func _ready() -> void:
	setup()
	
	GameLogic.player_mashed.connect(set_monolog)
	GameLogic.player_unmashed.connect(set_monolog)
	
	## MONOLOG TRIGGERS
	monolog_1.monolog_started.connect(func():
		if monolog_1.monolog_has_happened:
			return
		
		var tween = create_tween().set_parallel(true)
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(
			sprite_black_out.texture as GradientTexture2D,
			"fill_from",
			Vector2(0.55, 0.65),
			1.0
		)
		tween.tween_property(
			sprite_black_out.texture as GradientTexture2D,
			"fill_to",
			Vector2(1.0, 0.42),
			1.0
			)
		)
	monolog_1.monolog_finished.connect(func():
		if monolog_1.monolog_has_happened:
			return
		var tween = create_tween()
		tween.tween_property(
			sprite_black_out.texture as GradientTexture2D,
			"fill_to",
			Vector2(1.0, -1.0),
			1.0
			).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		
		ground_1.enabled = false
		ground_2.enabled = true
		terrain.modulate = Color(Color.WHITE * 0.4, 1.0)
		await get_tree().create_timer(0.1).timeout
		for unmash: UnmashedSpawner in unmashed_blocks:
			unmash.spawn()
		)
	monolog_2.monolog_finished.connect(func():
		if monolog_2.monolog_has_happened:
			return
		level_goal.visible = true
		)
	##
	
	## CAMERA ZOOM
	GameMgr.monolog_activated.connect(func(active: bool):
		if tween_cam:
			tween_cam.kill()
			
		tween_cam = create_tween().set_parallel(true)
		tween_cam.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		
		if active:
			tween_cam.tween_property(cam, "position", Vector2(740.0, 424.0), 1.0)
			tween_cam.tween_property(cam, "zoom", Vector2.ONE * 1.1, 1.0)
			tween_cam.tween_property(cam, "zoom", Vector2.ONE * 1.1, 1.0)
		else:
			tween_cam.tween_property(cam, "position", Vector2(640.0, 400.0), 1.0)
			tween_cam.tween_property(cam, "zoom", Vector2.ONE, 1.0)
		)
	
	
