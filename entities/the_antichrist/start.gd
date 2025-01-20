extends State
var dent = load("res://compositor_effects/woah/dent.tres")
func on_enter() -> void:
	target.target = Global.player.global_position + Vector3.UP * 10.0
	Global.boss_started.emit(target.health_component)
	Global.enforce_crosshair.emit(0)
	Global.enforce_cursor = target.health_component.capped_health > 0
	dent.enabled = true
func physics_tick(dt: float) -> void:
	target.update_rotation_random(dt)
	target.goto_target(dt)
