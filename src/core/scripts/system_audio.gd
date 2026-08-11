extends Node

#@onready var SFX_BUS_ID: int = AudioServer.get_bus_index("SFX")
@onready var UISound_BUS_ID: int = AudioServer.get_bus_index("UI")

#@onready var music_stage: AudioStreamPlayer = %MusicStage
#@onready var music_stage_2: AudioStreamPlayer = %MusicStage2
@onready var music_current: AudioStreamPlayer = %MusicCurrent


# RIP memory lol

@onready var bakery_complete: AudioStreamPlayer = %BakeryComplete

@onready var sideoder_progress: AudioStreamPlayer = %SideoderProgress
@onready var sideorder_loss: AudioStreamPlayer = %SideorderLoss
@onready var medal_unlock: AudioStreamPlayer = %MedalUnlock


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
	
	tween.tween_property(music_current, "volume_db", original_music_db-low, dur)
	tween.tween_property(music_current, "volume_db", original_music_db, dur).set_delay(dur)


func lower_music(dur: float = 1.0, low: float = 15.0) -> void:
	var tween = create_tween()
	
	tween.tween_property(music_current, "volume_db", original_music_db-low, dur)
	#tween.tween_property(music_current, "volume_db", original_music_db, dur).set_delay(dur)



func off_on_ui_sound(dur: float = 1.0) -> void:
	AudioServer.set_bus_mute(UISound_BUS_ID, true)
	await get_tree().create_timer(dur).timeout
	AudioServer.set_bus_mute(UISound_BUS_ID, false)


func set_music(vol: float = original_music_db) -> void:
	music_current.volume_db = vol
	

# var _music_timer: Timer = Timer.new()
var music_path: String = "res://audio/music/stage_music_%d.ogg"
var bid: int

func start_music() -> void:
	await get_tree().create_timer(0.1).timeout

	if music_current.playing:
		return
	
	var lvl: Level = GameMgr.current_level
	var lvlid := GameMgr.level_id
	bid = GameMgr.bakery_id

	if lvl:
		if !lvl.has_started || lvlid <= 0 || lvlid >= Util.NUMBER_OF_LEVELS:
			return

	music_current.stream = load(music_path % bid)

	if bid == 1:
		original_music_db = -6.0
	elif bid == 2:
		original_music_db = 0.0

	if !music_current.playing:
		music_current.volume_db = original_music_db

		music_current.play(0.0)
		#
		#if _tween_aud:
			#_tween_aud.kill()
			#
		#_tween_aud = create_tween()
		#_tween_aud.tween_property(music_current, "volume_db", original_music_db, 1.5)
	

func stop_music() -> void:
	if music_current.playing:
		if _tween_aud:
			_tween_aud.kill()
			
		_tween_aud = create_tween()
		_tween_aud.tween_property(music_current, "volume_db", -80.0, 0.75)
		
		await _tween_aud.finished

		music_current.stop()

func _ready() -> void:
	music_current.finished.connect(func():
		if bid == 1:
			music_current.play(8.422)
		elif bid == 2:
			music_current.play(11.549)
		)
	
	#if !music_current.playing:
		#music_current.volume_db = -80.0
		#
		#music_current.play()
		#
		#if _tween_aud:
			#_tween_aud.kill()
			#
		#_tween_aud = create_tween()
		#_tween_aud.tween_property(music_current, "volume_db", original_music_db, 1.5)

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
			sfx.pitch_scale = lerpf(0.7, 1.4, GameLogic.completion_percentage)
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
