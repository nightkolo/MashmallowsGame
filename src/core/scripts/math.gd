extends Node
class_name Math



## Returns true if two Vector2s are approximately equal within a tolerance.
static func is_equal_approx_vec2(a: Vector2, b: Vector2, tolerance: float = 0.0001) -> bool:
	return a.distance_to(b) <= tolerance


## Returns true if two floats are approximately equal within a tolerance.
static func is_equal_approx_custom(a: float, b: float, tolerance: float = 0.0001) -> bool:
	return abs(a - b) <= tolerance
	

## Maps a Vector2 value from one range (input space) to another (output space).
##
## This performs a linear remapping:
## - `value` is assumed to be within the range [`in_min`, `in_max`]
## - It will be proportionally converted into the range [`out_min`, `out_max`]
static func map_range(value: Vector2, in_min: Vector2, in_max: Vector2, out_min: Vector2, out_max: Vector2) -> Vector2:
	return out_min + ((value - in_min) / (in_max - in_min)) * (out_max - out_min)


static func round_to_dec(num: float, decimals: int) -> float:
	return roundf(num * pow(10.0, decimals)) / pow(10.0, decimals)


static func get_highest_axis(vec: Vector2) -> Vector2:
	if absf(vec.x) > absf(vec.y):
		return Vector2(signf(vec.x), 0.0)
	else:
		return Vector2(0.0, signf(vec.y))

static func get_direction(dir: String) -> Vector2:
	dir = dir.to_lower()
	
	if dir.contains("up"):
		return Vector2.UP
	elif dir.contains("down"):
		return Vector2.DOWN
	elif dir.contains("left"):
		return Vector2.LEFT
	elif dir.contains("right"):
		return Vector2.RIGHT
	
	return Vector2.ZERO
