@tool
extends Level

var t  := 0.0
var tick := false
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
@onready var area_3d: Area3D = $Area3D

@export var portal_teleports: Array[PortalTeleport]
@onready var label: Label = $CanvasLayer/Label

@export var strawb: CollectibleStrawberry
var fog = load("res://world/subway/subwayoffv1_fog.tres")
var nofog = load("res://world/subway/subwayoffv1_nofog.tres")
func _ready() -> void:
	if Engine.is_editor_hint():return
	area_3d.body_entered.connect(on_achievement_area_body)
	Music.stop()
	Music.set_event_name(song.event_name)
	Music.set_parameter("Charge", Global.randf())
	Music.play()
	surf_area.body_entered.connect(on_surf_body.bind(nofog))
	surf_area2.body_entered.connect(on_surf_body.bind(fog))
	for area in fall_areas:
		area.body_entered.connect(on_teleport)
	surf_area_3.body_entered.connect(play)
	surf_area_3.body_exited.connect(stop)

	Global.teleport_to_id.connect(on_tp)
func on_surf_body(b: Node3D, env: Environment) -> void:
	if b is Player:
		world_environment.environment = env
func on_achievement_area_body(b: Node3D) -> void:
	tick = false
func play(b: Node3D) -> void:
	if b is not Player:
		return
	t = 0.0
	tick = true
	if strawb:
		strawb.visible = true
		strawb.set_deferred("monitoring", true)
		strawb.set_deferred("monitorable", true)
	song.volume = 0.0
	Music.stop()
	Music.set_event_name(bhop.event_name)
	Music.play()
func stop(b: Node3D) -> void:
	if b is not Player:
		return
	tick = false
	song.volume = 1.0
	Music.stop()
	Music.set_event_name(song.event_name)
	Music.play()
func on_teleport(b: Node3D) -> void:
	if b is Player:
		b.global_position = fall_point.global_position
		b.velocity = Vector3.ZERO


func on_tp(id: int) -> void:
	print("tpd with id: %d" % id)
	if id == 0:
		if strawb:
			strawb.visible = true
			strawb.set_deferred("monitoring", true)
			strawb.set_deferred("monitorable", true)
		t = 0

func _process(delta: float) -> void:
	if Engine.is_editor_hint():return
	t += delta * float(tick)
	if t > 0:
		label.text = "TIME: %.2f" % t
	else:
		label.text = ""
	
	if t > 15 and strawb and strawb.visible:
		strawb.visible = false
		strawb.set_deferred("monitoring", false)
		strawb.set_deferred("monitorable", false)
