extends MarginContainer
class_name LevelPanel

signal entered_cb_1()
signal entered_cb_2()

@export var order_preview: UIOrderPreview

@onready var panel_1: BakeryPanel = %Panel
@onready var panel_2: BakeryPanel = %Panel2
#@onready var marker_2d: Marker2D = $Marker2D
#@onready var main_container: MarginContainer = %Main

#@onready var panels: Array[NinePatchRect] = [%Panel, %Panel2]

@onready var board_btns: Array[Node] = get_tree().get_nodes_in_group("UIBoardButton")

@onready var lvl_panels: Array[Node] = get_tree().get_nodes_in_group("UILevelPanel")
@onready var lvl_panel_containers: Array[Node] = get_tree().get_nodes_in_group("UILevelPanelContainer")



func bakery_panel_entered(bakery_num: int, lvl_num: int = 0) -> void:
	#print_debug("Bakery %s entered" % i)
	if order_preview:
		print_debug(lvl_num)
		order_preview.current_level_focussed = lvl_num
	
	for p: BakeryPanel in lvl_panels:
		p.is_active = false
	
	anim_levels_panel(lvl_panels[bakery_num])
	(lvl_panels[bakery_num] as BakeryPanel).is_active = true


func _ready() -> void:
	
	#for p: MarginContainer in lvl_panel_containers:
	for i in range(lvl_panel_containers.size()):
		lvl_panels[i].custom_minimum_size = lvl_panel_containers[i].size
		
	for board_btn: BoardSelectButton in board_btns:
		var lvl_num := board_btn.name.to_int()
			
		var bakery_num := floori((lvl_num - 1.0) / 10.0)
		
		board_btn.focus_entered.connect(bakery_panel_entered.bind(bakery_num, lvl_num))
		board_btn.mouse_entered.connect(bakery_panel_entered.bind(bakery_num, lvl_num))
		
	%BtnB1.grab_focus()
	bakery_panel_entered(0, 1)
	
	
var _panel_tween: Tween
#var _last_control: NinePatchRect = null


func anim_levels_panel(control: NinePatchRect) -> void:
	if lvl_panels.is_empty():
		return
		
	#_last_control = control
	
	if _panel_tween:
		_panel_tween.kill()
	
	var dur := 0.25
	var scal := 0.75
	var s := get_viewport_rect().size.y
	
	print_debug("Animating %s" % control)
	
	_panel_tween = create_tween().set_parallel(true)
	_panel_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	_panel_tween.tween_property(self, "position:y", -1 * (control.position.y - 250.0), dur)
	
	for p: NinePatchRect in lvl_panels:
		p.pivot_offset_ratio = Vector2(0.0, 0.5)
		
		if p == control:
			_panel_tween.tween_property(p, "scale", Vector2.ONE, dur).set_trans(Tween.TRANS_BACK)
			_panel_tween.tween_property(p, "modulate", Color(Color.WHITE, 1.0), dur)
			continue
		
		_panel_tween.tween_property(p, "scale", Vector2.ONE * scal, dur)
		_panel_tween.tween_property(p, "modulate", Color(Color.WHITE, 0.5), dur)
	
	
	
	
	
