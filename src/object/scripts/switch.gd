extends Area2D
class_name Switch

signal switch_activated(is_on: bool)

@export var door_to_interact_with: Door

@onready var sprite_head: Sprite2D = $Head ## Placeholder

var is_activated: bool


func _ready() -> void:
	body_entered.connect(_try_interact)
	body_exited.connect(_try_interact)


func interact(switch_on: bool = !is_activated) -> void:
	if is_activated == switch_on:
		return
	
	is_activated = switch_on
	door_to_interact_with.interact(switch_on)
	
	switch_activated.emit(switch_on)
	
	anim_psuh()

	
func _try_interact(_body: Node2D) -> void:
	interact(get_overlapping_bodies().size() > 0)

var tween_psuh: Tween

func anim_psuh():
	if tween_psuh:
		tween_psuh.kill()
		
	tween_psuh= create_tween()
	
	if is_activated:
		tween_psuh.tween_property(sprite_head, "scale:y", 0.1, 0.1)
	else:
		tween_psuh.tween_property(sprite_head, "scale:y", 0.5, 0.3)
