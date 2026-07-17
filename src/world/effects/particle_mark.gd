extends Sprite2D


func _ready() -> void:
	anim()


func anim() -> void:
	scale = Vector2(1.0, 0.0)
	var tween := create_tween().set_parallel(true)

	tween.tween_property(self, "scale", Vector2.ONE / 1.5, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback(
		[
			anim_slide,
			anim_fall
		].pick_random()
	)
	await get_tree().create_timer(2.0).timeout
	queue_free()

func anim_slide() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "position:x", 10.0, 1.0).as_relative()
	tween.tween_property(self, "self_modulate", Color(1.0,1.0,1.0, 0.0), 0.75)
	await tween.finished

func anim_fall() -> void:
	await get_tree().create_timer(0.25).timeout
	var tween := create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation_degrees", 180.0, 0.75).set_trans(Tween.TRANS_BACK)

	tween.chain().tween_property(self, "position:y", 40.0, 0.5).as_relative()
	tween.tween_property(self, "self_modulate", Color(1.0,1.0,1.0, 0.0), 0.4)
	await tween.finished
