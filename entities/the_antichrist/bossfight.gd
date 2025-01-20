extends CharacterBody3D
class_name Bossfight1

@onready var player := Global.player
@onready var boss_schizo: BossSchizo = $Schizophrenia/BossSchizo
@onready var health_component: HealthComponent = $HealthComponent
@onready var model: Node3D = $Sketchfab_model/Youmu_low_obj_cleaner_materialmerger_gles
@onready var s: Node3D = $Sketchfab_model

@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var song: FmodEventEmitter3D = $Song
@onready var rot: SecondOrderDynamics = $Rot
@onready var rot_offset := s.quaternion
@onready var marker: Marker3D = $Marker3D
@onready var slow_timer: Timer = $Timers/SlowTimer
@onready var fast_timer: Timer = $Timers/FastTimer
@onready var state_machine: StateMachine = $StateMachine

@onready var vel_rot: SecondOrderDynamics = $VelRot
@onready var world := get_world_3d().direct_space_state
@export_category("Stats")
@export var slow_speed := 5.0
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var ouch: FmodEventEmitter3D = $Hit
var dent = load("res://compositor_effects/woah/dent.tres")
var distort = load("res://compositor_effects/distort/distort.tres")
var lock_on := false
var target := Vector3.ZERO
var tween: Tween
enum States {
	STOP,
	HIT,
	FAST,
	SLOW,
	RANDOM_TP,
	SPLIT,
	START
}
var state := States.START
func _ready() -> void:
	song.timeline_marker.connect(on_marker)
	song.play()
	vel_rot.init(Vector3.ZERO)

	hurtbox.hit.connect(hit)
	health_component.died.connect(die)
func hit(_h, _hhg) -> void:
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(model, "scale", Vector3.ONE, 1.0).from(Vector3(1.1, 0.9, 1.1))
	ouch["fmod_parameters/Charge"] = 0.8
	ouch.play()
	print(health_component.capped_health)
func _physics_process(_delta: float) -> void:
	if boss_schizo.player_in_sight:
		Global.enforce_crosshair.emit(1)
	else:
		Global.enforce_crosshair.emit(0)
	var local_pos := player.camera.unproject_position(global_position)
	var relative := local_pos / Vector2(DisplayServer.window_get_size())
	Global.center_shader = relative
	move_and_slide()

func goto_target(dt: float) -> void:
	velocity = vel_rot.update(global_position, target, dt)[1]

func look_at_player(delta: float) -> void:
	var q := Quaternion(s.basis.z, global_position.direction_to(player.camera.global_position))
	s.quaternion = rot.update_q(s.quaternion, q * s.quaternion * rot_offset * Quaternion(Vector3.UP, -PI/2), delta)[0]
func update_rotation_random(dt: float) -> void:
	var q := Quaternion(-s.global_basis.z, M.rand_vec())
	s.quaternion = rot.update_q(s.quaternion, q * s.quaternion * rot_offset * Quaternion(Vector3.UP, -PI/2), dt)[0]
func can_go_there(where: Vector3) -> bool:
	var ray_params := PhysicsRayQueryParameters3D.create(global_position, global_position + where, 1)
	
	return world.intersect_ray(ray_params).is_empty()
func on_marker(data: Dictionary) -> void:
	if data["name"] == "Die":
		print("die")
		health_component.capped_health = 0
	state_machine.current_state.transitioned.emit(state_machine.current_state.name, data["name"])

func change_target_random(r_min: float, r_max: float) -> void:
	var attempts := 0
	var p_p := player.global_position
	var new_dir :Vector3= p_p + M.random_sample_point_in_cone(PI/6, -player.camera.global_basis.z) * randf_range(r_min, r_max)
	while not can_go_there(new_dir) and attempts < 100:
		new_dir = p_p + M.random_sample_point_in_cone(PI/6, -player.camera.global_basis.z) * randf_range(r_min, r_max)
		attempts += 1
	if attempts == 100:
		print('attemts')
		new_dir = p_p - player.camera.global_basis.z * randf_range(r_min, r_max)
	if new_dir.y < player.camera.global_position.y + 6:
		new_dir.y += randf_range(3, 12)
	target = new_dir


func reset_rot() -> void:
	rot.initq(s.quaternion)

func die() -> void:
	dent.enabled = false
	Global.enforce_cursor = false
	Global.enforce_disabled.emit()
	queue_free()
