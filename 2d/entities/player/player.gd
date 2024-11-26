extends CharacterBody2D
class_name Player2D
@export var attack_speed := 2.0
@export var stats: PlayerStats2d
@export var dash_ghosts: Array[GhostSpawner]
var direction := Vector2.ZERO:
	set(value):
		if value.length():
			former_dir = value
		direction = value
var iterations := 15
enum {
	FREE = 0,
	DASHING = 1,
	STUNNED = 2,
	AIMING = 3
}
var state := FREE:
	set(value):
		if value != state:
			state_changed.emit(state, value)
			if value != AIMING:
				focus = 0.0
				focus_coeff = -1.0
			else:
				focus_coeff = 1.0
		state = value
var dash_left := 0.0
var times = {
	FREE: 0.0,
	DASHING: 0.0,
	STUNNED: 0.0,
	AIMING: 0.0
}
var collision: KinematicCollision2D:
	set(value):
		if not collision and not value:
			return
		if collision and not value:
			p_col_ended.emit(state, collision)
		elif not collision and value:
			p_col_started.emit(state, value)
			
		elif collision.get_collider() != value.get_collider():
			p_col_ended.emit(state, collision)
			p_col_started.emit(state, value)
			player_collided.emit(state, value)
		collision = value

var focus := 0.0:
	set(value):
		focus = clampf(value, 0.0, 1.0)
var inv_focus:
	get:
		return maxf(1.0 - focus, 0.0)
var can_aim:
	get:
		return Input.is_action_pressed("interact")
var focus_coeff := 0.0
var current_speed := 0.0
var speed:
	get:
		if state == AIMING:
			return stats.aiming_speed
		elif state == FREE:
			return stats.move_speed
		elif state == DASHING:
			return stats.dash_speed
		return 200.0
var former_dir: Vector2 = Vector2.ZERO
signal player_collided(state, collision)
signal p_col_started(state, collision)
signal p_col_ended(state, collision)
signal state_changed(old, new)
func _ready() -> void:
	Global2d.player = self

func _physics_process(delta: float) -> void:
	focus += focus_coeff * delta
	for spawner in dash_ghosts:
		spawner.active = state == DASHING
	
	match state:
		FREE:
			do_free(delta)
		DASHING:
			do_dashing(delta)
		STUNNED:
			do_stunned(delta)
		AIMING:
			do_aiming(delta)
	custom_collide(delta)
func get_input() -> void:
	direction = Input.get_vector("left", "right", "front", "back")

func do_aiming(delta):
	
	get_input()
	if current_speed > speed:
		current_speed *= 0.95
	elif current_speed > speed:
		current_speed *= 1.05
	
	do_movement(delta, current_speed)
	var dir := global_position.direction_to(get_global_mouse_position())
	dir = dir.rotated(randf_range(-stats.half_spread * inv_focus, stats.half_spread * inv_focus))
	add_times_except(AIMING, delta)
	if not Input.is_action_pressed("interact") and not check_dash(dir, focus):
		state = FREE
func do_movement(delta: float, speed: float) -> void:
	if times[DASHING] < 0.5:
		velocity = velocity.slerp(former_dir * speed, 1.0 - exp(-delta * (1.0 - times[DASHING] )*20.0))
	else:
		velocity = velocity.slerp(former_dir * speed, 1.0 - exp(-delta * 15.0))
func do_free(delta: float) -> void:
	current_speed += delta * stats.acceleration if current_speed < speed else -delta * stats.acceleration
	if current_speed - speed > speed:
		current_speed *= 0.995
	get_input()
	if Input.is_action_just_pressed("jump"):
		current_speed += 500.0
	do_movement(delta, current_speed)
	add_times_except(FREE, delta)
	if can_aim:
		state = AIMING
func do_dashing(delta: float) -> void:
	add_times_except(DASHING, delta)
func check_dash(dir: Vector2, velocity_mul := 1.0) -> bool:
	
	state = DASHING
	dash_left = stats.dash_distance * velocity_mul
	current_speed = speed
	velocity = dir * current_speed
	former_dir = dir
	return true
func do_stunned(delta: float) -> void:
	add_times_except(STUNNED, delta)
func custom_collide(delta: float) -> void:
	var res_o
	for i in range(iterations):
		var subdelt := delta / iterations
		var res := move_and_collide(velocity * subdelt)
		
		if res: 
			if not res_o or res_o.get_collider() != res.get_collider():
				collision = res
			res_o = res

			direction = velocity.bounce(res.get_normal()).normalized()
			velocity = velocity.bounce(res.get_normal())
		if state == DASHING:
			if dash_left > 0.0:
				dash_left -= (velocity * subdelt).length()
				dash_left = maxf(dash_left, 0.0)
			else: 
				state = FREE
	collision = res_o
func add_times_except(i: int, delta: float) -> void:
	for time in times:
		if time != i:
			times[time] += delta
	times[i] = 0.0
