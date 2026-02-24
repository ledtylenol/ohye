extends Node3D
@export var shaker: ShakerComponent3D
var first_preset:
	get: return shaker.get_shaker_preset().RotationShake[0]
var second_preset:
	get: return shaker.get_shaker_preset().RotationShake[1]

@export var shaker_curve: Curve
@export var player: Player
func _physics_process(delta: float) -> void:
	do_shaker(delta)

func do_shaker(delta: float) -> void :
	if player.dead:
		first_preset.amplitude = M.smooth_nudgev(first_preset.amplitude, Vector3.ZERO, 10.0, delta)
		second_preset.amplitude = M.smooth_nudgev(second_preset.amplitude, Vector3.ZERO, 10.0, delta)
		return
	if player.direction and player.state_machine.current_state.name == "Grounded" and not Input.is_action_pressed("slide"):
		if not Input.is_action_pressed("sprint"):
			first_preset.amplitude = M.smooth_nudgev(first_preset.amplitude, Vector3(0.03, 0.01, 0.03)  * shaker_curve.sample(player.velocity.length()), 10.0, delta)
			second_preset.amplitude = M.smooth_nudgev(second_preset.amplitude, Vector3.ZERO, 10.0, delta)
		else:
			second_preset.amplitude = M.smooth_nudgev(second_preset.amplitude, Vector3(0.03, 0.01, 0.03), 10.0, delta)
			first_preset.amplitude = M.smooth_nudgev(first_preset.amplitude, Vector3.ZERO, 10.0, delta)
	else:
		first_preset.amplitude = M.smooth_nudgev(first_preset.amplitude, Vector3.ZERO, 10.0, delta)
		second_preset.amplitude = M.smooth_nudgev(second_preset.amplitude, Vector3.ZERO, 10.0, delta)
