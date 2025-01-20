extends CanvasLayer

var tween: Tween
@onready var f: FmodEventEmitter3D = $FmodEventEmitter3D
var cooldown := 0.5
var current_cooldown := 0.0
@export var alternatives: Array[RandomScene]
@onready var scene_loader: SceneLoader = $SceneLoader

func _ready() -> void:
	reset()
func _process(delta: float) -> void:
	current_cooldown -= delta
	current_cooldown = maxf(0.0, current_cooldown)
func reset() -> void:

	$ColorRect.color.a = 1.0
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property($ColorRect, "color:a", 0.0, 5.0)
	f.play_one_shot()

func reload_scene() -> void:
	if current_cooldown > 0.0:
		return
	if not get_tree() or not get_tree().current_scene: return
	reset()
	var scene = ResourceLoader.load(get_tree().current_scene.scene_file_path, "", ResourceLoader.CACHE_MODE_REPLACE)
	var pp := Global.player.global_position
	change_scene(scene)
	current_cooldown = cooldown
	await Global.player_set
	Global.player.global_position = pp
func request_load() -> void:
	scene_loader.request_load()

func change_scene(new_scene: PackedScene) -> void:
	if current_cooldown > 0.0:
		return
	reset()
	get_tree().call_deferred("change_scene_to_packed", new_scene)
	current_cooldown = cooldown
	Global.randomize_name()
func return_to_sub() -> void:
	if not Global.game_stats.completed_subway:
		change_scene(load("res://world/subway/subwayoff.tscn"))
	else:
		scene_loader.try_load()
