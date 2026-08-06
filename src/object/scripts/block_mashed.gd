class_name Mashed
extends CollisionShape2D

signal mashable_state_changed(can_mash: bool)
signal cherry_bomb_activated(at_pos: Vector2)
signal attribute_set()

@export var mash_type: Util.MashType
@export var build_type: Util.BuildType

@export_category("Objects to assign")
@export var block_detect: BlockDetector
@export var dust_particles: CPUParticles2D
@export var r_particles: CPUParticles2D
@export var l_particles: CPUParticles2D
@export var audio: MashedAudio

@export_category("Animation")
# For Anim
@export var anim: AnimationPlayer
@export_group("Nodes")
@export var node_block_sprites: Node2D # node_block_sprites
@export var node_eye_sprites_2: Node2D # node_eye_sprites
@export var node_eye_sprites: Node2D # node_eye_sprites
@export_group("Sprites")
@export var sprite_block: Sprite2D  # sprite_block
@export var sprite_highlight: Sprite2D
@export_group("Eyes")
@export var sprite_eyes_open: Sprite2D #sprite_eyes_open
@export var node_eyes_regular: Node2D
@export var sprite_eyes_regular: Sprite2D
@export var sprite_eyes_angry: Sprite2D
@export var sprite_eyes_wide: Sprite2D
@export var sprite_eyes_closed: Sprite2D # sprite_eyes_closed
@export var sprite_eyes_stressed: Sprite2D # sprite_eyes_closed
#

# Objects
var particle_mark: PackedScene = preload("res://world/effects/particle_mark.tscn")
var trail: PackedScene = preload("res://world/effects/mashed_trail.tscn")
var mashed_object: PackedScene = preload("res://object/objects/block_mashed_1x1.tscn")
var mashed_object_1x2: PackedScene = preload("res://object/objects/block_mashed_1x2.tscn")

# Animation
var sprite_original_pos: Vector2

# Attributes
var attributes: BlockAttributes
var is_idle_animating: bool
var is_original: bool ## @experimental
var parent_player: Player
var current_trail: Trail
var unmashed_block_entered: bool:
	set(value):
		if value != unmashed_block_entered:
			mashable_state_changed.emit(value)
			unmashed_block_entered = value


func is_on_player() -> bool: # -> O(1)
	var ray: ShapeCast2D = block_detect.blocks_ray
	
	ray.force_shapecast_update()
	
	if ray.is_colliding():
		var colli: Node2D = ray.get_collider(ray.get_collision_count() - 1)
		
		if colli is Player && colli != parent_player:
			return true
		
	return false


## Returns true if the mashed block on ground tilemap, not other unmashed blocks
func is_on_ground() -> bool: # -> O(1)
	var ray: ShapeCast2D = block_detect.ground_ray
	
	ray.force_shapecast_update()
	
	if ray.is_colliding():
		return true
		
	return false


# Returns true if the [Mashed] mash_block on a [Unmashed].
func is_on_block() -> bool: # -> O(1)
	var ray: ShapeCast2D = block_detect.blocks_ray
	
	ray.force_shapecast_update()
	if ray.is_colliding():
		var colli: Node2D = ray.get_collider(ray.get_collision_count() - 1)
		
		if colli is Unmashed:
			return true
		
	return false


func set_asleep(player: Player, role_swapped: bool = false) -> void:
	if !role_swapped:
		sprite_eyes_closed.visible = player.start_asleep
		sprite_eyes_open.visible = !player.start_asleep
		anim_highlight(true)

		player.has_waken_up.connect(func():
			sprite_eyes_closed.visible = false
			sprite_eyes_open.visible = true
			anim_highlight(false)
		)
	else:
		sprite_eyes_closed.visible = !player.is_active
		sprite_eyes_open.visible = player.is_active


func _ready() -> void:
	sprite_original_pos = node_block_sprites.position
	
	cherry_bomb_activated.connect(anim_explode)
	mashable_state_changed.connect(func(p_can_mash: bool):
		if parent_player.audio == null:
			return
		
		if p_can_mash:
			parent_player.audio.sfx_unmash_enter.play()
		else:
			parent_player.audio.sfx_unmash_exit.play()
		)
	
	# Shared with [Unmashed]
	if attributes == null:
		attributes = BlockAttributes.new()

		attributes.mash_type = mash_type
		attributes.build_type = build_type
	else:
		mash_type = attributes.mash_type
		build_type = attributes.build_type

	attribute_set.emit()
	
	if mash_type != Util.MashType.MISC:
		anim_awake()
		
	node_eye_sprites_2.visible = mash_type != Util.MashType.MISC

	if get_parent() is Player:
		parent_player = get_parent()
		
		_ready_parent_dependencies()
	
	
	# Exclamation mark animation
	if mash_type != Util.MashType.MISC && particle_mark:
		var m := particle_mark.instantiate()
		m.global_position = global_position + (Vector2.RIGHT * Util.BLOCK_SIZE * 0.5)
		if GameMgr.current_level:
			GameMgr.current_level.add_child(m)

	GameLogic.setup_mash(sprite_block, attributes.mash_type, attributes.build_type)
	
	# Eyes
	if node_eyes_regular && sprite_eyes_wide && sprite_eyes_angry:
		sprite_eyes_angry.visible = false
		node_eyes_regular.visible = false
		sprite_eyes_wide.visible = false
		match mash_type:
			Util.MashType.AIR_CHERRY_BOMB, Util.MashType.CHERRY_BOMB:
				sprite_eyes_angry.visible = true
			Util.MashType.MISC:
				pass
			_:
				var is_choco := mash_type == Util.MashType.CHOCO
				
				sprite_eyes_open.visible = !is_choco
				sprite_eyes_wide.visible = is_choco
				node_eyes_regular.visible = true
				
				# Ledge animation
				if mash_type != Util.MashType.PLAYER && parent_player:
					anim_stressed()
					
					parent_player.has_landed.connect(_show_regular_eyes)
					block_detect.ground_detect.body_entered.connect(_show_regular_eyes)
					
					block_detect.ground_detect.body_exited.connect(func(_body: Node2D):
						if !parent_player.is_mashing && parent_player.is_on_floor() && block_detect.ground_detect.get_overlapping_bodies().is_empty():
							node_eyes_regular.visible = false
							sprite_eyes_stressed.visible = true
						else:
							_show_regular_eyes()
						)

	anim_blinking()

	for ray: RayCast2D in block_detect.unmashed_block_detection_rays:
		ray.enabled = true
	
	for ray: RayCast2D in block_detect.cherry_bomb_rays:
		ray.enabled = true


func _show_regular_eyes(_temp = null) -> void:
	node_eyes_regular.visible = true
	sprite_eyes_stressed.visible = false


func _ready_parent_dependencies() -> void:
	# Dust animation
	if dust_particles:
		parent_player.state_machine.player_state_changed.connect(func(state: State):
			if parent_player.is_running_full() && state is RunState && is_on_ground():
				dust_particles.emitting = true
			elif state is AirState:
				dust_particles.emitting = false
			)
		parent_player.is_running.connect(func():
			dust_particles.emitting = is_on_ground()
		)
		parent_player.has_stopped.connect(func():
			dust_particles.emitting = false
		)
		
	if l_particles && r_particles:
		parent_player.has_landed.connect(func(strength: float):
			var hit_ground := (is_on_ground() || is_on_block()) && strength > 12.0
			l_particles.emitting = hit_ground
			r_particles.emitting = hit_ground
			if is_on_ground(): anim_blink(true) 
		)
	#
	
	node_block_sprites.visible = parent_player.show_blocks
	
	if parent_player.auto_assign_child_blocks:
		parent_player.push_block(self)
	
	parent_player.new_child_blocks.append(self)

	# Trail
	if parent_player.show_trail:
		parent_player.has_jumpped.connect(func():
			if current_trail == null && (is_on_ground() || is_on_block()):
				current_trail = trail.instantiate()
				current_trail.exit_on_empty = true
				current_trail.target = self
				GameMgr.current_level.add_child(current_trail)
			)
		parent_player.has_landed.connect(func(_strength: float):
			if current_trail:
				current_trail.trail_enabled = false
				current_trail = null
			)
			
			
func mash() -> bool: 
	if mash_type == Util.MashType.CHERRY_BOMB || mash_type == Util.MashType.AIR_CHERRY_BOMB:
		return false

	# Mash to a block
	# Ok -> O(1)
	# block_detect.unmashed_block_detection_rays.size() fixed to 3 or 5
	var collided: bool = false
	
	for ray: RayCast2D in block_detect.unmashed_block_detection_rays:
		ray.force_raycast_update()
		
		if !ray.is_colliding():
			continue

		var obj: Object = ray.get_collider()
			
		if obj is Unmashed:
			var unmashed: Unmashed = obj as Unmashed

			if !unmashed.is_mashable():
				continue
			
			collided = true

			var block_on_top: Unmashed = unmashed.get_top_unmashed()
			var spawner: UnmashedSpawner = unmashed.unmashed_spawner as UnmashedSpawner
			
			if block_on_top:
				block_on_top.move_up(5.0)
			
			if spawner:
				spawner.has_been_taken = true
			
			var build: Util.BuildType = unmashed.build_type
			var unmash_at: Vector2 = _get_unmashed_position(
				unmashed.global_position - global_position,
				build,
				unmashed.mash_type
				)
			var new_mashed: Mashed = _get_mashed_object(build)
			
			# ATTRIBUTE SYNC
			new_mashed.position = get_new_mashed_positioning(unmash_at, build, ray)
			new_mashed.attributes = unmashed.attributes.duplicate(true)
			#
			
			parent_player.has_mashed.emit(unmash_at, build)
			unmashed.queue_free()
			
			parent_player.add_child(new_mashed)
			
			await parent_player.return_position()
			break
		
	return collided


func _get_unmashed_position(found_at: Vector2, type: Util.BuildType, p_mash: Util.MashType) -> Vector2:
	var unmash_at: Vector2
	
	match type:
		
		Util.BuildType.RECTANGLE:
			if absf(found_at.y) > absf(found_at.x):
				unmash_at = Vector2(0.0, signf(found_at.y))
			else:
				unmash_at = Vector2(signf(found_at.x) ,minf(0.0, signf(found_at.y)))
		
		Util.BuildType.SQUARE:
			if p_mash == Util.MashType.TWISTED:
				if absf(found_at.x) < Util.BLOCK_SIZE * 0.5:
					unmash_at = Vector2(0.0, signf(found_at.y))
				else:
					unmash_at = Vector2(signf(found_at.x), 0.0)
			else:
				if absf(found_at.x) > absf(found_at.y):
					unmash_at = Vector2(signf(found_at.x), 0.0)
				else:
					unmash_at = Vector2(0.0, signf(found_at.y))
		
	return unmash_at


func get_new_mashed_positioning(found_at: Vector2, type: Util.BuildType, ray: RayCast2D = null) -> Vector2:
	var repos: Vector2
	
	match type:
		Util.BuildType.SQUARE:
			repos = position + (found_at * Util.BLOCK_SIZE)
			
			if build_type == Util.BuildType.RECTANGLE:
				repos += Vector2.DOWN * Util.BLOCK_SIZE * 0.5
				
				if ray != null:
					if ray.position.y < 0:
						repos += (Vector2.UP * Util.BLOCK_SIZE)
				
		Util.BuildType.RECTANGLE:
			repos = position + (found_at * Util.BLOCK_SIZE) + (Vector2.DOWN * Util.BLOCK_SIZE * 0.5)
	
	return repos
				
# Suggestion: Move to GameLogic
func _get_mashed_object(type: Util.BuildType) -> Mashed: 
	if mashed_object == null:
		mashed_object = preload("res://object/objects/block_mashed_1x1.tscn")
	if mashed_object_1x2 == null:
		mashed_object_1x2 = preload("res://object/objects/block_mashed_1x2.tscn")
	
	match type:
		Util.BuildType.SQUARE:
			return mashed_object.instantiate()
		Util.BuildType.RECTANGLE:
			return mashed_object_1x2.instantiate()
		_:
			return null

## Anim
var t_wobble: Tween

func anim_eye_wobble(dur: float = 1.0, mag: float = 10.0) -> void:
	if t_wobble:
		t_wobble.kill()

	# var mag := 10.0
	var extra := Util.BLOCK_SIZE * 0.5 if attributes.build_type == Util.BuildType.RECTANGLE else 0.0

	node_eye_sprites_2.position.y = (mag * 0.5) + extra

	t_wobble = create_tween().set_loops()
	t_wobble.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

	t_wobble.tween_property(node_eye_sprites_2, "position:y", -mag + extra, dur)
	t_wobble.tween_property(node_eye_sprites_2, "position:y", mag + extra, dur)


func anim_stressed():
	var t := create_tween().set_loops()
	t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	t.tween_property(sprite_eyes_stressed, "position:x", -4.0, 0.25)
	t.tween_property(sprite_eyes_stressed, "position:x", 4.0, 0.25)


func anim_blinking():
	# Interrupt idle animation on move
	parent_player.state_machine.player_state_changed.connect(func(state: State):
		if !(state is IdleState) && anim.is_playing() && anim.current_animation == "idle":
			anim.play("RESET")
			# idle_timer.stop()
	)

	while true:
		await get_tree().create_timer(randf_range(2.0, 5.0)).timeout
		anim_blink()


func anim_blink(landed: bool = false):
	if anim.is_playing() && is_idle_animating:
		return
	if parent_player.state_machine.current_state is RunState && !landed:
		return
	anim.play("blink")

func anim_awake() -> void:
	var rand := signf(randf()-0.5)
	var mag := Util.BLOCK_SIZE * 0.5 * rand
	node_eye_sprites.position.y += mag * 0.1 * rand
	if build_type == Util.BuildType.RECTANGLE:
		node_eye_sprites.position.y -= 30.0

	var t := create_tween()
	t.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(node_eye_sprites, "position:y", mag, 0.05).as_relative()
	t.tween_property(node_eye_sprites, "position:y", -mag, 0.05).as_relative()
	t.tween_property(node_eye_sprites, "position:y", mag*0.5, 0.05).as_relative()
	t.tween_property(node_eye_sprites, "position:y", -mag*0.5, 0.05).as_relative()
	t.tween_property(node_eye_sprites, "position:y", mag*0.25, 0.05).as_relative()
	t.tween_property(node_eye_sprites, "position:y", -mag*0.25, 0.05).as_relative()
	t.tween_property(node_eye_sprites, "position:y", 0.0, 0.15)


var _tween_light: Tween

func anim_highlight(p_mash: bool) -> void:
	if parent_player:
		if !parent_player.can_perform_mash():
			p_mash = false
		
		if p_mash:
			parent_player.audio.listener.make_current()
		else:
			parent_player.audio.listener.clear_current()
	
	unmashed_block_entered = p_mash
	
	if _tween_light:
		_tween_light.kill()
		
	_tween_light = create_tween()
	if p_mash:
		_tween_light.tween_property(sprite_highlight, "scale", Vector2.ONE*0.52, 0.1)
	else:
		_tween_light.tween_property(sprite_highlight, "scale", Vector2.ONE*0.25, 0.1)
		await _tween_light.finished
		
		
var explosion_fx: PackedScene = preload("res://world/effects/cherry_bomb_exposion_effect.tscn")

func anim_explode(at_pos: Vector2) -> void:
	var ex: ExplosionFX = explosion_fx.instantiate()
	
	if at_pos == Vector2.RIGHT:
		ex.rotation = PI * 0.5
	elif at_pos == Vector2.LEFT:
		ex.rotation = -PI * 0.5
	
	if mash_type == Util.MashType.CHERRY_BOMB:
		# Anim start
		var tween := create_tween()
		tween.tween_property(sprite_block, "scale", Vector2.ONE * 0.125, Util.CHERRY_BOMB_WAITTIME_BEFORE_EXPLODING)
		
		await get_tree().create_timer(Util.CHERRY_BOMB_WAITTIME_BEFORE_EXPLODING).timeout
	
	ex.position = global_position + (-at_pos * Util.BLOCK_SIZE * 0.5)
	ex.pos_at = at_pos
	
	GameMgr.current_level.add_child(ex)


#func is_attached() -> bool: ## What a stupid method.
	#return get_parent() is Player
