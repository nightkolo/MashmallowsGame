@tool
extends Node2D
class_name InputPrompt

@export var character: String:
	set(value):
		character = value
		%Label.text = value
@export var blink_time : float = 2.0
@export var blink_interval : float = 1.0
@onready var masked_spiral: Sprite2D = %Spiral
@onready var base: Node2D = %Base


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween := create_tween().set_loops()
	
	tween.tween_property(masked_spiral, "rotation", -PI, 1.0).as_relative()

	var tween_b := create_tween().set_loops()

	tween_b.tween_property(base, "position:y", 10.0, 0.1)
	tween_b.tween_property(base, "position:y", -2.0, 0.1) 
	if blink_interval > 0.0:
		tween_b.tween_interval(randf_range(blink_time - blink_interval, blink_time + blink_interval))
	else:
		tween_b.tween_interval(blink_time)
