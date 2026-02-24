@tool
extends MeshInstance3D
class_name Teleporter
@export var col: CollisionShape3D
@export var portal_teleport: PortalTeleport
@export var portal: Portal 
@export var id := ""
@export var other_tp: Teleporter

func _func_godot_build_complete() -> void:
	print("BUILD COMPLETED")
	print(get_children())
	for sib in get_parent().get_children():
		if sib != self and sib is Teleporter and sib.id == id:
			other_tp = sib
			other_tp.portal.exit_portal = portal
			break
func _func_godot_apply_properties(props: Dictionary) -> void:
	print("YTA")
	id = props["id"]
	var size: Vector3
	var m: MeshInstance3D
	for child in get_children():
		if child is MeshInstance3D and child is not Portal:
			m = child
			size = m.get_aabb().size
			var angle: float = deg_to_rad(fmod(props["mangle"].y, 180))
			size.x = cos(angle) * size.x + sin(angle) * size.y
			size.y = -sin(angle) * size.x + cos(angle) * size.y
			break
	if m:
		m.visible = false
	var s2d = Vector2(size.x, size.y)
	print(s2d)
	portal = Portal.new()
	portal.vertical_viewport_resolution = 0
	portal.fade_out_distance_max = 50
	portal.fade_out_distance_min = 40
	portal.disable_viewport_distance = 50
	portal_teleport = PortalTeleport.new()
	col = CollisionShape3D.new()
	col.shape = BoxShape3D.new()
	col.shape.size = size
	portal_teleport.add_child(col)
	portal.add_child(portal_teleport)
	portal.mesh = PlaneMesh.new()
	portal.mesh.size = s2d
	portal.mesh.orientation = PlaneMesh.FACE_Z
	add_child(portal)
	props["mangle"].x = deg_to_rad(props["mangle"].x)
	props["mangle"].y = deg_to_rad(props["mangle"].y)
	props["mangle"].z = deg_to_rad(props["mangle"].z)
	portal.rotation = props["mangle"]
	var root = get_tree().edited_scene_root
	portal.owner = root
	portal_teleport.owner = root
	col.owner = root
func find_teleporter() -> void:
	for tp in Global.teleporters.filter(func(x): return x and x != self):
		if tp.id == id:
			other_tp = tp
			break
	if not other_tp:
		print("could nto find any oop")
		queue_free()
		return
	portal.exit_portal = other_tp.portal
	
