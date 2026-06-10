## [b]Note:[/b] Set [member CanvasItem.texture_repeat] for this to work.
@tool
extends Sprite2D
class_name TiledSprite2D
	
	
@export var animate_scroll: bool = false:
	set(value):
		set_process(value)
		if value:
			region_enabled = true
		else:
			_pos = Vector2.ZERO
			region_rect = Rect2(Vector2.ZERO, _init_size)
		animate_scroll = value
		notify_property_list_changed()
@export_range(0, 360, 1.0, "radians_as_degrees") var scroll_trajectory: float = 45.0
@export_range(-100.0, 100, 0.1, "or_greater", "or_less") var scroll_speed: float = 50.0



func _ready() -> void:
	_init_node_size = scale


func _validate_property(property: Dictionary):
	var hidden_properties: Array[String] = ["scroll_trajectory", "scroll_speed"]
	
	_init_size = region_rect.size
	
	_init_node_size = scale
	
	if animate_scroll == false:
		for p: String in hidden_properties:
			if property.name == p:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		
		
var _init_size: Vector2
var _init_node_size: Vector2
var _pos: Vector2:
	set(value):
		var p := pow(2.0, 64.0)
		if value.x > p || value.y > p:
			_pos = Vector2.ZERO
		_pos = value


func _animate_scroll(delta: float) -> void:
	var deg: float = scroll_trajectory
	var direction: Vector2 = Vector2(cos(deg), sin(deg))
	
	_pos += direction * scroll_speed * delta
	
	region_rect = Rect2(_pos, region_rect.size)
	#global_scale = _init_node_size


func _process(delta: float) -> void:
	if animate_scroll:
		_animate_scroll(delta)
