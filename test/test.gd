extends MeshInstance3D

var target_rotation := Quaternion.IDENTITY
@onready var sod: SecondOrderDynamics = $SecondOrderDynamics
@onready var schizophrenia_component: Schizophrenia = get_parent()
@onready var area_3d: Area3D = $Area3D

func _ready() -> void:
	sod.initq(Quaternion.IDENTITY)
	schizophrenia_component.player_exited.connect(print.bind("EXIT"))
	#schizophrenia_component.player_exited.connect(toggle_visible)

func _physics_process(delta: float) -> void:
	var dir := global_position.direction_to(Global.player.global_position)
	var q := Quaternion(-global_basis.z, dir)
	quaternion = sod.update_q(quaternion, q * Quaternion(global_basis), delta)[0]

func toggle_visible() -> void:
	visible = not visible
	area_3d.set_deferred("monitorable", visible)
