extends MeshInstance3D

var target_rotation := Quaternion.IDENTITY
@onready var sod: SecondOrderDynamics = $SecondOrderDynamics
@onready var schizophrenia_component: Schizophrenia = get_parent()
@onready var area_3d: Area3D = $Area3D
@onready var marker: Marker3D = $Marker3D

func _ready() -> void:
	sod.initq(Quaternion.IDENTITY)
	schizophrenia_component.player_exited.connect(print.bind("EXIT"))
	#schizophrenia_component.player_exited.connect(toggle_visible)

func _physics_process(delta: float) -> void:
	marker.global_position = global_position
	marker.look_at(Global.player.global_position)
	target_rotation = marker.quaternion
	quaternion = sod.update_q(quaternion, target_rotation, delta)[0]

func toggle_visible() -> void:
	visible = not visible
	area_3d.set_deferred("monitorable", visible)
