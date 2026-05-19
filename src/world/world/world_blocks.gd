extends Node2D
class_name WorldBlocks

var decos: Array[String] = ["choco", "heart", "star", "white"]


func _ready() -> void:
	for node: Node in get_children():
		if decos.is_empty():
			break

		if node is DecoBlock:
			var s: String = decos.pop_at( randi_range(0, decos.size() - 1) )

			(node as DecoBlock).sprite.texture = get_sprite_texture(s)	

	

func get_sprite_texture(s: String) -> Texture2D:
	return load("res://assets/world/terrain-deco-%s.png" % s)
