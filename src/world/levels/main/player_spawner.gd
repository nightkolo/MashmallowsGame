extends Marker2D
class_name PlayerSpawner

signal zoomed_in()

@export var spawn_config: int = 1

@onready var p: PackedScene = preload("res://object/objects/player.tscn")
@onready var mashed_1x1: PackedScene = preload("res://object/objects/block_mashed_1x1.tscn")
@onready var mashed_1x2: PackedScene = preload("res://object/objects/block_mashed_1x2.tscn")


func _ready() -> void:
	#spawn()
	pass


func spawn(anim_endscreen: bool = false, queue_free_after: float = -1.0):
	var lvl : String = str(spawn_config)
	
	if !LevelData.order_data.has(lvl):
		return false # Failed
	
	var oc: Array = LevelData.order_data[lvl]["order_code"]
	
	if oc.is_empty():
		return
	
	var player: Player = p.instantiate()
	#var stat: bool = GameData.runtime_data[p_lvl]["completed"]
	
	for entry: Dictionary in oc:
		var build: Util.BuildType = entry["build"]
		var new_mashed: Mashed = _get_mashed_object(build)
		
		new_mashed.position = Util.BLOCK_SIZE * Vector2(
			entry["pos"]["x"],
			entry["pos"]["y"]
		)
		
		new_mashed.attributes = BlockAttributes.new()
		new_mashed.attributes.build_type = build
		new_mashed.attributes.mash_type = entry["type"]
		
		player.add_child(new_mashed)
	
	player.auto_controlled = true
	player.idle_direction = Vector2.RIGHT
	player.random_jumping = true
	player.global_position = self.global_position
	
	GameMgr.current_level.add_child(player)
	
	var t := create_tween()
	
	t.tween_callback(func():
		if anim_endscreen:
			await player.animator.anim_zoom_in(0.25, true)
			zoomed_in.emit()
		).set_delay(2.0)
	
	if queue_free_after > 0.0:
		t.tween_callback(func(): player.queue_free()).set_delay(queue_free_after)


func _get_mashed_object(type: Util.BuildType) -> Mashed: 
	if mashed_1x1 == null:
		mashed_1x1 = preload("res://object/objects/block_mashed_1x1.tscn")
	if mashed_1x2 == null:
		mashed_1x2 = preload("res://object/objects/block_mashed_1x2.tscn")
	
	match type:
		Util.BuildType.SQUARE:
			return mashed_1x1.instantiate()
		Util.BuildType.RECTANGLE:
			return mashed_1x2.instantiate()
		_:
			return null
