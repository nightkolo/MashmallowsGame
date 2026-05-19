extends RichTextLabel



func _ready() -> void:
	pivot_offset_ratio = Vector2.ONE * 0.5
	
	var t := create_tween().set_loops()
	t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(self, "scale", Vector2(0.98, 1.02), 3.0)
	t.tween_property(self, "scale", Vector2(1.02, 0.98), 3.0)
	var t2 := create_tween().set_loops()
	t2.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	t2.tween_property(self, "rotation_degrees", 1.0, 1.0)
	t2.tween_property(self, "rotation_degrees", -1.0, 1.0)
