extends Node2D
class_name Terrain


func _ready():
	var children: Array[Node] = get_children()

	# I'm so lazy lol

	if children.size() > 1:
		var node := children[0]
		var node_2 := children[1]
		
		if node is Node2D:
			(node as Node2D).self_modulate = Color(Color.WHITE, 0.5)
		if node_2 is Node2D:
			(node_2 as Node2D).light_mask = 8
