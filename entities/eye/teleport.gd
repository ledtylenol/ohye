extends State
class_name EyeTeleport

var tween: Tween
@export var scale_target: Node3D
@export var hp: HealthComponent

var t := 0.0
func on_enter() -> void:
	t = randf_range(1, 2)
	var pos := target.global_position + M.random_sample_point_in_cone(PI, Vector3.UP) * randf_range(10, 20)
	target.teleport_to(pos)
	if tween: tween.kill()
	scale_target.scale = Vector3.ZERO
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(scale_target, "scale", Vector3.ONE, 1.0)
func physics_tick(dt:float) -> void:
	t -= dt
	if t <= 0.0:
		transitioned.emit("teleport", "floating")
