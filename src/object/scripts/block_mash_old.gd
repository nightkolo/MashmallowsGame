## @deprecated
## Mash block in [Mashed]
extends Area2D
class_name MashBlock

var mash_type: Util.MashType
var build_type: Util.BuildType
var g: bool

var attributes: BlockAttributes

var parent_block: Mashed


func _ready() -> void:
	collision_layer = 4
	collision_mask = 0
	
	if get_parent() is Mashed:
		parent_block = get_parent() as Mashed
		await get_tree().create_timer(0.04).timeout
		
		attributes = parent_block.attributes
		# mash_type = parent_block.mash_type
		# build_type = parent_block.build_type
		# g = parent_block.is_golden

		parent_block.has_touched_flame.connect(func(flamed: bool):
			attributes.is_golden = flamed
		)

		GameLogic.ready_to_check.emit()


func is_match(att: BlockAttributes) -> bool:
	if parent_block:

		# print("")
		# print_debug(self)
		# print_debug(att.mash_type)
		# print_debug("Block mash type: " + str(self.parent_block.attributes.mash_type))
		# print_debug(att.build_type == attributes.build_type)
		# print_debug(att.is_golden == attributes.is_golden)
		var mash: Util.MashType = attributes.mash_type

		return (
			(mash != Util.MashType.CHERRY_BOMB || mash != Util.MashType.AIR_CHERRY_BOMB) &&
			att.mash_type == mash &&
			att.build_type == attributes.build_type &&
			att.is_golden == attributes.is_golden
			)
		
	return false
