extends AnimatableBody2D
class_name TwistedColliBlock

var parent_unmashed: Unmashed

func _ready() -> void:
	if get_parent() is Node:
		if get_parent().get_parent() is Unmashed:
			parent_unmashed = get_parent().get_parent() as Unmashed
	
	print_debug(parent_unmashed)
	
	collision_layer = 4096
	collision_mask = 1 + 8
