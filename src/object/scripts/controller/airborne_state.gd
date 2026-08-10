## Under construction
extends State
class_name AirState




func enter(msg := {}):
	
	if player.is_node_ready():
		
		if player.audio.slide_sfx.playing:
			player.audio.slide_sfx.stop()
			
		
		#if msg.get("falling", false):
			#player.audio.fall_sfx.play()
		


func physics_update(delta: float) -> void:
	if player == null:
		return
	
	if player.velocity_position_based.y > 660.0:
		if !player.audio.fall_sfx.playing:
			player.audio.fall_sfx.play()
		else:
			player.audio.fall_sfx.volume_db = minf(0.0, -20.0 + (player.velocity.y / 25.0)) if player.screen_notifier.is_on_screen() else -100.00
	## Gravity logic is global
	#player.velocity += player.get_gravity() * delta
	
	# Variable jump height
	if Input.is_action_just_released("move_jump") and player.velocity.y < 0.0:
		player.stop_jump_sfx()
		
		player.velocity.y = player.velocity.y / 4.0
	
	var dir := player.input_x
	
	if player.is_on_floor():
		if player.is_being_flown():
			player.cherry_bomb_air_timer.stop()

		if dir != 0.0:
			state_machine.change_state("RunState")
		else:
			state_machine.change_state("IdleState")

		return
	
	if dir != 0.0:
		player.velocity.x = move_toward(
			player.velocity.x,
			dir * player.speed,
			player.air_deceleration * delta
		)
	else:
		if player.is_being_flown():
			player.velocity.x = move_toward(
				player.velocity.x,
				0.0,
				player.flown_deceleration * delta
			)
