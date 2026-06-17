extends StaticBody2D
class_name Door

const BLOCK_ACTIVATION_DELAY := 0.125

var is_open: bool = false
var door_blocks: Array[DoorBlock] = []

var activation_timer: Timer = Timer.new()
var next_block_index: int = 0


func _ready() -> void:
	for child: Node in get_children():
		if child is DoorBlock:
			door_blocks.append(child as DoorBlock)

	activation_timer.wait_time = BLOCK_ACTIVATION_DELAY
	add_child(activation_timer)

	activation_timer.timeout.connect(_on_activation_timer_timeout)


func _on_activation_timer_timeout() -> void:
	activate_next_block()
	next_block_index += 1


func activate_next_block() -> void:
	if next_block_index >= door_blocks.size():
		activation_timer.stop()
		return

	door_blocks[next_block_index].activate(true)


func interact(should_open: bool) -> void:
	if should_open == is_open:
		return

	is_open = should_open

	if should_open:
		activation_timer.start()
	else:
		reset_door()


func reset_door() -> void:
	activation_timer.stop()
	next_block_index = 0

	for block: DoorBlock in door_blocks:
		block.activate(false)
