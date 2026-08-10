@tool
extends Node2D
class_name BlockDetector

signal changed_index()

@export var notify_mash_highlight: bool = true
@export var unmash_notify_rays_length: float = 45.0:
	set(value):
		unmash_notify_rays_length = value
		
		for ray: CollisionShape2D in [%Collision, %Collision2, %Collision3, %Collision8, %Collision7, %Collision6, %Collision5, %Collision4]:
			(ray.shape as SeparationRayShape2D).length = value
@export var unmash_detection_rays_length: float = 45.0:
	set(value):
		unmash_detection_rays_length = value
		
		for ray: RayCast2D in [%Right, %Left, %Right2, %Left2, %Down]:
			var dir := Math.get_direction(ray.name)
			
			ray.target_position = value * dir
		
@onready var ground_ray: ShapeCast2D = $GroundRay
@onready var blocks_ray: ShapeCast2D = $BlocksRay
@onready var unmashed_block_detection_rays: Array[RayCast2D] = [$Down, $Right, $Left]
@onready var cherry_bomb_rays: Array[RayCast2D] = [$CherryBombRays/Up, $CherryBombRays/Right, $CherryBombRays/Left]

@onready var unmashed_block_detect_1x1: Area2D = $UnmashedBlockDetect1x1
@onready var unmashed_block_detect_1x2: Area2D = $UnmashedBlockDetect1x2
@onready var ground_detect: Area2D = $GroundDetect


var parent_block: Mashed


func _ready() -> void:
	if get_parent() is Mashed:
		parent_block = get_parent()
		
		if notify_mash_highlight:
			GameLogic.player_mashed.connect(func():
				await get_tree().create_timer(0.1).timeout
				parent_block.anim_highlight(is_colliding())
				)
		
		if parent_block.build_type == Util.BuildType.RECTANGLE:
			for ray: RayCast2D in [$Right2, $Left2]:
				unmashed_block_detection_rays.append(ray)
				ray.visible = true
			
			if notify_mash_highlight:
				unmashed_block_detect_1x2.visible = true
				
				# Signal connect
				unmashed_block_detect_1x2.body_entered.connect(notify_highlight_state.bind(1))
				unmashed_block_detect_1x2.body_exited.connect(notify_highlight_state.bind(-1))
		else:
			if notify_mash_highlight:
				unmashed_block_detect_1x1.visible = true
				
				# Signal connect
				unmashed_block_detect_1x1.body_entered.connect(notify_highlight_state.bind(1))
				unmashed_block_detect_1x1.body_exited.connect(notify_highlight_state.bind(-1))
		
		await get_tree().create_timer(0.2).timeout
		parent_block.parent_player.move_state_changed.connect(update_unmashed_direction_arrow_index)


# Ok -> O(n)
func update_unmashed_direction_arrow_index(moving_toward: Vector2) -> void: 
	if moving_toward == Vector2.ZERO || !is_colliding(true):
		return
	
	var dir: Vector2
	
	if absf(moving_toward.x) > 0.0:
		dir = Vector2(moving_toward.x, 0.0)
	elif absf(moving_toward.y) > 0.0:
		dir = Vector2.DOWN
	
	var n: int = unmashed_block_detection_rays.size() # Either 3 or 5
	
	#print_debug("Before: " + str(unmashed_block_detection_rays))
	
	changed_index.emit()
	
	for i in n:
		if (unmashed_block_detection_rays[i] as RayCast2D).target_position.sign() != dir:
			continue
		
		if i > 0:
			unmashed_block_detection_rays.push_front(
				unmashed_block_detection_rays.pop_at(i) as RayCast2D
			)
		
		if n == 3: # Does not include an extra node to check
			break
	#print_debug("After: " + str(unmashed_block_detection_rays))
	


# Ok -> O(n)
func is_colliding(quick_check: bool = false) -> bool:
	for ray: RayCast2D in unmashed_block_detection_rays:
		if quick_check:
			if ray.is_colliding():
				return true
			continue
				
		ray.force_raycast_update()
		
		var colli: Node2D = ray.get_collider()
		if colli is Unmashed || colli is TwistedColliBlock:
			return true
	return false



func notify_highlight_state(unmashed_block_detected: Node2D, entered: int):
	parent_block.anim_highlight(is_colliding())
	
	if unmashed_block_detected is Unmashed:
		# NOTE: Critical section, increment solution for Unmashed.anim_highlight function call
		(unmashed_block_detected as Unmashed).amount_collided_with += entered
		#
	elif unmashed_block_detected is TwistedColliBlock:
		(unmashed_block_detected as TwistedColliBlock).parent_unmashed.amount_collided_with += entered
	
	elif unmashed_block_detected is Player:
		var p: Player = (unmashed_block_detected as Player)
		
		if !p.is_active:
			p.original_block.anim_highlight(entered > 0)
			parent_block.anim_highlight(entered > 0)
