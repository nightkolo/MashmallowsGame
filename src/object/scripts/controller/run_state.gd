extends State
class_name RunState

# Actions available
	#Jump
	#Mash
	#Unmash
func enter(msg := {}):
	
	if player:
		player.has_moved.emit()
		player.audio.slide_sfx.play(randf())
		player.audio.slide_sfx.finished.connect(func():
			player.audio.slide_sfx.play()
			)
			
		if player.audio.fall_sfx.playing:
			player.audio.fall_sfx.stop()



func physics_update(delta: float) -> void:
	if player == null:
		return
	
	## Jump logic and platform fall is handled globally in player code
	
	## SLIDE AUDIO
	player.audio.slide_sfx.volume_db = minf(5.0, (absf(player.velocity.x) / (player.speed / 40.0)) - 30.0)
	# print(minf(2.0, (absf(player.velocity.x) / (player.speed / 40.0)) - 30.0))
	var dir := player.input_direction

	if dir == 0.0:
		state_machine.change_state("IdleState")
		return

	# Stop friction
	if dir < 0.0 and player.velocity.x > 0.0:
		player.velocity.x = move_toward(
			player.velocity.x,
			0.0,
			player.stop_deceleration * delta
			)

	elif dir > 0.0 and player.velocity.x < 0.0:
		player.velocity.x = move_toward(
			player.velocity.x,
			0.0,
			player.stop_deceleration * delta
			)

	# Normal acceleration
	else:
		player.velocity.x = move_toward(
			player.velocity.x,
			dir * player.speed,
			player.acceleration * delta
		)
