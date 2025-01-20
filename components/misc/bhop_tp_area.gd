@tool
extends Node3D
class_name BhopArea
@export var id := 0

var properties: Dictionary

func _func_godot_apply_properties(props: Dictionary) -> void:
	id = props["id"]
func make_area(c: MeshInstance3D) -> Area3D:
	var shape = c.mesh.create_trimesh_shape()
	var area = Area3D.new()
	area.collision_mask = 1 << 3
	var col_shape := CollisionShape3D.new()
	col_shape.shape = shape
	add_child(area)
	area.add_child(col_shape)
	return area
func _ready() -> void:
	for child: MeshInstance3D in M.nightmare_getter(self, MeshInstance3D, "MeshInstance3D"):
		var a := make_area(child)
		a.body_entered.connect(func(_x) -> void:
			Global.teleport_to_id.emit(id)
			)
