extends State
class_name PlayerAir

@export var ground_cast: ShapeCast3D
@export var scream: RaytracedAudioPlayer3D
var can_play := true
var player: Player:
	get:
		return target as Player

func on_enter() -> void:
	can_play = true
func on_exit() -> void:
	pass


func physics_tick(delta: float) -> void:
	if player.velocity.y < 0:
		var suv = suvat(-player.velocity.y, -player.stats.fall_gravity)
		if can_play  and suv > 1.15 and suv < 1.25:
			scream.play(0.57)
			can_play = false

	if player.do_ground_jump():
		player.jump_ground.emit()
		player.times.air = player.COYOTE_TIME + 0.0001
		player.times.jump = 0.0
	player.move_air(delta)
	#if player.do_air_jump():
		#player.jump_air.emit()
	if player.grounded:
		transitioned.emit("air", "grounded")
		return
	elif player.raycasts_colliding and player.velocity.dot(-player.camera.global_basis.z) > 0.0 and not (ground_cast.is_colliding() and ground_cast.get_collision_normal(0).angle_to(Vector3.UP) > PI/2):
		transitioned.emit("air", "wall")
		return
	
	player.apply_gravity(delta)


func suvat(u: float, a: float) -> float:
	var state := player.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(player.global_position, player.global_position + player.velocity.normalized() * 3000, 1, [player.get_rid()])
	var res := state.intersect_ray(query)
	if res.is_empty():
		return -1.0
	var s: float = sqrt((res["position"].y - player.global_position.y) ** 2)
	return (-u + sqrt(pow(u, 2) + 2 * a * s) )/ a
