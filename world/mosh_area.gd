extends Area3D
class_name MoshArea

var player: Player
@export var max_distance := 30.0
func _ready() -> void:
	body_entered.connect(on_b_enter)
	body_exited.connect(on_b_exit)
	collision_mask = 1 << 3

func on_b_enter(body: Node3D) -> void:
	if body is Player:
		player = body

func on_b_exit(body: Node3D) -> void:
	if body is Player:
		player = null


func _physics_process(delta: float) -> void:
	if player:
		var dist = player.global_position.distance_to(global_position)
		var rel := clampf(dist / max_distance, 0.0, 1.0)
		Global.datamosh_amount = sqrt(1.0 - rel) + 0.2
		Global.force_datamosh = 0.0
	else:
		Global.datamosh_amount = 0.0
