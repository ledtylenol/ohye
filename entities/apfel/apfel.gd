extends Node3D
var t := 0.0
var x_accel := 0.0
var z_accel := 0.0
func _process(delta: float) -> void:
	t += delta
	
	x_accel += (sin(t * 0.3)) * delta
	z_accel += (cos(t * 0.7)) * delta 
	z_accel += sin(t * 2) * delta * 0.2
	x_accel += cos(t * 4) * delta * 0.1
	rotate_x(x_accel * delta)
	rotate_y(z_accel * delta)
