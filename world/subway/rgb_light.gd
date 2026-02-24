extends SpotLight3D

var x := Global.randf_range(-50.0, 50.0)
func _physics_process(delta: float) -> void:
	x += delta
	light_color.s = 0.5 + (sin(x) ** 2) / 2.0
	light_color.h = 0.5 + cos(x) * 0.5
