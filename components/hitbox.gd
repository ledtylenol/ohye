extends Area3D
class_name Hitbox

var damage := 1

func _ready() -> void:
	collision_layer = 1 << 7
