extends CanvasLayer

@onready var inputs_container: HBoxContainer = %InputContainer

@onready var move_inputs: MarginContainer = %Move
@onready var select_inputs: MarginContainer = %Select
@onready var back_inputs: MarginContainer = %Back
@onready var tutorial_inputs: MarginContainer = %Tutorial

@onready var select_button: Button = %SelectButton
@onready var back_button: Button = %BackButton
@onready var tut_button: Button = %TutButton

@onready var buttons: Array[Button] = [%SelectButton, %BackButton, %TutButton]


func _ready() -> void:
	for btn: Button in buttons:
		btn.self_modulate = Color(Color.WHITE, 0.0)
		btn.mouse_filter = Control.MOUSE_FILTER_PASS
		
		btn.mouse_entered.connect(func():
			btn.self_modulate = Color(Color.WHITE, 0.5)
			)
		btn.mouse_exited.connect(func():
			btn.self_modulate = Color(Color.WHITE, 0.0)
			)
		
		
	select_button.pressed.connect(func():
		var event = InputEventAction.new()
		event.action = "ui_accept"
		event.pressed = true
		Input.parse_input_event(event)
		)
	back_button.pressed.connect(func():
		var event = InputEventAction.new()
		event.action = "game_cancel"
		event.pressed = true
		Input.parse_input_event(event)
		)
	tut_button.pressed.connect(func():
		var event = InputEventAction.new()
		event.action = "game_tutorial"
		event.pressed = true
		Input.parse_input_event(event)
		)
		
