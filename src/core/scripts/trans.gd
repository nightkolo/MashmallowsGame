extends CanvasLayer

@onready var anim: AnimationPlayer = $Anim

## omg! I'm so proud bestie!!
var is_transitioning: bool


func player_zoom_to_scene(scene: String, waittime: float = 0.0, spd: float = 1.0) -> void:
	if is_transitioning:
		return 
	
	is_transitioning = true
	# ($Trans1 as Node2D).visible = true
	
	# anim.play(&"slide_in", -1, spd)
	Audio.lower_higher_music(0.4 * (2.0 - spd))
	
	await GameMgr.current_player.animator.anim_zoom_in(spd, true)

	# await anim.animation_finished
	
	await get_tree().create_timer(waittime).timeout
	
	
	get_tree().change_scene_to_file(scene)
	
	GameLogic.reset_game_logic()
	# anim.play(&"slide_out", -1, spd)
	
	# await GameMgr.current_player.animator.anim_zoom_out(spd, true)
	# await anim.animation_finished
	
	# ($Trans1 as Node2D).visible = false
	is_transitioning = false


func instant_to_scene(scene: String, waittime: float = 0.0, spd: float = 2.4) -> void:
	if is_transitioning:
		return 
	
	is_transitioning = true
	($Trans3 as Node2D).visible = true
	
	# await get_tree().create_timer(0.1).timeout
	# anim.play(&"slide_in", -1, spd)
	# Audio.lower_higher_music(0.4)
	
	# await anim.animation_finished
	
	# await get_tree().create_timer(waittime).timeout
	
	GameLogic.reset_game_logic()
	
	get_tree().change_scene_to_file(scene)
	
	# anim.play(&"slide_out", -1, spd)
	
	# await anim.animation_finished
	
	($Trans3 as Node2D).visible = false
	is_transitioning = false


func slide_to_scene(scene: String, waittime: float = 0.0, spd: float = 2.4) -> void:
	if is_transitioning:
		return 
	
	is_transitioning = true
	($Trans1 as Node2D).visible = true
	
	anim.play(&"slide_in", -1, spd)
	Audio.lower_higher_music(0.4)
	
	await anim.animation_finished
	
	await get_tree().create_timer(waittime).timeout
	
	GameLogic.reset_game_logic()
	
	get_tree().change_scene_to_file(scene)
	
	anim.play(&"slide_out", -1, spd)
	
	await anim.animation_finished
	
	($Trans1 as Node2D).visible = false
	is_transitioning = false



func slide_to_next_stage(scene: String) -> void:
	if is_transitioning:
		return 
	
	is_transitioning = true
	($Trans1 as Node2D).visible = true
	
	anim.play(&"slide_in", -1, 2.4)
	Audio.lower_higher_music(0.3)
	
	await anim.animation_finished
	
	GameLogic.reset_game_logic()
	
	get_tree().change_scene_to_file(scene)
	
	anim.play(&"slide_out", -1, 2.4)
	
	await anim.animation_finished
	
	($Trans1 as Node2D).visible = false
	is_transitioning = false


func reset_level() -> void:
	if is_transitioning:
		return 
	
	is_transitioning = true
	($Trans2 as Node2D).visible = true
	
	anim.play(&"fade_in", -1, 8.0)
	Audio.lower_higher_music(0.3)
	Audio.play_reset_sound()
	
	await anim.animation_finished
	
	GameMgr.reset_game()
	
	anim.play(&"fade_out", -1, 8.0)
	
	await anim.animation_finished
	
	($Trans2 as Node2D).visible = false
	is_transitioning = false
