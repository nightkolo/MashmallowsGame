extends CanvasLayer

@onready var state_label: Label = %StateLabel


func _process(delta: float) -> void:
	var s = GameMgr.current_main_player.state_machine.current_state
	
	state_label.text = "STATE: " + str(s)
