extends CanvasLayer

signal level_entered()
signal menu_entered(menu: Menus)
signal game_pause_toggled(is_paused: bool)
signal game_just_ended()
signal game_end()
signal game_reset()
signal monolog_activated(active: bool)

enum Menus {START, PAUSE, MENUS, RUNTIME, MISC}

## Self-assigned by the Entites
var current_level_number: int:
	set(value):
		if current_level_goal:
			current_level_goal.level_number_label.text = "1-" + str(value)
		current_level_number = value
var current_level: Level:
	set(value):
		current_level = value
		#current_level.show_dev_ui = true
var current_level_world: World
var current_menu: Menus
var current_player: Player
var current_order_checker: OrderChecker
var current_NPC: NPCBoard
var current_ui_handler: GameplayUI
var current_level_goal: LevelGoal
var current_camera: Cam

var game_has_ended: bool
var is_monolog_active: bool
## Level Begin
# Variables self-assigned


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("game_reset"):
		game_reset.emit()
		
	# if event.is_action_pressed("debug_next"):
	# 	if current_level_number != 0:
	# 		goto_next_level()
	
	# if event.is_action_pressed("debug_prev"):
	# 	goto_next_level(-1)


func _ready() -> void:
	#Engine.time_scale = 1.0/8.0
	
	menu_entered.connect(func(menu: Menus):
		current_menu = menu
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
