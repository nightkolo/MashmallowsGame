## State.gd
class_name State
extends Node

## Reference to the state machine that owns this state.
## Set automatically by the StateMachine on initialization.
var state_machine: StateMachine

## Reference to the player (player, enemy, etc.)
## that this state operates on.
## Also injected by the StateMachine.
var player: Player


## Called once when the state becomes active.
## Use this for one-time setup logic:
## - Setting velocity
## - Playing animations
## - Resetting timers
## - Applying effects
##
## `msg` is an optional dictionary that can pass
## contextual data during a transition.
func enter(msg := {}):
	pass


## Called once when transitioning away from this state.
## Use this for cleanup logic:
## - Stopping effects
## - Clearing flags
## - Resetting temporary values
func exit():
	pass


## Called every frame from _process().
## Use for non-physics logic such as:
## - Input handling
## - Animation logic
## - Non-physics timers
func update(delta: float):
	pass


## Called every physics frame from _physics_process().
## Use for physics-related behavior:
## - Gravity
## - Movement
## - Collision-based transitions
func physics_update(delta: float):
	pass
