"""
	Asset: Godot Simple Portal System
	File: portal.gd
	Description: An area which teleports the player through the parent node's portal.
	Instructions: For detailed documentation, see the README or visit: https://github.com/Donitzo/godot-simple-portal-system
	Repository: https://github.com/Donitzo/godot-simple-portal-system
	License: CC0 License
"""

extends Area3D
class_name PortalTeleport

var _parent_portal:Portal
var enabled := true

func _ready():
	_parent_portal = get_parent() as Portal
	if _parent_portal == null:
		push_error("The PortalTeleport \"%s\" is not a child of a Portal instance" % name)
	connect("area_entered", _on_area_entered)
	_parent_portal.exit_portal_area.area_exited.connect(re_enable)
func _on_area_entered(area:Area3D):
	if not enabled: return
	if area.has_meta("teleportable_root"):


		var root: Player = area.get_node(area.get_meta("teleportable_root"))
		if _parent_portal.exit_environment:
			root.camera.environment = _parent_portal.exit_environment
		await get_tree().physics_frame
		await get_tree().physics_frame

		if root.velocity.normalized().dot(-global_basis.z) < 0.0 or M.xz(root.velocity.normalized()).angle_to(-M.xz(root.camera.global_basis.z)) > PI/2 + 0.05: 
			return
		var real_tf = _parent_portal.real_to_exit_transform(root.global_transform)
		root.velocity = _parent_portal.real_to_exit_direction(root.velocity )
		root.global_transform = real_tf
		enabled = false
		_parent_portal.exit_portal_area.enabled = false
func re_enable(area: Area3D) -> void:
	if area.has_meta("teleportable_root"):
		enabled = true
		_parent_portal.exit_portal_area.enabled = true
