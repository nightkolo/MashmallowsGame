extends Control
class_name LoadingScreen
var p: Array = []
var s: String = "res://world/levels/main/level_0.tscn"
var load_status: int
func _ready() -> void:
	set_process(false)
	var l: Label = $Label
	l.pivot_offset_ratio = Vector2.ONE * 0.5
	var t: Tween = create_tween().set_loops()
	t.set_parallel(true)
	print_debug(t)
	t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(l, "scale", Vector2.ONE*0.85, 0.25)
	t.tween_property(l, "self_modulate", Color(Color.WHITE, 0.75), 0.25)
	t.chain().tween_property(l, "scale", Vector2.ONE, 0.25)
	t.tween_property(l, "self_modulate", Color(Color.WHITE, 1.0), 0.25)
func start_loading() -> void:
	# var t: AnimationPlayer = $AnimationPlayer
	# t.play(&"a")
	set_process(true)
	ResourceLoader.load_threaded_request(s)
func _process(_delta: float) -> void:
	load_status = ResourceLoader.load_threaded_get_status(s, p)
	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var l_s = ResourceLoader.load_threaded_get(s)
		get_tree().change_scene_to_packed(l_s)
	# print_debug(p[0] * 100)
