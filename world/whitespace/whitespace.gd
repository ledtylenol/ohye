@tool
extends Level


@onready var song: FmodEventEmitter3D = $Song

func _ready() -> void:
	if Engine.is_editor_hint(): return
	Music.change_song(song)
