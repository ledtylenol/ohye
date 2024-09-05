extends Node
class_name HealthComponent

@export var max_health := 5:
	set(value):
		max_health = value
		max_health_changed.emit(value)
@export var starting_health := 5
@onready var current_health = starting_health:
	set(value):
		current_health = value
		health_changed.emit(value)
		if value <= 0:
			died.emit()
var capped_health: int:
	get: return mini(current_health, max_health)
	set(value):
		current_health = mini(max_health, value)
var uncapped_health: int:
	get: return current_health
	set(value): current_health = value

signal health_changed(new_health: int)
signal max_health_changed(new_max: int)
signal died

func _ready() -> void:
	health_changed.connect(prints.bind(max_health))
