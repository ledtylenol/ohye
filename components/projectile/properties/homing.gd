extends ProjectileProperty
class_name Homing
@export var infl := 0.5
@export var  rot_speed := 3.0
@export var time := 5.0
@export var use_advanced := false
func generate(node: Node) -> HomingComponent:
	if use_advanced:
		return AdvancedHomingComponent.new(node, infl, rot_speed, time)
	return HomingComponent.new(node, infl, rot_speed, time)

class AdvancedHomingComponent extends HomingComponent:

	func on_tick(dt: float) -> void:
		if target.dir.length() < 0.5:
			return
		time -= dt
		if time < 0:
			queue_free()
		var player := Global.player
		if is_zero_approx(target.velocity.length()):
			return
		var t: float = player.global_position.distance_to(target.global_position) / target.velocity.length()
		var pred_pos := player.global_position + player.velocity * t / 2
		var infl_vec :Vector3= target.dir.normalized().slerp(target.global_position.direction_to(pred_pos),infl)
		target.dir = M.slerp_normal(target.dir, infl_vec, dt, rot_speed)

class HomingComponent extends ProjectileComponent:
	var infl := 0.5
	var rot_speed := 3.0
	var time := 5.0

	func _init(_target: Node3D, _infl: float, _rot_speed: float, _time: float) -> void:
		infl = _infl
		rot_speed = _rot_speed
		time = _time
		target = _target
	func on_tick(dt: float) -> void:
		time -= dt
		if time < 0:
			queue_free()
		var player := Global.player
		var infl_vec :Vector3= target.dir.normalized().slerp(target.global_position.direction_to(player.global_position),infl)
		target.dir = M.slerp_normal(target.dir, infl_vec, dt, rot_speed)
