@tool
extends Node3D
@export var generatse: bool:
	set(value):
		generate()
@export var amount := 10
@export var th := PI/6:
	set(value):
		th = value
		generate()
@export var north: Vector3:
	set(v):
		north = v
		generate()
@export var spread := TAU:
	set(value):
		spread = value
		generate()
@export var ring_total := 10
func random_sample_point_in_cone(theta: float, north_pole: Vector3) -> Vector3:
	#thank you my beloved stackoverflow for this answer it took me SO long
	var z = randf_range(cos(theta), 1.0)
	var phi = randf_range(0, TAU)
	var r = sqrt(1.0 - z * z)
	var local_sample = Vector3(r * cos(phi), r * sin(phi), z)

	north_pole = north_pole.normalized()
	north_pole.y *= -1

	# Compute rotation axis
	var axis = Vector3(0, 0, 1).cross(north_pole)
	var axis_norm = axis.length()

	if axis_norm < 1e-6:  # Already aligned with (0,0,1)
		return local_sample

	axis = axis.normalized()  # Normalize axis
	var angle = acos(Vector3(0, 0, 1).dot(north_pole))  # Compute angle

	# Rodrigues' rotation formula
	var cos_a = cos(angle)
	var sin_a = sin(angle)
	var K := Basis(
		Vector3(cos_a + (1 - cos_a) * axis.x * axis.x, (1 - cos_a) * axis.x * axis.y - sin_a * axis.z, (1 - cos_a) * axis.x * axis.z + sin_a * axis.y),
		Vector3((1 - cos_a) * axis.y * axis.x + sin_a * axis.z, cos_a + (1 - cos_a) * axis.y * axis.y, (1 - cos_a) * axis.y * axis.z - sin_a * axis.x),
		Vector3((1 - cos_a) * axis.z * axis.x - sin_a * axis.y, (1 - cos_a) * axis.z * axis.y + sin_a * axis.x, cos_a + (1 - cos_a) * axis.z * axis.z)
	)

	return K * local_sample
func spiral_sample_point_in_cone(index: int, total: int, theta: float, north_pole: Vector3) -> Vector3:
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

func sample_ring_in_cone(index: int, total: int, theta: float, north_pole: Vector3) -> Vector3:
	"""Generate `total` points evenly spaced in a single ring at the edge of a cone with half-angle `theta`."""
	
	var z = cos(theta)  # Fixed height at the cone edge
	var r = sin(theta)  # Corresponding radius

	var phi = (index / float(total * spread)) * TAU  # Evenly distribute angles

	var local_sample = Vector3(r * cos(phi), r * sin(phi), z)  # Point on the ring

	# Rotate to align with `north_pole`
	north_pole = north_pole.normalized()

	var axis = Vector3(0, 0, 1).cross(north_pole)
	var axis_norm = axis.length()

	if axis_norm < 1e-6:
		return local_sample  # Already aligned

	axis = axis.normalized()
	var angle = acos(Vector3(0, 0, 1).dot(north_pole))
	var cos_a = cos(angle)
	var sin_a = sin(angle)
	var K = Quaternion(north_pole, Vector3.FORWARD)
	local_sample = K * local_sample
	local_sample.z *= -1
	return local_sample
func _ready():
	var theta = deg_to_rad(30)
	var north_pole = Vector3(0.2, 0.5, 0.84)

func generate() -> void:
	for child in get_children():
		child.queue_free()
	var mb := MeshInstance3D.new()
	var shapeb := SphereMesh.new()
	mb.mesh = shapeb
	add_child(mb)
	mb.global_position = north.normalized() * 10

	for i in amount:
		var m := MeshInstance3D.new()
		var shape := SphereMesh.new()
		m.mesh = shape
		add_child(m)
		m.global_position += M.random_sample_point_in_cone(th, north) * 10
