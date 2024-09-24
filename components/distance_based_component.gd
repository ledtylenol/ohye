extends Node
class_name DistanceBasedComponent

@export var target: Node3D
@export var callee: Node
@export var what_to_call: String
@export var desired_distance: float = 5.0
@export var grounded_only := true
@export_flags("x", "y", "z") var desired_axes

@onready var gp := target.global_position:
	set(value):
		if desired_axes & 1:
			gp.x = value.x
		if desired_axes & 2:
			gp.y = value.y
		if desired_axes & 4:
			gp.z = value.z
@onready var former_gp := gp

var distance := 0.0

signal distance_reached
func _ready() -> void:
	if not target:
		queue_free()
	if callee and what_to_call:
		distance_reached.connect(callee.call.bind(what_to_call))
	if not "is_on_floor" in target and grounded_only:
		queue_free()
func _physics_process(_delta: float) -> void:
	gp = target.global_position
	if gp.distance_to(former_gp) > 100.0:
		former_gp = gp
	if grounded_only and target.is_on_floor():
		distance += gp.distance_to(former_gp)
	elif not grounded_only:
		distance += gp.distance_to(former_gp)

	former_gp = gp
	if distance >= desired_distance:
		distance_reached.emit()
		distance -= desired_distance
