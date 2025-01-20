extends MeshInstance3D
func _process(delta: float) -> void:
	if Input.is_action_pressed("front"):
		rotate_object_local(Vector3.UP, delta * PI/2)
