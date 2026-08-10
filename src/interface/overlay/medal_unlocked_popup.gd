extends CanvasLayer
class_name MedalUnlockedPopup

@onready var label: Label = %Label
@onready var label_2: Label= %Label2
@onready var v_box_container: VBoxContainer = %VBoxContainer


var _tween: Tween


func _ready() -> void:
	GameMgr.current_medal_notifier = self
	
	visible = false
	

func anim_medal_unlocked(medal_id: int = 0) -> void:
	if !GameMgr.ON_NEWGROUNDS_MIRROR:
		return
	
	var dur := 1.0
	
	if _tween:
		_tween.kill()
	
	var m_res: MedalResource = NG.get_medal_resource(medal_id)
	
	var medal_name: String = '"%s"' % m_res.name
	label_2.text = medal_name
	
	visible = true
	
	_tween = create_tween().set_parallel(true)
	_tween.set_ease(Tween.EASE_OUT)
	for l_label: Label in [label, label_2]:
		l_label.scale.x = 0.0
		l_label.self_modulate = Color(Color.WHITE, 0.0)
		_tween.tween_property(l_label, "self_modulate", Color(Color.WHITE, 1.0), dur / 2.0)
		_tween.tween_property(l_label, "scale:x", 1.0, dur).set_trans(Tween.TRANS_ELASTIC)
		_tween.tween_property(l_label, "self_modulate", Color(Color.WHITE, 0.0), dur * 2.0).set_delay(dur)
	
	
	await get_tree().create_timer(dur * 4.0).timeout
	
	visible = false
