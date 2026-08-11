extends Area2D

func _ready() -> void:
	collision_mask = 2
	
	body_entered.connect(func():
		await MedalMgr.unlock_a_medal("2_11", NewgroundsIds.MedalId.NothingHersheyButUsChickens, true)
		)
		
