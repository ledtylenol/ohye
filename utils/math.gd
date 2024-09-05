extends RefCounted
class_name M

static func smooth_nudgev(start: Vector3, end: Vector3, weight: float, delta: float) -> Vector3:
	return start.lerp(end, 1.0 - exp(-weight * delta))
static func smooth_nudgef(start: float, end: float, weight: float, delta: float) -> float:
	return lerpf(start, end, 1.0 - exp(-weight * delta))

static func xor(a : bool, b : bool) -> bool:
	return int(b) ^ int(a)

static func xz(v: Vector3) -> Vector3: return Vector3(v.x, 0.0, v.z)
static func xy(v: Vector3) -> Vector3: return Vector3(v.x, v.y, 0.0)
static func yz(v: Vector3) -> Vector3: return Vector3(0.0, v.y, v.z)
static func x(v: Vector3) -> Vector3: return Vector3(v.x, 0.0, 0.0)
static func y(v: Vector3) -> Vector3: return Vector3(0.0, v.y, 0.0)
static func z(v: Vector3) -> Vector3: return Vector3(0.0, 0.0, v.z)
