extends AudioStreamPlayer3D
@export var distance: float = 10.0
@onready var player := Global.player
@export var audio_to_stop: AudioStreamPlayer
var starting_audio := 0.0
func _ready() -> void:
	starting_audio = audio_to_stop.volume_db
	max_distance = distance
func _physics_process(delta: float) -> void:
	if player.global_position.distance_to(global_position) > distance:
		audio_to_stop.volume_db = starting_audio
		return
	var l := 1.0 - (player.global_position.distance_to(global_position) / distance)
	volume_db = linear_to_db(minf(l + 0.5, 1.0))
	audio_to_stop.volume_db = linear_to_db(clampf(0.2 - l, 0.0, 1.0))
