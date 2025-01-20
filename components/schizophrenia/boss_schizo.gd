extends SchizophreniaComponent
class_name BossSchizo
@export var angle_target: Node3D
@onready var parent :Schizophrenia = get_parent()
var player_in_sight := false
func on_visible() -> void:
	pass

func on_hidden() -> void:
	pass

func visible_tick(_dt: float) -> void:
	var player_dir:Vector3 = parent.player.camera.global_position.direction_to(angle_target.global_position)
	var player_forward: Vector3 = -parent.player.camera.global_basis.z
	player_in_sight = player_dir.angle_to(player_forward) < PI/24
func hidden_tick(_dt: float) -> void:
	player_in_sight = false
