extends Node3D
class_name Footsteps
@export var player: Player

@export var stream_map: Dictionary[String, RaytracedAudioPlayer3D]

func play_thing() -> void :
	if player.dead: return
	var current = stream_map[Constants.enum_to_string(player.last_ground_type)]
	if current:
		for key in stream_map:
			var stream = stream_map[key]
			if stream == current:
				stream.enable()
			else:
				stream.disable()
	current.play()
