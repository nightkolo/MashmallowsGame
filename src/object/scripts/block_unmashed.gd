@tool
class_name Unmashed
extends CharacterBody2D

signal has_landed(strength: float)
signal started_breathing()
signal started_expanding()
signal player_entered(entered: bool)

@export var tutorial_block: bool = false
@export var mash_type: Util.MashType:
	set(value):
		if is_node_ready():
			sprite.texture = Util.get_mash_type_texture(value, build_type)
		if attributes:
			attributes.mash_type = value
		mash_type = value
@export var build_type: Util.BuildType:
	set(value):
		if is_node_ready():
			sprite.texture = Util.get_mash_type_texture(mash_type, value)
		if attributes:
			attributes.build_type = value
		build_type = value

@export_group("Variables")
# @export var cherry_bomb_strength: float = 1600.0
# @export var twisted_strength: float = 5.0

@export_group("Area casts")
@export var player_down_detect: ShapeCast2D
@export var top_detect: ShapeCast2D

@export_group("Audio")
@export var audio: UnmashedAudio
@export_group("Nodes")
@export var slippery_colli: CollisionPolygon2D 
@export var colli: CollisionShape2D 
@export var particles_spawn: CPUParticles2D 
@export var particles_z: CPUParticles2D 

@export_group("Sprites")
@export var node_mash_prompt: Node2D 
@export var sprite: Sprite2D
@export var twisted_mask: Sprite2D
@export var sprite_mashable: Sprite2D
@export var sprite_highlight: Sprite2D
@export var sprite_input: Sprite2D
@export var sprite_node: Node2D 
@export var eyes_node: Node2D 

var attributes: BlockAttributes
var unmashed_spawner: Node
# var dubbleganger_block: bool = false
var was_mashed: bool = false
var is_player_close: bool = false:
	set(value):
		player_entered.emit(value)
		is_player_close = value
var is_at_expand_period: bool = false
var is_expanding: bool = false


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
		sprite.visible = false
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
		
		if mash_type != Util.MashType.TWISTED:
			anim_sleep()
			
	eyes_node.visible = mash_type != Util.MashType.MISC

	GameLogic.setup_mash(sprite, attributes.mash_type, attributes.build_type)
	
	_ready_twisted()
	
	if was_mashed:
		await anim_unmashed_finished
	
	if GameMgr.current_level:
		sprite_node.visible = GameMgr.current_level.show_unmashed_blocks


func _ready_twisted() -> void:
	#collision_mask = 1 + 2 + 8
	if mash_type == Util.MashType.TWISTED:
		#(colli.shape as RectangleShape2D).size.x -= 10.0
		
		anim_expanding(!was_mashed)


func is_mashable() -> bool:
	# if dubbleganger_block:
	# 	var p: Player = GameMgr.current_player
	# 	if p != null:
	# 		return !is_at_expand_period && p.dubbleganger
	return !is_at_expand_period 


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

# TODO Add raycast based collision checking
func stop_expanding(pushback: float = 20.0) -> void:
	if tween_expand && is_at_expand_period:
		tween_expand.kill()
		
		(twisted_mask.texture as GradientTexture2D).height -= int(pushback)
		(colli.shape as RectangleShape2D).size.y -= pushback
		
		is_at_expand_period = false
		is_expanding = false

const EXPAND_TIME = 1.0
const WAIT_TIME_BEFORE_EXPAND = 0.75


func anim_expanding(instant: bool = false) -> void:
	if colli == null || twisted_mask == null:
		return
	
	var pos_to: float = attributes.twisted_strength * Util.BLOCK_SIZE
	var s1: float = pos_to * 0.5
	var s2: float = pos_to * 0.395
	
	if instant:
		(colli.shape as RectangleShape2D).size.y = pos_to
		(twisted_mask.texture as GradientTexture2D).height = int(pos_to)
		top_detect.position.y = -s1
		
		player_down_detect.position.y = s1
		position.y -= s2
		
		twisted_mask.position.y = s2
		eyes_node.position.y = s2
		return
	
	started_expanding.emit()
	
	is_at_expand_period = true
	
	if tween_expand:
		tween_expand.kill()
	
	tween_expand = create_tween().set_parallel(true)
	
	tween_expand.tween_callback(func():
		is_expanding = true
		start_stop_expansion()
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
	var p: float = twisted_mask.position.y
	var t:= create_tween().set_loops(3)
	
	sprite_mashable.visible = true
	
	t.tween_property(sprite_mashable, "self_modulate", Color(Color.WHITE, 1.0), dur * 0.06)
	t.tween_property(sprite_mashable, "self_modulate", Color(Color.WHITE, 0.0), dur * 0.27)
	
	var t_b := create_tween().set_loops(3)
	
	t_b.tween_property(twisted_mask, "position:y", p - 3.0, dur * 0.06)
	t_b.tween_property(twisted_mask, "position:y", p, dur * 0.27)


## TODO Add to Player
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
		
var _landed: bool

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
		has_landed.emit(abs(velocity.y / 100.0))
		_landed = true
		
	if !is_on_floor():
		_landed = false
		
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
		var displace: float = EXPAND_TIME * (attributes.twisted_strength / 4.0)
		
		position.y -= displace * 100.0 * delta
		
		if player_down_detect.is_colliding():
			var obj: Node2D = player_down_detect.get_collider(0)
			
			if obj is Unmashed:
				if (obj as Unmashed).is_expanding:
					position.y -= displace * 200.0 * delta

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
	if sprite_node:
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
	s.texture = sprite.texture.duplicate()
	s.scale = Vector2.ZERO
	s.rotation = 0.0 if attributes.build_type == Util.BuildType.RECTANGLE else PI / 4.0
	s.z_index = 1
	add_child(s)

	var tween := create_tween().set_parallel(true)
	tween.tween_property(s, "scale", Vector2.ONE * 1.5, 1.0)
	tween.tween_property(s, "self_modulate", Color(Color.WHITE, 0.0), 1.0)
	tween.chain().tween_callback(func(): s.queue_free() )

var _tween_prompt: Tween

func anim_highlight(p_highlight: bool) -> void:
	var can_mash: bool = true

	if GameMgr.current_main_player:
		can_mash = GameMgr.current_main_player.can_perform_mash()
		sprite_input.visible = !can_mash
	
	is_player_close = p_highlight
	
	if _tween_light:
		_tween_light.kill()
		
	_tween_light = get_tree().create_tween().set_parallel()
	
	if sprite_mashable:
		sprite_mashable.self_modulate = Color(Color.WHITE, 1.0)
	
	if p_highlight:
		if tutorial_block && node_mash_prompt:
			node_mash_prompt.visible = true
			
			if _tween_prompt:
				_tween_prompt.kill()
			_tween_prompt = create_tween()
			_tween_prompt.tween_property(node_mash_prompt, "scale", Vector2.ONE, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		
		if can_mash:
			if sprite_mashable:
				sprite_mashable.visible = true
			_tween_light.tween_property(sprite_highlight, "scale", Vector2.ONE*0.52, 0.1)
		else:
			if sprite_mashable:
				sprite_mashable.visible = false
			_tween_light.tween_property(sprite_highlight, "scale", Vector2.ONE*0.25, 0.1)
		
		_tween_light.tween_property(sprite_input, "modulate", Color(Color.WHITE), 0.1)

	else:
		if tutorial_block && node_mash_prompt:
			if _tween_prompt:
				_tween_prompt.kill()
				
			_tween_prompt = create_tween()
			_tween_prompt.tween_property(node_mash_prompt, "scale", Vector2.ONE * 0.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

		if can_mash:
			if sprite_mashable:
				sprite_mashable.visible = false
			_tween_light.tween_property(sprite_highlight, "scale", Vector2.ONE*0.25, 0.1)
		
		_tween_light.tween_property(sprite_input, "modulate", Color(Color.WHITE, 0.0), 0.1)
		
		await _tween_light.finished
		
		if node_mash_prompt:
			node_mash_prompt.visible = false
