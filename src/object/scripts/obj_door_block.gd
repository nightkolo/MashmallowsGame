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

var is_activated: bool:
	get:
		return is_activated
	set(value):
		#if value != is_activated:
			#activate(value)
		is_activated = value
var is_popping: bool



func _ready() -> void:
	if get_parent() is Door:
		(get_parent() as Door).door_blocks.append(self)
		
		
		

func activate(p_activate: bool) -> void:
	set_deferred("disabled", p_activate)
	
	#await get_tree().create_timer(0.1).timeout
	#print_debug(is_activated)
	
	if p_activate == is_activated:
		return
	
	is_activated = p_activate
	
	if p_activate:
		anim_pop()
	else:
		anim_regen()
		
		
		

var tween_eye: Tween
var tween_pop: Tween
var pop_sprite: Sprite2D

func cancel_anim_pop():
	if tween_pop:
		tween_pop.kill()
		
	if pop_sprite != null:
		pop_sprite.queue_free()


func anim_pop() -> void:
	await get_tree().create_timer(randf() * 0.25).timeout
	
	if !is_activated:
		return
	
	is_popping = true
	
	cancel_anim_pop()
	pop_sprite = Sprite2D.new()
	pop_sprite.texture = [pop_text_1, pop_text_2].pick_random()
	pop_sprite.scale = Vector2.ZERO
	add_child(pop_sprite)
	#####
	sprite_eye.texture = eye_text_closed
	sprite_eye.scale = Vector2.ONE * 1.5
	
	var pop_dur := 0.15
	
	tween_pop = create_tween().set_parallel(true)
	tween_pop.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_pop.tween_property(sprite_bubble, "scale", Vector2.ONE * 1.0, pop_dur).set_ease(Tween.EASE_IN)
	tween_pop.tween_property(sprite_bubble, "self_modulate", Color(Color.WHITE, 0.0), pop_dur).set_delay(pop_dur * 0.75)
	
	tween_pop.tween_property(sprite_eye, "scale", Vector2.ONE * 0.5, 1.0)
	tween_pop.tween_property(sprite_eye, "self_modulate", Color(Color.WHITE, 0.0), 1.0)
	
	tween_pop.tween_property(pop_sprite, "scale", Vector2.ONE, 1.0).set_delay(pop_dur)
	tween_pop.tween_property(pop_sprite, "self_modulate", Color(Color.WHITE, 0.0), 1.0).set_delay(pop_dur)
	tween_pop.chain().tween_callback(func():
		pop_sprite.queue_free()
		)
	await tween_pop.finished
	
	is_popping = false
	
	
var tween_regen: Tween

func anim_regen() -> void:
	
	if is_popping || is_activated:
	
		cancel_anim_pop()
		
		sprite_bubble.scale = Vector2.ZERO
		sprite_bubble.self_modulate = Color.WHITE
		
		var pop_dur := 0.15
		
		sprite_eye.texture = eye_text_reg
		
		tween_pop = create_tween().set_parallel(true)
		#tween_pop.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween_pop.tween_property(sprite_bubble, "scale", Vector2.ONE * 0.5, pop_dur * 4.0).set_ease(Tween.EASE_IN)
		tween_pop.tween_property(sprite_bubble, "self_modulate", Color(Color.WHITE, 1.0), pop_dur)
		
		tween_pop.tween_property(sprite_eye, "scale", Vector2.ONE * 0.5, pop_dur * 4.0)
		tween_pop.tween_property(sprite_eye, "self_modulate", Color(Color.WHITE, 1.0), pop_dur)
		
		#tween_pop.tween_property(pop_sprite, "scale", Vector2.ONE, 1.0).set_delay(pop_dur)
		#tween_pop.tween_property(pop_sprite, "self_modulate", Color(Color.WHITE, 0.0), 1.0).set_delay(pop_dur)
		#tween_pop.chain().tween_callback(func():
			#pop_sprite.queue_free()
			#)
			
			
		#sprite_bubble.self_modulate = Color(Color.WHITE, 1.0)
		#sprite_bubble.scale = Vector2.ONE * 0.5
		#
		#sprite_eye.self_modulate = Color(Color.WHITE, 1.0)
		#sprite_eye.scale = Vector2.ONE * 0.5
	#
	
	
