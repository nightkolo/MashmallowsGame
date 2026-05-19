## Checks a single [MashBlock] in [Mashed] 
extends Area2D
class_name MashBlockChecker

# Set by [Order]
var attributes: BlockAttributes
# @export var is_mash_type: Util.MashType
# @export var is_build_type: Util.BuildType
# @export var is_golden: bool
var corresponding_mash_block_id: MashBlockCheckerID
#

func _ready() -> void:
	if get_parent() is OrderChecker:
		(get_parent() as OrderChecker).order_blocks.append(self)
	
	collision_layer = 0
	collision_mask = 4
	
	
# Called by parent OrderChecker
func check_satisfaction() -> bool: # Ok -> O(1), worst case -> O(n)
	var value: bool = false
	var areas: Array[Area2D] = get_overlapping_areas()

	if areas.size() == 1 && areas[0] is MashBlock:
		
		value = (areas[0] as MashBlock).is_match(attributes)
	
	if corresponding_mash_block_id:
		corresponding_mash_block_id.anim_satisfied(value)
	
	return value
