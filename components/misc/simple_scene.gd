extends Scene
class_name SimpleScene

@export_file("*.tscn") var scene: String

func get_level() -> String:
	return scene
