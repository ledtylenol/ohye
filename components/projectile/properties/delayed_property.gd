extends ProjectileProperty
class_name Delayed
@export var lifetime := 5.0
@export var properties: Array[ProjectileProperty]
func generate(node: Node) -> DelayedComponent:
	return DelayedComponent.new(node, lifetime, properties)


class DelayedComponent extends ProjectileComponent:
	var time := 5.0
	var properties: Array[ProjectileProperty]
	func _init(_t: Node3D,_time: float, props: Array[ProjectileProperty]) -> void:
		time = _time
		target = _t
		properties = props
	func on_tick(dt: float) -> void:
		time -= dt
		if time < 0:
			for c in properties:
				var g = c.generate(target)
				target.add_child(g)
			queue_free()
