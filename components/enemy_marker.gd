extends Node
class_name EnemyMarker

@export var target: Node3D
func _ready() -> void:
	if not target:
		target = get_parent()
	
	Global.active_enemies.push_back(target)

func erase_enemy() -> void:
	if Global.active_enemies.has(target): Global.active_enemies.erase(target)
func _exit_tree() -> void:
	if Global.active_enemies.has(target): Global.active_enemies.erase(target)
