extends Entity
class_name NoiseEntity


@export var update_frequency := 0.5
@export var pos_thres := 0.2
@export var mesh: MeshInstance3D
@export var sch: Schizophrenia
@export var agent: NavigationAgent3D
var time_scale := 1.0
var t := 0.0:
	set(v):
		t = v 
		if mesh:
			mesh.set_instance_shader_parameter("time", t)
var wrapt := 0.0
var realt := 0.0:
	set(v):
		realt = v
		if mesh:
			mesh.set_instance_shader_parameter("real_time", realt)
var fixed: int = 0
var player: Player
var tween: Tween
@export var timer: Timer
@export var hitbox: Hitbox
@export var collider: CollisionShape3D
@export var face_marker: Marker3D
@export var part: GPUParticles3D
@export var sprite_timer: Timer
@onready var raycast: RayCast3D = $RayCast3D
@onready var ground_cast: RayCast3D = $GroundCast
@export var state_machine: StateMachine
var target_pos: Vector3 = Vector3.ZERO
var follow_target_pos := false
const ENABLED_GROUP_NAME: StringName = &"enabled_raytraced_audio_player_3d"
const GROUP_NAME: StringName = &"raytraced_audio_player_3d"

signal activated
func _ready() -> void:
	sch.player_entered.connect(on_player_enter)
	sch.player_exited.connect(on_player_exit)
	hitbox.hit.connect(on_hit)
	part.top_level = true
	sprite_timer.timeout.connect(on_sprite_timer_timeout)
	agent.link_reached.connect(on_link)
	agent.waypoint_reached.connect(on_waypoint)
	
	GlobalObserver.sound_played.connect(sound_heard)
func _process(delta: float) -> void:
	wrapt += delta * time_scale
	realt += delta
	while wrapt > update_frequency / (time_scale + 0.1):
		t += update_frequency
		wrapt -= update_frequency
	if int(wrapt / pos_thres) != fixed:
		mesh.position = M.xz(M.rand_vec())
		fixed = int(wrapt / pos_thres)
	if player:
		collider.set_deferred("disabled", not (not sch.in_sight and timer.is_stopped()))
	part.position = face_marker.global_position + 1.5 * face_marker.global_position.direction_to(Global.player.global_position)
	part.rotation = rotation
	state_machine.current_state.tick(delta)

func move(delta: float, speed: float) -> void:
	if player:
		if not sch.in_sight:
			var xzpos := M.xz(mesh.global_position)
			var playerpos := Global.player.global_position
			var playerxz := M.xz(playerpos)
			if not xzpos.is_equal_approx(playerxz):
				var dir := xzpos.direction_to(playerxz)
				var q := Quaternion(-basis.z, dir)
				quaternion = q * quaternion
			agent.target_position = playerpos
			var pos := Vector3.ZERO
			if raycast.is_colliding():
				pos = raycast.get_collision_normal()
			if follow_target_pos:
				position = position.move_toward(target_pos, delta * speed)
				if is_zero_approx(position.distance_to(target_pos)):
					follow_target_pos = false
			else:
				position = position.move_toward(agent.get_next_path_position() + pos * 0.25, delta * speed)
func _physics_process(delta: float) -> void:
	if ground_cast.is_colliding():
		var col := ground_cast.get_collider() as SoundTile
		if not col: return
		last_ground_type = col.sound
	state_machine.current_state.physics_tick(delta)

func on_player_enter() -> void:
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "time_scale", 0.1, 1.75)
	
func on_player_exit() -> void:
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "time_scale", 1.0, 0.2)


func on_hit() -> void:
	Global.player.velocity += (position.direction_to(Global.player.position).slerp(Vector3.UP, 0.3)) * 50.0
	timer.start()

func on_sprite_timer_timeout() -> void:
	
	sprite_timer.start(randf_range(0.001, 0.7))

func on_link(details: Dictionary) -> void:
	print("LINK")
	follow_target_pos = true
	target_pos = details.link_exit_position

func on_waypoint(details: Dictionary) -> void:
	if follow_target_pos:
		follow_target_pos = false
		print("WAYPOINT REACHED")

func sound_heard(sound: RaytracedAudioPlayer3D) -> void:
	var vol := db_to_linear(sound.get_volume_db_from_pos(position))
	if vol > 0.8:
		print(sound.name)
	else:
		prints("not loud enough", vol)
