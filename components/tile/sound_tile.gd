@tool
extends StaticBody3D
class_name SoundTile
enum Tile {Dirt, Stone}
@export var sound: Tile = Tile.Stone
func _func_godot_apply_properties(props: Dictionary) -> void:
	sound = props["sound"]
