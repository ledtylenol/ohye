class_name SecondOrderDynamics
extends Node
@export var do_angle: bool = false
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

@onready
var xp
@onready
var xpf: float
@onready
var yd
@onready
var ydf: float = 0.0
func init(start: Vector3, startf: float= 0):

	_calc_k()
	xp = start
	xpf = startf
	yd = Vector3.ZERO
func init2(start: Vector2):
	_calc_k()
	xp = start
	yd = Vector2.ZERO
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
	if not do_angle:
		xd = (target - xp) / delta
	else:
		xd.x = angle_difference(xp.x, target.x )
		xd.y = angle_difference(xp.y, target.y )
		xd.z = angle_difference(target.z, xp.z)
	xp = target
	var iterations:int = ceili(delta/_delta_crit)
	var delta_t = delta/iterations
	for i in range(0,iterations):
		current = current + (delta_t*yd)
		yd = yd + (delta_t*(target + _k3*xd  - current - _k1*yd )) / _k2;
	return [current, yd]

func update_f(current: float, target: float, delta:float):
	_calc_k()
	var xd = (target - xpf) / delta
	xpf = target
	var iterations:int = ceili(delta/_delta_crit)
	var delta_t = delta/iterations
	for i in range(0,iterations):
		current = current + (delta_t*ydf)
		ydf = ydf + (delta_t*(target + _k3*xd  - current - _k1*ydf )) / _k2;
	return current
