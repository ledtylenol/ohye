extends Resource
class_name Settings

@export_storage var sfx_volume := 0.5:
	set(value):
		sfx_volume = clampf(value, 0.0, 2.0)
@export_storage var music_volume := 0.5:
	set(value):
		music_volume = clampf(value, 0.0, 2.0)
@export_storage var sensitivity := 10.0:
	set(v):
		sensitivity_changed.emit(sensitivity, max(0.0, v))
		sensitivity = maxf(0.0, v)
@export_storage var screen_size: Vector2i
@export_storage var screen_pos: Vector2i
@export_storage var transition_secs := 2.0
signal sensitivity_changed(old: float, new: float)
