extends ProjectileProperty
class_name Timed
@export var lifetime := 5.0

func generate(node: Node) -> TimedComponent:
	return TimedComponent.new(node, lifetime)


class TimedComponent extends ProjectileComponent:
	var time := 5.0
	func _init(_t: Node3D,_time: float) -> void:
		time = _time
		target = _t
	func on_tick(dt: float) -> void:
		time -= dt
		if time < 0:
			target.queue_free()
