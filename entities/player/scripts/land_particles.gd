extends GPUParticles3D
class_name FunkyParticle

var up_dir: = Vector3.UP
func _ready() -> void :
	var mat: ParticleProcessMaterial = process_material as ParticleProcessMaterial
	mat.gravity = mat.gravity.length() * ( - up_dir)
	mat.direction = up_dir
	get_tree().create_timer(lifetime).timeout.connect(queue_free)
	amount_ratio = randf_range(0.1, 0.3)
	emitting = true
