@tool
extends Control
class_name LevelInfo

signal letter_showing_started()
signal letter_showing_finished()

@onready var monolog_label: RichTextLabel = %MonologLabel
@onready var bubble: MarginContainer = %BubbleContainer

@export_multiline() var level_info: String = "Mash the [M][color=yellow]Marshmallows[/color] to fulfill the order!":
	set(value):
		%MonologLabel.text = BBcode_default + value
		
		level_info = value
@export var show_sprites: Array[Node2D]
@export var BBcode_default: String = "[b][font_size=21.0]"
@export var box_pop_up_time: float = 2.4
@export var letter_time: float = 0.04
@export var space_time: float = 0.08
@export var punctuation_time: float = 0.32
@warning_ignore("unused_private_class_variable")
@export_tool_button("Animate", "Animation") var _animate = animate_node


func animate_node():
	start()
	

var _letter_index: int
var displayed_text: String
var _letter_show_timer: Timer = Timer.new()
var is_showing_text: bool

var area: Area2D = Area2D.new()
var colli: CollisionShape2D = CollisionShape2D.new()
var tween_fade: Tween

func _ready() -> void:
	_letter_show_timer.one_shot = true
	add_child(_letter_show_timer)
	
	for node: Node2D in show_sprites:
		node.modulate = Color(Color.WHITE, 0.0)

	monolog_label.visible_characters = 0
	bubble.scale = Vector2.ONE * 0.5
	bubble.modulate = Color(Color.WHITE, 0.0)
	%InfoSpriteNode.visible = false

	_letter_show_timer.timeout.connect(_show_letter)
	letter_showing_finished.connect(func():
		is_showing_text = false
		)
	
	colli.shape = RectangleShape2D.new()
	(colli.shape as RectangleShape2D).size = bubble.size
	area.add_child(colli)
	area.collision_layer = 0
	area.collision_mask = 2 # Player layer
	area.position = bubble.size * 0.5
	add_child(area)
	area.body_entered.connect(func(_nody: Node2D):
		if tween_fade:
			tween_fade.kill()
		tween_fade = create_tween()
		tween_fade.tween_property(self, "modulate", Color(Color.WHITE, 0.5), 0.2)
		)
	area.body_exited.connect(func(_nody: Node2D):
		if tween_fade:
			tween_fade.kill()
		tween_fade = create_tween()
		tween_fade.tween_property(self, "modulate", Color(Color.WHITE, 1.0), 0.2)
		)
		

func start() -> void:
	if !Engine.is_editor_hint():
		Audio.level_info.play()

	anim_show()
	anim_info_sprite()
	anim_sprite()
	show_text(level_info)


func anim_sprite():
	if show_sprites.is_empty():
		return

	await get_tree().create_timer(0.25).timeout

	var tween := create_tween()
	
	for node: Node2D in show_sprites:
		tween.tween_property(node, "modulate", Color(Color.WHITE, 1.0), 1.0)


func anim_info_sprite() -> void:

	var tween:= create_tween().set_loops()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	var info_sprite := %InfoSprite
	tween.tween_property(info_sprite, "rotation_degrees", -10.0, 1.0)
	tween.tween_property(info_sprite, "rotation_degrees", 10.0, 1.0)


func anim_show():
	# What the hell was I thinking...

	var dur := box_pop_up_time
	
	%InfoSpriteNode.visible = true

	bubble.scale = Vector2.ONE * 0.0
	bubble.modulate = Color(Color.WHITE, 0.0)

	var info_sprite := %InfoSprite
	info_sprite.visible = true
	info_sprite.position = Vector2( bubble.size.x / 2, 0.0)

	var tween := create_tween().set_parallel()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	tween.tween_property(bubble,"scale:y",1.0,dur)
	tween.tween_property(bubble,"scale:x",1.0,dur).set_delay(dur / 13.33)

	tween.tween_property(info_sprite,"position:y",bubble.size.y - 30.0,dur)
	tween.tween_property(info_sprite,"position:x",bubble.size.x,dur).set_delay(dur / 13.33)

	tween.tween_property(bubble, "modulate", Color(Color.WHITE, 1.0), dur * 0.05).set_trans(Tween.TRANS_LINEAR)



func show_text(text_to_show: String) -> void:
	_letter_index = 0

	monolog_label.text = BBcode_default + text_to_show
	displayed_text = monolog_label.get_parsed_text()
	
	_show_letter()
	
	letter_showing_started.emit()
		
	is_showing_text = true


func _show_letter() -> void:
	monolog_label.visible_characters = _letter_index + 1
	
	_letter_index += 1
	
	if _letter_index < displayed_text.length():
		var current_letter := displayed_text[_letter_index]
		
		#play_speech(displayed_text[_letter_index])
		
		match current_letter:
			
			"!", ",", "?":
				_letter_show_timer.start(punctuation_time)
				
			" ":
				_letter_show_timer.start(space_time)
			
			".":
				_letter_show_timer.start(letter_time)
			
			_:
				_letter_show_timer.start(letter_time)
					
	else:
		letter_showing_finished.emit()
