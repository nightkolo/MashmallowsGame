## @experimental: Under construction
extends Node
class_name PlayerAnimationComponent

var player: Player

func _ready() -> void:
	if get_parent() is Player:
		player = get_parent() as Player
	
	else:
		push_error(str(self) + " should be a child of Player.")
		return
	

	player.has_landed.connect(anim_land)
	player.has_jumpped.connect(anim_jump)
	player.has_mashed.connect(func(_pos: Vector2, _build: Util.BuildType):
		await get_tree().create_timer(0.1).timeout
		anim_eye_wobble()
		)
	player.has_idled.connect(anim_eye_wobble)
	player.has_moved.connect(pause_anim_eye_wobble)

func pause_anim_eye_wobble():
	for block: Mashed in player.child_blocks:
		if block.t_wobble:
			block.t_wobble.kill()
			if block.attributes.build_type == Util.BuildType.RECTANGLE:
				block.node_eye_sprites_2.position.y = Util.BLOCK_SIZE * 0.5
			else:
				block.node_eye_sprites_2.position.y = 0.0
			

var tween_jump: Tween

func anim_eye_wobble():
	if !player.is_active:
		return

	for block: Mashed in player.child_blocks:
		block.anim_eye_wobble(0.4, signf(randf()-0.5) * 3.0)

### Anim
var _tween_land: Tween
var _tween_down: Tween

# Movement
func anim_down(input: bool, ignore_state: bool = false) -> void:
	if !player.animate || (player.state_machine.current_state is AirState && !ignore_state): 
		return

	var mag: float = 0.4 if input else 0.0
	var dur: float = 1.0 if !input else 0.8

	if input:
		if player.audio.stretch.playing:
			player.audio.stretch.stop()
		player.audio.squash.play()
	else:
		if player.audio.squash.playing:
			player.audio.squash.stop()
		player.audio.stretch.play()

	if _tween_down:
		_tween_down.kill()
	
	_tween_down = get_tree().create_tween().set_parallel()
	_tween_down.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	for block: Mashed in player.child_blocks:
		var ori: float = block.sprite_original_pos.y

		if block.is_on_ground() || block.is_on_block():
			if block.attributes.build_type == Util.BuildType.RECTANGLE:
				mag = mag / 2.0
			_tween_down.tween_property(block.node_block_sprites,"scale",Vector2(1.0 + mag,1.0 - mag),dur)
		else:
			_tween_down.tween_property(block.node_block_sprites,"position:y",ori + (mag * 60.0),dur)



func anim_land(strength: float = 1.0) -> void:
	if !player.animate || player.input_y > 0.0:
		return
	
	var mag: float = minf(strength / 20.0, 0.5)
	var dur := 1.35
	
	if _tween_land:
		_tween_land.kill()
	
	_tween_land = get_tree().create_tween().set_parallel()
	_tween_land.set_ease(Tween.EASE_OUT)
	
	for block: Mashed in player.child_blocks:
		block.node_block_sprites.scale = Vector2.ONE

		var ori: float = block.sprite_original_pos.y
		
		block.node_block_sprites.position.y = ori
		
		if block.is_on_ground() || block.is_on_block():
			if block.build_type == Util.BuildType.RECTANGLE:
				mag = mag / 2.0
			_tween_land.tween_property(block.node_block_sprites,"scale",Vector2(1.0 + mag,1.0 - mag),0.07)
			_tween_land.tween_property(block.node_block_sprites,"scale",Vector2(1.0,1.0),dur).set_trans(Tween.TRANS_ELASTIC).set_delay(0.07)
		else:
			_tween_land.tween_property(block.node_block_sprites,"position:y",ori + (mag * 58.0),0.07)
			_tween_land.tween_property(block.node_block_sprites,"position:y",ori,dur).set_trans(Tween.TRANS_ELASTIC).set_delay(0.07)


func anim_jump() -> void:
	if !player.animate:
		return
	
	if tween_jump:
		tween_jump.kill()
		
	tween_jump = get_tree().create_tween().set_parallel()
	
	tween_jump.set_ease(Tween.EASE_OUT)
	
	for block: Mashed in player.child_blocks:
		if block.is_on_ground():
			tween_jump.tween_property(block.sprite_block, "scale", Vector2(0.875, 1.25) * 0.5, 0.1)
			tween_jump.tween_property(block.sprite_block, "scale", Vector2.ONE * 0.5, 0.6).set_trans(Tween.TRANS_SINE).set_delay(0.1)
		else:
			tween_jump.tween_property(block.sprite_block, "scale", Vector2.ONE*0.5, 1.0)




var tween_zoom: Tween
var tween_rotate: Tween

func anim_zoom_rotate() -> void:
	await get_tree().create_timer(0.1).timeout

	if tween_rotate:
		tween_rotate.kill()

	var node := player.node_player_zoom_trans
	tween_rotate = create_tween().set_loops()
	tween_rotate.tween_property(node, "rotation", TAU / 2.0, 10.0)
	tween_rotate.chain().tween_callback(func(): node.rotation = 0.0 )


func anim_zoom_rotate_stop() -> void:
	if tween_rotate:
		tween_rotate.kill()

	tween_rotate = create_tween()
	tween_rotate.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween_rotate.tween_property(player.node_player_zoom_trans, "rotation", PI/16.0, 0.1)


func anim_tease_zoom_out() -> void:
	player.node_player_zoom_trans.visible = true
	Audio.trans_03.play()

	anim_zoom_rotate()

	if tween_zoom:
		tween_zoom.kill()

	tween_zoom = create_tween().set_parallel(true)
	tween_zoom.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

	for node: Sprite2D in player.trans_nodes:
		tween_zoom.tween_property(node, "position", node.position.sign() * (640.0 + 100.0), 1.0)

	await tween_zoom.finished


func anim_zoom_out(spd: float = 1.0, reset: bool = false) -> void:
	player.node_player_zoom_trans.visible = true
	
	anim_zoom_rotate_stop()

	if reset:
		for node: Sprite2D in player.trans_nodes:
			node.position = node.position.sign() * 640.0

	Audio.trans_01.play()
	if tween_zoom:
		tween_zoom.kill()

	tween_zoom = create_tween().set_parallel(true)
	tween_zoom.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

	for node: Sprite2D in player.trans_nodes:
		tween_zoom.tween_property(node, "position", node.position.sign() * (640.0 + 1000.0), 1.0)

	await tween_zoom.finished
	player.node_player_zoom_trans.visible = false


func anim_zoom_in(spd: float = 1.0, reset: bool = false) -> void:
	player.node_player_zoom_trans.visible = true

	anim_zoom_rotate_stop()

	if reset:
		for node: Sprite2D in player.trans_nodes:
			node.position = node.position.sign() * (640.0 + 1000.0)

	Audio.trans_02.play()

	if tween_zoom:
		tween_zoom.kill()
		
	tween_zoom = create_tween().set_parallel(true)
	tween_zoom.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

	for node: Sprite2D in player.trans_nodes:
		tween_zoom.tween_property(node, "position", node.position.sign() * 640.0, 1.0)
	
	await tween_zoom.finished
	# player.node_player_zoom_trans.visible = false
