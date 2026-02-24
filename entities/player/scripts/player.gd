extends Entity
class_name Player

const FRICTION: float = 9.0
const STOP_SPEED: float = 5.0 * SCALE_FACTOR
const SCALE_FACTOR: float = 0.03125
const AIR_SPEED: float = 2.0
const COYOTE_TIME: float = 0.1
const HIT_ME = preload("res://shakes/hit_me.tres")
var collider: CapsuleShape3D = load("res://entities/player/player_collider.tres")
@warning_ignore_start("unused_signal")
signal just_left_ground
signal just_landed
signal just_pounded
signal jump_ground
signal jump_air
signal teleport
signal active_set(v: bool)
enum STATES{AIR, GROUNDED, POUNDING, WALKING, CROUCHING, STUNNED}

var last_ground_type: = Constants.Ground.STONE

@export_category("Components")
@export var camera: PlayerCamera
@export var shaker: ShakerComponent3D
@export var winds: AudioStreamPlayer
@export var health_component: HealthComponent
@export var hurtbox: Hurtbox
@export var hit_shaker: ShakerComponent3D
@export var circle_progress: CircleProg
@export var shape_cast: ShapeCast3D
@export var left_cast: RayCast3D
@export var right_cast: RayCast3D
@export var stats: PlayerStats
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var spot_light: SpotLight3D = $PanNode / PlayerCamera / SpotLight3D
@onready var sounds: Node3D = $Sounds
@export var menu: Menu
@export var resume: Button
@export var state_machine: StateMachine

var raycasts_colliding := false
var heat: float = 0.0
var grav_dir: = Vector3.DOWN
var grounded: = false:
	set(v):
		if v and not touched_ground:
			touched_ground = true
		if times.air > 0.1 and touched_ground:
			just_left_ground.emit()
			touched_ground = false
		grounded = v

var times: = {"jump": 0.0, "air": 0.0, "space": 0.0}
var current_frame: = 0
var current_air_coefficient: float = 0.1
var jumps_left: int = 0
var direction: Vector3 = Vector3.ZERO:
	set(v):
		if v.length():
			former_dir = v
		direction = v
var former_dir := direction
var touched_ground: bool = false
var former_velocity: Vector3 = Vector3.ZERO
var former_gp: = Vector3.ZERO
var let_go_of_space: bool = false
var grav_areas: Array[GravArea]
var current_speed := 0.0
var inventory: = {}
var active: = true:
	set(v):
		active = v
		active_set.emit(v)

var wall_normal := Vector3.ZERO
@export_category("Params")
@export var auto_jump: bool = false
@export var randomize_scale: = false


func _ready() -> void:

	resume.button_up.connect(set.bind("ingame_mode", false))

	if randomize_scale:
		scale = Vector3.ONE * Global.randf_range(0.7, 1.2)
	process_inputs()
	Global.player = self
	if hurtbox:
		if hit_shaker:
			hurtbox.hit.connect(hit)
	if health_component:
		health_component.died.connect(die)
	Global.enforce_cursor = false

func check_ground() -> void:
	grounded = shape_cast.is_colliding()

	
func _physics_process(delta: float) -> void :
	if not active: return
	if dead:
		if Input.is_action_pressed("interact"):
			Transition.reload_scene()
		return
	
	check_ground()
	raycasts_colliding = (Input.is_action_pressed("left") and left_cast.is_colliding()
		 or Input.is_action_pressed("right") and right_cast.is_colliding())
	times.jump += delta
	state_machine.current_state.physics_tick(delta)
	former_velocity = velocity
	former_gp = global_position
	move_and_slide()
	current_frame += 1

func _process(delta: float) -> void:
	times["jump"] += delta
	times.space += delta
	if Input.is_action_just_pressed("jump"): times.space = 0.0
	if not grounded: times.air += delta
	else: times.air = 0.0
	process_inputs()
	state_machine.current_state.tick(delta)
func process_inputs():
	var dir = Input.get_vector("left", "right", "front", "back")
	direction = global_basis * Vector3(dir.x, 0, dir.y)


func move_ground(delta: float) -> void :
	if Input.is_action_pressed("jump") and auto_jump:
		return
	apply_friction(delta)
	var speed = 5.0 if Input.is_action_pressed("sprint") else stats.speed
	if direction:
		current_speed = move_toward(current_speed, speed, delta * maxf(1.0, stats.ground_acceleration) )
	if current_speed:
		velocity = velocity.move_toward(direction * current_speed, stats.ground_acceleration * delta)
		velocity = velocity.slerp(direction * velocity.length(), 1.0 - exp(-delta * 5))

	#velocity += accel * stats.ground_accel_modifier * direction


	#velocity += accel * stats.ground_accel_modifier * direction


func move_air(delta: float) -> void :
	var new_vel: = velocity
	var dot: = new_vel.dot(direction)
	var add_speed: = AIR_SPEED - dot

	if add_speed <= 0.0:
		return

	var accel: = maxf(1.0, stats.air_accel)  * stats.air_speed * delta * stats.speed_mul
	if accel > add_speed:
		accel = add_speed

	velocity += accel * direction


func apply_friction(delta: float) -> void :
	var new_velocity: = velocity
	var speed: = new_velocity.length()
	var des_speed = 5.0 if Input.is_action_pressed("sprint") else stats.speed
	if speed < 0.0001 or speed < des_speed and direction.length() and direction.dot(velocity) > 0:
		if speed < 0.0001:
			current_speed = 0.0
		return

	var control: float
	if speed < STOP_SPEED:
		control = STOP_SPEED
	elif auto_jump and Input.is_action_pressed("jump"):
		control = STOP_SPEED / 3
	else:
		control = speed

	var new_speed: = move_toward(speed, 0.0, delta * control * FRICTION)


	new_speed /= speed
	current_speed = current_speed * new_speed
	velocity = velocity.move_toward(direction * current_speed, delta * control * FRICTION)

func do_ground_jump() -> bool:
	var can_jump: bool = (times.air < COYOTE_TIME and 
		jumps_left > 0 and (Input.is_action_just_pressed("jump")
		or (Input.is_action_pressed("jump") and (auto_jump )))
	)
	if (
		not can_jump
	):
		return false
	times["jump"] = 0.0
	let_go_of_space = false
	jumps_left -= 1
	velocity = M.xz(velocity) + Vector3.UP * stats.jump_velocity
	return true


func do_air_jump() -> bool:
	if not Input.is_action_just_pressed("jump") or jumps_left < 1:
		return false
	let_go_of_space = false
	jumps_left -= 1
	velocity.y = stats.jump_velocity
	return true


func apply_gravity(delta: float) -> bool:
	var down_vel: = velocity.project( - grav_dir)
	if grounded or down_vel.length() > 265:
		return false
	if not Input.is_action_pressed("jump"):
		let_go_of_space = true


	if down_vel.length() < 0.0:
		velocity -= grav_dir * stats.fall_gravity * delta
		return true
	else:
		if let_go_of_space and times["jump"] > stats.minimum_jump_duration:
			velocity -= 2.0 * grav_dir * stats.fall_gravity * delta
			return true
		velocity -= grav_dir * stats.jump_gravity * delta
		return true

func apply_wall_gravity(delta: float, n: Vector3) -> void:
	if grounded or velocity.dot(grav_dir) > 5:
		var rem = velocity.dot(grav_dir) - 5.0
		var dir := velocity.normalized().slide(n).slerp(-grav_dir, 0.2)
		if velocity.slide(n).length() < stats.wall_speed:
			velocity -= dir * (stats.fall_gravity) * delta * 0.5 * dir.dot(-camera.global_basis.z)
		velocity -= dir * (rem) * delta * 0.5 * dir.dot(-camera.global_basis.z)
		return
	velocity -= grav_dir * stats.fall_gravity * delta * 0.5



func hit(_a, _b) -> void :
	if dead:
		return
	HIT_ME.get_rotation_shake()[0].noise_texture.noise.seed = randi()
	hit_shaker.force_stop_shake()
	hit_shaker.shake(HIT_ME, ShakerComponent3D.ShakeAddMode.add, 0.4, 1.0, 1.0, 0.0, 0.3)





func has_item(item: ItemData) -> bool:
	return inventory.has(item)


func disable_collision() -> void :
	$CollisionShape3D.set_deferred("disabled", true)


func die() -> void :
	dead = true
	$CanvasLayer / Control / Dead.show()
	hurtbox.set_deferred("monitoring", false)
