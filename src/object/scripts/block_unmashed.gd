@tool
class_name Unmashed
extends CharacterBody2D

signal has_landed(strength: float)
signal started_breathing()
signal started_expanding()
signal player_entered(entered: bool)

# Shared variables with [Mashed]
var attributes: BlockAttributes

@export var tutorial_block: bool = false
@export var mash_type: Util.MashType:
	set(value):
		if is_node_ready():
			sprite.texture = Util.get_mash_type_texture(value, build_type)
			#sprite_shade.texture = Util.get_mash_type_shade_texture(value, build_type)
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
@export var cherry_bomb_strength: float = 1600.0
@export var twisted_strength: float = 5.0

@export_group("Area casts")
@export var player_down_detect: ShapeCast2D
@export var top_detect: ShapeCast2D
#@export var twisted_marshmallow: Twisted

@export_group("Audio")
@export var audio: UnmashedAudio
@export_group("Nodes")
@export var colli: CollisionShape2D 
@export var particles_spawn: CPUParticles2D 
@export var particles_z: CPUParticles2D 

@export_group("Sprites")
@export var node_mash_prompt: Node2D 
@export var sprite: Sprite2D
@export var sprite_shade: Sprite2D
@export var sprite_highlight: Sprite2D
@export var sprite_input: Sprite2D
@export var sprite_node: Node2D 
@export var eyes_node: Node2D 

#var twisted: PackedScene = preload("res://object/objects/block_twisted_collision.tscn")

var unmashed_spawner: Node
var was_mashed: bool = false
var is_player_close: bool = false:
	set(value):
		player_entered.emit(value)
		is_player_close = value
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

	
	if mash_type == Util.MashType.TWISTED:
		sprite_highlight.visible = false
		
		if colli:
			colli.shape = colli.shape.duplicate() as RectangleShape2D
	
	if mash_type != Util.MashType.MISC:
		anim_sleep()
		particles_z.emitting = true
		if audio:
			audio.play_spawn_sound()
	else:
		sprite_node.scale = Vector2.ONE
		
	eyes_node.visible = mash_type != Util.MashType.MISC

	GameLogic.setup_mash(sprite, attributes.mash_type, attributes.build_type)
	#
	spawn_twisted()
	
	if was_mashed:
		await anim_unmashed_finished
	
	if mash_type == Util.MashType.TWISTED:
		sprite_node.visible = false
	elif GameMgr.current_level:
		sprite_node.visible = GameMgr.current_level.show_unmashed_blocks


func spawn_twisted():
	if mash_type == Util.MashType.TWISTED:
		collision_mask = 1 + 8
		#var t: Twisted = twisted.instantiate()
		#t.position = Vector2.ZERO
		#if was_mashed:
			#await anim_unmashed_finished
		#add_child(t)
		#move_child(t, 0)
		#twisted_marshmallow = t
		anim_expanding()
	else:
		collision_mask = 1 + 8 + 4096

func is_mashable() -> bool:
	return !is_expanding

const EXPAND_TIME = 0.5
const WAIT_TIME_BEFORE_EXPAND = 0.75

var tween_expand: Tween

func anim_expanding() -> void:
	if colli == null:
		return

	is_expanding = true
	
	# TODO duplicate shape before-hand
	
	# create tween
	# move to pos_to, on twisted_strength
	# set conditions
	
	started_expanding.emit()
	
	if tween_expand:
		tween_expand.kill()
	
	tween_expand = create_tween()
	
	#var pos_to: float = twisted_strength * Util.BLOCK_SIZE
	
	tween_expand.tween_property(
		colli.shape as RectangleShape2D,
		"size:y",
		twisted_strength * Util.BLOCK_SIZE,
		EXPAND_TIME
		).set_delay(WAIT_TIME_BEFORE_EXPAND)
	
	
	if was_mashed:
		# anim indicator
		pass
		#twisted_marshmallow.anim_indicator(WAIT_TIME_BEFORE_EXPAND)
	
	await tween_expand.finished
	
	is_expanding = false

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
		return player_down_detect.is_colliding()
	return false


var amount_collided_with: int:
	set(value):
		amount_collided_with = value
		var collidied: bool = amount_collided_with > 0
		
		anim_highlight(collidied)
		
		#if twisted_marshmallow:
			#twisted_marshmallow.anim_highlight(collidied)
		

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

	move_and_slide()


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

func anim_highlight(p_mash: bool) -> void:
	var can_mash: bool = true

	if GameMgr.current_main_player:
		can_mash = GameMgr.current_main_player.can_perform_mash()
		sprite_input.visible = !can_mash
	
	is_player_close = p_mash
	
	if _tween_light:
		_tween_light.kill()
		
	_tween_light = get_tree().create_tween().set_parallel()
	
	# TODO FIx highlight system
	print_debug("Can mash: %s" % p_mash)
	
	if p_mash:
		if tutorial_block && node_mash_prompt:
			node_mash_prompt.visible = true
			if _tween_prompt:
				_tween_prompt.kill()
			_tween_prompt = create_tween()
			_tween_prompt.tween_property(node_mash_prompt, "scale", Vector2.ONE, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

		#sprite_input.visible = true
		#sprite_highlight.visible = true
		if can_mash:
			_tween_light.tween_property(sprite_highlight, "scale", Vector2.ONE*0.52, 0.1)
		else:
			_tween_light.tween_property(sprite_highlight, "scale", Vector2.ONE*0.25, 0.1)
		_tween_light.tween_property(sprite_input, "modulate", Color(Color.WHITE), 0.1)
		
	else:

		if tutorial_block && node_mash_prompt:
			if _tween_prompt:
				_tween_prompt.kill()
			_tween_prompt = create_tween()
			_tween_prompt.tween_property(node_mash_prompt, "scale", Vector2.ONE * 0.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

		if can_mash:
			_tween_light.tween_property(sprite_highlight, "scale", Vector2.ONE*0.25, 0.1)
		_tween_light.tween_property(sprite_input, "modulate", Color(Color.WHITE, 0.0), 0.1)
		await _tween_light.finished
		#sprite_highlight.visible = false
		if node_mash_prompt:
			node_mash_prompt.visible = false
		#sprite_input.visible = false
