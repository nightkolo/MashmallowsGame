extends CollisionShape2D
class_name DoorBlock

@export var pop_text_1: Texture = preload("res://assets/world/pop-02.png")
@export var pop_text_2: Texture = preload("res://assets/world/pop-03.png")

@export var eye_text_reg: Texture = preload("res://assets/objects/bubblegate-eyes-reg.png")
@export var eye_text_closed: Texture = preload("res://assets/objects/bubblegate-eyes-closed.png")

@onready var sprite_node: Node2D = $Sprite2
@onready var sprite_inflators: Sprite2D = %Inflators
@onready var sprite_bubble: Sprite2D = %Bubble
@onready var sprite_eye: Sprite2D = %Eye
#@onready var area_2d: Area2D = $Area2D
@onready var open_sfx: Array[AudioStreamPlayer2D] = [%Open01, %Open02, %Open03]
@onready var close_sfx: Array[AudioStreamPlayer2D] = [%Close01, %Close02]

@onready var detector_rays: Array[Area2D] = [$Down, $Up, $Right, $Left]

var is_activated: bool:
	get:
		return is_activated
	set(value):
		is_activated = value
var parent_door: Door
var t_wobble: Tween

func anim_eye_wobble(dur: float = 0.5, mag: float = 3.0) -> void:
	if t_wobble:
		t_wobble.kill()

	#var mag := 10.0
	#var extra := Util.BLOCK_SIZE * 0.5 if attributes.build_type == Util.BuildType.RECTANGLE else 0.0

	sprite_eye.position.y = (mag * 0.5)

	t_wobble = create_tween().set_loops()
	t_wobble.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

	t_wobble.tween_property(sprite_eye, "position:y", -mag, dur)
	t_wobble.tween_property(sprite_eye, "position:y", mag, dur)

var tween_squish: Tween

func _ready() -> void:
	anim_eye_wobble()
	
	if get_parent() is Door:
		parent_door = get_parent() as Door
	
	for area: Area2D in detector_rays:
		area.body_entered.connect(func(body: Node2D):
			anim_body_entered(area.position.sign())
			if parent_door:
				if parent_door.can_self_activate:
					parent_door.interact(true)
			
			)
		area.body_exited.connect(func(_body: Node2D):
			#for in_area: Area2D in detector_rays:
				#print_debug("%s: %s" % [self, in_area.get_overlapping_bodies()])
			anim_body_exited()
			)



func anim_body_entered(dir: Vector2) -> void:
	var offset: Vector2 = dir

	if tween_squish:
		tween_squish.kill()
	
	tween_squish = create_tween()
	if abs(offset.x) > abs(offset.y):
		tween_squish.tween_property(sprite_bubble, "scale", Vector2(0.8, 1.0) * 0.5, 0.1)
	else:
		tween_squish.tween_property(sprite_bubble, "scale", Vector2(1.0, 0.8) * 0.5, 0.1)


func anim_body_exited() -> void:
	if tween_squish:
		tween_squish.kill()
	
	tween_squish = create_tween()
	tween_squish.tween_property(sprite_bubble, "scale", Vector2.ONE * 0.5, 1.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		

func activate(p_activate: bool) -> void:
	if is_activated == p_activate:
		return
	
	is_activated = p_activate
	
	set_deferred("disabled", p_activate)
	
	if p_activate:
		anim_pop()
		#sprite_node.modulate = Color(Color.WHITE, 0.5)
	else:
		anim_regen()
		#sprite_node.modulate = Color(Color.WHITE, 1.0)


var tween_eye: Tween
var tween_pop: Tween
var pop_sprite: Sprite2D


func cancel_anim_pop() -> void:
	if tween_pop:
		tween_pop.kill()
		
	if pop_sprite != null:
		pop_sprite.queue_free()


func anim_pop() -> void:
	if !is_activated:
		return
	
	var sfx : AudioStreamPlayer2D= open_sfx.pick_random()
	sfx.play()
	#is_popping = true
	
	cancel_anim_pop()
	pop_sprite = Sprite2D.new()
	pop_sprite.texture = [pop_text_1, pop_text_2].pick_random()
	pop_sprite.scale = Vector2.ZERO
	pop_sprite.rotation = randf() * TAU
	add_child(pop_sprite)

	sprite_eye.texture = eye_text_closed
	sprite_eye.scale = Vector2.ONE * 1.5
	
	var pop_dur := 0.15
	var dur_2 := 1.0
	
	tween_pop = create_tween().set_parallel(true)
	tween_pop.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_pop.tween_property(sprite_bubble, "scale", Vector2.ONE * 1.0, pop_dur).set_ease(Tween.EASE_IN)
	tween_pop.tween_property(sprite_bubble, "self_modulate", Color(Color.WHITE, 0.0), pop_dur).set_delay(pop_dur * 0.75)
	
	tween_pop.tween_property(sprite_eye, "scale", Vector2.ONE * 0.5, dur_2)
	tween_pop.tween_property(sprite_eye, "self_modulate", Color(Color.WHITE, 0.0), dur_2)
	
	if pop_sprite:
		tween_pop.tween_property(pop_sprite, "scale", Vector2.ONE, dur_2).set_delay(pop_dur)
		tween_pop.tween_property(pop_sprite, "self_modulate", Color(Color.WHITE, 0.0), dur_2).set_delay(pop_dur)
	tween_pop.chain().tween_callback(func():
		if pop_sprite:
			pop_sprite.queue_free()
		)
	await tween_pop.finished
	
	#is_popping = false
	
	
var tween_regen: Tween

func anim_regen() -> void:
	
	cancel_anim_pop()
	
	
	var sfx : AudioStreamPlayer2D = close_sfx.pick_random()
	sfx.play()
	
	sprite_bubble.scale = Vector2.ZERO
	sprite_bubble.self_modulate = Color.WHITE
	
	var pop_dur := 0.15
	
	sprite_eye.texture = eye_text_reg
	
	tween_pop = create_tween().set_parallel(true)
	#tween_pop.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_pop.tween_property(sprite_bubble, "scale", Vector2.ONE * 0.5, pop_dur * 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween_pop.tween_property(sprite_bubble, "self_modulate", Color(Color.WHITE, 1.0), pop_dur)
	
	tween_pop.tween_property(sprite_eye, "scale", Vector2.ONE * 0.5, pop_dur * 3.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween_pop.tween_property(sprite_eye, "self_modulate", Color(Color.WHITE, 1.0), pop_dur)
	
	if pop_sprite:
		tween_pop.tween_property(pop_sprite, "scale", Vector2.ONE, 1.0).set_delay(pop_dur)
		tween_pop.tween_property(pop_sprite, "self_modulate", Color(Color.WHITE, 0.0), 1.0).set_delay(pop_dur)
	tween_pop.chain().tween_callback(func():
		if pop_sprite != null:
			pop_sprite.queue_free()
		)
	
		
	
