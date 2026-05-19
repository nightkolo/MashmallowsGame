extends Area2D
class_name Switch

signal switch_activated(is_on: bool)

@export var door_to_interact_with: Door

@onready var sprite_base: Sprite2D = $Base ## Placeholder

var is_activated: bool


func _ready() -> void:
	body_entered.connect(_try_interact)
	body_exited.connect(_try_interact)


func interact(switch_on: bool = !is_activated) -> void:
	is_activated = switch_on
	door_to_interact_with.interact(switch_on)
	
	switch_activated.emit(switch_on)

	
func _try_interact(_body: Node2D) -> void:
	interact(get_overlapping_bodies().size() > 0)
