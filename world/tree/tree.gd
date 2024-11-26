extends Node3D
@export_multiline var no_item_dialogues: Array[String]
@export_multiline var item_dialogues: Array[String]
@onready var text_writer_3d: TextWriter3D = $TextWriter3D
@onready var interact_component: InteractComponent = $Cube/StaticBody3D/InteractComponent
var player_interacted := 0
@onready var scene_loader: SceneLoader = $"../SceneLoader"
@onready var apple: InteractComponent = $MeshInstance3D/InteractComponent

func _ready() -> void:
	interact_component.interact.connect(p_i)
	text_writer_3d.texts = no_item_dialogues
	apple.interact.connect(Global.player.set_meta.bind("item1", 0))
	apple.interact.connect(disable_apple)

func p_i() -> void:
	if player_interacted == 0:
		player_interacted = 1
		scene_loader.request_load()
	if player_interacted == 1 and Global.player.has_meta("item1"):
		text_writer_3d.texts = item_dialogues
		scene_loader.try_load()

func disable_apple() -> void:
	apple.alpha = 0.0
	$MeshInstance3D/StaticBody3D/CollisionShape3D.set_deferred("disabled", true)
	$MeshInstance3D/InteractComponent.set_deferred("monitorable", false)
	$MeshInstance3D.hide()
	scene_loader.request_load()
