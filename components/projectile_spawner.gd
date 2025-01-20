extends Node3D
class_name ProjectileSpawner

var properties: Array[ProjectileSpawnerProperty]:
	get:
		return M.nightmare_getter(self, ProjectileSpawnerProperty)
@export var pos_target: Node3D
@export var cooldown := 1.0
var running := false
var active := false

func spawn_one_off(tf_owner: Node3D) -> void:

	for sp_prop in properties:
		sp_prop.spawn(tf_owner)
		if sp_prop.outer_delay:
			await get_tree().create_timer(sp_prop.outer_delay).timeout

func _physics_process(_delta: float) -> void:
	if active and not running:
		spawn(pos_target)

func spawn(tf_owner: Node3D) -> void:
	if running:
		return
	running = true
	for sp_prop in properties:
		sp_prop.spawn(tf_owner)
		if sp_prop.outer_delay:
			await get_tree().create_timer(sp_prop.outer_delay).timeout
	if cooldown:
		await get_tree().create_timer(cooldown).timeout
	running = false
