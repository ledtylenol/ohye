extends AudioStreamPlayer3D
class_name ScaledStreamPlayer3D
@export_range(0.0, 1.0) var influence := 1.0:
	get:
		return clampf(influence, 0.0, 1.0)

func _process(_delta: float) -> void:
	pitch_scale = maxf(0.001, Engine.time_scale * influence + 1.0 - influence)
	
