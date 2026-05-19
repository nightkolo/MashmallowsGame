extends Node2D
class_name Terrain


func _ready():
	var children: Array[Node] = get_children()

	if children.size() == 2:
		var node := children[0]
		
		if node is Node2D:
			(node as Node2D).self_modulate = Color(Color.WHITE, 0.5)