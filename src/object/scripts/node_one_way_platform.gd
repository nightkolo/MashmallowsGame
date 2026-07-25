extends StaticBody2D
class_name OneWayPlatform

@export var enable: bool = true

var p: Player
var drop_notice: Node2D

var notice: PackedScene = preload("res://world/interface/one_way_platform_drop_notice.tscn")


func setup_node() -> void:
	var children: Array[Node] = get_children()

	if GameMgr.current_level == null || children.size() != 1:
		return
	
	drop_notice = notice.instantiate()
	GameMgr.current_level.add_child.call_deferred(drop_notice)

	var node: Node = children[0]

	if node is CollisionShape2D:
		var colli := node as CollisionShape2D
		colli.one_way_collision = true
		drop_notice.position.y = colli.position.y

		var area := Area2D.new()
		area.collision_mask = 2
		var new_colli: CollisionShape2D = colli.duplicate(true)
		new_colli.position.y -= 5.0
		area.add_child.call_deferred(new_colli)
		
		GameMgr.current_level.add_child.call_deferred(area)

		area.body_entered.connect(func(body: Node2D):
			if body is Player:
				p = body as Player
				
				if p.is_on_floor() || p.velocity.y >= 0.0:
					set_process(true)
					show_drop_notice(true)
			)

		area.body_exited.connect(func(body: Node2D):
			if body is Player:
				show_drop_notice(false)
				set_process(false)
				p = null
			)


func _ready() -> void:
	collision_layer = 2048
	collision_mask = 2048

	await get_tree().create_timer(0.1).timeout

	if enable:
		setup_node()
	else:
		set_process(false)

	
var _tween_prompt: Tween

func show_drop_notice(p_show: bool) -> void:
	if p_show:
		drop_notice.visible = true
		if _tween_prompt:
			_tween_prompt.kill()
		_tween_prompt = create_tween()
		_tween_prompt.tween_property(drop_notice, "scale", Vector2.ONE, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	else:
		if _tween_prompt:
			_tween_prompt.kill()
		_tween_prompt = create_tween()
		_tween_prompt.tween_property(drop_notice, "scale", Vector2.ZERO, 0.1)
		await _tween_prompt.finished
		drop_notice.visible = false

			
func _process(_delta: float) -> void:
	if p && drop_notice:
		drop_notice.position.x = p.global_position.x
