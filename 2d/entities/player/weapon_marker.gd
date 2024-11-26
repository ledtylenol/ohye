extends Area2D
class_name Weapon

var target_rot := 0.0
var offset := 0.0
var vel := 0.0
var current_offset := 0.0
func _process(delta: float) -> void:
	var offset_vel := offset - current_offset
	current_offset = M.smooth_nudgef(current_offset, offset, 15.0, delta)
	vel = 5.0 * angle_difference(rotation, target_rot + current_offset)
	rotate(delta * vel)
