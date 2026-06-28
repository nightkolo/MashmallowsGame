## Under construction
class_name Player
extends CharacterBody2D

# INPUT EVENTS
signal has_mashed(pos: Vector2, build: Util.BuildType)
signal has_unmashed()
signal has_jumpped() ## Emits when player has jumpped.
signal has_moved() ## Emits when player enters [RunState]
signal has_idled() ## Emits when player enters [IdleState]

# GAMEPLAY EVENTS
signal has_waken_up()
signal has_touched_flame()
signal has_landed(strength: float)
signal has_touched_ceiling()
signal cherry_bomb_activated()
signal cherry_bomb_exploded()
signal is_running() ## Emits when player is in [RunState] at full [member speed] after accelerating.
signal has_stopped() ## Emits when player full stops ([code]velocity == 0.0[/code]), regardless of state. (i.e. hits wall)

# LOGIC
signal check_finished()

@export var animate: bool = true
@export var dubbleganger: bool = false:
	set(value):
		set_active(!value)
		dubbleganger = value
@export var start_asleep: bool = false:
	set(value):
		start_asleep = value
		is_active = !value
@export var auto_assign_child_blocks: bool = true
@export_group("Movement Variables")
@export_range(-600.0, 600.0, 1.0, "or_greater", "or_less") var speed: float = 450.0
@export_range(-1500.0, 1500.0, 1.0, "or_greater", "or_less") var acceleration: float = 800.0
@export_range(-2000.0, 2500.0, 1.0, "or_greater", "or_less") var deceleration: float = 1000.0
@export_range(-400.0, 400.0, 1.0, "or_greater", "or_less") var jump_height: float = 1100.0
@export_group("Appearance")
@export var show_trail: bool = true
@export var show_blocks: bool = true
@export var show_light: bool = true:
	set(value):
		$TerrainLight.enabled = value
		show_light = value

@export_category("Objects to Assign")
@export var animator: PlayerAnimationComponent
@export var state_machine: StateMachine
@export var original_block: Mashed

@onready var audio: PlayerAudio = $Audio
@onready var audio_listener: AudioListener2D = $AudioListener2D
@onready var jump_window_timer: Timer = %JumpBufferTimer
@onready var coyote_jump_timer: Timer = %CoyoteJumpTimer
@onready var cherry_bomb_air_timer: Timer = %CherryBombAirTimer
@onready var idle_timer: Timer = %IdleTimer
@onready var mashed: Mashed = $Mashed
#@onready var mashed_nodes: Node2D = $MashedNodes

@onready var node_player_zoom_trans: Node2D = $PlayerZoomTrans
@onready var trans_nodes: Array[Sprite2D] = [%TransR,%TransL,%TransD,%TransU]
# @onready var sprite_player_zoom_in: Sprite2D = %PlayerZoomIn
@onready var reset_notice: Node2D = $ResetNotice
@onready var mash_notice: Node2D = $MashNotice
@onready var particles_m: CPUParticles2D = $Z
var unmashed_object: PackedScene = preload("res://object/objects/block_unmashed_1x1.tscn")
var unmashed_object_1x2: PackedScene = preload("res://object/objects/block_unmashed_1x2.tscn")

var stop_deceleration: float = deceleration * 4.0
var air_deceleration: float = deceleration / 1.25
var flown_deceleration: float = deceleration / 3.2
var input_direction: float
var input_y: float

#var posses: Array[Dictionary] = [ ## Template
	#{"type": Util.MashType.WHITE, "pos": Vector2.ZERO},
	#{"type": Util.MashType.HEART, "pos": Vector2.ZERO}
#]


var is_active: bool = true
#var is_sticky_platform_present: bool = false
var player_blocks_code: Array[Dictionary] = []
var child_blocks: Array[Mashed] = [] # Stack data structure
		
func push_child_block(block: Mashed) -> void:
	child_blocks.append(block)

	player_blocks_code.append({
		"type": block.mash_type,
		"pos": Vector2(
			block.position.x / Util.BLOCK_SIZE,
			block.position.y / Util.BLOCK_SIZE
		)
	})
	
	GameLogic.player_mashed.emit()
	print_debug(player_blocks_code)


func pop_child_block() -> Mashed:
	player_blocks_code.pop_back()
	#print_debug(player_blocks_code)
	return child_blocks.pop_back()


var new_child_blocks: Array[Mashed] # Stack data structure

var is_sleeping: bool:
	set(value):
		particles_m.emitting = value
		is_sleeping = value
var is_exploding: bool

#var is_active: bool = false

# Anim
var tween_jump: Tween

var _stopped: bool
var _landed: bool
var _pos_before_mash: Vector2
var _has_mashed: bool
var _last_velocity_y: float = 0.0




func show_reset_notice(wait: float = 4.0) -> void:
	if reset_notice.visible:
		return 
		
	reset_notice.modulate = Color(Color.WHITE, 0.0)
	reset_notice.visible = true
	
	await get_tree().create_timer(wait).timeout
	
	var tween = create_tween()
	tween.tween_property(reset_notice, "modulate", Color(Color.WHITE), 1.0)


func _ready() -> void:
	GameMgr.current_main_player = self
	
	if original_block:
		original_block.is_original = true

	for child: Mashed in child_blocks:
		child.node_block_sprites.visible = show_blocks
	
	if start_asleep:
		set_active(false)
	anim_idle_animation()

	## EVENTS
	has_touched_ceiling.connect(func():
		print("has_touched_ceiling")
		)
	has_landed.connect(func(strength: float):
		var s := strength / 80.0
		
		Input.start_joy_vibration(0, s / 2.0, s, 0.025)

		if input_y > 0.0:
			animator.anim_down(true, true)
		)
	has_jumpped.connect(func():
		Input.start_joy_vibration(0, 0.05, 0.0, 0.1)
		)
	has_mashed.connect(func(pos: Vector2, _build: Util.BuildType):
		Input.start_joy_vibration(0, 0.4, 0.0, 0.025)
		
		if !_has_mashed:
			_has_mashed = true
		
		await get_tree().create_timer(0.025).timeout
		
		_check_child_blocks()
		await get_tree().create_timer(0.01).timeout
		Input.start_joy_vibration(0, 0.0, 0.5, 0.025)
		)
	has_touched_flame.connect(func():
		GameLogic.player_touched_flame.emit()
	)
	cherry_bomb_activated.connect(func():
		cherry_bomb_air_timer.start()
		)
	
	new_child_blocks.clear()


func set_active(active: bool = !is_active) -> void:
	is_active = active
	
	if active:
		sleep()
	else:
		wake_up()


func sleep(animate_zoom: bool = true):
	is_sleeping = true
	#is_active = true
	if original_block:
		original_block.is_original = true

		original_block.set_asleep(self, !animate_zoom)
	
	if animate_zoom:
		mash_notice.visible = true
		if animator:
			animator.anim_tease_zoom_out()
	# if animator:
	# 	animator.pause_anim_eye_wobble()


func wake_up(animate_zoom: bool = true):
	is_sleeping = false
	mash_notice.visible = false
	#is_active = false
	has_waken_up.emit()

	if animator && animate_zoom:
		animator.anim_zoom_out()

		has_mashed.emit(Vector2.ZERO, original_block.attributes.build_type)
		original_block.anim_awake()
		if original_block.audio:
			original_block.audio.play_mashed_vocal_sfx()
		animator.anim_eye_wobble()


func anim_idle_animation():
	idle_timer.start()
	state_machine.player_state_changed.connect(func(state: State):
		if !(state is IdleState):
			idle_timer.stop()
		else:
			if idle_timer.is_stopped():
				idle_timer.start()
	)

	idle_timer.timeout.connect(func():
		
		# TODO: Issue, animation not starting on newly mashed blocks
		for block: Mashed in child_blocks:
			if !block.is_on_ground() || !block.is_on_block():
				continue

			if block.anim.is_playing():
				block.anim.stop()

			block.is_idle_animating = true
			block.anim.play("idle", -1, 0.75)
			await block.anim.animation_finished
			block.anim.play("RESET")
			block.is_idle_animating = false
		)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_mash"):
		mash_child_blocks()

		if start_asleep && is_active:
			set_active(true)
	
	if event.is_action_pressed("move_active"):
		is_active = !is_active
	
	if event.is_action_pressed("move_unmash"):
		unmash()
		
	if event.is_action_released("move_jump"):
		Input.stop_joy_vibration(0)

	if event.is_action_pressed("move_down"):
		drop()

	if event.is_action_released("move_down"):
		animator.anim_down(false, true)


func drop() -> void:
	animator.anim_down(true)
	position.y += 10.0


func mash_child_blocks() -> void: ## Ok -> O(n)
	if !can_perform_mash():
		return

	if input_y > 0.0:
		return
	
	var blocks: Array[Mashed] = child_blocks.duplicate(true) # To avoid infinite recursion
	_pos_before_mash = position
	
	for block: Mashed in blocks:
		var res := await block.mash()
		
		if res:
			animator.anim_down(false, true)
			
			break


func is_colliding() -> bool:
	for block: Mashed in child_blocks:
		if block.block_detect.is_colliding():
			return true
			
	return false



func unmash() -> void: # -> O(1)
	if !can_unmash():
		return
	
	var old_mashed: Mashed = child_blocks[-1]
	_pos_before_mash = position
	
	match old_mashed.mash_type:
		Util.MashType.CHERRY_BOMB:
			if state_machine.current_state is AirState:
				return
				
			has_unmashed.emit()
			_handle_cherry_bomb(old_mashed)
			
		Util.MashType.AIR_CHERRY_BOMB:
			has_unmashed.emit()
			_handle_cherry_bomb(old_mashed)
			
		_:
			if state_machine.current_state is AirState:
				return
			
			has_unmashed.emit()
			
			pop_child_block()

			# ATTRIBUTE SYNC
			var unmashed: Unmashed = get_unmashed_object(old_mashed.build_type)
			unmashed.global_position = old_mashed.global_position
			unmashed.attributes = old_mashed.attributes.duplicate(true)
			unmashed.twisted_strength = old_mashed.twisted_strength
			unmashed.was_mashed = true
			#

			old_mashed.queue_free()
			GameMgr.current_level.add_child(unmashed)
			
			Input.start_joy_vibration(0, 0.0, 0.5, 0.025)

			await return_position()
			await get_tree().create_timer(0.025).timeout
			
			Input.start_joy_vibration(0, 0.2, 0.0, 0.025)

	GameLogic.player_unmashed.emit()


func _handle_cherry_bomb(old_mashed: Mashed) -> void:
	is_exploding = true
	cherry_bomb_activated.emit()
	
	var push_to: Vector2 = Vector2.ZERO
	var stre: float = old_mashed.cherry_bomb_strength
	
	for ray: RayCast2D in old_mashed.block_detect.cherry_bomb_rays:
		ray.force_raycast_update()
		if ray.get_collider() is Player:
			push_to = -ray.target_position.sign()
	
	old_mashed.cherry_bomb_activated.emit(push_to)
	
	var time := Util.CHERRY_BOMB_WAITTIME_BEFORE_EXPLODING if old_mashed.mash_type == Util.MashType.CHERRY_BOMB else 0.0
	
	await get_tree().create_timer(time).timeout
	
	pop_child_block()
	
	explode(push_to, stre)
	Input.start_joy_vibration(0, 0.25, 0.85, 0.025)
	
	old_mashed.queue_free()
	
	is_exploding = false


func explode(push: Vector2, strength: float = 1600.0) -> void:
	cherry_bomb_exploded.emit()
	GameLogic.cherry_bomb_exploded.emit()
	
	if absf(push.y) > absf(push.x) && velocity.y > 0:
		velocity.y = 0.0
	
	velocity += -push * strength
	
	state_machine.change_state("AirState", {"jumped": false, "falling": false})


# TODO: Move to GameLogic
func get_unmashed_object(type: Util.BuildType) -> Unmashed:
	match type:
		Util.BuildType.SQUARE:
			return unmashed_object.instantiate()
		Util.BuildType.RECTANGLE:
			return unmashed_object_1x2.instantiate()
		_:
			return null


func is_being_flown() -> bool:
	return cherry_bomb_air_timer.time_left > 0.0


func can_perform_mash() -> bool:
	return !(
		child_blocks[-1].mash_type == Util.MashType.CHERRY_BOMB ||
		child_blocks[-1].mash_type == Util.MashType.AIR_CHERRY_BOMB
		) && !GameLogic.has_won


func can_one_child_block_mash() -> bool:
	if is_exploding:
		return false
	
	for block: Mashed in child_blocks:
		if block.block_detect.is_colliding():
			return true
	return false
	
		
func can_unmash() -> bool:
	return child_blocks.size() > 1 && !is_exploding && !GameLogic.has_won && !(input_y > 0.0)


func return_position() -> void:
	await get_tree().create_timer(0.01).timeout
	
	position = _pos_before_mash


func is_tall_block_mashed() -> bool:
	if child_blocks.size() == 1:
		return false
	
	for block: Mashed in child_blocks:
		if block.build_type == Util.BuildType.RECTANGLE:
			return true
	
	return false

func stop_jump_sfx() -> void:
	if audio.sfx_jump_single.playing:
		audio.sfx_jump_single.stop()
	if audio.sfx_jump_mult.playing:
		audio.sfx_jump_mult.stop()
	if audio.sfx_jump_heavy.playing:
		audio.sfx_jump_heavy.stop()


func jump() -> void:
	if is_exploding:
		return
	
	if audio.fall_sfx.playing:
		audio.fall_sfx.stop()
		
	if is_tall_block_mashed():
		audio.sfx_jump_heavy.play()
	else:
		if child_blocks.size() > 1:
			audio.sfx_jump_mult.play()
		else:
			audio.sfx_jump_single.play()
	
	has_jumpped.emit()
	
	#var strength := -jump_height * 0.65 if is_on_sticky_platform() else -jump_height
	
	velocity.y = -jump_height
	move_and_slide()
	
	state_machine.change_state("AirState", {"jumped": true, "falling": false})

## Returns true if the player on a unmashed block (including [TwistedColliBlock]).
func is_on_block(twisted_only: bool = false) -> bool:
	var cond: bool = twisted_only
	
	for block: Mashed in child_blocks:
		if cond:
			var obj: Node2D = block.block_detect.blocks_ray.get_collider(0)
			
			if obj is Unmashed:
				if (obj as Unmashed).mash_type == Util.MashType.TWISTED:
					return true
		elif block.is_on_block():
			return true
	return false
	
	
## Returns true if the player on ground tilemap, and not other unmashed blocks
## -> Worst case, O(n)
func is_on_ground() -> bool: 
	for block: Mashed in child_blocks:
		if block.is_on_ground():
			return true
	return false


## Returns true if the player on stiky platform only.
## -> Worst case, O(n)
## @experimental
#func is_on_sticky_platform() -> bool:
	#if !is_sticky_platform_present:
		#return false
	#
	#for block: Mashed in child_blocks:
		#if block.is_on_sticky_platform():
			#return true
	#return false


var _prev_position: Vector2
var velocity_position_based: Vector2

## Computes velocity from global_position
func get_position_based_velocity(global_pos: Vector2, delta: float) -> Vector2:
	if delta <= 0.0:
		return Vector2.ZERO
	
	var vel := (global_pos - _prev_position) / delta
	_prev_position = global_pos
	return vel


func _move(delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * delta
		
	var was_on_floor = is_on_floor()
	
	_last_velocity_y = velocity.y
	
	velocity_position_based = get_position_based_velocity(global_position, delta)
	
	move_and_slide()

	## Jump logic, w/ coyote jump and buffer jump
	## Fell off platform
	if was_on_floor && !is_on_floor() && velocity.y >= 0.0:
		coyote_jump_timer.start()
		
		state_machine.change_state("AirState", {"jumped": false, "falling": true})
	
	
	if is_active && Input.is_action_just_pressed("move_jump"):
		if coyote_jump_timer.time_left > 0.0:
			jump()
		else:
			jump_window_timer.start()
		
		if (!is_on_floor() && !is_on_ground() && Math.is_equal_approx_custom(velocity_position_based.y, 0.0, 1.0)):
			jump()
			
	## If the player in on the floor and within the jump window/jump buffer timer, then jump
	## The player is stuck
	if is_on_floor() && !jump_window_timer.is_stopped():
		jump()
		
	if !is_active:
		input_direction = 0.0
		input_y = 0.0
	else:
		input_direction = Input.get_axis("move_left", "move_right")
		input_y = Input.get_axis("move_up", "move_down")



var _run: bool
var _ceiling: bool

func is_running_full() -> bool:
	return absf(velocity.x) == speed

func _state() -> void:
	# var stop := is_equal_approx(velocity.x, 0.0)

	if state_machine.current_state is RunState && is_running_full() && !_run:
		is_running.emit()
		_run = true

	if (velocity.x == 0.0) && !_stopped:
		has_stopped.emit()
		_stopped = true
		_run = false

	elif velocity.x != 0.0:
		_stopped = false

	if !_ceiling && is_on_ceiling():
		has_touched_ceiling.emit()
		_ceiling = true
		
	elif is_on_floor():
		_ceiling = false

	if !_landed && is_on_floor():
		has_landed.emit(abs(_last_velocity_y / 100.0))
		_landed = true
		
	if !is_on_floor():
		_landed = false
		
	if is_on_ceiling() && tween_jump:
		tween_jump.kill()
		
		for block: Mashed in child_blocks:
			block.sprite_block.scale = Vector2.ONE * 0.5


func _animate(delta: float) -> void:
	# TODO: Refactor
	
	for block: Mashed in child_blocks:
		if block:
			var node: Node2D = block.node_eye_sprites
			var move_y := input_y * 12.0 if (input_y != 0.0) && is_on_floor() else minf(12.0, velocity_position_based.y / 50.0)
			node.position = Vector2(
				move_toward(node.position.x, input_direction * 6.0, delta * 100.0),
				move_toward(node.position.y, move_y, delta * 200.0)
			) 


func _physics_process(delta: float) -> void:
	if !GameLogic.is_checking_order_match:
		_move(delta)
	_state()
	_animate(delta)
	
	#print(is_on_ceiling())
	

func _check_child_blocks() -> void:
	if new_child_blocks.is_empty():
		return
	
	# TODO: Fix for 1x2 blocks
	# There's issues probably
	
	for i in range(1, new_child_blocks.size()):
		if new_child_blocks[i].position == new_child_blocks[0].position:
			new_child_blocks[i].queue_free()
			pop_child_block()
			
	new_child_blocks.clear()
	_has_mashed = false
	
	check_finished.emit()
