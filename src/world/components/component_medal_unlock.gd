extends Node
class_name MedalUnlockComponent

@export var block_to_restrict: UnmashedSpawner

@export var player: Player
@export var area: Area2D

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
					pass
					#await MedalMgr.unlock_a_medal("1_2", NewgroundsIds.MedalId.AnOrderByTheBook, true)
					
			6:
				if block_to_restrict:
					if block_to_restrict.taken_no_regen == false:
						pass
						#await MedalMgr.unlock_a_medal("1_6", NewgroundsIds.MedalId.Trespassing, true)
		
			13:
				if block_to_restrict:
					if block_to_restrict.taken_no_regen == false:
						pass
						#await MedalMgr.unlock_a_medal("2_13", NewgroundsIds.MedalId.LoftyToffee, true)
			
			20:
				if _has_unmashed == false:
					pass
					#await MedalMgr.unlock_a_medal("2_20", NewgroundsIds.MedalId.TheFloorIsLava, true)
		)
	
	await get_tree().create_timer(0.5).timeout
	
	match GameMgr.level_id:
		# Processes condition medals
		2:	
			if player:
				player.has_unmashed.connect(func():
					_has_unmashed = true
					)
		
		20:
			if area:
				area.collision_mask = 2
				
				area.body_entered.connect(func(body: Node2D):
					if body is Player:
						_has_unmashed = true
					)
					
