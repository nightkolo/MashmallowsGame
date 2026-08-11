extends Node
class_name MedalUnlockComponent

var block_to_restrict: UnmashedSpawner

@export var player: Player

var _has_unmashed: bool = false

func _ready() -> void:
	GameMgr.game_data_saved.connect(func():
		# Checks for move count medals
		# It is made awkwardly this way
		
		match GameMgr.level_id:
			_:
				pass
		)
	
	GameMgr.game_just_ended.connect(func():
		# Checks for condition medals
		
		match GameMgr.level_id:
			
			2:
				if _has_unmashed == false:
					await MedalMgr.unlock_a_medal("1_2", NewgroundsIds.MedalId.AnOrderByTheBook, true)
		)
	
	await get_tree().create_timer(0.5).timeout
	
	if player == null:
		print("ASSIGN THE PLAYER")
		return
	
	match GameMgr.level_id:
		# Processes condition medals
		2:
			player.has_unmashed.connect(func():
				_has_unmashed = true
				)
