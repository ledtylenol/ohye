extends Node
class_name State

@export var target: Node3D
@warning_ignore("unused_signal")
signal transitioned(from: String, to: String)
func on_enter() -> void:
	pass

func on_exit() -> void:
	pass

func tick(_dt: float) -> void:
	pass

func physics_tick(_dt: float) -> void:
	pass
