@tool
extends Scene
class_name SimpleScene

@export_storage var edge_name: String = ""
func _get_property_list() -> Array:
	return [
		{
			"name": "edge_name",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": LevelHandler.get_edge_string()
		}
	]
