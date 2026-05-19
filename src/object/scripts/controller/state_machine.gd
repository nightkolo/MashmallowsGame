## Under construction
class_name StateMachine
extends Node

signal player_state_changed(state: State)

@export var initial_state: State

var current_state: State
var states := {}

func _ready() -> void:
	# Cache children states
	for child: Node in get_children():
		if child is State:
			states[child.name] = child
			child.state_machine = self
			child.player = get_parent() as Player

	if initial_state:
		change_state(initial_state.name)

func change_state(state_name: String, msg := {}) -> void:
	if current_state:
		current_state.exit()

	current_state = states.get(state_name)
	player_state_changed.emit(current_state)

	if current_state:
		current_state.enter(msg)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta) -> void:
	if current_state:
		current_state.physics_update(delta)
