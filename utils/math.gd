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
static func rand_vec() -> Vector3:
	return Vector3(randf_range(-1, 1), randf_range(-1,1), randf_range(-1,1)).normalized()

static func format_time(t: float) -> String:
	var milis = minf(fmod(t, 1) * 100, 99)
	var seconds = int(fmod(t, 60))
	var minutes = int(t / 60)
	return "%s:%02d.%02.0f" % [minutes, seconds, milis]

static func nightmare_getter(parent: Node, type: Variant, base: StringName = &"") -> Array:
	var sc := type as Script
	if base != &"":
		return Array(parent.get_children()\
			.filter(is_instance_of.bind(type)),\
			TYPE_OBJECT,\
			base,\
			type)
	return Array(parent.get_children()\
		.filter(is_instance_of.bind(type)),\
		TYPE_OBJECT,\
		sc\
		.get_instance_base_type(),\
		type)


static func random_sample_point_in_cone(theta: float, north_pole: Vector3) -> Vector3:
	#thank you my beloved stackoverflow for this answer it took me SO long
	var z = randf_range(cos(theta), 1.0)
	var phi = randf_range(0, TAU)
	var r = sqrt(1.0 - z * z)
	var local_sample = Vector3(r * cos(phi), r * sin(phi), z)

	north_pole = north_pole.normalized()

	# Compute rotation axis
	var axis = Vector3(0, 0, 1).cross(north_pole)
	var axis_norm = axis.length()

	if axis_norm < 1e-6:  # Already aligned with (0,0,1)
		return local_sample

	axis = axis.normalized()  # Normalize axis
	var angle = acos(Vector3(0, 0, 1).dot(north_pole))  # Compute angle

	# Rodrigues' rotation formula

	var K = Quaternion(north_pole, Vector3.FORWARD)
	local_sample = K * local_sample
	local_sample.z *= -1
	return local_sample
static func spiral_sample_point_in_cone(index: int, total: int, theta: float, north_pole: Vector3) -> Vector3:
	"""Generate the `index`-th point out of `total` evenly distributed within a cone of half-angle `theta`."""
	
	var z = lerp(cos(theta), 1.0, float(index) / float(total - 1))  # Evenly spaced in [cos(theta), 1]
	var phi = TAU * (index / float(total))  # Evenly distributed angle

	var r = sqrt(1.0 - z * z)
	var local_sample = Vector3(r * cos(phi), r * sin(phi), z)

	# Normalize the north pole vector
	north_pole = north_pole.normalized()

	# Compute rotation axis
	var n := Vector3(0, 0, 1)
	var axis = n.cross(north_pole)
	var axis_norm = axis.length()

	if axis_norm < 1e-6:  # Already aligned with (0,0,1)
		return local_sample

	axis = axis.normalized()  # Normalize axis
	var angle = acos(n.dot(north_pole))  # Compute angle

	# Rodrigues' rotation formula
	var cos_a = cos(angle)
	var sin_a = sin(angle)
	var K = Basis(
		Vector3(cos_a + (1 - cos_a) * axis.x * axis.x, (1 - cos_a) * axis.x * axis.y - sin_a * axis.z, (1 - cos_a) * axis.x * axis.z + sin_a * axis.y),
		Vector3((1 - cos_a) * axis.y * axis.x + sin_a * axis.z, cos_a + (1 - cos_a) * axis.y * axis.y, (1 - cos_a) * axis.y * axis.z - sin_a * axis.x),
		Vector3((1 - cos_a) * axis.z * axis.x - sin_a * axis.y, (1 - cos_a) * axis.z * axis.y + sin_a * axis.x, cos_a + (1 - cos_a) * axis.z * axis.z)
	)
	return K * local_sample  # Rotate the sampled point

static func sample_ring_in_cone(index: int, total: int, theta: float, north_pole: Vector3) -> Vector3:
	"""Generate `total` points evenly spaced in a single ring at the edge of a cone with half-angle `theta`."""
	if total == 1:
		return north_pole.normalized()
	var z = cos(theta)  # Fixed height at the cone edge
	var r = sin(theta)  # Corresponding radius

	var phi = (index / float(total - 1))  * TAU # Evenly distribute angles

	var local_sample = Vector3(r * cos(phi), r * sin(phi), z)  # Point on the ring

	# Rotate to align with `north_pole`
	north_pole = north_pole.normalized()

	var axis = Vector3(0, 0, 1).cross(north_pole)
	var axis_norm = axis.length()

	if axis_norm < 1e-6:
		return local_sample  # Already aligned

	axis = axis.normalized()
	var angle = acos(Vector3(0, 0, 1).dot(north_pole))

	var K = Quaternion(north_pole, Vector3.FORWARD)
	local_sample = K * local_sample
	local_sample.z *= -1
	return local_sample

static func pick_random(scenes: Array) -> Random:
	var acc_weights := 0
	for r in scenes:
		acc_weights += r.weight
	var rng := randi() % acc_weights
	var weight := 0
	for r in scenes:
		weight += r.weight
		if rng < weight:
			return r
	return null

enum Period {
	MORNING, NOON, AFTERNOON, EVENING, NIGHT, WITCHING_HOUR
}
static func get_time() -> Period:
	var t := Time.get_datetime_dict_from_system()
	match t["hour"]:
		var x when x == 3: return Period.WITCHING_HOUR
		var x when x >= 21 or x <= 6: return Period.NIGHT
		var x when x <= 11: return Period.MORNING
		var x when x <= 13: return Period.NOON 
		var x when x <= 16: return Period.AFTERNOON
		_: return Period.EVENING
