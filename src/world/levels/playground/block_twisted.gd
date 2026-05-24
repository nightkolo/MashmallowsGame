extends Node2D
class_name Twisted

@export var bodies: Array[TwistedColliBlock]


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
	


func expand_collision(strength: float = twisted_strength) -> void:
	if parent_unmashed.mash_type != Util.MashType.TWISTED:
		return
	
	print_debug("expanding...")
	print_debug(bodies)

	var dur := 1.0
	var stren := strength / bodies.size()
	var tween := create_tween()
	tween.set_parallel(true)

	for i in range(bodies.size()):
		bodies[i].position.x = 0.0
		var pos_to: float =  (i * Util.BLOCK_SIZE * -1 * stren)
		#if pos_to == 0.0:
			#continue
		tween.tween_property(bodies[i], "position:y", pos_to, dur / 2.0)
	await tween.finished
		# tween.tween_property(bodies[i], "position:y", 0.0, dur / 2.0).set_delay(dur / 2.0)
