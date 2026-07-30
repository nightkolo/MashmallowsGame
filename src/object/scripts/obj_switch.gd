extends Area2D
class_name Switch

signal switch_activated(is_on: bool)

@export var door_to_interact_with: Door

@onready var sprite_head: Sprite2D = $Head
@onready var drop: AudioStreamPlayer2D = $Audio/Drop
@onready var lift: AudioStreamPlayer2D = $Audio/Lift

var is_activated: bool
var interact_timer: Timer = Timer.new()


func _ready() -> void:
	interact_timer.wait_time = 0.05
	interact_timer.one_shot = true
	add_child(interact_timer)
	
	interact_timer.timeout.connect(_try_interact)
	
	body_entered.connect(start_timer)
	body_exited.connect(start_timer)


func start_timer(_body: Node2D) -> void:
	if interact_timer.is_stopped():
		interact_timer.start()
	else:
		interact_timer.stop()
		interact_timer.start()


func interact(switch_on: bool = !is_activated) -> void:
	if is_activated == switch_on:
		return
	
	if door_to_interact_with == null:
		push_error("door_to_interact_with not assigned, it's %s" % door_to_interact_with)
		return
	
	is_activated = switch_on
	door_to_interact_with.interact(switch_on)
	
	switch_activated.emit(switch_on)
	
	anim_psuh()

	
func _try_interact() -> void:
	interact(get_overlapping_bodies().size() > 0)


var tween_psuh: Tween

func anim_psuh():
	if tween_psuh:
		tween_psuh.kill()
		
	tween_psuh= create_tween()
	
	if is_activated:
		drop.play()
		tween_psuh.tween_property(sprite_head, "scale:y", 0.1, 0.1)
	else:
		lift.play()
		tween_psuh.tween_property(sprite_head, "scale:y", 0.5, 0.3)
