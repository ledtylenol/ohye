extends Sprite3D
@onready var teto_blast: Label3D = $"TETO BLAST"
@export var thres := 0.5
var t := 0.0
var old_t := 0.0
@onready var collision_shape_3d: CollisionShape3D = $Hitbox/CollisionShape3D

func _process(delta: float) -> void:
	t += delta
	if t - old_t > thres:
		old_t += thres
		randomize_power()


func randomize_power() -> void:
	if teto_blast.transparency < 0.5:
		teto_blast.transparency = 1.0
		return
	teto_blast.transparency = 0.0
	if Global.player and -Global.player.camera.global_basis.z.dot(Global.player.camera\
			.global_position.direction_to(global_position)) > 0:
		collision_shape_3d.set_deferred("disabled", false)
		await get_tree().create_timer(0.1).timeout
		collision_shape_3d.set_deferred("disabled", true)
		
