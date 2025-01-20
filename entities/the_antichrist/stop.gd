extends State


@export var timer: Timer
func on_enter() -> void:
	print("entered stop")
	target.reset_rot()

func physics_tick(dt: float) -> void:
	target.look_at_player(dt)
	target.goto_target(dt)
