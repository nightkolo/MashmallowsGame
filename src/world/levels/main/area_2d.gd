extends Area2D

func _ready() -> void:
	collision_mask = 8 + 2
	
	body_entered.connect(func(body: Node2D):
		body.position.y -= 10.0
		)
