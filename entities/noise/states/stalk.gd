extends State
class_name NoiseStalkState

@export var hitbox: Hitbox
@export var stalk_speed := 5.0

func on_enter() -> void:
	hitbox.hit.connect(on_hit)


func physics_tick(delta: float) -> void:
	target.move(delta, stalk_speed)

func on_hit() -> void:
	transitioned.emit("stalk", "active")
	target.activated.emit()
func on_exit() -> void:
	hitbox.hit.disconnect(on_hit)
