extends MeshInstance3D

var target_rotation := Quaternion.IDENTITY
@onready var sod: SecondOrderDynamics = $SecondOrderDynamics
var target_quat:
	get:
		return $Marker3D.quaternion
func _ready() -> void:
	sod.initq(target_quat)

func _physics_process(delta: float) -> void:
	if target_quat:
		quaternion = sod.update_q(quaternion, target_quat, delta)[0]
	$Marker3D.look_at(Global.player.global_position)
