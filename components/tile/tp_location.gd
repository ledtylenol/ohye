@tool
extends Node3D
class_name TPMarker

@export var id := 0
var properties: Dictionary
func _func_godot_apply_properties(props: Dictionary) -> void:
	id = props["id"]


func _ready() -> void:
	Global.teleport_to_id.connect(tp)

func tp(i: int) -> void:
	if id == i:
		Global.player.global_position = global_position
		Global.player.camera.reset_physics_interpolation()
