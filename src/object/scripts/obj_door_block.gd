extends CollisionShape2D
class_name DoorBlock

@export var pop_text_1: Texture = preload("res://assets/world/pop-02.png")
@export var pop_text_2: Texture = preload("res://assets/world/pop-03.png")

@export var eye_text_reg: Texture = preload("res://assets/objects/bubblegate-eyes-reg.png")
@export var eye_text_closed: Texture = preload("res://assets/objects/bubblegate-eyes-closed.png")

@onready var sprite_node: Node2D = $Sprite2
@onready var sprite_inflators: Sprite2D = %Inflators
@onready var sprite_bubble: Sprite2D = %Bubble
@onready var sprite_eye: Sprite2D = %Eye

var is_activated: bool:
	get:
		return is_activated
	set(value):
		#if value != is_activated:
			#activate(value)
		is_activated = value
var is_popping: bool



func _ready() -> void:
	pass
	#if get_parent() is Door:
		#(get_parent() as Door).door_blocks.append(self)
		#
		
		

func activate(p_activate: bool) -> void:
	set_deferred("disabled", p_activate)
	
	if p_activate:
		sprite_node.modulate = Color(Color.WHITE, 0.5)
	else:
		sprite_node.modulate = Color(Color.WHITE, 1.0)
