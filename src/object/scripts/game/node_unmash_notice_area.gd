extends Area2D
class_name UnmashArea

@export var misc: int = 3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
				   
	body_entered.connect(func(body: Node2D):
		if body is Player:
			var p: Player = body as Player
			
			p.show_z_notice(p.child_blocks.size() >= 3)
		)
			  
	body_exited.connect(func(body: Node2D):
		if body is Player:
			(body as Player).show_z_notice(false)
		)
		
