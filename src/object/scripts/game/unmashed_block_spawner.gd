## A configurable spawn point for spawning gameplay blocks at runtime.
##
## [UnmashedSpawner] is primarily used to define where and how a block should appear within a [Level]. It also provides optional editor-only visualization helpers and realtime collision prevention around the spawn area ([member collision_deflector]).
@tool
extends Marker2D
class_name UnmashedSpawner

@export var block_attributes: BlockAttributes ## The block configuration/resource this spawner should create.
@export var tutorial_block: bool = false ## If [code]true[/code], this block shows a "Press X to Mash" prompt.
@export var custom_spawn: Node2D ## Spawn location in the tree. Default is [member GameMgr.current_level] if not assigned
@export_tool_button("Display (For this specific node only)") var p_display = display_block
@export_group("Customize")
@export var cherry_bomb_strength: float = 1600.0 
@export_category("Objects to Assign")
@export var area: Area2D
@export var sprite: Sprite2D ## For displaying node in editor
@export var collision_deflector: StaticBody2D ## For preventing player from being in the spawn location of this spawner

var unmashed_object: PackedScene = preload("res://object/objects/block_unmashed_1x1.tscn")
var unmashed_object_1x2: PackedScene = preload("res://object/objects/block_unmashed_1x2.tscn")


func display_block() -> void:
	if sprite == null:
		return

	sprite.scale = 0.5 * Vector2.ONE

	sprite.texture = Util.get_mash_type_texture(block_attributes.mash_type, block_attributes.build_type)


func _ready() -> void:
	add_to_group("Spawner")
	display_block()

	sprite.self_modulate = Color(Color.WHITE, 0.0)

	if area:
		area.collision_layer = 0
		area.collision_mask = 2

		area.body_entered.connect(func(_body: Node2D):
			if sprite:
				sprite.self_modulate = Color(Color.WHITE, 0.5)
			)
		area.body_exited.connect(func(_body: Node2D):
			if sprite:
				sprite.self_modulate = Color(Color.WHITE, 0.0)
			)


func _deflect_end() -> void:
	if collision_deflector:
		collision_deflector.queue_free()
		await get_tree().create_timer(0.05).timeout

		if sprite && !Engine.is_editor_hint():
			sprite.queue_free()
			sprite = null


func spawn(node_index: int = -1, misc_consective_delay: float = 0.25) -> void: ## Self-explanatory.
	var unmashed: Unmashed = _get_unmashed_object(block_attributes.build_type)
	unmashed.global_position = global_position
	unmashed.attributes = block_attributes
	unmashed.tutorial_block = tutorial_block
	unmashed.cherry_bomb_strength = cherry_bomb_strength
	unmashed.was_mashed = false
	
	await _deflect_end()

	if custom_spawn:
		custom_spawn.add_child(unmashed)

		if node_index >= 0:
			custom_spawn.move_child(unmashed, node_index)

	else:
		GameMgr.current_level.add_child(unmashed)

		if node_index >= 0:
			GameMgr.current_level.move_child(unmashed, node_index)
		
	unmashed.anim_spawn_particles()
	unmashed.name = "Unmashed" + str(GameLogic.number_of_blocks)

	await get_tree().create_timer(misc_consective_delay).timeout
	
	
func _get_unmashed_object(type: Util.BuildType) -> Unmashed:
	match type:
		Util.BuildType.SQUARE:
			return unmashed_object.instantiate()
		Util.BuildType.RECTANGLE:
			return unmashed_object_1x2.instantiate()
		_:
			return null
