extends Node3D


@onready var scene_loader: SceneLoader = $SceneLoader
@onready var song: FmodEventEmitter3D = $Song
@onready var player: Player = $Player
@onready var surf_area: Area3D = $SurfArea
@onready var surf_area2: Area3D = $SurfArea2
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var surf_area_3: Area3D = $SurfArea3

@onready var bhop: FmodEventEmitter3D = $Bhop

@export var fall_areas: Array[Area3D]
@export var fall_point: Node3D
var fog = load("res://world/subway/subwayoffv1_fog.tres")
var nofog = load("res://world/subway/subwayoffv1_nofog.tres")
func _ready() -> void:
	song["fmod_parameters/Charge"] = randf()
	song.play()
	surf_area.body_entered.connect(on_surf_body.bind(nofog))
	surf_area2.body_entered.connect(on_surf_body.bind(fog))
	for area in fall_areas:
		area.body_entered.connect(on_teleport)
	surf_area_3.body_entered.connect(play)
	surf_area_3.body_exited.connect(stop)
func on_surf_body(b: Node3D, env: Environment) -> void:
	if b is Player:
		world_environment.environment = env

func play(b: Node3D) -> void:
	if b is not Player:
		return
	song.volume = 0.0
	bhop.play()
func stop(b: Node3D) -> void:
	if b is not Player:
		return
	song.volume = 1.0
	bhop.stop()
func on_teleport(b: Node3D) -> void:
	if b is Player:
		b.global_position = fall_point.global_position
		b.velocity = Vector3.ZERO
