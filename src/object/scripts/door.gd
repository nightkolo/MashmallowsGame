extends StaticBody2D
class_name Door

var is_openned: bool

var door_blocks: Array[DoorBlock]

var timer: Timer = Timer.new()

func _ready() -> void:
	for node: Node in get_children():
		if node is DoorBlock:
			door_blocks.append(node as DoorBlock)
	
	timer.wait_time = 0.125
	add_child(timer)
	timer.timeout.connect(func():
		print_debug("Timer timeout")
		chain_activate()
		_index += 1
		)
var _index: int = 0

func chain_activate() -> void:
	if _index >= door_blocks.size():
		timer.stop()
		return
		
	door_blocks[_index].activate(true)


func interact(open: bool) -> void:
	if open == is_openned:
		return
		
	is_openned = open
	
	if open:
		## Start
		timer.start()
	else:
		## Reset
		timer.stop()
		
		_index = 0
		for block: DoorBlock in door_blocks:
			block.activate(false)
			
