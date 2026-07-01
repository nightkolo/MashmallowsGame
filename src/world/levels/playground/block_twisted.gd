extends Node2D
class_name Twisted

@export var bodies: Array[TwistedColliBlock]
@export var player: Player
@export var twisted_mask_gradient: Texture
@export var twisted_mask: Sprite2D

var parent_unmashed: Unmashed
var twisted_strength: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for b: TwistedColliBlock in bodies:
		b.position = Vector2(0.0, 0.0)

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
			await get_tree().create_timer(0.1).timeout
			var l_strength := twisted_strength / bodies.size()
			
			for i in range(bodies.size()):

				var pos_to: float =  (-i * Util.BLOCK_SIZE * l_strength * 0.95)
				bodies[i].position = Vector2(0.0, pos_to)
				#print_debug(bodies[i].position)
			
			(twisted_mask.texture as GradientTexture2D).height = int(Util.BLOCK_SIZE * twisted_strength)
	
	if player == null:
		await get_tree().create_timer(0.1).timeout
		player = GameMgr.current_main_player
		
	start_stop_expansion()


var expand_tween: Tween

func start_stop_expansion() -> void:
	player.has_touched_ceiling.connect(_on_ceiling_touched)

func cancel_stop_expansion() -> void:
	if player.has_touched_ceiling.is_connected(_on_ceiling_touched):
		player.has_touched_ceiling.disconnect(_on_ceiling_touched)

func _on_ceiling_touched() -> void:
	if player == null:
		return
	
	if expand_tween && player.is_on_block():
		expand_tween.kill()
		
		(twisted_mask.texture as GradientTexture2D).height -= 20
		
		for b: TwistedColliBlock in bodies:
			b.position.y = minf(0.0, b.position.y + 20.0)


func expand_collision(strength: float = twisted_strength, p_dur: float = 0.5) -> void:
	if parent_unmashed.mash_type != Util.MashType.TWISTED || player == null || parent_unmashed == null:
		return
	
	if !parent_unmashed.was_mashed:
		return
		
	
	print_debug(strength)

	#var dur := p_dur
	var l_strength := strength / bodies.size()
	
	if expand_tween:
		expand_tween.kill()
	expand_tween = create_tween().set_parallel(true)

	if player.is_on_block(true):
		player.position.y -= Util.BLOCK_SIZE * 0.25

	for i in range(bodies.size()):
		#bodies[i].position = Vector2.ZERO
		#tween.tween_property(bodies[i], "position:y", 0.0, 0.1)
		
		#print_debug(bodies[i].position.y)
		
		var pos_to: float =  (-i * Util.BLOCK_SIZE * l_strength * 0.95)
		
		#print_debug(pos_to)
		
		expand_tween.tween_property(bodies[i], "position:y", pos_to, p_dur).from(0.0)
	
	#print_debug(s)
	expand_tween.tween_property(twisted_mask.texture as GradientTexture2D, "height", int(Util.BLOCK_SIZE * strength) ,p_dur )
	
	
	await expand_tween.finished
	cancel_stop_expansion()
		# tween.tween_property(bodies[i], "position:y", 0.0, dur / 2.0).set_delay(dur / 2.0)
