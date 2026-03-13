@tool
extends Area3D
class_name Water


var time := 0.0
@export var mesh: MeshInstance3D
@export var gravity_modifier := 1.0
func _func_godot_apply_properties(props: Dictionary) -> void:
	gravity_modifier = props.gravity
func _func_godot_build_complete() -> void:
	for child in get_children():
		if child is MeshInstance3D:
			mesh = child
			break
	var shape := mesh.mesh.create_convex_shape()
	var shape_node = CollisionShape3D.new()
	shape_node.shape = shape
	add_child(shape_node)
	shape_node.owner = get_tree().edited_scene_root
	print("Test?")
func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	time += delta
	mesh.set_instance_shader_parameter("time", time)
	if time > 7200.0:
		time = 0.0
