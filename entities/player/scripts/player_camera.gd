extends Camera3D
class_name PlayerCamera

var tween: Tween
@export var player: Player
@export var shaker: ShakerComponent3D
@onready var former_gp: = global_position
var first_preset:
	get: return shaker.get_shaker_preset().RotationShake[0]
var second_preset:
	get: return shaker.get_shaker_preset().RotationShake[1]
@export var pan_node: Node3D
@export_range(0.0, 1.0) var movement_tilt: float = 0.0
@export_range(0.0, 1.0) var camera_tilt: float = 1.0
var mins: = Vector3.ZERO
var maxs: = Vector3.ZERO
var target_rotation_z: = 0.0
var stats:
	get:
		return player.stats
@export_range(1.0, 100.0) var sensitivity: = 50.0:
	set(value):
		sensitivity = value
@export var y_offset: float = 3.0
var target_fov = 90.0

func _ready() -> void :
	if player and player is Player:
		player.just_landed.connect(_on_player_just_landed)
	rotation.y = 0
	rotation.x = 0
func _physics_process(delta: float) -> void :
	handle_fov(delta)
	do_shaker(delta)
	if player.dead or player.ingame_mode: return
	var x = - Input.get_axis("left", "right") * movement_tilt * int( not Input.is_action_pressed("slide"))
	pan_node.rotation.z = lerp_angle(pan_node.rotation.z, x * PI / 16.0, 1.0 - exp( - delta * 15))

func _input(event: InputEvent) -> void :
	if player.dead: return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		player.rotate_object_local(Vector3.UP, - event.relative.x * sensitivity / 4000.0)
		rotation.x -= event.relative.y * sensitivity / 4000.0
		rotation.x = clamp(rotation.x, - PI / 2, PI / 2)
		pan_node.rotate_z((global_basis.z.dot(player.basis.z) ** 2) * ( - event.relative.x * camera_tilt * pan_node.basis.z.dot(player.basis.z) ** 4) / 4000.0)


func _on_player_just_landed() -> void :
	if player.auto_jump and Input.is_action_pressed("jump"):
		return
	if tween:tween.kill()
	var remainder = min(abs(player.former_velocity.y / 10.0), 1.3)
	tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(false)
	tween.tween_property(self, "position:y", ( - remainder * 0.5) + y_offset, 0.1)
	tween.tween_property(self, "position:y", y_offset, 1.5)


func handle_fov(_delta: float):
	if player.normal == Vector3.ZERO:
		return






func do_shaker(delta: float) -> void :
	if player.dead or player.ingame_mode:
		first_preset.amplitude = M.smooth_nudgev(first_preset.amplitude, Vector3.ZERO, 10.0, delta)
		second_preset.amplitude = M.smooth_nudgev(second_preset.amplitude, Vector3.ZERO, 10.0, delta)
		return
	if player.direction and [player.STATES.GROUNDED, player.STATES.WALKING, player.STATES.CROUCHING].has(player.state) and not Input.is_action_pressed("slide"):
		if not Input.is_action_pressed("sprint"):
			first_preset.amplitude = M.smooth_nudgev(first_preset.amplitude, Vector3(0.03, 0.01, 0.03), 10.0, delta)
			second_preset.amplitude = M.smooth_nudgev(second_preset.amplitude, Vector3.ZERO, 10.0, delta)
		else:
			second_preset.amplitude = M.smooth_nudgev(second_preset.amplitude, Vector3(0.03, 0.01, 0.03), 10.0, delta)
			first_preset.amplitude = M.smooth_nudgev(first_preset.amplitude, Vector3.ZERO, 10.0, delta)
	else:
		first_preset.amplitude = M.smooth_nudgev(first_preset.amplitude, Vector3.ZERO, 10.0, delta)
		second_preset.amplitude = M.smooth_nudgev(second_preset.amplitude, Vector3.ZERO, 10.0, delta)
