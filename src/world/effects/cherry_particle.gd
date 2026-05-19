extends RigidBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	var dur := 2.2
	var tween := create_tween()
	
	tween.tween_property(sprite_2d, "self_modulate", Color(Color.WHITE, 0.0), dur)
	
	await get_tree().create_timer(dur).timeout
	
	queue_free()
