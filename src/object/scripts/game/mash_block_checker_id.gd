@tool
extends Node2D
class_name MashBlockCheckerID

@onready var sprite: Sprite2D = $Sprite2D

@export var attributes: BlockAttributes


func _ready() -> void:
	if attributes:
		GameLogic.setup_mash_block(sprite, attributes.mash_type, attributes.build_type)
		
		if attributes.mash_type != Util.MashType.PLAYER:
			GameLogic.number_of_order_blocks += 1
			is_satisfied = false

		if get_parent() is Order:
			(get_parent() as Order).mash_block_checker_ids.append(self)
		
		if attributes.is_golden:
			$Sprite2D.self_modulate = Color(Color.WHITE * 0.5,1.0)
		else:
			$Sprite2D.self_modulate = Color(Color.WHITE)


var is_satisfied: bool = true
var tween_anim: Tween


# TODO Clean-up
## Called by [MashBlockChecker]
func anim_satisfied(satisfied: bool) -> void:
	if satisfied == is_satisfied:
		return
	
	is_satisfied = satisfied
	
	if tween_anim:
		tween_anim.kill()
		
	tween_anim = create_tween().set_parallel()
	tween_anim.set_ease(Tween.EASE_OUT)
	
	sprite.self_modulate = Color(2.0 * Color.WHITE)
	sprite.scale = Vector2.ONE * 0.25
	
	tween_anim.tween_property(sprite, "scale", Vector2.ONE / 2.0, 1.25).set_trans(Tween.TRANS_ELASTIC)

	tween_anim.tween_property(sprite, "self_modulate", Color(Color.WHITE), 0.25)
	
	sprite.texture = Util.get_order_block_texture(attributes.mash_type, attributes.build_type, satisfied)
		
		
		
		
		
		
		
		
		
		
