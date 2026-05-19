extends Area2D
class_name ResetNoticeArea

enum Condition {NO_UNMASHED_IN_AREA, NO_CHERRY_BOMB_IN_AREA}

@export var condition: Condition

var timer: Timer = Timer.new()


func _ready() -> void:
	timer.wait_time = 1.0
	add_child(timer)
	timer.start()
	
	await timer.timeout
	
	body_entered.connect(func(body: Node2D):
		match condition:
			
			Condition.NO_UNMASHED_IN_AREA:
				if body is Player:
					var player := body as Player
					var bodies: Array[Node2D] = get_overlapping_bodies()
					
					if bodies.filter(func(entry: Node2D): 
						return entry is Unmashed
						).is_empty() && player.child_blocks.size() == 1:
							got_stuck()
		)


func got_stuck() -> void:
	GameLogic.is_stuck = true
	GameMgr.current_NPC.millie.expression = Millie.Expressions.FRUSTRATED
							
	GameMgr.current_player.show_reset_notice()
	
	
