extends Node3D


@onready var area_3d: Area3D = $Area3D
@onready var scene_loader: SceneLoader = $SceneLoader
@onready var song: FmodEventEmitter3D = $Song
@onready var start: Control = $CanvasLayer/Start
@export var player: Player

func _ready() -> void:
	if Global.closed_menu:
		on_finished()
		start.queue_free()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		start.finished.connect(on_finished)
		player.active = false
	area_3d.body_entered.connect(on_body)
	if Global.game_stats.read_start:
		song["fmod_parameters/Charge"] = randf()
		song.play()

func on_body(b: Node3D) -> void:
	if b is Player:
		Global.game_stats.completed_subway = true
		Global.save()
		scene_loader.try_load()
		area_3d.queue_free()

func on_finished() -> void:
	player.active = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.closed_menu = true
	
