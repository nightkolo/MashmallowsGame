extends PointLight2D
class_name TerrainExplosionEffect


func _ready() -> void:
	texture = texture.duplicate(true)
	
	await get_tree().create_timer(0.5).timeout
	
	anim_fade()


func anim_fade() -> void:
	var dur := 9.0
	var tween := create_tween().set_parallel()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(self, "scale", Vector2.ZERO, dur)
	tween.tween_property(
		(texture as GradientTexture2D).gradient,
		"colors",
		PackedColorArray(
			[Color(Color.BLACK, 0.0), Color(Color.BLACK, 0.0), Color(Color.WHITE, 0.0)]
		),
		dur * 0.6
		)
