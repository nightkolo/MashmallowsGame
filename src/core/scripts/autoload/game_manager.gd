extends Node

signal level_entered(is_level_id: int)
signal menu_entered(menu: MenuID)
signal game_pause_toggled(is_paused: bool)
signal game_just_ended()
signal game_end()
signal game_reset()

signal game_data_saved()
signal game_data_loaded()
signal game_medals_data_saved()
signal game_medals_data_loaded()

signal monolog_activated(active: bool)

enum MenuID {
	MENUS = 0,
	PAUSE = 1,
	WORLD_COMPLETE = 2,
	START = 3,
	TITLE = 4,
	LEVEL_SELECT = 5,
	CREDITS = 6,
	RUNTIME = 100,
	MISC = 101
	}

var menu_id: MenuID
var bakery_id: int = 0
var level_id: int = 0:
	set(value):
		if value > 0 && value < Util.NUMBER_OF_LEVELS:
			GameData.runtime_data["last_level"] = value
		elif value == Util.NUMBER_OF_LEVELS:
			GameData.runtime_data["last_level"] = 0
		
		level_id = value
		
		await get_tree().create_timer(1.0).timeout
		
		save_game_data()

# Self-assigned by the Entites
var current_level: Level
var current_player: Player
var current_NPC: NPCBoard ## Used for quicker access by [ResetNoticeArea]
var current_ui_handler: GameplayUI ## @experimental
var current_level_goal: LevelGoal
var current_camera: Cam

var game_has_ended: bool
#var is_monolog_active: bool
## Level Begin
# Variables self-assigned

var saver_loader: SaverLoader = SaverLoader.new()


func _input(event: InputEvent) -> void:
	pass
	#if event.is_action_pressed("game_reset"):
		#game_reset.emit()
		
	#if event.is_action_pressed("debug_next"):
		#if level_id != 0:
			#goto_next_level()
	#
	#if event.is_action_pressed("debug_prev"):
		#goto_next_level(-1)


const ON_NEWGROUNDS_MIRROR = false
const VER = 100

func _ready() -> void:
	add_child(saver_loader)
	
	load_game_data()
	saver_loader.save_level_data()
	
	if ON_NEWGROUNDS_MIRROR:
		#NG.on_session_change.connect(session_change)
		
		load_game_medals_data()
	
	if !GameData.runtime_data.has("ver"):
		reset_game_data()
		
	elif GameData.runtime_data["ver"] != VER:
		# TODO Adapt game data
		reset_game_data()
	
	set_adult_filter_on(GameData.runtime_data["op_a_on"])
	set_game_sfx_muted(GameData.runtime_data["op_sfx_muted"])
	set_game_music_muted(GameData.runtime_data["op_music_muted"])
	
	menu_entered.connect(func(menu: MenuID):
		menu_id = menu
		
		InputPrompts.select_inputs.visible = false
		InputPrompts.move_inputs.visible = false
		InputPrompts.back_inputs.visible = false
		InputPrompts.tutorial_inputs.visible = false
		
		match menu:
			MenuID.WORLD_COMPLETE:
				InputPrompts.visible = true
				InputPrompts.select_inputs.visible = true
				
			MenuID.TITLE, MenuID.PAUSE:
				InputPrompts.visible = true
				InputPrompts.select_inputs.visible = true
				InputPrompts.move_inputs.visible = true
			
			MenuID.LEVEL_SELECT:
				InputPrompts.visible = true
				InputPrompts.select_inputs.visible = true
				InputPrompts.move_inputs.visible = true
				InputPrompts.back_inputs.visible = true
				InputPrompts.tutorial_inputs.visible = true
				
			MenuID.CREDITS:
				InputPrompts.visible = true
				InputPrompts.back_inputs.visible = true
				
			_:
				InputPrompts.visible = false
		)
	
	game_just_ended.connect(func():
		await get_tree().create_timer(Util.ORDER_COMPLETE_WAIT_TIME_BEFORE_TRANSITION).timeout
		
		game_end.emit()
		)
	
	game_end.connect(order_complete)
		
	game_reset.connect(func():
		Trans.reset_level()
		
		#GameLogic.reset_game_logic()
		#get_tree().reload_current_scene()
		)

func order_complete() -> void:
	if level_id % 10 == 0:
		bakery_complete()
	else:
		goto_next_level()


func bakery_complete() -> void:
	if current_ui_handler:
		
		current_ui_handler.the_checkerboard_has_been_checkered()


func reset_game_data() -> void:
	saver_loader.new_game()
	saver_loader.new_game_medals()


func save_game_data() -> void:
	saver_loader.save_game()


func load_game_data() -> void:
	saver_loader.load_game()
	
	
func save_game_medals_data() -> void:
	saver_loader.save_medals()


func load_game_medals_data() -> void:
	saver_loader.load_medals()


func reset_game() -> void:
	GameLogic.reset_game_logic()
	get_tree().reload_current_scene()


func goto_next_checkerboard() -> void:
	Audio.stop_music()
	
	goto_next_level(1, true)
	
	if level_id + 1 <= Util.NUMBER_OF_LEVELS:
		await get_tree().create_timer(1.5).timeout
		Audio.set_music()
		


func goto_next_level(strength: int = 1, force_progression: bool = false) -> void:
	if !force_progression && !OS.has_feature("web"):
		if !current_level:
			return
		
		if current_level.no_progression:
			return
	
	print_debug("Moving to next level")

	var next_lvl_id := current_level.scene_file_path.to_int() + strength
	var next_lvl_path := Util.LEVEL_FILE_BEGIN + str(next_lvl_id) + Util.LEVEL_FILE_END
	
	if next_lvl_id <= Util.NUMBER_OF_LEVELS: 
	
		if ResourceLoader.exists(next_lvl_path):
			Trans.slide_to_next_stage(next_lvl_path)
		else:
			push_error("Level file missing: " + next_lvl_path)
			
	else:
		Trans.slide_to_endlevel(1.0)
		#Trans.slide_to_scene("res://interface/menus/thank_you_screen.tscn")
		game_has_ended = true

# Config
@onready var SFX_BUS_ID: int = AudioServer.get_bus_index("SFX")
@onready var Music_BUS_ID: int = AudioServer.get_bus_index("Music")

var _game_sfx_muted: bool = false:
	get:
		return _game_sfx_muted
	set(value):
		GameData.runtime_data["op_sfx_muted"] = value
		AudioServer.set_bus_mute(SFX_BUS_ID, value)
		_game_sfx_muted = value
		save_game_data()
var _game_music_muted: bool = false:
	get:
		return _game_music_muted
	set(value):
		GameData.runtime_data["op_music_muted"] = value
		AudioServer.set_bus_mute(Music_BUS_ID, value)
		_game_music_muted = value
		save_game_data()
var _adult_filter_on: bool = false:
	get:
		return _adult_filter_on
	set(value):
		GameData.runtime_data["op_a_on"] = value
		_adult_filter_on = value
		save_game_data()


func set_adult_filter_on(value: bool) -> void:
	_adult_filter_on = value


func get_adult_filter_on_setting() -> bool:
	return _adult_filter_on


func set_game_sfx_muted(value: bool) -> void:
	_game_sfx_muted = value


func get_game_sfx_muted_setting() -> bool:
	return _game_sfx_muted


func set_game_music_muted(value: bool) -> void:
	_game_music_muted = value


func get_game_music_muted_setting() -> bool:
	return _game_music_muted
##
