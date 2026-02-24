extends Camera3D
class_name PlayerCamera

var tween: Tween
@export var player: Entity

@onready var former_gp: = global_position

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
var target_fov = 90.0

func _ready() -> void :
	rotation.y = 0
	rotation.x = 0
	sensitivity = Global.game_settings.sensitivity
	Global.game_settings.sensitivity_changed.connect(change_sens)
	if not Global.current_menu:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if player.is_physics_interpolated_and_enabled():
		pan_node.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
func change_sens(_o: float, new: float) -> void:
	sensitivity = new
func _process(delta: float) -> void :

	handle_fov(delta)
	if player.dead or Global.current_menu: return
	var x = - Input.get_axis("left", "right") * movement_tilt * int( not Input.is_action_pressed("slide")) * int(player.velocity.length() > 0.1)
	pan_node.rotation.z = lerp_angle(pan_node.rotation.z, x * PI / 16.0, 1.0 - exp( - delta * 15))

func _input(event: InputEvent) -> void :
	if player.dead: return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var coef = 1.0 if not is_zero_approx(sensitivity) else 0.0
		player.rotate_object_local(Vector3.UP, - event.relative.x * sensitivity / 4000.0)
		rotation.x -= event.relative.y * sensitivity / 4000.0
		rotation.x = clamp(rotation.x, - PI / 2, PI / 2)
		pan_node.rotate_z((global_basis.z.dot(player.basis.z) ** 2) * ( coef * - event.relative.x * camera_tilt * pan_node.basis.z.dot(player.basis.z) ** 4) / 4000.0)




func handle_fov(_delta: float):
	if player.normal == Vector3.ZERO:
		return
