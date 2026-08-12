extends StaticBody2D
class_name DecoBlock

@export var text: String = ""

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	if text != "":
		
		sprite.texture = get_sprite_texture(text)

func get_sprite_texture(s: String) -> Texture2D:
	return load("res://assets/world/terrain-deco-%s.png" % s)
