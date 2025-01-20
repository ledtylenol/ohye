extends Node3D

@onready var sod: SecondOrderDynamics = $Sod
var player:
	get:
		return Global.player
@onready var target_pos := global_position:
	set(value):
		target_pos = value
@onready var start_pos := global_position
@onready var eye_schizo: EyeSchizo = $Schizophrenia/EyeSchizo
@onready var marker: Marker3D = $Marker3D
@onready var rot_sod: SecondOrderDynamics = $RotSod

@onready var sprite: Sprite3D = $Sprite3D
@onready var health_component: HealthComponent = $HealthComponent
@export var teleport_sound: FmodEventEmitter3D
func _ready() -> void:
	sod.init(target_pos)
	rot_sod.initq(marker.quaternion)
	health_component.died.connect(on_dead)
func _physics_process(delta: float) -> void:
	global_position = sod.update(global_position, target_pos, delta)[0]
	if eye_schizo.in_sight:
		if not Global.enforce_cursor:
			Global.enforce_crosshair.emit(1)
		Global.enforce_cursor = true
func teleport_to(new: Vector3) -> void:
	global_position = new
	target_pos = new
	
	sod.init(new)
	teleport_sound.play()
func choose_random_target_from_start(min_b: float, max_b: float) -> void:
	var f := randf_range(min_b, max_b)
	#target_pos = M.random_sample_point_in_cone(2 * PI, Vector3.UP) * f + start_pos

func look_at_player(delta: float) -> void:
	look_at_pos(Global.player.camera.global_position, delta)
func look_at_pos(pos: Vector3, delta: float) -> void:
	var rot := Quaternion(-global_basis.z, global_position.direction_to(pos))
	marker.quaternion = rot * quaternion
	quaternion = rot_sod.update_q(quaternion, marker.quaternion, delta)[0]
func on_dead() -> void:
	Global.enforce_cursor = false
	queue_free()
