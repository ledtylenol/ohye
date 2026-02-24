extends Node3D
@onready var h_jerm: FmodEventEmitter3D = $HJerm
@onready var area_3d: Area3D = $Area3D

@onready var light: SpotLight3D = $OmniLight3D
var dist = load("res://compositor_effects/distort/distort.tres")
@onready var spot: FmodEventEmitter3D = $OmniLight3D/Light
var tween: Tween
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D

var completion_amount := 10
var total_completions := 60
var timer := 0.0
func _ready() -> void:
	area_3d.body_entered.connect(on_body)
	area_3d.body_exited.connect(on_body_exit)
	if Global.game_stats.achievements.is_empty():
		gpu_particles_3d.emitting = false
	else:
		gpu_particles_3d.amount = Global.game_stats.achievements.size()

func on_body(b: Node3D) -> void:
	if not b is Player:
		return
	spot.play()
	light.visible = true

func on_body_exit(b: Node3D) -> void:
	if b is not Player:
		return
	light.visible = false
