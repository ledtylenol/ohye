extends ProjectileProperty
class_name Acceleration
@export var time := 5.0
@export var lifetime := 5.0
@export var starting_speed := 5.0
@export var diff := 0.1
func generate(node: Node) -> AccelerateComponent:
	return AccelerateComponent.new(node, starting_speed, time, lifetime, diff)


class AccelerateComponent extends ProjectileComponent:
	var time := 5.0
	var diff := 0.1
	var speed := 5.0
	var lifetime := 5.0
	func _init(_target: Node3D, s: float, _time: float, _life: float,  _diff: float) -> void:
		time = _time
		speed = s
		diff = _diff
		target = _target
		lifetime = _life
	func _ready() -> void:
		if not "velocity" in target:
			push_warning("target has no velocity")
			queue_free()
	func on_tick(dt: float) -> void:
		time -= dt
		lifetime -= dt
		if time > 0:
			speed += diff * dt
		if lifetime < 0:
			queue_free()
		target.velocity += target.dir * speed * dt
