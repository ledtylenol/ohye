extends CharacterBody3D
class_name Projectile

var up_dir := Vector3.UP
var dir := Vector3.UP

func _physics_process(delta: float) -> void:
	for child: ProjectileComponent in M.nightmare_getter(self, ProjectileComponent):
		child.on_tick(delta)
	move(delta)
func move(_delta: float) -> void:
	pass
