class_name SecondOrderDynamics
extends Node
@export
var _f: float = 1

@export
var _z: float = 0.65

@export
var _r: float = 2

var _k1: float
var _k2: float
var _k3: float

var _delta_crit: float

@onready var xp
@onready var xpf: float
@onready var xpq: Quaternion
@onready var yd
@onready var ydf: float = 0.0
@onready var ydq: Quaternion

func init(start: Vector3, startf: float= 0):

	_calc_k()
	xp = start
	xpf = startf
	yd = Vector3.ZERO
func init2(start: Vector2, sf: float = 0.0):
	_calc_k()
	xp = start
	yd = Vector2.ZERO
	xpf = sf
func initq(start: Quaternion):
	_calc_k()
	xpq = start
	ydq = Quaternion.IDENTITY
func _calc_k():
	_k1 = _z / (PI * _f)
	_k2 = 1 / pow(2*PI*_f,2)
	_k3 = _r * _z / (2*PI*_f)
	_delta_crit = 0.8 * (sqrt(4 * _k2 + _k1*_k1) - _k1)


func update(current, target, delta:float):
	_calc_k()
	var xd
	if current is Vector2:
		xd = Vector2.ZERO
	elif current is Vector3:
		xd = Vector3.ZERO 
	xd = (target - xp) / delta

	xp = target
	var iterations:int = ceili(delta/_delta_crit)
	var delta_t = delta/iterations
	for i in range(0,iterations):
		current = current + (delta_t*yd)
		yd = yd + (delta_t*(target + _k3*xd  - current - _k1*yd )) / _k2;
	return [current, yd]

func update_q(current: Quaternion, target: Quaternion, delta:float):
	_calc_k()
	if target.dot(current) < 0.0:
		current = -current
	var xd := Quaternion.IDENTITY
	xd = (target - xpq) / delta

	xpq = target
	var iterations:int = ceili(delta/_delta_crit)
	var delta_t = delta/iterations
	for i in range(0,iterations):
		current = current + (delta_t*ydq)
		ydq = ydq + (delta_t*(target + _k3*xd  - current - _k1*ydq )) / _k2;

	return [current.normalized(), ydq]
func update_f(current: float, target: float, delta: float, use_angle = false) -> float:
	_calc_k()

	var xd: float
	if use_angle:
		# Use shortest path for angular difference
		xd = fmod(target - xpf + PI, TAU) - PI
	else:
		xd = (target - xpf) / delta

	xpf = target
	var iterations: int = ceili(delta / _delta_crit)
	var delta_t: float = delta / iterations

	for i in range(iterations):
		if use_angle:
			# Calculate shortest path difference directly
			var diff = fmod(target - current + PI, TAU) - PI
			current += delta_t * ydf
			ydf += delta_t * (diff + _k3 * xd - _k1 * ydf) / _k2
			current = fmod(current + PI, TAU) - PI  # Wrap current after updates
		else:
			current += delta_t * ydf
			ydf += delta_t * (target + _k3 * xd - current - _k1 * ydf) / _k2

	return current
func normalize_sign(t: Quaternion) -> Quaternion:
	t.w *= -1
	t.x *= -1
	t.y *= -1
	t.z *= -1
	return t
