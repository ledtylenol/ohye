extends Node3D

@export var player: Player
@export var land_sounds: AudioStreamPlayer3D


func _ready() -> void:
	player.just_landed.connect(play_land_sound)

func play_land_sound() -> void:
	var vel := player.former_velocity.project(player.normal).length()
	print(vel)
	land_sounds.volume_db = linear_to_db(vel / 120 + 0.1)
	land_sounds.pitch_scale = 1.0 - minf(vel / 100, 0.3)
	print(1.0 - minf(vel / 100, 0.8))
	land_sounds.play()
