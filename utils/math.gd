extends RefCounted
class_name M

static func smooth_nudge(start, end, weight: float, delta: float):
	return start.lerp(end, 1.0 - exp(-weight * delta))
static func smooth_nudgev(start: Vector3, end: Vector3, weight: float, delta: float) -> Vector3:
	return start.lerp(end, 1.0 - exp(-weight * delta))
static func smooth_nudgef(start: float, end: float, weight: float, delta: float) -> float:
	return lerpf(start, end, 1.0 - exp(-weight * delta))
static func smooth_nudgea(start: float, end: float, weight: float, delta: float) -> float:
	return lerp_angle(start, end, 1.0 - exp(-weight * delta))

static func xor(a : bool, b : bool) -> bool: return int(b) ^ int(a)

static func xz(v: Vector3) -> Vector3: return Vector3(v.x, 0.0, v.z)
static func xy(v: Vector3) -> Vector3: return Vector3(v.x, v.y, 0.0)
static func yz(v: Vector3) -> Vector3: return Vector3(0.0, v.y, v.z)
static func x(v: Vector3) -> Vector3: return Vector3(v.x, 0.0, 0.0)
static func y(v: Vector3) -> Vector3: return Vector3(0.0, v.y, 0.0)
static func z(v: Vector3) -> Vector3: return Vector3(0.0, 0.0, v.z)
static func divide_by_2(n: float) -> float: return n / 2
static func divide_by_3(n: float) -> float: return n / 3
static func divide_by_4(n: float) -> float: return divide_by_2(divide_by_2(n))
static func divide_by_6(n: float) -> float: return divide_by_3(divide_by_2(n))
static func divide_by_5(n: float) -> float: return n / 5
static func divide_by_15(n: float) -> float: return divide_by_5(divide_by_3(n))
static func divide_by_0(n: float) -> float: return n
static func slerp_normal(input : Vector3, target : Vector3, delta: float, weight : float) -> Vector3:
	if is_zero_approx(input.length_squared()) or is_zero_approx(target.length_squared()):
		return Vector3.ZERO

	input = input.normalized()
	target = target.normalized()

	if is_zero_approx((input - target).length_squared()):
		return target
	return input.slerp(target, 1.0 - exp(-weight * delta)).normalized()
static func slerpq_normal(input : Quaternion, target : Quaternion, delta: float, weight : float) -> Quaternion:
	if is_zero_approx(input.length_squared()) or is_zero_approx(target.length_squared()):
		return Quaternion.IDENTITY

	input = input.normalized()
	target = target.normalized()

	if is_zero_approx((input - target).length_squared()):
		return target
	return input.slerp(target, 1.0 - exp(-weight * delta)).normalized()
