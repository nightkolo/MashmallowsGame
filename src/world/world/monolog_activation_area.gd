extends Area2D
class_name MonologArea

@export var enabled: bool = true:
	set(value):
		monitoring = value
		enabled = value
@export var monolog_system_to_activate: MonologSystem

var is_player_in: bool:
	set(value):
		if value == is_player_in:
			return
		
		GameLogic.player_interacted_monolog_area.emit(value)
		is_player_in = value


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	
	body_entered.connect(func(body: Node2D):
		is_player_in = true
		)
	body_exited.connect(func(body: Node2D):
		is_player_in = false
		)
		
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_start_monolog"):
		if is_player_in:
			if monolog_system_to_activate: 
				monolog_system_to_activate.start()
