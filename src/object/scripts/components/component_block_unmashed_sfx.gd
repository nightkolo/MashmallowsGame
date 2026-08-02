extends Node2D
class_name UnmashedAudio

#@onready var land_sfx: Array[AudioStreamPlayer2D] = [$Land01, $Land02, $Land03, $Land04]
@onready var vocal_sfx: Array[AudioStreamPlayer2D] = [$Vocal01, $Vocal02, $Vocal03, $Vocal04]
@onready var sleep_sfx: AudioStreamPlayer2D = $Sleep 
@onready var drop_sfx: AudioStreamPlayer2D = $Drop

@onready var twisted_rise: AudioStreamPlayer2D = $TwistedRise
@onready var twisted_rise_alert: AudioStreamPlayer2D = $TwistedRiseAlert
@onready var twisted_rise_stop: AudioStreamPlayer2D = $TwistedRiseStop



func _ready():
	if get_parent() is Unmashed:
		var block: Unmashed = get_parent() as Unmashed

		block.expanding_stopped.connect(func():
			twisted_rise_stop.play()
			if twisted_rise.playing:
				twisted_rise.stop()
			)
		block.expanding_entered.connect(func():
			twisted_rise_alert.pitch_scale = randf_range(0.8, 1.2)
			twisted_rise_alert.play()
			)
		block.expanding_started.connect(func():
			twisted_rise.play()
		)

		#block.has_landed.connect(func(strength: float):
			#if block.attributes.slippery_block:
				#return
				#
			#var sfx: AudioStreamPlayer2D = land_sfx.pick_random()
			#sfx.play()
		#)
		sleep_sfx.finished.connect(func(): sleep_sfx.play() )

		block.started_breathing.connect(func():
			sleep_sfx.play()
		)
		block.player_entered.connect(func(entered: bool):
			if GameMgr.current_player == null:
				return
			
			if entered && GameMgr.current_player.is_active:
				sleep_sfx.volume_db = -14.0
			else:
				sleep_sfx.volume_db = -80.0
		)
		
		

func play_spawn_sound() -> void:
	var sfx: AudioStreamPlayer2D = vocal_sfx.pick_random()
	# sfx.volume_db = -20.0
	sfx.play()
