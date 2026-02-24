@tool
extends StaticBody3D
class_name RandomSpawnBrush

@export var chance := 100
var properties: Dictionary

func _func_godot_apply_properties(props: Dictionary) -> void:
	chance = props["chance"]

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var roll := Global.randi() % 100
	if roll < chance:
		print(roll)
		queue_free()
