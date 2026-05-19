extends StaticBody2D
class_name Door

var is_openned: bool

var door_blocks: Array[DoorBlock]


#func _ready() -> void:
	#colli = get_children()


func interact(open: bool) -> void:
	is_openned = open
	
	for block: DoorBlock in door_blocks:
		block.is_activated = open
		#col.disabled = open
