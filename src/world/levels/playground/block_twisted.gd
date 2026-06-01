extends Node2D
class_name Twisted

@export var bodies: Array[TwistedColliBlock]
@export var player: Player

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
	
	if player == null:
		await get_tree().create_timer(0.1).timeout
		player = GameMgr.current_player


var expand_tween: Tween

func start_stop_expansion() -> void:
	if player == null:
		return
		
	player.has_touched_ceiling.connect(_on_ceiling_touched)

func cancel_stop_expansion() -> void:
	if player == null:
		return
		
	if player.has_touched_ceiling.is_connected(_on_ceiling_touched):
		player.has_touched_ceiling.disconnect(_on_ceiling_touched)

func _on_ceiling_touched() -> void:
	if player == null:
		return
	var cond := player.is_on_block()
	print_debug(cond)
	if expand_tween && cond:
		expand_tween.kill()


func expand_collision(strength: float = twisted_strength, p_dur: float = 0.5) -> void:
	if parent_unmashed.mash_type != Util.MashType.TWISTED:
		return
	
	start_stop_expansion()
	
	print_debug("expanding...")

	#var dur := p_dur
	var l_strength := strength / bodies.size()
	if expand_tween:
		expand_tween.kill()
	expand_tween = create_tween().set_parallel(true)

	for i in range(bodies.size()):
		#bodies[i].position = Vector2.ZERO
		#tween.tween_property(bodies[i], "position:y", 0.0, 0.1)
		
		#print_debug(bodies[i].position.y)
		
		var pos_to: float =  (i * Util.BLOCK_SIZE * -1 * l_strength)
		
		#print_debug(pos_to)
		
		expand_tween.tween_property(bodies[i], "position:y", pos_to, p_dur).from(0.0)
		
	await expand_tween.finished
	cancel_stop_expansion()
		# tween.tween_property(bodies[i], "position:y", 0.0, dur / 2.0).set_delay(dur / 2.0)
