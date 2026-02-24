extends Node
class_name DistanceBasedComponent

@export var target: Node3D
@export var callee: Node
@export var what_to_call: String
@export var distance_over_velocity: Curve
@export var grounded_only := true
@export_flags("x", "y", "z") var desired_axes
var former_velocity := Vector3.ZERO
var gp: Vector3:
	set(value):
		if desired_axes & 1:
			gp.x = value.x
		if desired_axes & 2:
			gp.y = value.y
		if desired_axes & 4:
			gp.z = value.z
var former_gp := gp

var distance := 0.0

signal distance_reached
func _ready() -> void:
	if not target:
		queue_free()
	gp = target.global_position
	if callee and what_to_call:
		distance_reached.connect(callee.call.bind(what_to_call))
	if not "is_on_floor" in target and grounded_only:
		queue_free()
	former_gp = gp
func _physics_process(_delta: float) -> void:
	gp = target.global_position
	if gp.distance_to(former_gp) > 100.0:
		former_gp = gp
	if grounded_only and target.is_on_floor():
		distance += gp.distance_to(former_gp)
	elif not grounded_only:
		distance += gp.distance_to(former_gp)
	former_velocity = (gp - former_gp) / _delta
	former_gp = gp
	var desired_distance := distance_over_velocity.sample(former_velocity.length())
	if distance >= desired_distance:
		distance_reached.emit()
		distance -= desired_distance
