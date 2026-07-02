## @deprecated
extends Area2D
class_name FlameDetect

var parent_mashed: Mashed
var parent_unmashed: Unmashed


func _ready() -> void:
	collision_layer = 0
	collision_mask = 256
	
	_setup()

func _setup() -> void:
	var allowed: bool = false
	
	if get_parent() is Mashed:
		parent_mashed = get_parent() as Mashed
		
		allowed = parent_mashed.mash_type != Util.MashType.PLAYER
	elif get_parent() is Unmashed:
		parent_unmashed = get_parent() as Unmashed
		
		allowed = true
		
	if !allowed:
		return
		
	if parent_mashed:
		area_entered.connect(func(area: Node2D):
			if area is Flame2D:
				parent_mashed.set_golden(true)
				(area as Flame2D).anim_out()
			)
			
	if parent_unmashed:
		area_entered.connect(func(area: Node2D):
			if area is Flame2D:
				parent_unmashed.set_golden(true)
				(area as Flame2D).anim_out()
		)
		
