extends Resource
class_name Settings

@export_storage var sfx_volume := 0.5:
	set(value):
		sfx_volume = clampf(value, 0.0, 2.0)
@export_storage var music_volume := 0.5:
	set(value):
		music_volume = clampf(value, 0.0, 2.0)
