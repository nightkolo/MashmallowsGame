@tool
extends Resource
class_name BlockAttributes

# signal attribute_set()

# enum Mash {
# 	WHITE = 0,
# 	STAR = 1,
# 	CHOCO = 2,
# 	HEART = 3,
# 	PLAYER = 99,
# 	CHERRY_BOMB = 100,
# 	AIR_CHERRY_BOMB = 101
# }
# enum Build {
# 	SQUARE = 0,
# 	RECTANGLE = 1
# }

@export var mash_type: Util.MashType:
	set(value):
		# attribute_set.emit()
		# if is_node_ready():
		# 	$Visual/SpriteNode/Sprite2D.texture = Util.get_mash_type_texture(value, build_type)
		mash_type = value
@export var build_type: Util.BuildType:
	set(value):
		# attribute_set.emit()
		# if is_node_ready():
		# 	$Visual/SpriteNode/Sprite2D.texture = Util.get_mash_type_texture(mash_type, value)
		build_type = value
