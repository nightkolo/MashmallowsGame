@tool
extends Node2D
class_name Level

#@export_group("Dev options")
@export var level_id: int = -1
# @export var adjust_spawn_anim_fixed_time: bool = true
@export var spawn_anim_time: float = 0.75
@export var set_for_each: bool = false
@export var spawn_anim_time_each: float = 0.0
@export_group("Miscellaneous")
@export var show_dev_ui: bool = false ## @experimental
@export var show_unmashed_blocks: bool = true 
@export var auto_spawn_unmashed_blocks: bool = true
@export var ignore_order: bool = false
@export var no_progression: bool = false

@export_category("Objects to Assign")
@export var level_goal: LevelGoal
@export var level_info: LevelInfo
@export var player: Player
# @export var terrain: Terrain
# @export var world: World

# var is_intro_order: bool = false
var intro_order: Order
var has_started: bool = true

var _dev_ui: PackedScene = preload("res://interface/menus/dev_ui.tscn")


@onready var spawners: Array = get_tree().get_nodes_in_group("Spawner")


func anim_level():
	has_started = true
	Audio.start_music()
	
	if auto_spawn_unmashed_blocks:
		await spawn_blocks()
	
	
	if level_info:
		level_info.start()

	if level_goal:
		level_goal.visible = true
		anim_level_goal()


func deflect_spawn_blocks():
	for spawn: UnmashedSpawner in spawners:
		spawn.deflect()


func spawn_blocks(p_spawn_speed: float = spawn_anim_time_each):
	for spawn: UnmashedSpawner in spawners:
		await spawn.spawn(-1, p_spawn_speed)


func anim_level_goal():
	level_goal.anim_wobble()
	level_goal.anim_spawn()


func _ready() -> void:
	GameMgr.current_level = self
	GameMgr.level_entered.emit()
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


	if level_id < 0:
		GameMgr.level_id = scene_file_path.to_int()
	# elif level_id == 0:
	# 	setup_intro_sequence()
	else:
		GameMgr.level_id = level_id
	
	if show_dev_ui:
		var ui := _dev_ui.instantiate()
		
		GameMgr.current_level.add_child(ui)
		GameMgr.current_level.move_child(ui, 0)
	
