extends State
@export var vel_rot: SecondOrderDynamics
@export var timer: Timer
@export var slow_speed := 5.0
var time_looked := 0.0
@export var schizo: BossSchizo
@export var health_component: HealthComponent
var cooldown := 1.0
func on_enter() -> void:
	timer.timeout.connect(target.change_target_random.bind(10, 40))
	target.velocity = M.rand_vec() * slow_speed
	vel_rot._f = 0.2
	vel_rot._r = 0.6
	vel_rot._z = 1
	time_looked = 0.0
func physics_tick(dt: float) -> void:
	target.update_rotation_random(dt)
	target.goto_target(dt)
	if schizo.player_in_sight:
		time_looked += dt
	cooldown -= dt
	if cooldown <= 0.0:
		$"../Random".on_enter()
		cooldown = randf_range(0.1, 0.4)
	if time_looked > 0.4:
		$"../Random".on_enter()
		time_looked -= 0.4
		health_component.capped_health -= 40
func on_exit() -> void:
	timer.timeout.disconnect(target.change_target_random)
