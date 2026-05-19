## Use scene
@tool
extends Node2D
class_name World

# TODO: PRE-DEFINED BG COLORS
# TODO: Export variables, Camera, 
enum BGcolors {WORLD_1, WORLD_2}

@onready var bg_sprite: TiledSprite2D = %TiledSprite2D
@export var bg_color_set: BGcolors:
	set(value):
		bg_color_set = value
		%TiledSprite2D.self_modulate = Util.get_bg_color_set(value)
@export var terrain_color: Color = Color(Color.WHITE * 0.98, 1.0):
	set(value):
		terrain_color = value
		var t := get_node_or_null("Terrain")
		
		if t:
			t.modulate = value
@export_category("Objects to Assign")
@export var terrain: Terrain
@export var camera: Cam

var terrain_light: PackedScene = preload("res://world/effects/terrain_light.tscn")


func _ready() -> void:
	GameMgr.current_level_world = self
	
	if terrain:
		terrain.modulate = terrain_color
		var t: TileMapLayer = terrain.get_child(0) as TileMapLayer
		if t:
			t.light_mask = 8

	if camera:
		# TODO: Fix terrain light issue, use RemoteTransform2D on Player to keep both nodes in same tree.
		var tl: PointLight2D = terrain_light.instantiate()
		tl.global_position = camera.global_position
		tl.scale = Vector2.ONE / (camera.zoom.x / camera.dynamic_effect)

		await get_tree().create_timer(0.1).timeout
		GameMgr.current_level.add_child.call_deferred(tl)
		tl.range_item_cull_mask = 8

	
