extends Node3D
@onready var music: FmodEventEmitter3D = $Music

func _ready() -> void:
	if Music.event_name != music.event_name:
		Music.stop()
		Music.event_name = music.event_name
		Music.play()
