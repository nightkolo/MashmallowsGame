class_name Twisted2
extends CharacterBody2D


func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	
	var t := create_tween()
	
	var colli: CollisionShape2D = $CollisionShape2D
	
	colli.shape = colli.shape.duplicate() as RectangleShape2D
	
	t.tween_property(colli.shape as RectangleShape2D, "size", Vector2(64.0, 500.0), 2.0)



func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
