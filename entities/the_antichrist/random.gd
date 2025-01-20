extends State

var small_tween: Tween
var distort_tween: Tween
@onready var projectile_spawner: ProjectileSpawner = $ProjectileSpawner
@export var tp_sound: FmodEventEmitter3D
func on_enter() -> void:
	if distort_tween: distort_tween.kill()
	distort_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	distort_tween.tween_property(target.dent, "k", 0.0, 1.0).from(0.2)
	distort_tween.tween_property(target.distort, "k", 0.0, 1.0).from(-0.2)
	
	projectile_spawner.spawn_one_off(target)
	target.change_target_random(3, 15.0)
	target.quaternion *= Quaternion(M.rand_vec(), randf_range(-PI * 1.5, PI * 1.5))
	target.global_position = target.target
	if small_tween: small_tween.kill()
	small_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	small_tween.tween_property(target, "scale", Vector3.ONE, 0.5).from(Vector3.ONE * 0.01)
	tp_sound.play()
func physics_tick(dt: float) -> void:
	target.update_rotation_random(dt)
