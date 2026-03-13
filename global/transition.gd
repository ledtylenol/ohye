extends CanvasLayer

var thres_noise: NoiseTexture2D = load("uid://ida4pqrk63kv")
@onready var timer: Timer = $Timer

var tween: Tween
@onready var f: FmodEventEmitter3D = $FmodEventEmitter3D
var cooldown := 0.05
var current_cooldown := 0.0
@onready var scene_loader: SceneLoader = $SceneLoader
var can_change_noise := true
var thres := 0.0:
	set(v):
		thres = v
		$ColorRect.set_instance_shader_parameter("threshold", v)

func _ready() -> void:
	timer.timeout.connect(update_seed)
	thres = 1.0
func _process(delta: float) -> void:
	current_cooldown -= delta
	current_cooldown = maxf(0.0, current_cooldown)
func reset() -> void:
	can_change_noise = false
	var image = ImageTexture.create_from_image(get_viewport().get_texture().get_image())
	$ColorRect.material.set_shader_parameter("screen", image)
	$ColorRect.material.set_shader_parameter("thres_noise", thres_noise)
	$ColorRect.color.a = 1.0
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "thres", 1.1, Global.game_settings.transition_secs).from(0.0)
	f.play()
	tween.tween_callback(func(): can_change_noise = true)

func reload_scene() -> void:
	if current_cooldown > 0.0:
		return
	if not get_tree() or not get_tree().current_scene: return
	reset()
	var scene = ResourceLoader.load(get_tree().current_scene.scene_file_path, "", ResourceLoader.CACHE_MODE_IGNORE)

	change_scene(scene)
	current_cooldown = cooldown

func request_load() -> void:
	scene_loader.request_load()

func change_scene(new_scene: PackedScene, do_reset := true) -> void:
	if current_cooldown > 0.0:
		return
	if do_reset: reset()
	get_tree().call_deferred("change_scene_to_packed", new_scene)
	current_cooldown = cooldown
	Global.randomize_name()
func return_to_sub() -> void:
	if not Global.game_stats.completed_subway:
		print("subway has not been completed yet! proceeding to guaranteed path")
		change_scene(load("res://world/subway/subwayoff.tscn"))
	else:
		reset()
		scene_loader.try_load()
func start_sub() -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, false)
	get_viewport().always_on_top = false
	get_window().grab_focus()

func update_seed() -> void:
	if can_change_noise:
		thres_noise.noise.seed = (thres_noise.noise.seed + 3) % 1232 
		print("NOISE CHANGED")
