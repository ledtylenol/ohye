extends Node2D
@onready var target_rot: Marker2D = $TargetRot
@export var weapons: Array[Weapon]

@export var player: Player2D
var t := 0.0
var attack_speed: float:
	get:
		return Global2d.stats.attack_speed

func _physics_process(delta: float) -> void:
	t += delta
	target_rot.look_at(get_global_mouse_position())
	target_rot.rotation = fmod(target_rot.rotation, TAU)
	for i in weapons.size():
		var polar_i := i - weapons.size() / 4.0
		var rel_i := polar_i / (weapons.size())
		if player.state != player.DASHING:
			weapons[i].target_rot = target_rot.rotation
			weapons[i].offset =  player.inv_focus * polar_i * player.stats.spread
			var focus := player.focus ** 8
			weapons[i].position = Vector2(randf_range(-focus * 40.0, focus * 40.0),\
										 randf_range(-focus * 40.0, focus * 40.0))
		else:
			weapons[i].target_rot = player.velocity.normalized().angle()
			weapons[i].rotation = player.velocity.normalized().angle() + weapons[i].offset
			weapons[i].position = Vector2.ZERO
