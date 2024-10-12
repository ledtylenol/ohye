extends Area3D
class_name GravArea

var player: Player
func _ready() -> void:
	body_entered.connect(on_body_enter)
	body_exited.connect(on_body_exit)
	collision_mask = 8

func on_body_enter(body: Node3D) -> void:
	player = body as Player
	if not player:
		return
	player.grav_areas.push_back(self)
func on_body_exit(body: Node3D) -> void:
	player = body as Player
	if not player:
		return
	player.grav_areas.erase(self)
