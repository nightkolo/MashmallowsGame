extends Camera2D
class_name Cam

## @experimental
@export var dynamic_cam: bool = true
@export var dynamic_effect: float = 1.03:
	set(value):
		dynamic_effect = value


var cam_min: Vector2
var cam_max: Vector2

var p_min: Vector2 = Vector2.ZERO
var p_max: Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
	)


func _ready():
	GameMgr.current_camera = self
	
	GameLogic.cherry_bomb_exploded.connect(func():
		shake(16.0, 5.0)
		)
	
	if dynamic_cam:
		zoom = zoom * dynamic_effect
		cam_min = position / dynamic_effect
		cam_max = position * dynamic_effect


var shake_strength := 0.0
var shake_fade := 5.0

func shake(strength: float, fade: float):
	shake_strength = strength
	shake_fade = fade


func _process(delta: float) -> void:
	if GameMgr.current_player && dynamic_cam:
		position = Util.map_range(
			GameMgr.current_player.global_position,
			p_min,
			p_max,
			cam_min,
			cam_max
		)
		
	if shake_strength > 0:
		offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)

		shake_strength = lerp(shake_strength, 0.0, shake_fade * delta)
	else:
		offset = Vector2.ZERO
