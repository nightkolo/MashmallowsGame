extends CanvasLayer

signal level_entered()
signal menu_entered(menu: MenuID)
signal game_pause_toggled(is_paused: bool)
signal game_just_ended()
signal game_end()
signal game_reset()

signal game_data_saved()
signal game_data_loaded()

signal monolog_activated(active: bool)

enum MenuID {
	MENUS = 0,
	PAUSE = 1,
	WORLD_COMPLETE = 2,
	START = 3,
	CREDITS = 4,
	RUNTIME = 100,
	MISC = 101
	}

var menu_id: MenuID
var level_id: int:
	set(value):
		if current_level_goal:
			current_level_goal.level_number_label.text = "1-" + str(value)
		level_id = value

# Self-assigned by the Entites
var current_level: Level
var current_level_world: World ## @deprecated
var current_menu: MainMenusUI ## @deprecated
var current_player: Player
var current_order_checker: OrderChecker ## @deprecated
var current_NPC: NPCBoard ## Used for quicker access by [ResetNoticeArea]
var current_ui_handler: GameplayUI ## @experimental
var current_level_goal: LevelGoal
var current_camera: Cam

var game_has_ended: bool
var is_monolog_active: bool
## Level Begin
# Variables self-assigned

var saver_loader: SaverLoader = SaverLoader.new()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("game_reset"):
		game_reset.emit()
		
	# if event.is_action_pressed("debug_next"):
	# 	if level_id != 0:
	# 		goto_next_level()
	
	# if event.is_action_pressed("debug_prev"):
	# 	goto_next_level(-1)


func _ready() -> void:
	add_child(saver_loader)
	
	load_game_data()
	
	menu_entered.connect(func(menu: MenuID):
		menu_id = menu
		
		match menu:
			
			MenuID.RUNTIME, MenuID.MISC, MenuID.START:
				InputPrompts.visible = false
			
			_:
				InputPrompts.visible = true
		)
	
	game_just_ended.connect(func():
		await get_tree().create_timer(Util.ORDER_COMPLETE_WAIT_TIME).timeout
		
		game_end.emit()
		)
	
	game_end.connect(goto_next_level)
		
	game_reset.connect(func():
		Trans.reset_level()
		
		#GameLogic.reset_game_logic()
		#get_tree().reload_current_scene()
		)

func reset_game_data() -> void:
	saver_loader.new_game()
	saver_loader.new_game_medals()


func save_game_data() -> void:
	saver_loader.save_game()


func load_game_data() -> void:
	saver_loader.load_game()
	

func reset_game() -> void:
	GameLogic.reset_game_logic()
	get_tree().reload_current_scene()


func goto_next_level(strength: int = 1) -> void:
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
		Trans.slide_to_scene("res://interface/menus/thank_you_screen.tscn")
		game_has_ended = true

# Config

@onready var SFX_BUS_ID: int = AudioServer.get_bus_index("SFX")
@onready var Music_BUS_ID: int = AudioServer.get_bus_index("Music")


var _game_sfx_muted: bool = false:
	get:
		return _game_sfx_muted
	set(value):
		AudioServer.set_bus_mute(SFX_BUS_ID, value)
		_game_sfx_muted = value
var _game_music_muted: bool = false:
	get:
		return _game_music_muted
	set(value):
		AudioServer.set_bus_mute(Music_BUS_ID, value)
		_game_music_muted = value

func set_game_sfx_muted(value: bool) -> void:
	_game_sfx_muted = value


func get_game_sfx_muted_setting() -> bool:
	return _game_sfx_muted


func set_game_music_muted(value: bool) -> void:
	_game_music_muted = value


func get_game_music_muted_setting() -> bool:
	return _game_music_muted

##
