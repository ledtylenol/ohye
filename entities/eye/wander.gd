extends State
class_name Wander

@export var schizo: EyeSchizo
func physics_tick(dt: float) -> void:
	if schizo.player_in_sight:
		transitioned.emit("wander", "floating")
func on_exit() -> void:
	target.teleport_to(Global.player.camera.global_position + Vector3.UP * 10)
