## @deprecated
## Check if all [BlockMashChecker]s are satisfied
## Gameplay check actor
extends Node2D
class_name OrderChecker

var order_blocks: Array[Node]


func _ready() -> void:
	visible = true
	
	GameMgr.current_order_checker = self
	GameLogic.order_check_ori_pos = global_position


## Returns the number of satisfied order blocks.
func check_satisfaction_full() -> int: # Always -> O(n)
	var value: int = 0
	
	for block: MashBlockChecker in order_blocks:
		if block.check_satisfaction():
			value += 1
			
	return value


## Checks if all order blocks are satisfied, if not, early returns [code]false[/code].
func check_satisfaction() -> bool: # Ok -> O(n), Worst case -> O(n^2)
	for block: MashBlockChecker in order_blocks:
		if !block.check_satisfaction():
			return false
			
	return true
	
