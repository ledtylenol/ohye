@tool
extends Resource
class_name Edge

@export_storage var from: String:
	set(v):
		if v and v == to: 
			push_error("edges cannot go from a level to the same level")
			return
		from = v
@export_storage var to: String:
	set(v):
		if v and v == from: 
			push_error("edges cannot go from a level to the same level")
			return
		to = v
@export var chance := 0.5
func _get_property_list() -> Array:
	var hint: String = LevelHandler.get_string()
	return [
		{
			"name": "from",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": hint
		},
		{
			"name": "to",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": hint
		}
	]
