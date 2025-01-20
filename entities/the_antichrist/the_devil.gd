extends CharacterBody3D
class_name Peeper


var tween: Tween

var active := false
@onready var interact_component: InteractComponent = $InteractComponent
@onready var sound: FmodEventEmitter3D = $Sound
@onready var y: Node3D = $Sketchfab_model/Youmu_low_obj_cleaner_materialmerger_gles
@onready var rot: SecondOrderDynamics = $Rot
@onready var s: Node3D = $Sketchfab_model
@onready var initial_rot := s.quaternion
@onready var hitbox: Hitbox = $Hitbox
@onready var twiddle: FmodEventEmitter3D = $Twiddle

const BOSSFIGHT = preload("res://entities/the_antichrist/bossfight.tscn")
var was_disabled := false
var charging := false
var rot_vel := 0.0
var accumulated_rotation := 0.0

enum State{
	INACTIVE,
	CHARGING,
	ACTIVE,
	NULL
}
var transitioned := false
var state := State.INACTIVE
func _ready() -> void:
	interact_component.interact_start.connect(do_interact)
	rot.initq(s.quaternion)
	$Timer.timeout.connect(hitbox.set_deferred.bind("monitorable", false))
func do_interact() -> void:
	if state == State.INACTIVE:
		if randi() % 3 == 0:
			state = State.CHARGING
		do_inactive_tween()
func do_inactive_tween() -> void:
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(y, "scale", Vector3(1.1, 0.9, 1.1), 0.1)
	tween.tween_property(y, "scale", Vector3.ONE, 0.2)
	sound.play_one_shot()
	hitbox.set_deferred("monitorable", true)
	$Timer.start()
func _process(delta: float) -> void:
	match state:
		State.INACTIVE: do_inactive(delta)
		State.CHARGING: do_charging(delta)
func do_inactive(delta: float) -> void:
	var pos := M.xz(Global.player.camera.global_position) + Vector3.UP * s.global_position.y
	var q := Quaternion(global_basis.x, global_position.direction_to(pos))
	s.quaternion = rot.update_q(s.quaternion, q * initial_rot  , delta)[0]
func do_charging(delta: float) -> void:
	rot_vel += PI * delta * 0.9
	rotate_y(rot_vel * delta)
	accumulated_rotation += rot_vel * delta
	while accumulated_rotation > 2 * PI:
		accumulated_rotation -= 2 * PI
		sound["fmod_parameters/Charge"] = minf(1.0, rot_vel /( 10 * 2 * PI))
		sound.play()
		var parts := $GPUParticles3D.duplicate()
		var timed := TimedFree.new()
		timed.lifetime = 2.5
		parts.add_child(timed)
		parts.global_transform = global_transform
		get_tree().current_scene.add_child(parts)
		parts.emitting = true
	#if rot_vel > 2 * PI and not transitioned:
	if (rot_vel / 10 > 2 * PI or Input.is_action_just_pressed("secondary_attack")) and not transitioned:
		transition_to_active()
	translate(Vector3.UP * delta * 0.2)
func transition_to_active() -> void:
	var bossfight := BOSSFIGHT.instantiate()
	transitioned = true
	if tween: tween.kill()
	var tf := global_transform
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector3.ONE * 0.001, 1.0)
	tween.tween_callback($GPUParticles3D.set.bind("emitting", true))
	tween.tween_callback(func():
		get_tree().current_scene.add_child(bossfight)
		bossfight.global_transform = tf
		bossfight.velocity = Vector3.UP * bossfight.slow_speed * 2.0
		)
	tween.tween_callback(queue_free)
