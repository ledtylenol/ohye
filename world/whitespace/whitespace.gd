extends Node3D


@onready var song: FmodEventEmitter3D = $Song

func _ready() -> void:
	song.play()
