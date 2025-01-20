extends ProjectileSpawnerProperty
class_name TowardsPlayer
@export var target: Node3D
func get_dir() -> Vector3:
	return target.global_position.direction_to(Global.player.global_position)
