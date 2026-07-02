## @deprecated
extends StaticBody2D
class_name FlameBody2D

@onready var sprite_object: Sprite2D = %Object
@onready var sprite_flame: Sprite2D = %Flame


func _ready() -> void:
	anim_spin()
	anim_flame()
	
var tween_spin: Tween
var tween_flame: Tween


func stop_anim_spin() -> void:
	if tween_spin:
		tween_spin.kill()
		
func stop_anim_flame() -> void:
	if tween_flame:
		tween_flame.kill()
	sprite_flame.self_modulate = Color(Color.GRAY, 1.0)


func anim_spin() -> void:
	stop_anim_spin()
	
	tween_spin = create_tween().set_loops()
	
	tween_spin.tween_property(sprite_object, "rotation", TAU, 5.0)
	tween_spin.tween_callback(func(): sprite_object.rotation = 0.0 )



func anim_flame() -> void:
	stop_anim_flame()
	
	tween_flame = create_tween().set_loops()
	
	tween_flame.tween_property(sprite_flame, "self_modulate", Color(Color.YELLOW * 1.5, 1.0), 1.0)
	tween_flame.tween_property(sprite_flame, "self_modulate", Color(Color.YELLOW, 1.0), 1.0)
	
	
	
	
	
