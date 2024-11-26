extends Resource
class_name PlayerStats2d

@export var attack_speed := 1.0
var aps:
	get:
		return 1.0 / attack_speed
	set(value):
		attack_speed = 1.0 / value
@export var move_speed := 500.0
@export var acceleration := 30.0
@export var dash_distance := 1000.0
@export var dash_speed := 2000.0
@export var aiming_speed := 100.0
@export var spread := PI / 2.0
var half_spread:
	get:
		return spread / 2.0
