extends Camera3D
class_name PlayerCamera
@export var player: Player
@export var shaker: ShakerComponent3D
@onready var former_gp := global_position
var first_preset:
	get: return shaker.get_shaker_preset().RotationShake[0]
var second_preset:
	get: return shaker.get_shaker_preset().RotationShake[1]
@export var pan_node: Node3D
@export_range(0.0, 1.0) var movement_tilt: float = 0.0
@export_range(0.0, 1.0) var camera_tilt: float = 1.0
var mins := Vector3.ZERO
var maxs := Vector3.ZERO
var target_rotation_z := 0.0
var stats:
	get:
		return player.stats
@export_range(1.0,100.0) var sensitivity := 50.0:
	set(value):
		sensitivity = value
@export var y_offset: float = 3.0
var target_fov = 90.0

func _ready() -> void:
	if player:
		player.just_landed.connect(_on_player_just_landed)
func _process(delta: float) -> void:
	if player.dead: return
	handle_fov(delta)
	do_shaker(delta)
	var x = -Input.get_axis("left", "right") * movement_tilt * int(not Input.is_action_pressed("slide"))
	pan_node.rotation.z = lerp_angle(pan_node.rotation.z, x * PI/16.0, delta * 3)
	if Input.is_action_just_pressed("ui_accept"):
		Global.influence = 1.0 - Global.influence
func _input(event: InputEvent) -> void:
	if player.dead: return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		player.global_rotate(player.normal, -event.relative.x * sensitivity / 4000.0) 
		rotation.x -= event.relative.y * sensitivity / 4000.0
		rotation.x = clamp(rotation.x, -PI/2, PI/2)
		pan_node.rotate_z((global_basis.z.dot(player.basis.z) ** 2)*(-event.relative.x * camera_tilt * pan_node.basis.z.dot(player.basis.z) ** 4)/4000.0)
		#pan_node.rotate_objec = clampf(pan_node.rotation.z, -PI/16, PI/16)
	if event.is_action_pressed("ui_cancel") and not player.ingame_mode:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_player_just_landed() -> void:
	var remainder = min(abs(player.former_velocity.y / 10.0), 1.3)
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(false)
	tween.tween_property(self, "position:y", (-remainder * 0.5) + y_offset, 0.1)
	tween.tween_property(self, "position:y", y_offset, 1.5)



func handle_fov(delta: float):
	if player.normal == Vector3.ZERO:
		return
	var vel_length = player.velocity.slide(player.normal).length()
	var vel_horizontal = player.velocity.slide(player.normal).normalized()
	var basis_horizontal = Vector3(player.basis.z.x, 0, player.basis.z.z).normalized()
	target_fov = clampf(90 + 15 * vel_length * max((-basis_horizontal).dot(vel_horizontal) * vel_horizontal.dot(player.direction), 0) / (player.stats.speed) * (player.stats.speed/30), 75, 110)
	fov = lerpf(fov, target_fov, 1.0-exp(-(delta*2)))

func do_shaker(delta: float) -> void:
	var v := global_position.distance_to(former_gp)
	if player.direction and [player.STATES.GROUNDED, player.STATES.WALKING, player.STATES.CROUCHING].has(player.state) and not Input.is_action_pressed("slide"):
		if not Input.is_action_pressed("sprint"):
			first_preset.amplitude = M.smooth_nudgev(first_preset.amplitude, Vector3(0.03, 0.01, 0.03), 10.0, delta)
			second_preset.amplitude = M.smooth_nudgev(second_preset.amplitude,  Vector3.ZERO, 10.0, delta)
		else:
			second_preset.amplitude = M.smooth_nudgev(second_preset.amplitude,  Vector3(0.03, 0.01, 0.03), 10.0, delta)
			first_preset.amplitude = M.smooth_nudgev(first_preset.amplitude, Vector3.ZERO, 10.0, delta)
	else:
		first_preset.amplitude = M.smooth_nudgev(first_preset.amplitude, Vector3.ZERO, 10.0, delta)
		second_preset.amplitude = M.smooth_nudgev(second_preset.amplitude, Vector3.ZERO, 10.0, delta)
	#if shaker._external_shakes.is_empty():
		#rotation.y = lerp_angle(rotation.y, 0.0, 1.0 - exp(-10 * delta))
		#rotation.z = lerp_angle(rotation.z, 0.0, 1.0 - exp(-10 * delta))
