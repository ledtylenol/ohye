extends State
class_name ActiveNoiseState

@export var speed := 30.0
@export var footsteps: Footsteps
@export var dist_per_footstep := 10.0
var dist := 0.0:
	set(v):
		if v > dist_per_footstep:
			dist = 0
			footsteps.play_thing()
		else:
			dist = v
func on_enter() -> void:
	print("entered noise state")

func physics_tick(delta: float) -> void:
	var old_pos := target.position.slide(Vector3.UP)
	target.move(delta, speed)
	dist += old_pos.distance_to(target.position.slide(Vector3.UP))
