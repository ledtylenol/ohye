@tool
extends Resource
class_name Scene


@export_file("*.tscn") var scene: String

func get_level() -> SimpleScene:
	return self
