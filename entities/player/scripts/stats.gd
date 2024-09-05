extends Resource
class_name PlayerStats

@export var jump_count := 1
@export var speed := 5
@export var speed_mul: float = 1.0
@export var jump_height: float: set = set_jump_height
@export var jump_peak_time: float: set = set_jump_peak_time
@export var jump_descend_time: float: set = set_jump_descend_time

@export var max_ground_pounds := 3

@export var ground_acceleration: float
@export var minimum_jump_duration: float

var jump_gravity: float
var jump_velocity: float
var fall_gravity: float

func set_jump_height(value: float):
	jump_height = value
	jump_velocity = (2.0 * value) / jump_peak_time;
	jump_gravity = (-2.0 * value) / (jump_peak_time * jump_peak_time);
	fall_gravity = (-2.0 * value) / (self.jump_descend_time * self.jump_descend_time);
func set_jump_descend_time(value: float):
	jump_descend_time = value
	jump_velocity = (2.0 * jump_height) / jump_peak_time;
	jump_gravity = (-2.0 * jump_height) / (jump_peak_time * jump_peak_time);
	fall_gravity = (-2.0 * jump_height) / (jump_descend_time * jump_descend_time);

func set_jump_peak_time(value: float): 
	jump_peak_time = value;
	jump_velocity = (2.0 * jump_height) / jump_peak_time;
	jump_gravity = (-2.0 * jump_height) / (jump_peak_time * jump_peak_time);
	fall_gravity =(-2.0 * jump_height) / (jump_descend_time * jump_descend_time);

func calculate_stuff() -> void:
	jump_velocity = (2.0 * jump_height) / jump_peak_time;
	jump_gravity = (-2.0 * jump_height) / (jump_peak_time * jump_peak_time);
	fall_gravity =(-2.0 * jump_height) / (jump_descend_time * jump_descend_time);
