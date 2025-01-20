extends Node
class_name HealthComponent
@export var hurtbox: Hurtbox
@export var max_health := 5:
	set(value):
		max_health = value
		max_health_changed.emit(value)
@export var starting_health := 5
@onready var current_health = starting_health:
	set(value):
		if not is_node_ready():
			return
		current_health = value
		health_changed.emit(value)
		if value <= 0:
			died.emit()
var capped_health: int:
	get: return clampi(current_health, 0, max_health) if is_node_ready() else 0
	set(value):
		current_health = clampi(value, 0, max_health)
var uncapped_health: int:
	get: return current_health if is_node_ready() else 0
	set(value): current_health = value

var capped_ratio: float:
	get: return capped_health / float(max_health)

var uncapped_ratio: float:
	get: return uncapped_health / float(max_health)
var damage_mult := 1.0
signal health_changed(new_health: int)
signal max_health_changed(new_max: int)
signal died


func _ready() -> void:
	if hurtbox:
		hurtbox.hit.connect(on_hit)
	

func on_hit(_b, damage: int) -> void:
	current_health -= damage * damage_mult
