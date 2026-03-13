extends Node3D

@export var player: Player
@export var land_sounds: RaytracedAudioPlayer3D
@export var hit_sound: RaytracedAudioPlayer3D
@export var teleport_sound: RaytracedAudioPlayer3D
@export var light_sound: RaytracedAudioPlayer3D
@export var foot_slide: Footsteps
@export var enabled := true
@export var slide_threshold := 0.0
@export var land_volume_curve: Curve
var t := 0.0
var former_dir := Vector3.ZERO
func _ready() -> void :
	if not enabled:
		return
	player.hurtbox.hit.connect(hit_sound.play.unbind(2))
	player.teleport.connect(teleport_sound.play)
	player.just_landed.connect(play_ground_sound)
func _physics_process(delta: float) -> void:
	if not enabled: return
	t += delta
	
	if player.grounded and not (player.auto_jump and Input.is_action_pressed("jump")):
		if M.xz(player.velocity).length() > 1.0 and player.direction and former_dir.length() > 1.0 and not player.is_on_wall():
			if M.xz(player.direction).dot(former_dir.normalized()) < slide_threshold and t > 0.3 :
				t = 0.0
				foot_slide.play_thing()
	former_dir = M.xz(player.velocity)
func play_ground_sound() -> void:
	land_sounds.volume_linear = land_volume_curve.sample(player.former_velocity.dot(Vector3.DOWN))
	land_sounds.play()
