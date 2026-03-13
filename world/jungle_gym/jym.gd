@tool
extends Level
@onready var music: FmodEventEmitter3D = $Music
@export var noise: NoiseEntity
@onready var scene_loader: SceneLoader = $SceneLoader

func _ready() -> void:
	if Engine.is_editor_hint():return
	Music.change_song(music)
	#noise.activated.connect(scene_loader.try_load)
