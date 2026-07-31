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
const ORDER_COMPLETE_WAIT_TIME_BEFORE_TRANSITION = 1.0

const NUMBER_OF_DEMO_LEVELS = 10
const NUMBER_OF_LEVELS = 20

const NUMBER_OF_BAKERIES = 2
const LEVEL_FILE_BEGIN = "res://world/levels/main/level_"
const LEVEL_FILE_END = ".tscn"

const CHERRY_BOMB_WAITTIME_BEFORE_EXPLODING = 0.125

const BLOCK_SIZE = 64.0
const GRAVITY_MULT = 4.0



const bg_b1: Array[Color] = [
	Color(1.0, 1.0, 0.56),
	Color(1.0, 1.0, 0.5)
]
const bg_b2: Array[Color] = [
	Color(1.0, 0.767, 1.0, 1.0)
]

static func get_bakery_number(lvl_id: int) -> int:
	@warning_ignore("integer_division")
	return ((lvl_id - 1) / 10) + 1


static func set_block_code(arr: Array[Dictionary], block: BlockAttributes, node: Node2D) -> void:
	#arr.clear()
	arr.append({
		"type": block.mash_type,
		"build": block.build_type,
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
			col = bg_b1.pick_random()
		
		World.BGcolors.WORLD_2:
			col = bg_b2.pick_random()
	
	return col



static func disable_buttons(btns: Array[Node], disable: bool = true) -> void:
	for btn: Button in btns:
		if !(btn is Button):
			continue
			
		btn.disabled = disable


static func get_order_block_texture(type: MashType, build: BuildType, satisfied: bool = false) -> Texture2D:
	if type == MashType.PLAYER:
		return preload("res://assets/interface/order-player.png")

	var l_name := str(MashType.find_key(type)).to_lower()
	
	var build_str := "1x2" if build == BuildType.RECTANGLE else "1x1"
	var color_suffix := "-02" if satisfied else "-grey"

	var path := "res://assets/interface/order-%s-%s%s.png" % [
		l_name, build_str, color_suffix
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
