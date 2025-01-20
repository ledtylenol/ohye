extends Scene
class_name RandomScenePicker

@export var scenes: Array[RandomScene]

func get_level() -> String:
	return M.pick_random(scenes).path
