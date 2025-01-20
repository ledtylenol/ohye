extends Node3D
class_name ProjectileSpawnerProperty

@export var properties: Array[ProjectileProperty]
@export var amount := 5
@export var scene: PackedScene
@export var spawn_dir := Vector3.UP:
	get = get_dir
@export var percent := 1.0
@export var spread := PI/6
@export var delay := 0.05
@export var outer_delay := 0.0
@export var play_sound: FmodEventEmitter3D
@export var per_bullet := false
func spawn(tf_owner: Node3D) -> void:
	if play_sound and not per_bullet:  play_sound.play_one_shot()
	for i in amount:
		var tf := tf_owner.global_transform
		var sc: Projectile = scene.instantiate()
		for prop in properties:
			var n := prop.generate(sc)
			sc.add_child(n)
		generate(sc, tf, i)
		if play_sound and per_bullet: play_sound.play()

		if delay: await get_tree().create_timer(delay).timeout
func get_dir() -> Vector3:
	return spawn_dir

func generate(sc: Projectile, tf: Transform3D, i: int) -> void:
	var dir := M.sample_ring_in_cone(i, amount, spread, spawn_dir)
	sc.transform = tf
	sc.dir = dir
	sc.dir = sc.dir.normalized()
	get_tree().current_scene.add_child(sc)
