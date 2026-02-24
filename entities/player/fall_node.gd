extends Node3D

@export var offset_over_remainder: Curve
@export var player: Player
@export var y_offset := 0.5
var tween: Tween
@export var camera: PlayerCamera
@onready var camera_sod: SecondOrderDynamics = $"../../CameraSod"
var former_sign := 0:
	set(value):
		if value != former_sign:
			sign_changed.emit(value)
		former_sign = value
var remainder := 0.0
signal sign_changed(sign: int)
func _ready() -> void:
	player.just_landed.connect(_on_player_just_landed)
	player.jump_ground.connect(jumped)
	camera_sod.init(camera.position)
func _process(delta: float) -> void:
	camera.position = camera_sod.update(camera.position, Vector3(0, y_offset, 0), delta)[0]
	if abs(camera_sod.yd.y) > 0.1:
		former_sign = sign(camera.position.y - y_offset)
func _on_player_just_landed() -> void :
	if player.auto_jump and Input.is_action_pressed("jump"):
		return
	remainder = offset_over_remainder.sample(abs(player.former_velocity.y))
	#camera_sod.xp.y += remainder
	camera_sod.yd.y -= remainder * 10

func jumped() -> void:
	pass
	#camera_sod.yd.y += 0.5
