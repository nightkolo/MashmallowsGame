extends Node

#@onready var SFX_BUS_ID: int = AudioServer.get_bus_index("SFX")
@onready var UISound_BUS_ID: int = AudioServer.get_bus_index("UI")

@onready var music_stage: AudioStreamPlayer = %MusicStage

@onready var order_loss: AudioStreamPlayer = %OrderLoss
@onready var order_lost: AudioStreamPlayer = %OrderLost
@onready var order_progress_01: AudioStreamPlayer = %OrderProgress01
@onready var order_progress_02: AudioStreamPlayer = %OrderProgress02
@onready var game_reset_01: AudioStreamPlayer = %GameReset01
@onready var game_reset_02: AudioStreamPlayer = %GameReset02
@onready var trans_01: AudioStreamPlayer = %Trans1
@onready var trans_02: AudioStreamPlayer = %Trans2
@onready var trans_03: AudioStreamPlayer = %Trans3
@onready var text_01: AudioStreamPlayer = %Text1

@onready var level_info: AudioStreamPlayer = %LevelInfoOn
@onready var monolog_on: AudioStreamPlayer = %MonologOn
@onready var monolog_off: AudioStreamPlayer = %MonologOff
@onready var monolog_next: AudioStreamPlayer = %MonologNext

@onready var game_paused: AudioStreamPlayer = %GamePause
@onready var game_unpaused: AudioStreamPlayer = %GameUnpause
@onready var game_start: AudioStreamPlayer = %GameStart

@onready var ui_button_clicks: Array[AudioStreamPlayer] = [%UIButtonClick, %UIButtonClick2, %UIButtonClick3, %UIButtonClick4]

@onready var ui_button_hover: AudioStreamPlayer = %UIButtonHover

@onready var order_progress: Array[AudioStreamPlayer] = [%OrderProgress01, %OrderProgress03]

var original_music_db: float

var _tween_aud: Tween


func lower_higher_music(dur: float = 1.0, low: float = 15.0) -> void:
	var tween = create_tween()
	
	tween.tween_property(music_stage, "volume_db", original_music_db-low, dur)
	tween.tween_property(music_stage, "volume_db", original_music_db, dur).set_delay(dur)


func lower_music(dur: float = 1.0, low: float = 15.0) -> void:
	var tween = create_tween()
	
	tween.tween_property(music_stage, "volume_db", original_music_db-low, dur)
	#tween.tween_property(music_stage, "volume_db", original_music_db, dur).set_delay(dur)



func off_on_ui_sound(dur: float = 1.0) -> void:
	AudioServer.set_bus_mute(UISound_BUS_ID, true)
	await get_tree().create_timer(dur).timeout
	AudioServer.set_bus_mute(UISound_BUS_ID, false)


func set_music(vol: float = original_music_db) -> void:
	music_stage.volume_db = vol
	

# var _music_timer: Timer = Timer.new()

func start_music():
	await get_tree().create_timer(0.1).timeout

	if !GameMgr.current_level.has_started || GameMgr.level_id <= 0 || music_stage.playing:
		return

	music_stage.finished.connect(func():
		music_stage.play(8.422)
		)

	if !music_stage.playing:
		music_stage.volume_db = original_music_db
		#music_stage.volume_db = -80.0
		#
		music_stage.play(0.0)
		#
		#if _tween_aud:
			#_tween_aud.kill()
			#
		#_tween_aud = create_tween()
		#_tween_aud.tween_property(music_stage, "volume_db", original_music_db, 1.5)
	

func stop_music():
	if music_stage.playing:
		if _tween_aud:
			_tween_aud.kill()
			
		_tween_aud = create_tween()
		_tween_aud.tween_property(music_stage, "volume_db", -80.0, 0.75)
		
		await _tween_aud.finished

		music_stage.stop()

func _ready() -> void:
	original_music_db = music_stage.volume_db
	
	#if !music_stage.playing:
		#music_stage.volume_db = -80.0
		#
		#music_stage.play()
		#
		#if _tween_aud:
			#_tween_aud.kill()
			#
		#_tween_aud = create_tween()
		#_tween_aud.tween_property(music_stage, "volume_db", original_music_db, 1.5)

	GameMgr.menu_entered.connect(func(entered: GameMgr.MenuID):
		print_debug(entered)
		
		match entered:
			
			GameMgr.MenuID.PAUSE, GameMgr.MenuID.WORLD_COMPLETE, GameMgr.MenuID.RUNTIME:
				start_music()
			
			_:
				stop_music()
	)
	
	GameLogic.order_gain.connect(func(_amount: int):
		var comp : float = GameLogic.completion_percentage
		
		if comp != 1.0:
			var sfx: AudioStreamPlayer = order_progress.pick_random()
			sfx.pitch_scale = lerpf(0.8, 1.3, GameLogic.completion_percentage)
			sfx.play()
		else:
			order_progress_02.play()
		)
	GameLogic.order_loss.connect(func():
		order_loss.play()
		if GameLogic.amount_satisfied == 1:
			order_lost.play()
		)

	GameLogic.order_checked.connect(func():
		pass
		)


func play_click_cound() -> void:
	var sfx : AudioStreamPlayer = ui_button_clicks.pick_random()
	sfx.play()


var _reset_sound: bool


func play_reset_sound() -> void:
	_reset_sound = !_reset_sound
	
	if _reset_sound:
		game_reset_01.play()
	else:
		game_reset_02.play()
