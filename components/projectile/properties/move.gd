extends ProjectileProperty
class_name Move
@export var lifetime := 5.0
@export var speed := 50.0
func generate(node: Node) -> MoveComponent:
	return MoveComponent.new(node, speed,lifetime)


class MoveComponent extends ProjectileComponent:
	var diff := 0.1
	var speed := 5.0
	var lifetime := 5.0
	func _init(_target: Node3D, s: float, _life: float) -> void:
		speed = s
		target = _target
		lifetime = _life
	func _ready() -> void:
		if not "velocity" in target:
			push_warning("target has no velocity")
			queue_free()
	func on_tick(dt: float) -> void:
		lifetime -= dt
		if lifetime < 0:
			queue_free()
		target.velocity = target.dir * speed * dt
