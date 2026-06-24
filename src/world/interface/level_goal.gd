@tool
extends Control
class_name LevelGoal


@onready var level_number_label: Label = %LevelNumber

@onready var star_node_2: Node2D = $Star/Star2
@onready var star_node: Node2D = %Star
@onready var star_no_win: Sprite2D = %NoWin
@onready var board: NinePatchRect = %LevelGoalBoard
@onready var particles_1 = %SpawnParticles
@onready var particles_2 = %SpawnParticles2
@onready var particles_3 = %SpawnParticles3

@onready var audio_show = %Show
@onready var audio_shake = %Shake

@onready var percent_gradient: Sprite2D = %PercentGradient

var prec_grad: GradientTexture2D = preload("res://core/resources/gradient/order_star_gradient_texture_2d.tres")

var _current_order_precent: float
var _tween: Tween


func anim_spawn() -> void:
	level_number_label.text = "%s-%s" % [GameMgr.bakery_id, GameMgr.level_id]
	
	var dur := 0.75
	var mag := 0.7
	particles_1.emitting = true
	particles_2.emitting = true
	particles_3.emitting = true

	audio_show.play()
	audio_shake.play()

	var t := create_tween()
	t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(board, "self_modulate", Color(Color.WHITE * mag, 1.0), dur/4.0)
	t.tween_property(board, "self_modulate", Color(Color.WHITE * 1.0, 1.0), dur/4.0)
	t.tween_property(board, "self_modulate", Color(Color.WHITE * mag, 1.0), dur/4.0)
	t.tween_property(board, "self_modulate", Color(Color.WHITE * 1.0, 1.0), dur/4.0)


func anim_wobble(strength: float = PI / 28.0) -> void:
	var dur = 5.0
	
	rotation = 0.0
	
	if _tween:
		_tween.kill()
		
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	_tween.tween_property(self, "rotation", strength, dur / 20.0)
	_tween.tween_property(self, "rotation", 0.0, dur).set_trans(Tween.TRANS_ELASTIC)


func _ready() -> void:
	GameMgr.current_level_goal = self
	percent_gradient.texture = prec_grad
	
	level_number_label.position = Vector2(-level_number_label.size.x / 2, 16.0)
	star_node.position = Vector2(board.size.x / 4.0, board.size.y / 2.0)

	GameLogic.completion_percentage_updated.connect(update_completion_prec)
	GameLogic.cherry_bomb_exploded.connect(anim_wobble)
	GameLogic.order_complete.connect(anim_complete)
	
	GameMgr.level_entered.connect(func():
		if tween_prec:
			tween_prec.kill()
			
		prec_grad.gradient.set_offset(1, 0.126)
		)
	
	anim_idle(star_node, star_node_2)
	
	#await get_tree().create_timer(0)


func anim_complete() -> void:
	star_no_win.self_modulate = Color(Color.WHITE * 4.0)
		
	%Particles.emitting = true
	
	var tween = create_tween()
	
	tween.tween_property(%Particles, "self_modulate", Color(Color.WHITE, 0.0), 0.5).set_delay(0.5)

var tween_prec: Tween

func anim_idle(node: Node2D, sprite: Node2D) -> void:
	var dur_hover := 1.7
	var dur_rot := 1.0
	var mag_hover := 5.0 # magnitude
	var mag_rot := 10.0
	
	var tween = create_tween().set_loops()
	var tween_b = create_tween().set_loops()
	
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween_b.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(node,"position:y", -mag_hover ,dur_hover).as_relative()
	tween.tween_property(node,"position:y", mag_hover ,dur_hover).as_relative()
	
	tween_b.tween_property(sprite,"rotation", deg_to_rad(-mag_rot / 2.0), dur_rot)
	tween_b.tween_property(sprite,"rotation", deg_to_rad(mag_rot / 2.0), dur_rot)


# TODO Clean-up
func update_completion_prec(perc: float) -> void:
	var old_perc := _current_order_precent
	_current_order_precent = perc

	if tween_prec:
		tween_prec.kill()

	tween_prec = create_tween().set_parallel(true)
	tween_prec.set_ease(Tween.EASE_OUT)

	var decreasing := perc < old_perc

	if decreasing:
		star_node_2.scale = Vector2(0.6, 1.8)
		tween_prec.set_trans(Tween.TRANS_LINEAR)
	else:
		for p: CPUParticles2D in [%ParticlesStar, %ParticlesStar2]:
			if not p.emitting:
				p.emitting = true

		prec_grad.gradient.set_offset(1, 0.15)
		star_node_2.scale = Vector2(2.0, 0.5)
		star_no_win.self_modulate = Color(Color.WHITE * 4.0)

	var target_offset := maxf(0.125, lerpf(0.15, 0.9, perc))

	tween_prec.tween_property(
		prec_grad.gradient,
		"offsets",
		PackedFloat32Array([0.0, target_offset]),
		0.5
	)

	tween_prec.tween_property(
		star_no_win,
		"self_modulate",
		Color(Color.WHITE, 1.0),
		0.4
	)

	tween_prec.tween_property(
		star_node_2,
		"scale",
		Vector2.ONE,
		0.4
	).set_trans(Tween.TRANS_BACK)
