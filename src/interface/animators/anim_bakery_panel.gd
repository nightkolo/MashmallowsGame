@tool
extends NinePatchRect
class_name BakeryPanel

@onready var arrow_node: Node2D = $ArrowNode

@onready var spiral: Sprite2D = $Mask/Spiral
@onready var arrow: Sprite2D = $ArrowNode/Arrow

var tween_b: Tween
var arrow_pos: Vector2

var is_active: bool = false:
	set(value):
		if value:
			anim_arrow_trans()
			if value != is_active:
				anim_arrow()
		else:
			if value != is_active:
				stop_anim_arrow()
		is_active = value


func _ready() -> void:
	arrow_pos = Vector2(size.x + 50.0, size.y / 2.0)
	arrow_node.position = arrow_pos
	
	var tween := create_tween().set_loops()
	
	tween.tween_property(spiral, "rotation", TAU, 12.0).from(0.0)
	
	#anim_arrow()

var tween_trans: Tween # LOL

func anim_arrow_trans():
	#if !is_active:
		#stop_anim_arrow_trans()
		#return
	
	arrow_node.position.x = arrow_pos.x + 20.0
	stop_anim_arrow_trans()
	
	tween_trans = create_tween()
	
	tween_trans.tween_property(arrow_node, "position:x", arrow_pos.x, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)


func stop_anim_arrow_trans():
	if tween_trans:
		tween_trans.kill()
	arrow.position = Vector2.ZERO
	arrow.scale = Vector2.ONE * 0.5


func stop_anim_arrow():
	if tween_b:
		tween_b.kill()
	
	arrow.position = Vector2.ZERO
	arrow.scale = Vector2.ONE * 0.5
		

func anim_arrow():
		
	await get_tree().create_timer(0.5).timeout
	
	if !is_active:
		stop_anim_arrow()
		return
	
	stop_anim_arrow()
	
	
	tween_b = create_tween().set_loops()
	
	tween_b.tween_property(arrow, "position:x", 10.0, 0.15).set_delay(0.75)
	tween_b.tween_property(arrow, "scale:y", 1.2 * 0.5, 0.1)
	tween_b.tween_property(arrow, "scale:y", 1.0 * 0.5, 0.1)
	tween_b.tween_property(arrow, "scale:y", 1.2 * 0.5, 0.1)
	tween_b.tween_property(arrow, "scale:y", 1.0 * 0.5, 0.1)
	tween_b.tween_property(arrow, "position:x", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	
	
