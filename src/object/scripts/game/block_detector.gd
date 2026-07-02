@tool
extends Node2D
class_name BlockDetector

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
@onready var wall_ray: ShapeCast2D = $WallRay
@onready var unmashed_block_detection_rays: Array[RayCast2D] = [$Down, $Right, $Left]
@onready var cherry_bomb_rays: Array[RayCast2D] = [$CherryBombRays/Up, $CherryBombRays/Right, $CherryBombRays/Left]

@onready var dubbleganger_detect_1x1: Area2D = $DubblegangerDetect1x1
@onready var unmashed_block_detect_1x1: Area2D = $UnmashedBlockDetect1x1
@onready var unmashed_block_detect_1x2: Area2D = $UnmashedBlockDetect1x2

var parent_block: Mashed


func update_index(moving_toward: String):
	
	pass


func is_colliding() -> bool:
	for ray: RayCast2D in unmashed_block_detection_rays:
		ray.force_raycast_update()
		if ray.get_collider() is Unmashed || ray.get_collider() is TwistedColliBlock || ray.get_collider() is Player:
			return true
	return false



func notify_highlight_state(unmashed_block_detected: Node2D, entered: int):
	
	parent_block.anim_highlight(is_colliding())
	if unmashed_block_detected is Unmashed:
		#parent_block.anim_highlight(is_colliding())

		# NOTE: Critical section, increment solution for Unmashed.anim_highlight function call
		(unmashed_block_detected as Unmashed).amount_collided_with += entered
		#
	elif unmashed_block_detected is TwistedColliBlock:
		(unmashed_block_detected as TwistedColliBlock).parent_unmashed.amount_collided_with += entered


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
			
			
