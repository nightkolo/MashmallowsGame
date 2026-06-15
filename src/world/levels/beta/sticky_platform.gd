extends StaticBody2D
class_name StickyPlatform

func _ready() -> void:
	collision_layer = 8192
	collision_mask = 8192
	
	await get_tree().create_timer(0.1).timeout
	
	if GameMgr.current_player:
		GameMgr.current_player.is_sticky_platform_present = true
		
