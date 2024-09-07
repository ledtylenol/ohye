extends CharacterBody3D
class_name Player


const FRICTION: float = 6.0;
const STOP_SPEED: float = 1.0 * SCALE_FACTOR;
const SCALE_FACTOR: float = 0.03125;
const AIR_SPEED: float = 1.0;
const COYOTE_TIME: float = 0.1
signal just_left_ground()
signal just_landed()
signal just_pounded()
signal jump_ground()
signal jump_air()

enum STATES {
	AIR,
	GROUNDED,
	POUNDING,
	STUNNED
}
@export var stats: PlayerStats
@export var state: STATES:
	set(value):
		if value == STATES.GROUNDED:
			ground_pound_count = 3
		state = value
@export_category("")
@export var camera: PlayerCamera
@export var shaker: ShakerComponent3D
@export var winds: AudioStreamPlayer
var heat: float = 0.0
var pounding := false
var combo:int = 0
var can_glide := false
var ground_pound_count := 3:
	set(value):
		ground_pound_count = max(0, value)
var times := {
	"jump": 0.0,
	"air": 0.0
}
var current_frame := 0
var current_air_coefficient: float = 0.1
var jumps_left: int = 0
var direction: Vector3 = Vector3.ZERO
var touched_ground: bool = false
var former_velocity: Vector3 = Vector3.ZERO
var former_gp := Vector3.ZERO
var let_go_of_space: bool = false
var normal: Vector3 = Vector3.ZERO
var dead: bool = false
@export var auto_jump: bool = false

func _ready() -> void:
	Global.player = self
func _physics_process(delta: float) -> void:
	if dead:
		return
	
	times["jump"] += delta
	process_inputs()
	check_ground(delta)

	match state:
		STATES.GROUNDED:
			move_ground(delta)
		STATES.AIR:
			move_air(delta)
	if do_ground_jump():
		jump_ground.emit()
		times["air"] = COYOTE_TIME + 0.001
		let_go_of_space = false
	elif do_air_jump():
		jump_air.emit()
	else:
		if touched_ground and state != STATES.GROUNDED: apply_floor_snap()
	pounding = do_ground_pound()
	apply_gravity(delta)
	
	
	if is_on_wall_only():
		normal = get_wall_normal()
		velocity = velocity.slide(normal)
	former_velocity = velocity
	former_gp = global_position
	move_and_slide()
	current_frame += 1
func process_inputs():
	var dir = Input.get_vector("left", "right", "front", "back")
	var temp_dir:Vector3 = (dir.x * global_basis.x + dir.y * global_basis.z)
	var old_dir := direction
	direction = (dir.x * global_basis.x + dir.y * global_basis.z)
	#if normal.length() > 0:
		#var slid_dir := direction.slide(normal)
		#if Input.is_action_pressed("crouch"):
			#direction = slid_dir

func check_ground(delta: float) -> void:
	if is_on_floor():
		normal = get_floor_normal()
		if not touched_ground:
			touched_ground = true
			just_landed.emit()
			if not Input.is_action_pressed("jump"):
				state = STATES.GROUNDED
			if state == STATES.POUNDING:
				just_pounded.emit()
		times["air"] = 0.0
		jumps_left = stats.jump_count
		if state == STATES.AIR:
			state = STATES.GROUNDED
	else:
		normal = Vector3.ZERO
		if touched_ground and times["air"] > 0.1:
			touched_ground = false
			just_left_ground.emit()
		times["air"] += delta
		if state ==  STATES.GROUNDED:
			state = STATES.AIR
func move_ground(delta: float) -> void:
	if Input.is_action_pressed("jump") and auto_jump:
		return
	if Input.is_action_pressed("crouch"):
		velocity = velocity.slide(normal)
		velocity += (global_basis.y * stats.fall_gravity * delta).slide(normal)

		if is_equal_approx(normal.dot(Vector3.UP), 1.0):
			if velocity.length() < 0.2:
				velocity = velocity.move_toward(Vector3(0, velocity.y, 0), delta)
			else:
				velocity -= M.xz(velocity).normalized() *0.2
		#if not(Input.is_action_pressed("jump") and auto_jump):
			#apply_floor_snap()
		
		return
	else:
		apply_friction(delta)
	var speed :float
	if stats.speed_mul > 10:
		speed = stats.speed * (10 + log((stats.speed_mul - 10)**3))
	else:
		speed = stats.speed * stats.speed_mul
	var new_vel := velocity
	var dot := new_vel.dot(direction)
	var add_speed: float
	if Input.is_action_pressed("sprint"):
		add_speed = 5.0 - dot
	else:
		add_speed = speed - dot
	if add_speed <= 0.0:
		return
	var accel: float
	if Input.is_action_pressed("sprint"):
		accel = 10.0 * 5.0 * delta
	else: 
		accel = maxf(1.0,stats.ground_acceleration) * speed * delta
	if add_speed > 50:
		accel *= add_speed / speed
	if accel > add_speed:
		accel = add_speed
	if stats.ground_acceleration < 1.0 and not Input.is_action_pressed("sprint"):
		accel *= maxf(0.4, stats.ground_acceleration)
	velocity += accel * direction
	Global.influence = 1.0 - clampf(velocity.length() / 24.0, 0.0, 1.0)
func move_air(delta: float) -> void:
	var new_vel := velocity
	var dot := new_vel.dot(direction)
	var add_speed := AIR_SPEED - dot
	
	if add_speed <= 0.0:
		return
	
	var accel := maxf(1.0,stats.ground_acceleration) * 10 * stats.speed * delta * stats.speed_mul
	if accel > add_speed:
		accel = add_speed
	
	velocity += accel * direction

func apply_friction(delta: float) -> void:
	var new_velocity := velocity
	var speed := new_velocity.length()
	if speed < 0.001:
		return
	
	var control: float
	if speed < STOP_SPEED:
		control = STOP_SPEED
	elif auto_jump and Input.is_action_pressed("jump"):
		control = STOP_SPEED / 3
	else:
		control = speed
	
	var new_speed := speed - delta * control * FRICTION
	if new_speed <= 0.0:
		new_speed = 0.0
	
	new_speed /= speed
	velocity = new_velocity * new_speed

func do_ground_jump() -> bool:
	var can_jump := jumps_left > 0 and Input.is_action_just_pressed("jump") or (Input.is_action_pressed("jump") and \
			(auto_jump or state == STATES.POUNDING))
	if not (state == STATES.GROUNDED or state == STATES.POUNDING) or \
			times["air"] > COYOTE_TIME or not can_jump:
		return false
	times["jump"] = 0.0
	jumps_left -= 1
	if state == STATES.POUNDING and not is_zero_approx(normal.length()):
		state = STATES.AIR


		var new_vel: Vector3= M.xz(former_velocity) + \
				 (normal + Vector3.UP * max(0.0, -1 + sqrt(absf(former_velocity.y) / 100.0))) * normal.dot(Vector3.UP) * \
				stats.jump_velocity * \
				(1 + stats.max_ground_pounds - ground_pound_count)
		print("%s %s" % [max(1.0, abs(former_velocity.y) - 100.0), abs(former_velocity.y) - 100.0])
		velocity = new_vel
		ground_pound_count -= 1
		return true
	velocity.y = stats.jump_velocity
	return true
	

func do_air_jump() -> bool:
	if not Input.is_action_just_pressed("jump") or jumps_left < 1:
		return false
	let_go_of_space = false
	jumps_left -= 1
	velocity.y = stats.jump_velocity
	state = STATES.AIR
	return true


func apply_gravity(delta: float) -> bool:
	if is_on_floor() or velocity.y < -265:
		return false
	if not Input.is_action_pressed("jump"):
		let_go_of_space = true
	
	if velocity.y < 0.0:
		velocity += global_basis.y * stats.fall_gravity * delta
		return true
	else:
		if let_go_of_space and times["jump"] > stats.minimum_jump_duration:
			velocity += 2.0 * global_basis.y * stats.fall_gravity * delta
			return true
		velocity += global_basis.y * stats.jump_gravity * delta
		return true


func do_ground_pound() -> bool:
	if not state == STATES.AIR or not Input.is_action_just_pressed("crouch") or ground_pound_count <= 0:
		return false
	velocity.y = -100.0
	state = STATES.POUNDING
	return true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			Global.datamosh_amount = 0.0
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			Global.datamosh_amount = 1.0
