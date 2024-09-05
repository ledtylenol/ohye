extends Area3D
class_name DetectionArea
var has_enemy := false:
	set(value):
		if GlobalSound.playing:
			if value and not has_enemy:
				GlobalSound.change_song_parts(3)
			elif not value and has_enemy:
				GlobalSound.change_song_parts(1)

		has_enemy = value

func _physics_process(delta: float) -> void:
	var i := 0
	for col in get_overlapping_bodies():
		if col is not OutlineTest: continue
		i += 1
	has_enemy = i != 0
