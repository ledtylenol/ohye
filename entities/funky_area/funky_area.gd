extends Area3D
class_name FunkyArea
var p: Player
func _ready() -> void:
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)
	collision_mask = 1 << 3
func _physics_process(delta: float) -> void:
	if p:
		Global.force_datamosh = 1.0 - global_position.distance_to(p.global_position) / 50

func on_body_entered(body: Node3D) -> void:
	var player := body as Player
	if not player:
		return
	p = player
func on_body_exited(body: Node3D) -> void:
	var player := body as Player
	if not player:
		return
	p = null
