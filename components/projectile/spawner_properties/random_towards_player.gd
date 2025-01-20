extends RandomSpawner
class_name RandomTowardsPlayer
@export var target: Node3D
func get_dir() -> Vector3:
	return target.global_position.direction_to(Global.player.global_position)
