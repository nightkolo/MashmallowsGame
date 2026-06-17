extends MarginContainer


@onready var keyboard: TextureRect = $HBoxContainer/Keyboard
@onready var controller: TextureRect = $HBoxContainer/Controller

# TODO: Add controller and keyboard detection

func _ready() -> void:
	#controller.self_modulate = Color(Color.WHITE * 0.1, 1.0)
	#keyboard.self_modulate = Color(Color.WHITE * 0.1, 1.0)
	
	controller.visible = false
