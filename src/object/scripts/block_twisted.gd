extends Node2D
class_name Twisted

@onready var ray_cast: RayCast2D = $RayCast2D

@export var bodies: Array[TwistedColliBlock]
@export var player: Player
@export var twisted_mask_gradient: Texture
@export var twisted_mask: Sprite2D

var parent_unmashed: Unmashed
var twisted_strength: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#for b: TwistedColliBlock in bodies:
		#b.position = Vector2(0.0, 0.0)

	if get_parent() is Unmashed:
		parent_unmashed = get_parent() as Unmashed
		
		visible = parent_unmashed.mash_type == Util.MashType.TWISTED
		
		if visible:
			await get_tree().create_timer(0.1).timeout
			twisted_strength = parent_unmashed.twisted_strength
		
	if twisted_mask_gradient:
		twisted_mask.texture = twisted_mask_gradient.duplicate(true)
		(twisted_mask.texture as GradientTexture2D).height = 64
		twisted_mask.visible = true
		
	if parent_unmashed:
		if !parent_unmashed.was_mashed:
			modulate = Color(Color.WHITE, 0.0)
			
			for i in range(bodies.size()):
				var pos_to: float = -get_colli_scale(i)
				bodies[i].position = Vector2(0.0, pos_to)
			
			(twisted_mask.texture as GradientTexture2D).height = get_texture_scale()
			
			anim_show()
			
	if player == null:
		await get_tree().create_timer(0.1).timeout
		player = GameMgr.current_main_player
		
	start_stop_expansion()
	
	
func anim_show() -> void:
	var t:= create_tween()
	t.tween_property(self, "modulate", Color(Color.WHITE, 1.0), 0.125)


func start_stop_expansion() -> void:
	player.has_touched_ceiling.connect(_on_ceiling_touched)


func cancel_stop_expansion() -> void:
	if player.has_touched_ceiling.is_connected(_on_ceiling_touched):
		player.has_touched_ceiling.disconnect(_on_ceiling_touched)

var expand_tween: Tween


func _on_ceiling_touched() -> void:
	if player == null:
		return
	
	if expand_tween && player.is_on_block():
		expand_tween.kill()
		
		(twisted_mask.texture as GradientTexture2D).height -= 20
		
		for b: TwistedColliBlock in bodies:
			b.position.y = minf(0.0, b.position.y + 20.0)


func get_texture_scale() -> int:
	var s := twisted_strength
	return int(Util.BLOCK_SIZE * s * (bodies.size() / lerpf(3.75, 5.0, s * 0.2)))


func get_colli_scale(placement: int) -> float:
	return placement * Util.BLOCK_SIZE * (twisted_strength / bodies.size())


func expand_collision(strength: float = twisted_strength, p_dur: float = 0.5) -> void:
	# Memory checks
	if ( 
		player == null ||
		parent_unmashed == null
		):
		return
	#
	
	if (
		!parent_unmashed.was_mashed ||
		parent_unmashed.mash_type != Util.MashType.TWISTED
		):
		return
		
	if expand_tween:
		expand_tween.kill()
		
	expand_tween = create_tween().set_parallel(true)

	ray_cast.force_raycast_update()
	
	if ray_cast.is_colliding():
		(ray_cast.get_collider() as Node2D).position.y -= Util.BLOCK_SIZE * 0.25

	for i in range(bodies.size()):
		var pos_to: float = -get_colli_scale(i)
		expand_tween.tween_property(bodies[i], "position:y", pos_to, p_dur).from(0.0)
	
	expand_tween.tween_property(twisted_mask.texture as GradientTexture2D, "height", get_texture_scale(), p_dur)
	
	await expand_tween.finished
	cancel_stop_expansion()
