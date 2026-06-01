extends AnimatableBody2D
class_name TwistedColliBlock

@onready var colli: CollisionShape2D = $CollisionShape2D

var parent_unmashed: Unmashed

func _ready() -> void:
	if get_parent() is Node:
		if get_parent().get_parent() is Unmashed:
			parent_unmashed = get_parent().get_parent() as Unmashed
	
	#print_debug(parent_unmashed)
	
	collision_layer = 4096
	collision_mask = 1 + 8

	if parent_unmashed:
		parent_unmashed.started_expanding.connect(func():
			colli.set_deferred("disabled", parent_unmashed.mash_type != Util.MashType.TWISTED)
			)
