extends Node
class_name WallDistanceComp
signal distance_reached
var distance := 0.0
@export var target: Player
@export var distance_over_velocity: Curve
@export var state_machine: StateMachine
@export var sound: Footsteps
func physics_tick(delta: float, wall: Vector3) -> void:
	if wall.is_zero_approx(): return
	var left = Input.is_action_pressed("left")
	distance += target.velocity.slide(wall).length() * delta
	var desired_distance := distance_over_velocity.sample(target.velocity.length())
	if distance >= desired_distance:
		distance_reached.emit()
		distance -= desired_distance
		sound.play_thing()
