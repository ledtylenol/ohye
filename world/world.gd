extends Node3D


var enemy_count: int:
	get: return Global.active_enemy_count
var music_triggered := false
@onready var global_sound: Node = $GlobalSound

func _ready() -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.hit.connect(trigger_music)
	$Area3D/OmniLight3D.light_energy = 0
func trigger_music() -> void:
	if music_triggered:
		return
	music_triggered = true
	global_sound.play(1)
func _process(_delta: float) -> void:
	if enemy_count == 0 and not global_sound.song_parts == 0:
		
		global_sound.change_song_parts(0)
		$Area3D/OmniLight3D.light_energy = 5
		if not $Area3D.active:
			$Area3D.active = true
