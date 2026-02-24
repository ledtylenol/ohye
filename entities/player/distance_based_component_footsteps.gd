extends DistanceBasedComponent
var gp_p: Vector3
func _ready() -> void :
	if not target:
		queue_free()
		return
	gp_p = target.global_position
	if callee and what_to_call:
		distance_reached.connect(callee.call.bind(what_to_call))
	if not "is_on_floor" in target and grounded_only:
		queue_free()
	target.just_landed.connect(reset)
func _physics_process(_delta: float) -> void :
	if not target: return
	if target.grounded:
		var scale_avg: = target.scale.x + target.scale.y
		scale_avg *= 0.5
		distance += target.velocity.slide(target.normal).length() / scale_avg * _delta

	former_gp = gp
	var desired_distance := distance_over_velocity.sample(target.velocity.length())
	if distance >= desired_distance:
		distance_reached.emit()
		distance -= desired_distance
		if distance > desired_distance:
			distance = 0
func reset() -> void :
	distance = 0
