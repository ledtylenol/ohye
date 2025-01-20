extends ProjectileSpawnerProperty
class_name RandomSpawner

func generate(sc: Projectile, tf: Transform3D, _i: int) -> void:
	if not is_inside_tree():
		return
	var dir := M.random_sample_point_in_cone(spread, spawn_dir)
	sc.transform = tf
	sc.dir = dir
	sc.dir = sc.dir.normalized()
	get_tree().current_scene.add_child(sc)
