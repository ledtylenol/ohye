extends Area3D
class_name Hitbox
@export var piercing := false
@export var damage := 1
@export var is_enemy := true
var ignore_list: Array[Hurtbox] = []
func _ready() -> void:
	if is_enemy:
		collision_layer = 1 << 3
	else:
		collision_layer = 1 << 4
