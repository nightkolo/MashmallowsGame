extends Node
class_name Util

enum MashType {
	WHITE = 0,
	STAR = 1,
	CHOCO = 2,
	HEART = 3,
	PLAYER = 99,
	CHERRY_BOMB = 100,
	AIR_CHERRY_BOMB = 101,
	TWISTED = 102,
	MISC = 999
}
enum BuildType {
	SQUARE = 0,
	RECTANGLE = 1
}

const MASH_WAIT_TIME = 0.5
const ORDER_COMPLETE_WAIT_TIME = 1.0

const NUMBER_OF_LEVELS = 20

const NUMBER_OF_WORLDS = 2
const LEVEL_FILE_BEGIN = "res://world/levels/main/level_"
const LEVEL_FILE_END = ".tscn"

const CHERRY_BOMB_WAITTIME = 0.125

const BLOCK_SIZE = 64.0
const GRAVITY_MULT = 4.0

# var UNMASHED_OBJECT = preload("res://object/objects/block_unmashed_1x1.tscn")
# var UNMASHED_OBJECT_1x2 = preload("res://object/objects/block_unmashed_1x2.tscn")


# static func get_unmashed_object(type: Util.BuildType) -> Unmashed:
# 	match type:
# 		Util.BuildType.SQUARE:
# 			return UNMASHED_OBJECT.instantiate()
# 		Util.BuildType.RECTANGLE:
# 			return UNMASHED_OBJECT_1x2.instantiate()
# 		_:
# 			return null


const bg_w1: Array[Color] = [
	Color(1.0, 1.0, 0.56),
	Color(1.0, 1.0, 0.5)
]
const bg_w2: Array[Color] = [
	Color(1.0, 0.767, 1.0, 1.0)
]

static func set_block_code(arr: Array[Dictionary], block: BlockAttributes, node: Node2D) -> void:
	arr.clear()
	arr.append({
		"type": block.mash_type,
		"pos": Vector2(
			node.position.x / Util.BLOCK_SIZE,
			node.position.y / Util.BLOCK_SIZE
		),
		"ref": node
	})
	

static func get_bg_color_set(p_set: World.BGcolors) -> Color:
	var col: Color
	## TODO: Make selectable variants
	match p_set:
		
		World.BGcolors.WORLD_1:
			col = bg_w1.pick_random()
		
		World.BGcolors.WORLD_2:
			col = bg_w2.pick_random()
	
	return col
	
 
static func setup_block() -> void:

	pass

## Returns true if two Vector2s are approximately equal within a tolerance.
static func is_equal_approx_vec2(a: Vector2, b: Vector2, tolerance: float = 0.0001) -> bool:
	return a.distance_to(b) <= tolerance


## Returns true if two floats are approximately equal within a tolerance.
static func is_equal_approx_custom(a: float, b: float, tolerance: float = 0.0001) -> bool:
	return abs(a - b) <= tolerance

static func disable_buttons(btns: Array[Node], disable: bool = true) -> void:
	for btn: Button in btns:
		if !(btn is Button):
			continue
			
		btn.disabled = disable

## Maps a Vector2 value from one range (input space) to another (output space).
##
## This performs a linear remapping:
## - `value` is assumed to be within the range [`in_min`, `in_max`]
## - It will be proportionally converted into the range [`out_min`, `out_max`]
static func map_range(value: Vector2, in_min: Vector2, in_max: Vector2, out_min: Vector2, out_max: Vector2) -> Vector2: ## @dreprecated: Use [Math]
	return out_min + ((value - in_min) / (in_max - in_min)) * (out_max - out_min)


static func round_to_dec(num: float, decimals: int) -> float: ## @dreprecated: Use [Math]
	return roundf(num * pow(10.0, decimals)) / pow(10.0, decimals)


static func get_highest_axis(vec: Vector2) -> Vector2: ## @dreprecated: Use [Math]
	if absf(vec.x) > absf(vec.y):
		return Vector2(signf(vec.x), 0.0)
	else:
		return Vector2(0.0, signf(vec.y))

static func get_direction(dir: String) -> Vector2: ## @dreprecated: Use [Math]
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


static func get_order_block_texture(type: MashType, build: BuildType, satisfied: bool = false) -> Texture2D:
	if type == MashType.PLAYER:
		return preload("res://assets/interface/order-player.png")

	var l_name := str(MashType.find_key(type)).to_lower()
	var build_str := "1x2" if build == BuildType.RECTANGLE else "1x1"
	var color_suffix := "" if satisfied else "-grey"

	var path := "res://assets/interface/order-%s-%s%s.png" % [
		l_name, build_str, color_suffix
	]

	return load(path)


static func get_mash_type_shade_texture(type: MashType, build: BuildType) -> Texture2D:

	var l_num := "02" if type == MashType.HEART else "01"
	var build_str := "1x2" if build == BuildType.RECTANGLE else "1x1"

	var path := "res://assets/objects/block-shade-%s-%s.png" % [
		build_str, l_num
	]

	return load(path)

static func get_mash_type_texture(type: MashType, build: BuildType) -> Texture2D:
	# Special cases first (they break the pattern)
	match type:
		MashType.PLAYER:
			return preload("res://assets/objects/block-player.png")
		MashType.CHERRY_BOMB:
			return preload("res://assets/objects/block-cherry-bomb.png")
		MashType.AIR_CHERRY_BOMB:
			return preload("res://assets/objects/block-cherry-bomb-air.png")
		MashType.TWISTED:
			return preload("res://assets/objects/block-twisted-1x1.png")

	var l_name := str(MashType.find_key(type)).to_lower()
	var build_str := "1x2" if build == BuildType.RECTANGLE else "1x1"

	var path := "res://assets/objects/block-%s-%s.png" % [
		l_name, build_str
	]

	return load(path)


## @deprecated
static func get_mash_type_color(type: Util.MashType, build: Util.BuildType) -> Color:
	var col: Color
	
	match type:
		Util.MashType.WHITE:
			col = Color.WHITE * 1.5
			
		Util.MashType.STAR:
			col = Color.YELLOW
			
		Util.MashType.CHOCO:
			col = Color.GRAY
			
		Util.MashType.HEART:
			col = Color.DARK_GREEN
			
		Util.MashType.PLAYER:
			col = Color.WHITE * 3
			
	return col
