extends Node3D


var enemy_count: int:
	get: return Global.active_enemy_count
var music_triggered := false


func _ready() -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.hit.connect(trigger_music)

func trigger_music() -> void:
	if music_triggered:
		return
	print("YES")
	music_triggered = true
	GlobalSound.play(3)
func _process(delta: float) -> void:
	if enemy_count == 0 and not GlobalSound.song_parts == 0:
		GlobalSound.change_song_parts(0)
