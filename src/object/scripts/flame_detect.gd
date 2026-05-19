extends Area2D
class_name Flame2DDetect

var parent_mashed: Mashed
var parent_unmashed: Unmashed


func _ready() -> void:
	collision_mask = 256

	if get_parent() is Mashed:
		parent_mashed = get_parent() as Mashed
	elif get_parent() is Unmashed:
		parent_unmashed = get_parent() as Unmashed
	else:
		return

	area_entered.connect(func(area: Area2D):
		if area is Flame2D:
			if parent_unmashed:
				parent_unmashed.set_golden(true)

			if parent_mashed:
				parent_mashed.set_golden(true)
	)
