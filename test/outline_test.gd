extends CharacterBody3D
class_name OutlineTest

const HIT = preload("res://shakes/hit.tres")

@onready var initial_pos = global_position
var player: Player
var active := false
var t := 0.0
var interacted := false
var speed := 0.0
@export var health_c: HealthComponent
@export var healthbar: ProgressBar
@export var threshold := 5.0
@export var enemy_marker: EnemyMarker
signal hit
func _ready() -> void:
	if not Global.player:
		await Global.player_set
	player = Global.player
	active = true
	if not health_c: return
	health_c.died.connect(die)
	health_c.health_changed.connect(change_color)
	health_c.health_changed.connect(hit.emit.unbind(1))
	health_c.health_changed.connect(set_healthbar)
	health_c.health_changed.connect(shake)
	healthbar.max_value = health_c.max_health
	healthbar.value = health_c.current_health
	if not enemy_marker: return
	health_c.died.connect(enemy_marker.erase_enemy)
func _physics_process(delta: float) -> void:
	if not active:
		return
	if randi() % 500 == 0:
		velocity.x = -velocity.x
	elif randi() % 670 <= 5:
		velocity.z = -velocity.z
	var dir := Vector3.ZERO
	var player_pos = player.global_position
	player_pos.y = global_position.y
	$OmniLight3D.light_energy -= delta
	$OmniLight3D.light_energy *= 0.9
	$OmniLight3D.light_energy = maxf(0.0, $OmniLight3D.light_energy)
	dir = global_position.direction_to(player.global_position)
	if not velocity.length():
		velocity = dir
	var angle = velocity.signed_angle_to(dir, Vector3.UP)
	dir = velocity.rotated(Vector3.UP, angle * delta * 3).normalized()
	speed = M.smooth_nudgef(speed, 50.0, 1.0, delta)
	$InteractComponent/CollisionShape3D.set_deferred("disabled", interacted)
	dir *= speed
	if not interacted:
		velocity.x = dir.x
		velocity.z = dir.z
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	move_and_slide()

func _on_interact_component_interact() -> void:
	do_interact()
	interacted = true
	$ShakerEmitter3D.max_distance = 20
func do_interact():
	if interacted:
		return
	if $AudioStreamPlayer3D.stream.get_sync_stream(1):
		$AudioStreamPlayer3D.stream.set_sync_stream(1, null)
	health_c.uncapped_health -= 1
	$OmniLight3D.light_energy = 30
	$AudioStreamPlayer3D.play()
	await get_tree().create_timer(2.0).timeout
	interacted = false
	$ShakerEmitter3D.max_distance = 0

func change_color(new_health: int) -> void:
	var rel: float = new_health / float(health_c.max_health)
	var new_color = Color.WHITE.lerp(Color.RED, rel)
	$OmniLight3D.light_color = new_color
	var theme: StyleBoxFlat= $SubViewport/ProgressBar.get_theme_stylebox("fill").duplicate()
	theme.bg_color = new_color
	if $SubViewport/ProgressBar.has_theme_stylebox_override("fill"):
		$SubViewport/ProgressBar.remove_theme_stylebox_override("fill")
	$SubViewport/ProgressBar.add_theme_stylebox_override("fill", theme)

func die() -> void:
	$InteractComponent/CollisionShape3D.set_deferred("disabled", true)
	active = false
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property($ShakerEmitter3D/Area3D/AudioStreamPlayer3D, "pitch_scale", 0.2, 2.0)
	tween.tween_callback(deactivate)
func set_healthbar(value: int) -> void:
	healthbar.value = value

func deactivate() -> void:
	set_process(false)
	set_physics_process(false)
	global_position = Vector3(0, -123123123123123, 0)

func tween_force_mosh(_h) -> void:
	Global.tween_force_mosh(1.0, 2.0, 1.0)

func shake(h: int) -> void:
	Global.player.shaker.shake(HIT, ShakerComponent3D.ShakeAddMode.add, 3.0, 1.0, 2.0 + 1.0 - h / 5.0)
