extends Node3D


@onready var area_3d: Area3D = $Area3D
@onready var scene_loader: SceneLoader = $SceneLoader
@onready var song: FmodEventEmitter3D = $Song
@onready var start: Control = $CanvasLayer/Start
@export var player: Player
@onready var strawberry: CollectibleStrawberry = $Strawberry

func _ready() -> void:
	print_orphan_nodes()
	if not Global.game_stats.read_start:
		strawberry.queue_free()
	if Global.closed_menu or Global.last_sound.length() != 0:
		on_finished()
		start.queue_free()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if not Global.last_sound.is_empty():
			print("sound to play set from former scene, guid: %s" % Global.last_sound)
			Global.closed_menu = true
			song.event_guid = Global.last_sound
		else:
			song["fmod_parameters/Charge"] = Global.randf()
		song.play()
		
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		start.finished.connect(on_finished)
		player.active = false
	area_3d.body_entered.connect(on_body)
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
	
