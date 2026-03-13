@tool
extends StaticBody3D
class_name SoundTile
@export var sound: Constants.Ground = Constants.Ground.STONE
func _func_godot_apply_properties(props: Dictionary) -> void:
	sound = props["sound"]
