extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var n = -3 * 64
	print_debug(n % 64 == 0)
	
	print_debug(n / 64.0)
