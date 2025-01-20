extends SchizophreniaComponent
class_name TeleportComponent

@export var target_node: Node3D
@export var what_to_teleport: Node3D

@export var offset: Vector3
func _ready() -> void:
	if not target_node:
		target_node = get_parent()
	if not what_to_teleport:
		queue_free()
func on_visible() -> void:
	if _when_to_work & VISIBLE:
		what_to_teleport.global_position = target_node.global_position + target_node.global_basis * offset

func on_hidden() -> void:
	if _when_to_work & HIDDEN:
		what_to_teleport.global_position = target_node.global_position + target_node.global_basis * offset
