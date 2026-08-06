@tool
class_name Unmashed
extends CharacterBody2D

signal has_landed(strength: float)
signal started_breathing()
signal expanding_started() ## Emits when Twisted expands.
signal expanding_entered() ## Emits when Twisted is about to expand.
signal expanding_stopped() ## Emits when Twisted expansion stops. (i.e. ceiling collision)
signal player_entered(entered: bool)

@export var tutorial_block: bool = false
@export var mash_type: Util.MashType:
	set(value):
		if is_node_ready():
			sprite_block.texture = Util.get_mash_type_texture(value, build_type)
		if attributes:
			attributes.mash_type = value
		mash_type = value
@export var build_type: Util.BuildType:
	set(value):
		if is_node_ready():
			sprite_block.texture = Util.get_mash_type_texture(mash_type, value)
		if attributes:
			attributes.build_type = value
		build_type = value

@export_group("Area casts")
@export var player_down_detect: ShapeCast2D
@export var top_detect: ShapeCast2D
@export var ground_detect: ShapeCast2D
@export_group("Audio")
@export var audio: UnmashedAudio
@export_group("Nodes")
@export var slippery_colli: CollisionPolygon2D 
@export var colli: CollisionShape2D 
@export var particles_spawn: CPUParticles2D 
@export var particles_z: CPUParticles2D 
@export_group("Sprites")
@export var node_mash_prompt: Node2D 
@export var sprite_block: Sprite2D
@export var sprite_eyes: Sprite2D
@export var sprite_eyes_alert: Sprite2D
@export var sprite_eyes_one: Sprite2D
@export var twisted_mask: Sprite2D
@export var sprite_mashable: Sprite2D
@export var sprite_highlight: Sprite2D
@export var sprite_input: Sprite2D
@export var sprite_node: Node2D 
@export var eyes_node: Node2D 

var attributes: BlockAttributes
var unmashed_spawner: Node
var was_mashed: bool = false
var is_player_close: bool = false:
	set(value):
		player_entered.emit(value)
		is_player_close = value
var is_at_expand_period: bool = false
var is_expanding: bool = false

var _tween_land: Tween

func _ready() -> void:
	set_physics_process(true)
	process_mode = Node.PROCESS_MODE_INHERIT
	
	if was_mashed:
		anim_unmashed()
	
	if !was_mashed:
		GameLogic.number_of_blocks += 1
	
	# Shared with [Mashed]
	if attributes == null:
		attributes = BlockAttributes.new()

		attributes.mash_type = mash_type
		attributes.build_type = build_type
	else:
		mash_type = attributes.mash_type
		build_type = attributes.build_type
	#
	
	if slippery_colli && colli:
		slippery_colli.set_deferred("disabled", !attributes.slippery_block)
		colli.set_deferred("disabled", attributes.slippery_block)
	
	if mash_type == Util.MashType.TWISTED:
		sprite_block.visible = false
		sprite_highlight.visible = false
		twisted_mask.visible = true
		
		if colli:
			colli.shape = colli.shape.duplicate() as RectangleShape2D
			
			print_debug(twisted_mask.position)
			
			if twisted_mask:
				twisted_mask.texture = twisted_mask.texture.duplicate() as GradientTexture2D
	
	if mash_type == Util.MashType.MISC:
		sprite_node.scale = Vector2.ONE
	else:
		particles_z.emitting = true
		if audio:
			audio.play_spawn_sound()
		
		anim_sleep()
			
	eyes_node.visible = mash_type != Util.MashType.MISC

	GameLogic.setup_mash(sprite_block, attributes.mash_type, attributes.build_type)
	
	# Animation
	has_landed.connect(func(strength: float):
		var mag: float = minf(strength * 0.04, 0.5)
		var dur := 1.35
		
		sprite_highlight.visible = false
		
		if _tween_land:
			_tween_land.kill()
			
		_tween_land = create_tween().set_parallel(true)
		
		_tween_land.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		_tween_land.tween_property(sprite_block,"scale",0.5*Vector2(1.0 + mag,1.0 - mag),0.07)
		_tween_land.tween_property(sprite_block,"scale",0.5*Vector2(1.0,1.0),dur).set_delay(0.07)
		await _tween_land.finished
		
		sprite_highlight.visible = true
		)
	
	_ready_twisted_and_collision()
	
	if was_mashed:
		await anim_unmashed_finished
	
	if GameMgr.current_level:
		sprite_node.visible = GameMgr.current_level.show_unmashed_blocks


func _ready_twisted_and_collision() -> void:
	collision_layer = 8
	collision_mask = 1 + 2 + 8 + 2048
	
	if mash_type == Util.MashType.TWISTED:
		anim_expanding(!was_mashed)


func is_mashable() -> bool: ## @experimental
	return true 


var tween_expand: Tween

func start_stop_expansion() -> void:
	GameMgr.current_player.has_touched_ceiling.connect(_on_ceiling_touched)


func cancel_stop_expansion() -> void:
	var p: Player = GameMgr.current_player
	
	if p.has_touched_ceiling.is_connected(_on_ceiling_touched):
		p.has_touched_ceiling.disconnect(_on_ceiling_touched)


func _on_ceiling_touched() -> void:
	var p: Player = GameMgr.current_player
	
	if p == null:
		return
	
	if p.is_on_block():
		stop_expanding()


func stop_expanding(pushback: float = 20.0) -> void:
	if tween_expand && is_at_expand_period:
		tween_expand.kill()
		
		expanding_stopped.emit()
		
		(twisted_mask.texture as GradientTexture2D).height -= int(pushback)
		(colli.shape as RectangleShape2D).size.y -= pushback
		
		is_at_expand_period = false
		is_expanding = false

const EXPAND_TIME = 0.6
const WAIT_TIME_BEFORE_EXPAND = 0.75


func anim_expanding(instant: bool = false) -> void:
	if colli == null || twisted_mask == null:
		return
	
	var pos_to: float = attributes.twisted_strength * Util.BLOCK_SIZE
	var s1 := pos_to * 0.5
	var s2 := pos_to * 0.395
	
	if instant:
		(colli.shape as RectangleShape2D).size.y = pos_to
		(twisted_mask.texture as GradientTexture2D).height = int(pos_to)
		top_detect.position.y = -s1
		
		player_down_detect.position.y = s1
		position.y -= s2
		
		twisted_mask.position.y = s2
		eyes_node.position.y = s2
		
		return
	
	expanding_entered.emit()
	
	is_at_expand_period = true
	
	if tween_expand:
		tween_expand.kill()
	
	tween_expand = create_tween().set_parallel(true)
	
	tween_expand.tween_callback(func():
		is_expanding = true
		start_stop_expansion()
		expanding_started.emit()
		).set_delay(WAIT_TIME_BEFORE_EXPAND)
	tween_expand.chain().tween_property(colli.shape as RectangleShape2D,"size:y",pos_to,EXPAND_TIME)
	tween_expand.tween_property(twisted_mask.texture as GradientTexture2D,"height",pos_to,EXPAND_TIME)
	tween_expand.tween_property(top_detect,"position:y",-s1,EXPAND_TIME)
	tween_expand.tween_property(player_down_detect,"position:y",s1,EXPAND_TIME)
	tween_expand.tween_property(twisted_mask,"position:y",s2,EXPAND_TIME)
	tween_expand.tween_property(eyes_node,"position:y",s2,EXPAND_TIME)
	
	if was_mashed:
		anim_expanding_indicator(WAIT_TIME_BEFORE_EXPAND)

	await tween_expand.finished
	
	cancel_stop_expansion()
	is_at_expand_period = false
	is_expanding = false


func anim_expanding_indicator(dur: float) -> void:
	sprite_mashable.visible = true
	
	var p := twisted_mask.position.y
	var t1 := create_tween().set_loops(3)
	
	t1.tween_property(sprite_mashable, "self_modulate", Color(Color.WHITE, 1.0), dur * 0.06)
	t1.tween_property(sprite_mashable, "self_modulate", Color(Color.WHITE, 0.0), dur * 0.27)
	
	var t2 := create_tween().set_loops(3)
	
	t2.tween_property(twisted_mask, "position:y", p - 3.0, dur * 0.06)
	t2.tween_property(twisted_mask, "position:y", p, dur * 0.27)


func get_top_unmashed() -> Unmashed:
	if top_detect:
		if top_detect.is_colliding():
			if top_detect.get_collider(0) is Unmashed:
				return top_detect.get_collider(0) as Unmashed
	
	return null


func move_up(strength: float = 10.0) -> void:
	var top: Unmashed = get_top_unmashed()
	if top:
		top.move_up(2.0 * strength)
		await get_tree().create_timer(0.05).timeout
 	
	position.y -= strength


func is_player_on_top() -> bool:
	if top_detect:
		top_detect.force_shapecast_update()
		if top_detect.is_colliding():
			return top_detect.get_collider(0) is Player
	return false


func is_on_player() -> bool:
	if player_down_detect:
		player_down_detect.force_shapecast_update()
		
		if !player_down_detect.is_colliding():
			return false
		
		if player_down_detect.get_collider(0) is Player:
			return true
	return false


var amount_collided_with: int:
	set(value):
		amount_collided_with = value
		var collidied: bool = amount_collided_with > 0
		
		anim_highlight(collidied)
		
var _landed: bool = true:
	set(value):
		if _landed == value:
			return
		
		_landed = value
		if value:
			anim_sleep()
		else:
			anim_panick()
var t_panick: Tween


func anim_panick():
	if ground_detect.is_colliding():
		print_debug(ground_detect.get_collider(0))
		return
	
	if sprite_node && sprite_eyes && sprite_eyes_alert:
		sprite_eyes.visible = false
		sprite_eyes_alert.visible = true
		
		#if t_panick && t_panick.is_valid():
			#t_panick.kill()
		#const MAG = 10.0
		#const DUR = 0.25
		#
		## Bad.
		#
		#t_panick = create_tween().set_loops()
		#t_panick.set_parallel(true)
		#t_panick.tween_property(sprite_eyes_alert, "position", Vector2(randf_range(-MAG,MAG),randf_range(-MAG,MAG)), DUR)
		#t_panick.tween_property(sprite_node, "skew", MAG, DUR)
		#t_panick.tween_property(sprite_node, "rotation_degrees", MAG, DUR)
		#t_panick.chain().tween_property(sprite_eyes_alert, "position", Vector2(randf_range(-MAG,MAG),randf_range(-MAG,MAG)), DUR)
		#t_panick.tween_property(sprite_node, "skew", -MAG, DUR)
		#t_panick.tween_property(sprite_node, "rotation_degrees", -MAG, DUR)
		
var _last_velocity: Vector2

# TODO hanging mid-air
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		set_physics_process(false)
		return

	if !is_on_player() && !is_on_floor():
		velocity += 0.6 * get_gravity() * delta
	else:
		velocity.y = 0.0
		
	if !_landed && is_on_floor():
		has_landed.emit(abs(_last_velocity.y / 100.0))
		_landed = true
		
	if !is_on_floor():
		_landed = false
		sprite_eyes_one.visible = false
	
	_last_velocity = velocity
	
	if is_at_expand_period:
		
		if top_detect.is_colliding():
			var obj: Node2D = top_detect.get_collider(0)
			
			if obj is IgnoreCeilingArea:
				pass
			elif obj is TileMapLayer:
				stop_expanding(0.0)
			
			# TODO Check if player collision handling needed
			elif obj is Player:
				pass
	
	if !is_expanding:
		move_and_slide()
		
		
	else:
		var displace: float = (2.0 - EXPAND_TIME) * (attributes.twisted_strength / 4.0)
		
		position.y -= displace * 110.0 * delta
		
		if player_down_detect.is_colliding():
			var obj: Node2D = player_down_detect.get_collider(0)
			
			if obj is Unmashed:
				if (obj as Unmashed).is_expanding:
					position.y -= displace * 220.0 * delta

signal anim_unmashed_finished()

# Anim
func anim_unmashed() -> void:
	if sprite_node:
		var dur := 0.1
		var mag := 7.5
		var tween := create_tween()

		tween.tween_property(sprite_node, "rotation_degrees", -mag, dur)
		tween.tween_property(sprite_node, "rotation_degrees", mag/(5.0/4.0), dur/2.0)
		tween.tween_property(sprite_node, "rotation_degrees", -mag/(5.0/3.0), dur/2.0)
		tween.tween_property(sprite_node, "rotation_degrees", mag/(5.0/2.0), dur/2.0)
		tween.tween_property(sprite_node, "rotation_degrees", -mag/5.0, dur/2.0)
		tween.tween_property(sprite_node, "rotation_degrees", 0.0, dur/2.0)
		await tween.finished
		anim_unmashed_finished.emit()
	else:
		anim_unmashed_finished.emit()

func anim_sleep() -> void:
	if t_panick:
		t_panick.kill()
	
	if mash_type == Util.MashType.TWISTED:
		return
	
	if sprite_node && sprite_eyes && sprite_eyes_alert:
		sprite_eyes.visible = true
		sprite_eyes_alert.visible = false
		
		sprite_eyes_alert.position = Vector2.ZERO
		sprite_node.skew = 0.0
		sprite_node.rotation = 0.0
		var dur := 1.0
		var tween := create_tween().set_loops()
		tween.set_parallel(true)
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		
		tween.tween_property(sprite_node, "scale:x", 1.05, dur)
		tween.tween_property(sprite_node, "scale:y", 0.95, dur)
		tween.tween_property(sprite_node, "scale:x", 0.95, dur).set_delay(dur)
		tween.tween_property(sprite_node, "scale:y", 1.025, dur).set_delay(dur)
		await get_tree().create_timer(dur).timeout
		started_breathing.emit()

var _tween_light: Tween
#var _latest_mashed: Mashed

var cooldown_timer: Timer = Timer.new()

func anim_spawn_particles() -> void:
	if particles_spawn:
		particles_spawn.emitting = true
	else:
		push_warning("particles_spawn not assigned")

	var s: Sprite2D = Sprite2D.new()
	s.texture = sprite_block.texture.duplicate()
	s.scale = Vector2.ZERO
	s.rotation = 0.0 if attributes.build_type == Util.BuildType.RECTANGLE else PI / 4.0
	s.z_index = 1
	add_child(s)

	var tween := create_tween().set_parallel(true)
	tween.tween_property(s, "scale", Vector2.ONE * 1.5, 1.0)
	tween.tween_property(s, "self_modulate", Color(Color.WHITE, 0.0), 1.0)
	tween.chain().tween_callback(func(): s.queue_free() )

var _tween_prompt: Tween

func anim_highlight(highlight_block: bool) -> void:
	var can_mash: bool = true
	var p: Player = GameMgr.current_player
	
	if p:
		can_mash = p.can_perform_mash()
		sprite_input.visible = !can_mash
		
		if highlight_block && (randf() > 1.0 / 2.0):
			sprite_eyes_one.flip_h = signf(global_position.x - p.global_position.x) < 0
			sprite_eyes_one.visible = true
			sprite_eyes.self_modulate = Color(Color.WHITE, 0.0)
		else:
			sprite_eyes_one.visible = false
			sprite_eyes.self_modulate = Color(Color.WHITE, 1.0)
	
	is_player_close = highlight_block
	
	if _tween_light:
		_tween_light.kill()
		
	_tween_light = get_tree().create_tween().set_parallel()
	
	if sprite_mashable:
		sprite_mashable.self_modulate = Color(Color.WHITE, 1.0)
	
	if highlight_block:
		if tutorial_block:
			node_mash_prompt.visible = true
			
			if _tween_prompt:
				_tween_prompt.kill()
			_tween_prompt = create_tween()
			_tween_prompt.tween_property(node_mash_prompt, "scale", Vector2.ONE, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		
		if mash_type == Util.MashType.TWISTED:
			sprite_mashable.visible = can_mash
		else:
			_tween_light.tween_property(sprite_highlight, "scale", Vector2.ONE*0.52 if can_mash else Vector2.ONE*0.25, 0.1)
			_tween_light.tween_property(sprite_input, "modulate", Color(Color.WHITE), 0.1)

	else:
		if tutorial_block:
			if _tween_prompt:
				_tween_prompt.kill()
				
			_tween_prompt = create_tween()
			_tween_prompt.tween_property(node_mash_prompt, "scale", Vector2.ONE * 0.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

		if can_mash:
			if mash_type == Util.MashType.TWISTED:
				sprite_mashable.visible = false
			else:
				_tween_light.tween_property(sprite_highlight, "scale", Vector2.ONE*0.25, 0.1)
		
		_tween_light.tween_property(sprite_input, "modulate", Color(Color.WHITE, 0.0), 0.1)
		
		await _tween_light.finished
		
		if build_type == Util.BuildType.SQUARE:
			node_mash_prompt.visible = false
