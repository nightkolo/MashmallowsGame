@tool
extends Node2D
class_name Level

@export var level_id: int = -1
@export var bakery_id: int = -1
@export var spawn_anim_time: float = 0.75
@export var set_for_each: bool = false
@export var spawn_anim_time_each: float = 0.0
@export var save_stats: bool = true
@export_group("Miscellaneous")
@export var show_dev_ui: bool = false ## @experimental
@export var show_unmashed_blocks: bool = true 
@export var auto_spawn_unmashed_blocks: bool = true
@export var disable_reset: bool = false
@export var ignore_order: bool = false
@export var no_progression: bool = false
@export_category("Objects to Assign")
@export var level_goal: LevelGoal
@export var level_info: LevelInfo
@export var player: Player
@export var npc: NPCBoard

@onready var spawners: Array = get_tree().get_nodes_in_group("Spawner")

var intro_order: Order
var saver_loader: SaverLoader
var has_started: bool = true

var _dev_ui: PackedScene = preload("res://interface/runtime/dev_ui.tscn")


func _ready() -> void:
	GameMgr.current_level = self
	GameMgr.menu_entered.emit(GameMgr.MenuID.RUNTIME)
	
	# deflect_spawn_blocks()
	# Vague error: canvas_item_set_draw_index: Parameter "canvas_item" is null.

	if set_for_each:
		pass
	else:
		spawn_anim_time_each = spawn_anim_time / spawners.size()

	if player:
		if level_goal:
			level_goal.visible = false

		has_started = !player.start_asleep

		if !player.start_asleep:
			anim_level()
			
		else:
			player.has_waken_up.connect(
				func():
					# if !has_started:
					has_started = true
					Audio.start_music()
					await get_tree().create_timer(1.0).timeout
					anim_level()
			)
	else:
		push_warning("player not assigned")

	if save_stats:
		if !ignore_order:
			GameMgr.game_just_ended.connect(store_stats)
		
		var SL: SaverLoader = SaverLoader.new()
		add_child(SL)
		saver_loader = SL

	if level_id < 0:
		level_id = scene_file_path.to_int()
		bakery_id = Util.get_bakery_number(level_id)
		
		#print_debug(bakery_id)
		GameMgr.bakery_id = bakery_id
		GameMgr.level_id = level_id
	# elif level_id == 0:
	# 	setup_intro_sequence()
	else:
		GameMgr.bakery_id = bakery_id
		GameMgr.level_id = level_id
	
	GameMgr.level_entered.emit(level_id)
	
	if show_dev_ui:
		var ui := _dev_ui.instantiate()
		
		GameMgr.current_level.add_child(ui)
		GameMgr.current_level.move_child(ui, 0)
	

func spawn_blocks(p_spawn_speed: float = spawn_anim_time_each) -> void:
	for spawn: UnmashedSpawner in spawners:
		await spawn.spawn(-1, p_spawn_speed)


func deflect_spawn_blocks() -> void:
	for spawn: UnmashedSpawner in spawners:
		spawn.deflect()
		
		
func anim_level() -> void:
	has_started = true
	Audio.start_music()
	
	if auto_spawn_unmashed_blocks:
		await spawn_blocks()
	
	if level_info:
		level_info.start()

	if level_goal:
		level_goal.visible = true
		anim_level_goal()


func anim_level_goal() -> void:
	if npc:
		if npc.starting_emote == Millie.Expressions.HIDDEN:
			npc.millie.anim_emote(Millie.Emotes.PopUp)
		
	level_goal.anim_wobble()
	level_goal.anim_spawn()


func store_stats() -> void:
	if !save_stats:
		return
		
	if saver_loader == null:
		push_warning("Cannot save data. saver_loader not assigned.")
		return
	
	var board_num: String = str(level_id)
	var world_num: int = int((level_id - 1)/ 10.0) + 1
	var checkerboard_num: String = "10" + str(world_num)
	
	if !GameData.runtime_data.has(board_num):
		push_error("Cannot save data. Key %s not found in GameData.runtime_data." % board_num)
		return
	
	if !GameData.runtime_data.has(checkerboard_num):
		push_error("Cannot save data. Key %s not found in GameData.runtime_data." % checkerboard_num)
		return
	
	if GameData.runtime_data[board_num]["completed"] == false:
		GameData.runtime_data[board_num]["completed"] = true
	
	if GameData.runtime_data[checkerboard_num]["completed"] == false:
		GameData.runtime_data[checkerboard_num]["completed"] = _check_cb_progression(world_num)
	
	saver_loader.save_game()


func _check_cb_progression(cb: int) -> bool:
	var begin: int = 1 + ((cb - 1) * 10)
	var end: int = 11 + ((cb - 1) * 10)
	
	var completed: int = 0
	
	for i: int in range(begin, end):
		if !GameData.runtime_data.has(str(i)):
			push_warning("Cannot read data for _check_cb_progression. Key %s not found in GameData.runtime_data." % str(i))
			return false
			
		if GameData.runtime_data[str(i)]["completed"] == true:
			completed += 1
	
	return completed == 10
