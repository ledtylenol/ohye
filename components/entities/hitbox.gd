extends Area3D
class_name Hitbox
@export var piercing := false
@export var damage := 1
@export var is_enemy := true
@export var active := true
var ignore_list: Array[Hurtbox] = []
signal hit
func _ready() -> void:
	if is_enemy:
		collision_layer = 1 << 3
		collision_mask = 1 << 2
	else:
		collision_layer = 1 << 2
		collision_mask = 1 << 3
	area_entered.connect(on_area_entered)

func on_area_entered(area: Area3D) -> void:
	var hurtb = area as Hurtbox
	if not hurtb: return
	if not hurtb in ignore_list:
		hit.emit()
