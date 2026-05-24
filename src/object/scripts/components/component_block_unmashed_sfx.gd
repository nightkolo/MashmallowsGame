extends Node2D
class_name UnmashedAudio

@onready var land_sfx: Array[AudioStreamPlayer2D] = [$Land01, $Land02, $Land03, $Land04]
@onready var vocal_sfx: Array[AudioStreamPlayer2D] = [$Vocal01, $Vocal02, $Vocal03, $Vocal04]
@onready var sleep_sfx: AudioStreamPlayer2D = $Sleep 


func _ready():
	if get_parent() is Unmashed:
		var block: Unmashed = get_parent() as Unmashed

		block.has_landed.connect(func(strength: float):
			var sfx: AudioStreamPlayer2D = land_sfx.pick_random()
			sfx.play()
		)
		sleep_sfx.finished.connect(func(): sleep_sfx.play() )

		block.started_breathing.connect(func():
			sleep_sfx.play()
		)
		# block.player_entered.connect(func(entered: bool):
		# 	if entered:
		# 		sleep_sfx.volume_db = -14.0
		# 	else:
		# 		sleep_sfx.volume_db = -80.0
		# 	)

func play_spawn_sound() -> void:
	var sfx: AudioStreamPlayer2D = vocal_sfx.pick_random()
	# sfx.volume_db = -20.0
	sfx.play()