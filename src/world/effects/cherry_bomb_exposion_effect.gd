extends Node2D
class_name ExplosionFX

@onready var sprite_cloud: Sprite2D = $Cloud
@onready var sprite_cloud_2: Sprite2D = $Cloud2
@onready var sprite_bomb: Sprite2D = $Bomb


var cherry_particle: PackedScene = preload("res://world/effects/cherry_particle.tscn")
var terrain_traces: PackedScene = preload("res://world/effects/terrain_explosion_mark.tscn")

var sprite: Sprite2D ## TODO
var pos_at: Vector2 ## Set by [Mashed]


func _ready() -> void:
	anim_explode()


func anim_explode() ->void:
	
	## INITIALIZING
	sprite_cloud.visible = false
	sprite_cloud.texture = sprite_cloud.texture.duplicate(true)
	sprite_bomb.position = pos_at * Util.BLOCK_SIZE * 0.5
	
	anim_explode_then_free()


## @experimental
func anim_explode_then_free() -> void:
	sprite_cloud.visible = true
	sprite_bomb.visible = true
	
	## TRACES
	
	var trace: TerrainExplosionEffect = terrain_traces.instantiate()
	
	trace.position = global_position + (pos_at * Util.BLOCK_SIZE * 0.5)
	
	GameMgr.current_level.add_child(trace)
	
	## DEBRIS
	for i in range(10):
		var p: RigidBody2D = cherry_particle.instantiate()
		
		var angle := randf_range(60.0, 180.0 - 60.0)
		var vector := Vector2(cos(angle), sin(angle))
		
		var strength := randf_range(575.0, 1200.0)
		
		p.linear_velocity = vector * strength
		
		p.angular_velocity = 0.1 * strength * signf(randf() - 0.5)
		
		p.position = global_position
		
		GameMgr.current_level.add_child(p)
	
	## TWEENING
	var dur := 2.0
	
	var tween := create_tween().set_parallel()
	
	## TWEEENED PROPERTIES
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sprite_cloud.texture as GradientTexture2D, "fill_to:x", 1.45, dur)
	tween.tween_property(sprite_cloud, "self_modulate", Color(Color.WHITE, 0.0), dur)
	tween.tween_property(sprite_bomb, "self_modulate", Color(Color.WHITE, 0.0), dur * 0.4)
	tween.tween_property(sprite_bomb, "scale", Vector2.ONE * 2.0, dur * 0.4)
	##
	
	await tween.finished
	
	queue_free()
	
	
