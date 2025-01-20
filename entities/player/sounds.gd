extends Node3D

@export var player: Player
@export var land_sounds: FmodEventEmitter3D
@export var hit_sound: FmodEventEmitter3D
@export var teleport_sound: FmodEventEmitter3D
@export var light_sound: FmodEventEmitter3D
func _ready() -> void :
	player.just_landed.connect(play_land_sound)
	player.hurtbox.hit.connect(hit_sound.play.unbind(2))
	player.teleport.connect(teleport_sound.play)
func play_land_sound() -> void :
	if player.active:
		var vel: = player.former_velocity.project(player.normal).length()
		land_sounds.set_parameter("ProjectedVelocity", vel)
		land_sounds.play()
