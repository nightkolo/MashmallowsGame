extends Area2D
class_name Flame2D

var parent_flame_obj: FlameBody2D

func _ready() -> void:
	collision_layer = 256
	collision_mask = 0
	
	if get_parent() is FlameBody2D:
		parent_flame_obj = get_parent() as FlameBody2D
	#body_entered.connect(func(body: Node2D):
		#print_debug(get_overlapping_bodies())
		#)
		#
	#body_exited.connect(func(body: Node2D):
		#print_debug(body)
		#)


func anim_out() -> void:
	parent_flame_obj.stop_anim_flame()
	
	parent_flame_obj.stop_anim_spin()
	queue_free()
