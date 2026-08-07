extends Node2D
class_name PlayerAudio

@export var sfx_jump_single: AudioStreamPlayer2D
@export var sfx_jump_mult: AudioStreamPlayer2D
@export var sfx_jump_heavy: AudioStreamPlayer2D
@export var slide_sfx: AudioStreamPlayer2D
@export var fall_sfx: AudioStreamPlayer2D
@export var sfx_unmash_enter: AudioStreamPlayer2D
@export var sfx_unmash_exit: AudioStreamPlayer2D

@onready var listener: AudioListener2D = $AudioListener2D

@onready var land_hard_01: AudioStreamPlayer2D = $LandHard01
@onready var mash_01: AudioStreamPlayer2D = $Mash01
@onready var mash_02: AudioStreamPlayer2D = $Mash03
@onready var unmash_01: AudioStreamPlayer2D = $Unmash01
@onready var bomb: AudioStreamPlayer2D = $Bomb
@onready var laugh: AudioStreamPlayer2D = $Laugh
@onready var squash: AudioStreamPlayer2D = $Squash
@onready var stretch: AudioStreamPlayer2D = $Stretch
@onready var drop: AudioStreamPlayer2D = $Drop

@onready var land_sfx: Array[AudioStreamPlayer2D] = [$Land01, $Land02, $Land03, $Land04]

var player: Player

func _ready() -> void:
	if get_parent() is Player:
		player = get_parent() as Player
	
	else:
		return
	
	#await get_tree().create_timer(0.5).timeout
	
	player.has_unmashed.connect(func():
		if player.screen_notifier.is_on_screen():
			unmash_01.play()
		
		#if GameLogic.current_door:
			#if GameLogic.current_door.is_open:
				#drop.play()
		)
	player.has_landed.connect(func(strength: float):
		if !player.screen_notifier.is_on_screen():
			return
		
		var sfx: AudioStreamPlayer2D = land_sfx.pick_random()
		sfx.play()
		
		if strength > 12.0:
			land_hard_01.play()
		)
	player.cherry_bomb_exploded.connect(func():
		if !player.screen_notifier.is_on_screen():
			return
		
		bomb.play()
		laugh.play()
		)

	player.has_mashed.connect(func(pos: Vector2, _build: Util.BuildType):
		if !player.screen_notifier.is_on_screen():
			return
		
		if player.state_machine.current_state is AirState:
			mash_01.play()
		else:
			mash_02.play()
		)
		
