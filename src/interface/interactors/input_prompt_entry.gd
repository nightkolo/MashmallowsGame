extends MarginContainer
class_name InputPromptUI

@onready var keyboard: TextureRect = $HBoxContainer/Keyboard
@onready var controller: TextureRect = $HBoxContainer/Controller


func _ready() -> void:
	controller.visible = false
