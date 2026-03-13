@tool
extends Node3D
class_name Level

var level_name: String = "subway"
func _get_property_list() -> Array:
	return [
		{
			"name": "level_name",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": LevelHandler.get_string()
		}
	]

func _enter_tree() -> void:
	if Engine.is_editor_hint(): return
	if LevelHandler.levels.has(level_name):
		if Global.game_stats.levels.has(level_name):
			Global.game_stats.levels[level_name] += 1
		else:
			Global.game_stats.levels[level_name] = 1
