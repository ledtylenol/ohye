extends Node3D
class_name Footsteps
@export var player: Entity

@export var stream_map: Dictionary[Constants.Ground, RaytracedAudioPlayer3D]
func _ready() -> void:
	print(stream_map)
func play_thing() -> void :
	if player.dead: return
	var current = stream_map[player.last_ground_type]
	if current:
		for key in stream_map:
			var stream = stream_map[key]
			if stream == current:
				stream.enable()
			else :
				stream.disable()
	current.play()
	print("PLAYING %s" % player.last_ground_type)
