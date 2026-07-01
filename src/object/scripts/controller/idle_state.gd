## Under construction
extends State
class_name IdleState

# Actions available
	#Jump
	#Mash
	#Unmash


func enter(msg := {}) -> void:
	if player.audio.is_node_ready():
		player.has_idled.emit()
		
		if player.audio.slide_sfx.playing:
			player.audio.slide_sfx.stop()
			
		if player.audio.fall_sfx.playing:
			player.audio.fall_sfx.stop()
	

func physics_update(delta: float) -> void:
	if player == null:
		return
	
	## Jump logic and platform fall is handled globally in player code

	# Start running
	if player.input_x != 0.0:
		state_machine.change_state("RunState")
		return

	# Apply ground friction
	player.velocity.x = move_toward(
		player.velocity.x,
		0.0,
		player.deceleration * delta
	)

	
