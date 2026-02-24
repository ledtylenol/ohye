extends MeshInstance3D

@export var target: Marker3D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var vel := Vector3(event.relative.x, -event.relative.y, 0.0) / 1000.0
		target.position += vel


func _physics_process(delta: float) -> void:
	global_position = M.smooth_nudgev(global_position, target.global_position, 10.0,delta)
	quaternion = M.slerpq_normal(quaternion, target.quaternion, delta, 10.0)
	target.position = M.smooth_nudgev(target.position, Vector3(0.5, 0.0, -1.0), 5.0, delta)
