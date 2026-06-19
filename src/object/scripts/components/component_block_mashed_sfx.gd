extends Node2D
class_name MashedAudio

@onready var vocal_sfx: Array[AudioStreamPlayer2D] = [$Vocal01, $Vocal02]
@onready var vocal_cb_sfx: AudioStreamPlayer2D = $VocalCB

func _ready():
	if get_parent() is Mashed:
		var block: Mashed = get_parent() as Mashed
		
		await get_tree().create_timer(0.2).timeout
		
		if block.mash_type != Util.MashType.MISC:
			block.attribute_set.connect(func():
				if block.parent_player:
					if block.parent_player.child_blocks.size() == 1:
						return

				match block.attributes.mash_type:

					Util.MashType.CHERRY_BOMB, Util.MashType.AIR_CHERRY_BOMB:
						vocal_cb_sfx.play()

					_:
						play_mashed_vocal_sfx()
			)


func play_mashed_vocal_sfx():
	var sfx: AudioStreamPlayer2D = vocal_sfx.pick_random()
	sfx.play()
