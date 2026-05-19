extends Control

@onready var start_btn: Button = %StartBtn
@onready var spotlight: Sprite2D = $Spotlight


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameMgr.menu_entered.emit(GameMgr.Menus.START)
	
	start_btn.grab_focus()
	start_btn.pressed.connect(start_game)
	
	var t := create_tween().set_loops()
	
	t.tween_property(spotlight, "rotation", -PI, 30.0).as_relative()
	


func start_game() -> void:
	Trans.slide_to_scene("res://world/levels/level_1.tscn", 0.25)
