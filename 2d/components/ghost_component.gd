extends Node2D
class_name GhostComponent

var time := 1.0
func _init(_time: float) -> void:
	time = _time
func _process(delta: float) -> void:
	time -= delta
	set_time(time)
	if time < 0:
		get_parent().queue_free()
	if time > 1.0:
		set_alpha(1.0)
	elif time > 0.8:
		set_alpha(0.5)
	elif time > 0.6:
		set_alpha(1.0)
	elif time > 0.4:
		set_alpha(0.2)
	elif time > 0.26:
		set_alpha(1.0)
	else:
		set_alpha(time)

func set_alpha(val: float) -> void:
	var p_mat: ShaderMaterial = get_parent().material
	p_mat.set_shader_parameter("alpha", val)
func set_time(val: float) -> void:
	var p_mat: ShaderMaterial = get_parent().material
	p_mat.set_shader_parameter("time", val)
