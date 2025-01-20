extends Area3D
class_name HomingArea
var k: Array[Knife]
func _ready() -> void:
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)
func _physics_process(delta: float) -> void:
	for b: Knife in k:
		b.velocity = M.slerp_normal(b.velocity, b.global_position.direction_to(global_position), delta, 30.0) * b.velocity.length()
func on_body_entered(b: Node3D) -> void:
	if b is Knife and not b in k:
		k.append(b)

func on_body_exited(b: Node3D) -> void:
	if b is Knife and b in k:
		k.erase(b)
