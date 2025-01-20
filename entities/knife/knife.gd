extends Projectile
class_name Knife
var time := randf_range(-50.0, 50.0):
	set = set_time
var tween: Tween
var scale_tween: Tween
var particles = load("res://entities/player/land_particles.tscn")
var recall_target: Node3D
@onready var plane: MeshInstance3D = $knife/Plane
@onready var cylinder: MeshInstance3D = $knife/Cylinder
@onready var bounce: FmodEventEmitter3D = $Bounce
@onready var impale: FmodEventEmitter3D = $Impale
@onready var hitbox: Hitbox = $Hitbox

@export var gravity_power := 9.8
@export var substeps := 5
@export var speed := 15.0
@export var lifetime := 5.0:
	set(value):
		if value < 0.0 and not tween:
			start_dissolve_tween()
		lifetime = value
var active := true:
	set(value):
		active = value
		$GPUParticles3D.emitting = value
@export_range(0.0, 1000.0) var quant_amount = 150.0:
	set(value):
		plane.set_instance_shader_parameter("quant", value)
		cylinder.set_instance_shader_parameter("quant2", value)
		quant_amount = value
@export_range(0.0, 1.0) var dissolve := 0.0:
	set(value):
		plane.set_instance_shader_parameter("dissolve", value)
		cylinder.set_instance_shader_parameter("dissolve", value)
		dissolve = value
@onready var detection_area: Area3D = $DetectionArea
var targets: Array[Node3D] = []
var bounce_count := 0
var expire_timer := 2.0
var target:
	get:
		return targets.back() if not targets.is_empty() else null
func _ready() -> void:
	velocity += -global_basis.z * speed
	dissolve = 0.0
	detection_area.area_entered.connect(push_target)
	detection_area.area_exited.connect(pop_target)

func push_target(n: Node3D) -> void:
	targets.push_back(n)
func pop_target(n: Node3D) -> void:
	targets.erase(n)
func _physics_process(dt: float) -> void:
	if not active: expire_timer -= dt
	if expire_timer < 0.0: queue_free()
	time += dt
	lifetime -= dt
	$knife.position.x = sin(time * 38.5) * 0.01 + cos(time * 70.0) * 0.005 + sin(-time * 90) * 0.001
	$knife.position.y = sin(time * 80.5) * 0.01 + cos(time * 70.3) * 0.005 + sin(-time * 90) * 0.001
	super(dt)
func start_dissolve_tween() -> void:
	active = false
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "dissolve", 1.0, 1.5)
	#tween.tween_callback(queue_free)

func move(dt: float) -> void:
	if not active: move_and_collide(dt * velocity); return
	if not is_zero_approx((global_position + velocity).angle_to(Vector3.UP)):
		look_at(global_position + velocity, up_dir)
	for _i in substeps:
		var subdelt := dt / substeps
		var hor_vel = velocity.slide(up_dir)
		var vert_vel = velocity.project(up_dir)

		velocity = vert_vel + hor_vel
		var col = move_and_collide(velocity * subdelt)
		if col:
			up_dir = col.get_normal()
			if col.get_collider() is not StaticBody3D:
				impale.play_one_shot()
				var parent = col.get_collider()
				reparent(parent)
				active = false
				hitbox.set_deferred("monitorable", false)
				queue_free()
				break;
			else:
				
				bounce_count += 1
				bounce.play_one_shot()
				tween_scale()
				var pos = col.get_position()
				var norm = col.get_normal()
				var part = particles.instantiate()
				part.up_dir = norm
				part.position = pos
				get_tree().current_scene.add_child(part)
				velocity = velocity.bounce(norm)
				if target:
					var coeff = 0.6 if bounce_count == 1 else 0.4
					@warning_ignore("shadowed_variable_base_class")
					var dir := global_position.direction_to(target.global_position)
					dir *= velocity.dot(up_dir)
					velocity = velocity.project(up_dir) + velocity.slide(up_dir).slerp(dir.slide(up_dir), coeff)
	velocity += -up_dir * dt * gravity_power / (velocity.length() / speed)
func tween_scale() -> void:
	if not active: return
	if scale_tween: scale_tween.kill()
	scale_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	scale_tween.tween_property($knife, "scale", Vector3.ONE, 0.5).from(Vector3(1.62, 1.0, 0.4))

func set_time(val: float) -> void:
	time = val
	plane.set_instance_shader_parameter("time", time)
