extends Node
class_name StateMachine


var states: Dictionary
@export var current_state: State
func _ready() -> void:
	for child: State in M.nightmare_getter(self, State):
		states[child.name.to_lower()] = child
		child.transitioned.connect(on_transition)
	current_state.on_enter()
func _process(delta: float) -> void:
	current_state.tick(delta)

func _physics_process(delta: float) -> void:
	current_state.physics_tick(delta)
func on_transition(from: String, to: String) -> void:
	if from.to_lower() not in states:
		return
	var old_state: State = states[from.to_lower()]
	if to.to_lower() not in states:
		return
	var new_state: State = states[to.to_lower()]
	old_state.on_exit()
	new_state.on_enter()
	current_state = new_state
