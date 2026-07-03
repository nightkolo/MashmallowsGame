class_name Mashed
extends CollisionShape2D

signal mashable_state_changed(can_mash: bool)
signal cherry_bomb_activated(at_pos: Vector2)
signal has_touched_flame(flamed: bool)
signal attribute_set()

## Shared variables with [Unmashed]
var attributes: BlockAttributes
@export var mash_type: Util.MashType
@export var build_type: Util.BuildType
@export var is_golden: bool = false:
	set(value):
		is_golden = value
		if attributes:
			attributes.is_golden = value
		if !is_node_ready():
			return
		if value:
			sprite_block.self_modulate = Color(Color.WHITE * 0.5,1.0)
		elif !value:
			sprite_block.self_modulate = Color(Color.WHITE)
		#$Golden/Colli.set_deferred("disabled", !value)
##
@export_category("Objects to assign")
@export var block_detect: BlockDetector
#@export var mash_block: MashBlock
@export var dust_particles: CPUParticles2D
@export var r_particles: CPUParticles2D
@export var l_particles: CPUParticles2D
@export var audio: MashedAudio
#@onready var unmashed_block_detect: Area2D = $UnmashedBlockDetect

## For Anim

@export var anim: AnimationPlayer
@export var node_block_sprites: Node2D # node_block_sprites
@export var node_eye_sprites_2: Node2D # node_eye_sprites
@export var node_eye_sprites: Node2D # node_eye_sprites
@export var sprite_shade: Sprite2D
@export var sprite_block: Sprite2D  # sprite_block
@export var sprite_highlight: Sprite2D
@export var sprite_eyes_open: Sprite2D #sprite_eyes_open
@export var sprite_eyes_regular: Node2D
@export var sprite_eyes_angry: Sprite2D
@export var sprite_eyes_wide: Sprite2D
@export var sprite_eyes_closed: Sprite2D # sprite_eyes_closed
# @export var idle_timer: Timer


var mark: PackedScene = preload("res://world/effects/particle_mark.tscn")
var trail: PackedScene = preload("res://world/effects/mashed_trail.tscn")
var mashed_object: PackedScene = preload("res://object/objects/block_mashed_1x1.tscn")
var mashed_object_1x2: PackedScene = preload("res://object/objects/block_mashed_1x2.tscn")

var cherry_bomb_strength: float
var twisted_strength: float
var sprite_original_pos: Vector2

var parent_player: Player
var is_idle_animating: bool
var is_original: bool
var current_trail: Trail
var unmashed_block_entered: bool:
	set(value):
		if value != unmashed_block_entered:
			mashable_state_changed.emit(value)
			unmashed_block_entered = value

var _original_pos: Vector2


func can_mash() -> bool:
	return block_detect.is_colliding()


func is_on_player() -> bool:
	var ray: ShapeCast2D = block_detect.blocks_ray
	
	ray.force_shapecast_update()
	
	if ray.is_colliding():
		var colli: Node2D = ray.get_collider(ray.get_collision_count() - 1)
		
		if colli is Player && colli != parent_player:
			return true
		
	return false


# Returns true if the mashed block on ground tilemap/sticky platform, not other unmashed blocks
func is_on_ground() -> bool: # -> O(1)
	var ray: ShapeCast2D = block_detect.ground_ray
	
	ray.force_shapecast_update()
	
	if ray.is_colliding():
		return true
		
	return false


## Returns true if the mashed block only on a sticky platform.
## [Param ignore_game_logic] ignores game logic. Normally, if it's a golden (roasted) marshmallow,
## it won't be stuck in the sticky platform.
## @deprecated
#func is_on_sticky_platform(ignore_game_logic: bool = false) -> bool: # -> O(1)
	#if is_golden && !ignore_game_logic:
		#return false # Golden marshmallows don't stick.
		#
	#var ray: ShapeCast2D = block_detect.ground_ray
	#
	#ray.force_shapecast_update()
	#
	#if ray.is_colliding():
		#if ray.get_collider(0) is StickyPlatform:
			#return true # Found sticky platform
		#
	#return false


func is_on_wall() -> bool: # -> O(1)
	var ray: ShapeCast2D = block_detect.wall_ray
	
	ray.force_shapecast_update()
	
	if ray.is_colliding():
		return true
		
	return false


# Returns true if the [Mashed] mash_block on a [Unmashed] (including [TwistedColliBlock] and [Player]).
func is_on_block() -> bool: # -> O(1)
	var ray: ShapeCast2D = block_detect.blocks_ray
	
	ray.force_shapecast_update()
	if ray.is_colliding():
		var colli: Node2D = ray.get_collider(ray.get_collision_count() - 1)
		
		if colli is Unmashed || colli is TwistedColliBlock:
			return true
		
	return false


func set_golden(value: bool = !is_golden) -> void:
	is_golden = value

	has_touched_flame.emit(value)
	parent_player.has_touched_flame.emit()


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
	_original_pos = position
	sprite_original_pos = node_block_sprites.position
	
	cherry_bomb_activated.connect(anim_explode)
	
	mashable_state_changed.connect(func(p_can_mash: bool):
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
		attributes.is_golden = is_golden
	else:
		mash_type = attributes.mash_type
		build_type = attributes.build_type
		is_golden = attributes.is_golden

	if mash_type != Util.MashType.MISC:
		anim_awake()
		
	node_eye_sprites_2.visible = mash_type != Util.MashType.MISC

	if get_parent() is Player:
		parent_player = get_parent()
		
		parent_player.state_machine.player_state_changed.connect(func(state: State):
			if parent_player.is_running_full() && state is RunState && is_on_ground():
				dust_particles.emitting = true
			elif state is AirState:
				dust_particles.emitting = false
			)
		if dust_particles && l_particles && r_particles:
			parent_player.is_running.connect(func():
				dust_particles.emitting = is_on_ground()
			)
			parent_player.has_stopped.connect(func():
				dust_particles.emitting = false
			)
			parent_player.has_landed.connect(func(strength: float):
				var hit_ground := is_on_ground() && strength > 12.0
				l_particles.emitting = hit_ground
				r_particles.emitting = hit_ground
				if is_on_ground():
					anim_blink(true)
				)

		node_block_sprites.visible = parent_player.show_blocks
		
		if parent_player.auto_assign_child_blocks:
			parent_player.push_block(self)
		
		parent_player.new_child_blocks.append(self)

		if mark && mash_type != Util.MashType.MISC:
			var m := mark.instantiate()
			m.global_position = global_position + (Vector2.RIGHT * Util.BLOCK_SIZE * 0.5)
			if GameMgr.current_level:
				GameMgr.current_level.add_child(m)

		## TRAIL
		if parent_player.show_trail:
			parent_player.has_jumpped.connect(func():
				if current_trail == null && is_on_ground():
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
	
	attribute_set.emit()

	GameLogic.setup_mash(sprite_block, attributes.mash_type, attributes.build_type, attributes.is_golden)
	# if sprite_shade:
	# 	sprite_shade.texture = Util.get_mash_type_shade_texture(mash_type, build_type)
	if sprite_eyes_regular && sprite_eyes_wide && sprite_eyes_angry:
		sprite_eyes_angry.visible = false
		sprite_eyes_regular.visible = false
		sprite_eyes_wide.visible = false
		match mash_type:
			Util.MashType.AIR_CHERRY_BOMB, Util.MashType.CHERRY_BOMB:
				sprite_eyes_angry.visible = true
			Util.MashType.CHOCO:
				sprite_eyes_wide.visible = true
			_:
				sprite_eyes_regular.visible = true
	#

	#mash_block.mash_type = mash_type

	# await get_tree().create_timer(Util.MASH_WAIT_TIME).timeout
	
	anim_blinking()

	for ray: RayCast2D in block_detect.unmashed_block_detection_rays:
		ray.enabled = true
	
	for ray: RayCast2D in block_detect.cherry_bomb_rays:
		ray.enabled = true
		

func mash() -> bool: ## Ok O(1)
	var collided: bool = false
	
	if mash_type == Util.MashType.CHERRY_BOMB:
		return false
	
	var dubbles: Array = block_detect.dubbleganger_detect_1x1.get_overlapping_bodies()
	
	
	for p: Player in dubbles:
		if p != parent_player:
			print_debug("NO MATCH: %s != %s" % [p, parent_player])
			
			var active: bool = p.is_active
			
			
			#func move_up(strength: float = 10.0) -> void:
				#var top: Unmashed = get_top_unmashed()
				#if top:
					#top.move_up(2.0 * strength)
					#await get_tree().create_timer(0.05).timeout
			 	#
				#position.y -= strength
			
			if !active || p.dubbleganger:
				print_debug("Dubble: %s" % p.global_position)
				print_debug("Self: %s" % global_position)
				
				if p.global_position.y > global_position.y + (0.5 * Util.BLOCK_SIZE):
					parent_player.hang()
				
				print_debug("EXCHANGED: %s" % p)
				p.set_active(!active)
				parent_player.set_active(active)
				
			return true
		else:
			print_debug("MATCH: %s == %s" % [p, parent_player])
	
	for ray: RayCast2D in block_detect.unmashed_block_detection_rays:
		ray.force_raycast_update()
		
		if !ray.is_colliding():
			continue

		var obj: Object = ray.get_collider()
		var unmashed: Unmashed
		#var player: Player
			
		if obj is TwistedColliBlock:
			unmashed = (obj as TwistedColliBlock).parent_unmashed
		elif obj is Unmashed:
			unmashed = obj as Unmashed
		else:
			continue

		if !unmashed.is_mashable():
			continue

		var top: Unmashed = unmashed.get_top_unmashed()
		
		if top:
			top.move_up(5.0)
		
		collided = true
		
		#print_debug(unmashed.mash_type == Util.MashType.PLAYER)
		
		#var pos: Vector2 = unmashed.global_position - global_position
		var build: Util.BuildType = unmashed.build_type
		var unmash_at: Vector2 = get_unmashed_position(
			unmashed.global_position - global_position,
			build,
			unmashed.mash_type
			)
		var new_mashed: Mashed = get_mashed_object(build)
		

		# ATTRIBUTE SYNC
		new_mashed.position = get_new_mashed_positioning(unmash_at, build, ray)
		new_mashed.attributes = unmashed.attributes.duplicate(true)
		new_mashed.cherry_bomb_strength = unmashed.cherry_bomb_strength
		new_mashed.twisted_strength = unmashed.twisted_strength
		#
		
		parent_player.has_mashed.emit(unmash_at, build)
		unmashed.queue_free()
		
		parent_player.add_child(new_mashed)
		
		await parent_player.return_position()
			
		break
		
	return collided


func get_unmashed_position(found_at: Vector2, type: Util.BuildType, p_mash: Util.MashType) -> Vector2:
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
				
# TODO: Move to GameLogic
func get_mashed_object(type: Util.BuildType) -> Mashed: 
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
		
	_tween_light = get_tree().create_tween()
	if p_mash:
		_tween_light.tween_property(sprite_highlight, "scale", Vector2.ONE*0.52, 0.1)
	else:
		_tween_light.tween_property(sprite_highlight, "scale", Vector2.ONE*0.25, 0.1)
		await _tween_light.finished
		
		
##### TODO Animation commit
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
#####


func is_attached() -> bool:
	return get_parent() is Player
