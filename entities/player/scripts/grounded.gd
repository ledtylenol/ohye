extends State
class_name Grounded

@export var ground_sound: RaytracedAudioPlayer3D
@export var ground_cast: ShapeCast3D
@export var wall_state: State
var jumped_last_frame := false
var player: Player:
	get: return target as Player
func on_enter() -> void:
	ground_sound.play()
	player.times.grounded = 0.0
	player.just_landed.emit()
	player.jumps_left = player.stats.jump_count
	jumped_last_frame = false
	wall_state.last_wall = null
func tick(delta: float) -> void:
	player.times.grounded += delta
func physics_tick(delta: float) -> void:
	if not player.grounded:
		if player.raycasts_colliding and not (ground_cast.is_colliding() and ground_cast.get_collision_normal(0).angle_to(Vector3.UP) > PI/4):
			transitioned.emit("grounded", "wall")
		else:
			transitioned.emit("grounded", "air")
		return
	var sound = player.shape_cast.get_collider(0) as SoundTile
	if sound:
		player.last_ground_type = sound.sound
	player.move_ground(delta)
	if player.do_ground_jump():
		player.jump_ground.emit()
		player.times.air = player.COYOTE_TIME + 0.0001
		player.times.jump = 0.0
		transitioned.emit("grounded", "air")
func on_exit() -> void:
	player.times.grounded = 0.0
