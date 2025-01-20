extends RigidBody3D
class_name Ring
@onready var ring: MeshInstance3D = $ring/Ring
@onready var interact_component: InteractComponent = $InteractComponent
@export var interact_gravity := 0.1
func _ready() -> void:
	body_entered.connect(on_body_entered)
	interact_component.interact_start.connect(set_gravity_scale.bind(interact_gravity))
	interact_component.interact_end.connect(set_gravity_scale.bind(1.0))
func on_body_entered(_b) -> void:
	FmodServer.play_one_shot_attached("event:/Sfx3D/Bounce", self)
func _physics_process(delta: float) -> void:
	if interact_component.player and interact_component.interacting:
		var gp = interact_component.player.camera.global_position
		var cam_z = interact_component.player.camera.global_basis.z * -1
		var dir = global_position.direction_to(gp + cam_z * 1.5)
		apply_central_force(delta * dir * global_position.distance_to(gp) * 500.0)
