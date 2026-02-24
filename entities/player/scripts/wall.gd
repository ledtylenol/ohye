extends State
class_name PlayerWall

@export var distance_comp: WallDistanceComp
var former_normal := Vector3.UP:
	set(value):

		former_normal = value
var player: Player:
	get: return target as Player
var last_wall: Node3D

func on_enter() -> void:
	player.jumps_left = 1
func on_exit() -> void:
	pass

func tick(_dt: float) -> void:
	pass

func physics_tick(delta: float) -> void:
	var left := Input.is_action_pressed("left")
	if player.grounded:
		transitioned.emit("wall", "grounded")
		return
	if not player.raycasts_colliding or player.velocity.dot(-player.camera.global_basis.z) < 0.0:
		transitioned.emit("wall", "air")
		return
	var wall = player.left_cast.get_collider() if left else player.right_cast.get_collider()
	if wall is SoundTile:
		player.last_ground_type = wall.sound
	var normal = player.left_cast.get_collision_normal() if left else player.right_cast.get_collision_normal()
	if wall != last_wall and Input.is_action_just_pressed("jump"):
		last_wall = wall
		var dir := Vector3.UP.slerp(normal, 0.3)
		player.velocity += dir * player.stats.jump_velocity
		transitioned.emit(name.to_lower(), "air")
		player.times.space = 0.1
		player.jump_ground.emit()
		player.jumps_left -= 1
		return
	player.apply_wall_gravity(delta, normal)
	distance_comp.physics_tick(delta, normal)
	move_wall(delta, normal)
	former_normal = normal
func move_wall(delta: float, normal: Vector3) -> void :
	if not normal: return
	var speed = player.stats.speed
	if player.direction:
		if player.current_speed < player.stats.speed:
			player.current_speed = move_toward(player.current_speed, speed, delta * maxf(1.0, player.stats.ground_acceleration) )

	else:
		player.current_speed = move_toward(player.current_speed, 0.0, delta * player.FRICTION)
	if player.current_speed :
		if player.current_speed < player.stats.speed:
			player.velocity = (player.direction.slide(normal) * player.current_speed) + player.velocity.project(Vector3.UP) - normal
		else:
			player.velocity = player.velocity.slide(normal)
