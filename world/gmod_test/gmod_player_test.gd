@tool
extends Level

@export var song: FmodEventEmitter3D
func _ready() -> void:
	if Engine.is_editor_hint(): return
	InputCounter.active = false
	Music.change_song(song)
