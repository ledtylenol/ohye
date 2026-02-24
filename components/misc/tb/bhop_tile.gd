@tool
extends SoundTile
class_name BhopTile
var time_since := 0.0
@export var id := 0
var time_on := 0.0:
	set(value):
		time_since = 0.0
		time_on = value
		if time_on > 0.2:
			if not Engine.is_editor_hint():
				Global.teleport_to_id.emit(id)
				time_on = 0.0
var properties: Dictionary

func _func_godot_apply_properties(props: Dictionary) -> void:
	super(props)
	id = props["id"]

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	time_since += delta
	if time_since > 0.2:
		time_on = 0.0
