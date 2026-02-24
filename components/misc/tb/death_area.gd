@tool
extends Node3D
class_name DeathArea
@export var scene: String

@export var sc_l: SceneLoader
@export var properties: Dictionary

func _func_godot_apply_properties(props: Dictionary) -> void:
	scene = props["scene"]
	properties = props
	sc_l = SceneLoader.new()
	sc_l.scene_type = SimpleScene.new()
	sc_l.scene_type.scene = scene
	sc_l.can_change = true
	sc_l.load_immediately = false
	add_child(sc_l)
	sc_l.owner = get_tree().edited_scene_root
func make_area(c: MeshInstance3D) -> Area3D:
	var root := get_tree().edited_scene_root
	var shape = c.mesh.create_trimesh_shape()
	var area = Area3D.new()
	area.collision_mask = 1 << 3
	var col_shape := CollisionShape3D.new()
	col_shape.shape = shape
	add_child(area)
	area.owner = root
	area.add_child(col_shape)
	col_shape.owner = root
	c.visible = properties["visible"]
	return area
func _ready() -> void:
	if  Engine.is_editor_hint(): return
	for child: MeshInstance3D in M.nightmare_getter(self, MeshInstance3D, "MeshInstance3D"):
		var a := make_area(child)
		a.body_entered.connect(func(_x) -> void:
			print("yuh")
			sc_l.try_load()
			)
	sc_l.request_load()
