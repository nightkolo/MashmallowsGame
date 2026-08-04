extends Line2D
class_name Trail
 
@export var max_length: int = 60
@export var trail_enabled: bool = true
@export var exit_on_empty: bool = true

var target: Node2D
var queue: Array:
	set(value):
		visible = !value.is_empty()
		
		queue = value

var timer: Timer = Timer.new()



func _ready() -> void:
	if !exit_on_empty && get_parent() is Mashed:
		target = get_parent() as Mashed
		
	timer.one_shot = false
	timer.wait_time = 0.04
	timer.timeout.connect(func():
		if !queue.is_empty():
			queue.pop_back()
		elif exit_on_empty:
			queue_free()
		)
	add_child(timer)
	timer.start()


func _process(_delta: float) -> void:
	if trail_enabled && target && queue.size() < max_length:
		queue.push_front(target.global_position)
 
	clear_points()
	
	for point: Vector2 in queue:
		add_point(point)
 

#var MAX_LENGTH = 30
#
#func generic():
	#var pos = target.global_position
 #
	#queue.push_front(pos)
 #
	#if queue.size() > MAX_LENGTH:
		#queue.pop_back()
 #
	#clear_points()
 #
 #
	#for point in queue:
		#add_point(point)
 
#func _get_position():
	#return get_global_mouse_position()
