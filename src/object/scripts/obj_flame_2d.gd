extends Area2D
class_name Flame2D


func _ready() -> void:
	collision_layer = 256
	collision_mask = 0
	
	#body_entered.connect(func(body: Node2D):
		#print_debug(get_overlapping_bodies())
		#)
		#
	#body_exited.connect(func(body: Node2D):
		#print_debug(body)
		#)


func anim_out() -> void:
	queue_free()
