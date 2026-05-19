@tool
extends Node2D
class_name Millie

# enum Animations {NA = 0, TEST = 99}

enum Emotes {InitialMatch = 0, Match = 1, Unmatch = 2, Scared = 3, Complete = 4}

enum Expressions {NEUTRAL, EXCITED, FRUSTRATED, BOUNCY, ASLEEP, BITTEN}

enum Eyes {REGULAR, HALF_CLOSED, SIDE_EYE, HAPPY, BLANK, WIDE_CLOSED, HEART_EYES, CLOSED}

@export var animate: bool = true:
	set(value):
		$AnimationTree.active = value
		animate = value
@export var emote: Emotes = Emotes.Match
@warning_ignore("unused_private_class_variable")
@export_tool_button("Emote", "Animation") var _animate2 = animate_emote
@export var expression: Expressions = Expressions.NEUTRAL:
	set(value):
		if value == expression:
			return
		var tree := $AnimationTree
		var is_neutral := value == Expressions.NEUTRAL

		tree.set("parameters/DanceBlend2/blend_amount",
			0.0 if value == Expressions.BOUNCY else 1.0
		)

		tree.set("parameters/Neutral2ExpressionBlend2/blend_amount",
			1.0 if is_neutral else 0.0
		)

		tree.set("parameters/BreathingAdd2/blend_amount",
			0.0 if value == Expressions.BITTEN else 1.0
		)

		if !is_neutral:
			tree.set("parameters/EarAnimBlend2/blend_amount",
				0.0 if value == Expressions.EXCITED else 1.0
			)

		if expression == Expressions.BITTEN && value != Expressions.BITTEN:
			%ExpressionRegen.play()
		
		anim_expression(value, Eyes.REGULAR, true)
		expression = value
@export var eyes: Eyes:
	set(value):
		if eyes == value:
			return
		
		var l_eyes := %Eyes

		for child: Node in l_eyes.get_children():
			child.visible = false

		var node := l_eyes.get_node_or_null(str(value + 1))
		if node:
			node.visible = true

		eyes = value
		
		# anim_bounce(0.055)
@export var show_outline: bool = false:
	set(value):
		if get_node_or_null("Outline"):
			$Outline.visible = value
		show_outline = value 
@export_group("Animation variables")
@export_range(0.0, 2.0, 0.05, "or_greater") var bounceness: float = 1.5
@export_range(0.0, 50.0, 0.05, "or_greater") var noise_extend: float = 25.0
@warning_ignore("unused_private_class_variable")
@export_tool_button("Animate Transition", "Animation") var _animate = animate_node
@export_category("Object to Assign")
@export var world: Node2D

@onready var visual_root: Node2D = $VisualRoot
@onready var outline: Node2D = $Outline

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var body: Node2D = %BodyAnimate
@onready var hoodie_heart: Polygon2D = %HoodieHeart
@onready var blue_face: Sprite2D = %Blue

var current_poly: PackedVector2Array
var poly_middle_point: Vector2 = Vector2(186.769, 160)

var ear_fall: PackedScene = preload("res://world/character/ear_fall.tscn")
var hair_fall: PackedScene = preload("res://world/character/hair_fall.tscn")

func animate_node():
	anim_expression(expression, eyes)


func animate_emote():
	anim_emote(emote)


func _ready() -> void:
	current_poly = hoodie_heart.polygon


var tween_spin: Tween
var tween_bounce: Tween
var tween: Tween
var tween_emote: Tween

var is_emoting: bool = false

var _special_vocal_played: bool = false

func play_yippie_vocal() -> void:
	await get_tree().create_timer(0.1).timeout

	if GameLogic.has_won:
		return

	if randf() < 0.25 || _special_vocal_played:
		%Vocal01.play()
		_special_vocal_played = false
	else:
		%VocalExcited.play()
		_special_vocal_played = true

func anim_emote(p_emote : Emotes = emote, bounce: bool = true):
	if p_emote == Emotes.Complete:
		expression = Expressions.BOUNCY
		return
	else:
		expression = Expressions.NEUTRAL
	
	if is_emoting:
		return
	is_emoting = true
	emote = p_emote

	## PRESET
	var delay := 0.055

	## Tween reset
	if tween_spin:
		tween_spin.kill()
	if tween:
		tween.kill()

	# TWEEN TRANSITION
	var l_poly: PackedVector2Array
	if bounce && p_emote != Emotes.Complete:
		l_poly = anim_bounce(delay)

	# CACHE
	var heart_eyes := %"7"
	var ear_l := %EarL
	var ear_r := %EarR
	var noise_face := %NoiseFace
	var head := %MillieHead

	# print_debug(p_emote)

	match p_emote:
		Emotes.Match:
			eyes = Eyes.HEART_EYES
			
			play_yippie_vocal()

			heart_eyes.scale = Vector2.ONE * 0.25
			heart_eyes.position.y = -30.0
			ear_l.position.y = -116.0+25.0
			ear_r.position.y = -116.0+25.0
			tween = create_tween().set_parallel(true)
			tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
			
			tween.tween_property(heart_eyes, "scale", 0.5 * Vector2.ONE, 1.1)
			tween.tween_property(heart_eyes, "position:y", -60.0, 1.28)
			tween.tween_property(ear_l, "position:y", -116.0, 1.28)
			tween.tween_property(ear_r, "position:y", -116.0, 1.28)

			tween.chain().tween_property(heart_eyes, "position:y", 0.0, 1.28)
			tween.tween_callback(func():
				eyes = Eyes.REGULAR
			)
			
		Emotes.InitialMatch:
			eyes = Eyes.HEART_EYES
			
			play_yippie_vocal()

			heart_eyes.scale = Vector2.ZERO
			heart_eyes.position.y = 0.0
			ear_l.position.y = -116.0+50.0
			ear_r.position.y = -116.0+50.0
			tween = create_tween().set_parallel(true)
			tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
			
			tween.tween_property(heart_eyes, "scale", 0.5 * Vector2.ONE, 1.1)
			tween.tween_property(heart_eyes, "position:y", -60.0, 1.28)
			tween.tween_property(ear_l, "position:y", -116.0, 1.28)
			tween.tween_property(ear_r, "position:y", -116.0, 1.28)

			tween.chain().tween_property(heart_eyes, "position:y", 0.0, 1.28)
			tween.tween_callback(func():
				eyes = Eyes.REGULAR
			)
		Emotes.Unmatch:
			eyes = Eyes.WIDE_CLOSED
			%VocalFrustrated.play()
			noise_face.visible = true
			head.self_modulate = Color(1.0, 0.7, 0.7, 1.0)
			ear_l.position.y = -116.0+25.0
			ear_r.position.y = -116.0+25.0
			tween_spin = create_tween().set_loops()
			tween_spin.tween_callback(gen_noise).set_delay(0.1)
			await anim_wobble(%Head, 2.0 * bounceness, 1.2)
			if tween_spin:
				tween_spin.kill()
			if tween:
				tween.kill()
			tween = create_tween().set_parallel(true)
			tween.tween_property(ear_l, "position:y", -116.0, 0.125)
			tween.tween_property(ear_r, "position:y", -116.0, 0.125)
			eyes = Eyes.REGULAR
			noise_face.visible = false
			head.self_modulate = Color(Color.WHITE, 1.0)
			
		Emotes.Scared:
			eyes = Eyes.BLANK
			%VocalFrustrated.play()

			blue_face.visible = true
			# blue_face.position.y = -540.0
			ear_l.position.y = -116.0+25.0
			ear_r.position.y = -116.0+25.0

			tween = create_tween().set_parallel(true)
			tween.tween_property(head, "self_modulate", Color(1.0, 0.0, 1.0), 0.8)
			# tween.tween_property(blue_face, "position:y", -540.0+300.0, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			await anim_wobble(%Head, 2.0 * bounceness, 1.5)
			# await get_tree().create_timer(0.15).timeout
			if tween:
				tween.kill()
			tween = create_tween().set_parallel(true)
			tween.tween_property(ear_l, "position:y", -116.0, 0.125)
			tween.tween_property(ear_r, "position:y", -116.0, 0.125)
			# tween.tween_property(blue_face, "position:y", -540.0, 0.125)
			tween.tween_callback(func():
				head.self_modulate = Color.WHITE
				eyes = Eyes.REGULAR
				blue_face.visible = false
			)

	await get_tree().create_timer(delay-0.01).timeout
	
	if bounce && p_emote != Emotes.Complete:
		hoodie_heart.polygon = l_poly 

	is_emoting = false



func anim_bounce(delay: float, p_expression : Expressions = expression, strength: float = 1.0) -> PackedVector2Array:
	var l_poly: PackedVector2Array = current_poly.duplicate()
	
	body.scale.y = 1.0 / (strength * bounceness)

	# HOODIE HEART PRESET

	if p_expression == Expressions.FRUSTRATED:
		l_poly[8].x = poly_middle_point.x - (bounceness * 40.0)
	elif p_expression == Expressions.BOUNCY:
		l_poly[8].y = poly_middle_point.y - (bounceness * 10.0)
	else:
		l_poly[8].y = poly_middle_point.y - (bounceness * 35.0)
	
	if tween_bounce:
		tween_bounce.kill()
		
	tween_bounce = create_tween().set_parallel(true)
	tween_bounce.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_bounce.tween_property(body, "scale:y", 1.0, 1.0)
	tween_bounce.tween_property(hoodie_heart, "polygon", PackedVector2Array(current_poly), 2.4).set_delay(delay)
	
	return l_poly

func anim_expression(p_expression : Expressions = expression, p_eyes: Eyes = Eyes.REGULAR, bounce: bool = true) -> void:
	var heart_eyes := %"7"
	var ear_l := %EarL
	var ear_r := %EarR
	var m_ear_r := %MillieEarR
	var hair_1 := %MillieFrontHair
	var hair_2 := %MillieMarshmallowHair
	var noise_face := %NoiseFace
	var head := %MillieHead
	var particle_zzz := $Z


	## PRESET
	noise_face.visible = false
	particle_zzz.emitting = false
	hair_1.visible = true
	hair_2.visible = true

	m_ear_r.visible = true
	head.self_modulate = Color(Color.WHITE, 1.0)
	head.texture = preload("res://assets/character/millie-head.png")
	ear_l.position.y = -116.0
	ear_r.position.y = -116.0
	var delay := 0.055
	
	# TWEEN RESET
	
	if tween:
		tween.kill()
	if tween_spin:
		tween_spin.kill()
	if tween_wobble:
		tween_wobble.kill()
	
	var l_poly: PackedVector2Array
	
	# TWEEN TRANSITION
	if bounce:
		l_poly = anim_bounce(delay, p_expression)
	
	# TWEEN EXPRESSION SPECIFIC
	match p_expression:
		
		Expressions.BITTEN:
			eyes = Eyes.BLANK

			%ExpressionBitten.play()

			head.texture = preload("res://assets/character/millie-head-bitten.png")
			head.self_modulate = Color(1.0, 0.9, 0.9, 1.0)
		
			m_ear_r.visible = false
			hair_1.visible = false
			hair_2.visible = false
			anim_wobble(head, 2.0 * bounceness, 1.5)

			if world:
				var e: CPUParticles2D = ear_fall.instantiate()
				var h: CPUParticles2D = hair_fall.instantiate()
				h.global_position = hair_1.global_position
				e.global_position = ear_r.global_position
				world.add_child(h)
				world.add_child(e)
				e.emitting = true
				h.emitting = true
				await get_tree().create_timer(1.0).timeout
				e.queue_free()
				h.queue_free()
			else:
				%EarFall.emitting = true
				%HairFall.emitting = true

		Expressions.EXCITED:
			eyes = Eyes.HEART_EYES

			heart_eyes.scale = Vector2.ZERO
			heart_eyes.position.y = 0.0
			ear_l.position.y = -116.0+50.0
			ear_r.position.y = -116.0+50.0
			tween = create_tween().set_parallel(true)
			tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
			
			tween.tween_property(heart_eyes, "scale", 0.5 * Vector2.ONE, 1.1)
			tween.tween_property(heart_eyes, "position:y", -60.0, 1.28)
			tween.tween_property(ear_l, "position:y", -116.0, 1.28)
			tween.tween_property(ear_r, "position:y", -116.0, 1.28)
		
		Expressions.FRUSTRATED:
			%ExpressionFrustrated.play()

			eyes = Eyes.WIDE_CLOSED
			noise_face.visible = true
			head.self_modulate = Color(1.0, 0.7, 0.7, 1.0)
			ear_l.position.y = -116.0+25.0
			ear_r.position.y = -116.0+25.0
			anim_wobble(%Head, 2.0 * bounceness, 1.5)
			tween_spin = create_tween().set_loops()
			tween_spin.tween_callback(gen_noise).set_delay(0.1)
		
		Expressions.ASLEEP:
			eyes = Eyes.WIDE_CLOSED
			ear_l.position.y = -116.0+25.0
			ear_r.position.y = -116.0+25.0
			anim_wobble(%Head, 2.0 * bounceness, 4.5)
			particle_zzz.emitting = true
		
		Expressions.BOUNCY:
			eyes = Eyes.HAPPY

		
		_:
			eyes = p_eyes
	
	await get_tree().create_timer(delay-0.01).timeout
	
	if bounce:
		hoodie_heart.polygon = l_poly 
	
	
func gen_noise():
	var l_range := noise_extend
	%NoiseLine2D.points = PackedVector2Array([
	Vector2(randf_range(-l_range, l_range),randf_range(-l_range, l_range)),
	Vector2(randf_range(-l_range, l_range),randf_range(-l_range, l_range)),
	Vector2(randf_range(-l_range, l_range),randf_range(-l_range, l_range)),
	Vector2(randf_range(-l_range, l_range),randf_range(-l_range, l_range)),
	Vector2(randf_range(-l_range, l_range),randf_range(-l_range, l_range)),
	Vector2(randf_range(-l_range, l_range),randf_range(-l_range, l_range)),
	Vector2(randf_range(-l_range, l_range),randf_range(-l_range, l_range)),
	])


var tween_wobble: Tween

func anim_wobble(node: Node2D, amplitude: float = 10.0, duration: float = 1.0) -> void:
	var amp := amplitude
	var dur := duration
	
	if tween_wobble:
		tween_wobble.kill()
	tween_wobble = create_tween()
	tween_wobble.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween_wobble.tween_property(node,"rotation_degrees",amp,dur/18.0)
	tween_wobble.tween_property(node,"rotation_degrees",-amp,dur/18.0)
	tween_wobble.tween_property(node,"rotation_degrees",amp/2.0,dur/13.0)
	tween_wobble.tween_property(node,"rotation_degrees",-amp/2.0,dur/13.0)
	tween_wobble.tween_property(node,"rotation_degrees",amp/4.0,dur/13.0)
	tween_wobble.tween_property(node,"rotation_degrees",-amp/4.0,dur/13.0)
	tween_wobble.tween_property(node,"rotation_degrees",amp/8.0,dur/13.0)
	tween_wobble.tween_property(node,"rotation_degrees",-amp/8.0,dur/13.0)
	tween_wobble.tween_property(node,"rotation_degrees",0.0,dur/13.0)
	await tween_wobble.finished
