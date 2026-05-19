extends Control
class_name SpeechBubble

@onready var bubble: MarginContainer = %BubbleContainer
@onready var label_container: MarginContainer = $LabelContainer
@onready var label: RichTextLabel = %MonologLabel
@onready var monolog_arrow: Node2D = $Arrow
@onready var spiral: Sprite2D = %MaskedSpiral

@onready var circle: Sprite2D = %Circle
@onready var masked_arrow: Sprite2D = %MaskedArrow
@onready var pointing: Sprite2D = %Arrow
@onready var pointing_2: Sprite2D = %Arrow2
@onready var arrow: Node2D = $Arrow

@onready var options: HBoxContainer = $MonologOptions
@onready var choice1: Button = %Choice1
@onready var choice2: Button = %Choice2

var p_pos_1: float
var p_pos_2: float

func _ready() -> void:
	p_pos_1 = pointing.position.x
	p_pos_2 = pointing_2.position.x
	
	bubble.scale = Vector2.ZERO
	bubble.modulate = Color(Color.WHITE, 0.0)
	arrow.modulate = Color(Color.WHITE, 0.0)
	visible = false
	
	bubble.resized.connect(func():
		options.position = Vector2(-bubble.size.x / 2.0, bubble.size.y / 2.0)
		options.position -= options.size * 0.5
	)

	var tween := create_tween().set_loops()
	
	tween.tween_property(spiral, "rotation", -PI, 1.0).as_relative()


func anim_arrows_pop_up():
	var dur := 0.25
	
	arrow.modulate = Color(Color.WHITE, 0.0)
	pointing.position.x = p_pos_1 + 50.0
	pointing_2.position.x = p_pos_2- 50.0
	
	var tween := create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(pointing,"position:x",p_pos_1,dur)
	tween.tween_property(pointing_2,"position:x",p_pos_2,dur)
	tween.tween_property(arrow,"modulate",Color(Color.WHITE, 1.0),dur)
	
	tween.chain().tween_callback(anim_arrow_idle)

func anim_arrows_pop_out(dur: float = 0.25):
	
	if tween_circle:
		tween_circle.kill()
	if tween_idle:
		tween_idle.kill()
		
	var tween := create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(pointing,"position:x",p_pos_1 - 100.0,dur)
	tween.tween_property(pointing_2,"position:x",p_pos_2 + 100.0,dur)
	tween.tween_property(arrow,"modulate",Color(Color.WHITE, 0.0),dur)
	
	
func show_bubble() -> void:
	visible = true
	
	anim_pop_up()
	await get_tree().create_timer(0.25).timeout
	anim_arrows_pop_up()


func hide_bubble() -> void:
	var dur := 0.5
	
	anim_pop_out(dur)
	anim_arrows_pop_out(dur / 2.0)
	
	await get_tree().create_timer(dur).timeout
	
	visible = false


func anim_pop_up():
	var dur := 2.0
	
	bubble.scale = Vector2.ZERO
	bubble.modulate = Color(Color.WHITE, 0.0)
	
	var tween := create_tween().set_parallel()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	tween.tween_property(bubble,"scale:x",1.0,dur)
	tween.tween_property(bubble,"scale:y",1.0,dur).set_delay(dur / 13.33)
	tween.tween_property(bubble, "modulate", Color(Color.WHITE, 1.0), dur * 0.25).set_trans(Tween.TRANS_LINEAR)

func anim_pop_out(dur: float = 0.5):
	bubble.scale = Vector2.ONE
	bubble.modulate = Color(Color.WHITE, 1.0)
	
	var tween := create_tween().set_parallel()
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(bubble,"scale:x",0.0,dur).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(bubble,"scale:y",0.0,dur).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(bubble, "modulate", Color(Color.WHITE, 0.0), 2.0*dur)

var tween_idle: Tween

func anim_arrow_idle():
	var dur := 0.125
	var mag := 6.0
	var pause := 1.0
	
	anim_circle_idle(dur, pause)
	
	if tween_idle:
		tween_idle.kill()
		
	tween_idle = create_tween().set_loops().set_parallel()
	tween_idle.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	tween_idle.tween_property(pointing, "position:x", p_pos_1 - mag, dur)
	tween_idle.tween_property(pointing_2, "position:x", p_pos_2 + mag, dur)
	tween_idle.chain().tween_property(pointing, "position:x", p_pos_1, dur)
	tween_idle.tween_property(pointing_2, "position:x", p_pos_2, dur)
	
	tween_idle.chain().tween_property(pointing, "position:x", p_pos_1 - mag, dur)
	tween_idle.tween_property(pointing_2, "position:x", p_pos_2 + mag, dur)
	tween_idle.chain().tween_property(pointing, "position:x", p_pos_1, dur)
	tween_idle.tween_property(pointing_2, "position:x", p_pos_2, dur)
	
	## PAUSE
	tween_idle.chain().tween_property(pointing, "position:x", p_pos_1, pause)
	
var tween_circle: Tween

func anim_circle_idle(dur: float, pause: float):
	var mag := 0.125
	
	if tween_circle:
		tween_circle.kill()
		
	tween_circle = create_tween().set_loops()
	tween_circle.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	tween_circle.tween_property(circle, "scale", 0.5 * Vector2(1.0 - mag, 1.0 + mag), dur)
	tween_circle.tween_property(circle, "scale", 0.5 * Vector2.ONE, dur)
	tween_circle.tween_property(circle, "scale", 0.5 * Vector2(1.0 - (mag * 1.25), 1.0 + (mag * 1.25)), dur)
	tween_circle.tween_property(circle, "scale", 0.5 * Vector2.ONE, dur + pause).set_trans(Tween.TRANS_ELASTIC)
	
	
func anim_next_monolog_arrow():
	var mag := 0.35
	
	if tween_circle:
		tween_circle.kill()
	if tween_idle:
		tween_idle.kill()
	
	pointing.position.x = p_pos_1
	pointing_2.position.x = p_pos_2
	circle.scale = 0.5 * Vector2.ONE
	
	var tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	tween.tween_callback(anim_arrow)
	tween.tween_property(circle, "scale", 0.5 * Vector2(1.0 - mag, 1.0 + mag), 0.07)
	tween.tween_property(pointing, "position:x", p_pos_1 - (mag * 50.0), 0.07)
	tween.tween_property(pointing_2, "position:x", p_pos_2 + (mag * 50.0), 0.07)
	
	tween.chain().tween_property(circle, "scale", 0.5 * Vector2.ONE, 1.0).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(pointing, "position:x", p_pos_1, 1.0).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(pointing_2, "position:x", p_pos_2, 1.0).set_trans(Tween.TRANS_ELASTIC)
	
	tween.chain().tween_callback(anim_arrow_idle)

func anim_arrow():
	var tween := create_tween()
	#tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(masked_arrow, "position:y", 60.0, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		masked_arrow.position.y = -60.0
		)
	tween.tween_property(masked_arrow, "position:y", 60.0, 0.125).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(func():
		masked_arrow.position.y = -60.0
		)
	tween.tween_property(masked_arrow, "position:y", 6.0, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
