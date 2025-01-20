extends State

@export var vel_rot: SecondOrderDynamics
@export var timer: Timer
@export var slow_speed := 5.0
var time_looked := 0.0
@export var schizo: BossSchizo
@export var health_component: HealthComponent
@export var song: FmodEventEmitter3D
var counter := 0
var cooldown := 1.0
var shot_count := 0
func on_enter() -> void:
	shot_count = 0
	print("entered slow")
	timer.timeout.connect(target.change_target_random.bind(20, 50))
	target.velocity = M.rand_vec() * slow_speed
	vel_rot._f = 0.3
	vel_rot._r = 0.5
	vel_rot._z = 2
	time_looked = 0.0
	counter = 0
func physics_tick(dt: float) -> void:
	if time_looked <= 0.5:
		target.look_at_player(dt)
	else:
		target.update_rotation_random(dt)
	target.goto_target(dt)
	if schizo.player_in_sight:
		time_looked += dt
	cooldown -= dt
	health_component.damage_mult = 1.0 + time_looked
	if cooldown <= 0.0:
		if randi() % 2 == 0:
			$"../Random/ProjectileSpawner".spawn_one_off(target)
			cooldown = maxf(1.5 - shot_count / 25.0, 0.45)
			shot_count += 1
		else:
			$"../Random".on_enter()
			counter += 1
			cooldown = randf_range(0.1, 0.8)
	if time_looked > 1.0:
		$"../Random".on_enter()
		time_looked -= 1.0
		counter += 1
		health_component.capped_health -= 40
	song["fmod_parameters/Active"] = int(counter > 10 || shot_count > 20)
func on_exit() -> void:
	timer.timeout.disconnect(target.change_target_random)
