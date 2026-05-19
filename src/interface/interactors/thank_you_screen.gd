extends Control

@onready var start_btn: Button = %StartBtn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameMgr.menu_entered.emit(GameMgr.Menus.MISC)
	
	start_btn.pressed.connect(func():
		get_tree().change_scene_to_file("res://interface/menus/menu_start.tscn")
		)
