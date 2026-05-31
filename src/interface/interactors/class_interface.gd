class_name MainMenu
extends CanvasLayer

signal back_button_pressed()
signal is_showing()

var btns: Array[Node]
var viewport: MarginContainer # Null check needed
var viewport_extra: Node2D # Null check needed


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("game_cancel"):
		back_button_pressed.emit()

#func _ready() -> void:
	#select_button.pressed.connect(func():
		#Input.action_press("ui_accept")
		#)
	#InputPrompts.back_button.pressed.connect(func():
		#back_button_pressed.emit()
		#Input.action_press("game_cancel")
		#print_debug("back...")
		#)
	#tut_button.pressed.connect(func():
		#Input.action_press("game_tutorial")
		#)

func _init() -> void:
	await ready
	
	add_to_group("MenuScreen")
	btns = get_tree().get_nodes_in_group("UIButton")
	viewport = get_node_or_null("Main")
	viewport_extra = get_node_or_null("Main2")
	
	#InputPrompts.back_button.pressed.connect(func():
		#back_button_pressed.emit()
		#Input.action_press("game_cancel")
		#print_debug("back...")
	#)
	visibility_changed.connect(func():
		if visible:
			is_showing.emit()
		)


func disable_buttons(list_of_btns: Array[Node], disable: bool = true) -> void:
	for btn: Button in list_of_btns:
		btn.disabled = disable
