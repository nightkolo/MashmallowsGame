@tool
extends Node2D
class_name NPCBoard

@export var starting_emote: Millie.Expressions:
	set(value):
		starting_emote = value
		var m := %Millie
		
		if not Engine.is_editor_hint():
			await m.ready
		m.expression = value

@onready var interact_notice: ColorRect = %InteractNotice
@onready var nameplate: ColorRect = %Nameplate
@onready var node_millie: Node2D = %NodeMillie
@onready var info_nodes: Node2D = $InfoNodes
@onready var label: Label = %Label
@onready var label_2: Label = %Label2

@onready var millie: Millie = %Millie
@onready var masked_spiral: Sprite2D = %MaskedSpiral

@onready var board: Node2D = $Board


# TODO Tween and mask, return if no change
func anim_reveal_name(p_show: bool = true):
	if label:
		label.visible = !p_show
		label_2.visible = p_show


func anim_spiral() -> void:
	var tween := create_tween().set_loops()
	
	tween.tween_property(masked_spiral, "rotation", -PI, 1.0).as_relative()


func _ready() -> void:
	GameMgr.current_NPC = self
	info_nodes.scale = Vector2.ZERO
	
	anim_nameplate()
	
	anim_spiral()
	
	GameLogic.player_interacted_monolog_area.connect(anim_interact)
	GameMgr.monolog_activated.connect(anim_monolog_active)
	
# TODO complete anim
	GameLogic.cherry_bomb_exploded.connect(func():
		if !GameLogic.is_stuck:
			millie.anim_emote(Millie.Emotes.Scared)
	)

	GameLogic.order_gain.connect(func(amount: int):
		if !GameLogic.is_stuck:
			if amount == 2:
				millie.anim_emote(Millie.Emotes.InitialMatch)
			else:
				millie.anim_emote(Millie.Emotes.Match)
		)
	
	GameLogic.order_loss.connect(func():
		if !GameLogic.is_stuck:
			millie.anim_emote(Millie.Emotes.Unmatch)
		)
	
	GameLogic.order_complete.connect(func():
		millie.anim_emote(Millie.Emotes.Complete)
		)
	
	await get_tree().create_timer(0.1).timeout
	millie.world = GameMgr.current_level

func anim_nameplate():
	nameplate.pivot_offset_ratio = Vector2.ONE * 0.5
	var tween = create_tween().set_loops()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(nameplate, "rotation_degrees", -2.0, 1.0)
	tween.tween_property(nameplate, "rotation_degrees", 2.0, 1.0)


func anim_monolog_active(active: bool):
	nameplate.visible = active
	interact_notice.visible = !active
	if active:
		anim_interact(true)

var t_interact: Tween

func anim_interact(active: bool):
	
	if t_interact:
		t_interact.kill()
	t_interact = create_tween().set_parallel(true)
	
	if active:
		info_nodes.scale = Vector2.ZERO
		t_interact.tween_property(node_millie, "scale", Vector2.ONE * 1.05, 0.1)
		t_interact.tween_property(info_nodes, "scale", Vector2.ONE, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	else:
		t_interact.tween_property(node_millie, "scale", Vector2.ONE, 0.1)
		
		t_interact.tween_property(info_nodes, "scale", Vector2.ZERO, 0.1)
