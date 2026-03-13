extends CanvasLayer

var T := 2.0
var tick := true
var t := 0.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
@export var window_amt = 10
@export var min_time := 0.5
@onready var type: FmodEventEmitter3D = $Type
@onready var scene_loader: SceneLoader = $SceneLoader
@onready var transition: FmodEventEmitter3D = $Transition
@export var scene_if_not_finished: SimpleScene
@export var freq_curve: Curve
var w
var status: float:
	get:
		if scene_loader.next_scene:
			return 1.0
		var v = []
		ResourceLoader.load_threaded_get_status(scene_loader.scene, v)
		
		return v[0]
func _enter_tree() -> void:
	get_tree().root.transparent_bg = true
	get_tree().root.transparent = true
func _ready() -> void:
	if not Global.game_stats.read_start:
		scene_loader.scene_type = scene_if_not_finished
	if rng and "rng" in scene_loader:
		scene_loader.rng = rng
	scene_loader.request_load()
	get_viewport().always_on_top = true
	var time = Time.get_datetime_dict_from_system()
	rng.seed = time["hour"] + time["second"] + time["minute"] + time["day"]
	remove_child(transition)
func _process(delta: float) -> void:
	t += delta * float(tick)
	min_time -= delta
	if tick:
		T = freq_curve.sample(status)
	if Input.is_action_just_pressed("shoot") and tick:
		tick = false
		start()
	if tick and is_equal_approx(status, 1.0) and min_time < 0.0:
		start()
		tick = false
	if t > T:
		t = 0.0
		snap()

func snap() -> void:

	var size := Global.window_size / 2
	var pos := Vector2(rng.randf_range(-size.x, size.x), rng.randf_range(0.0, size.y * 2))
	
	var text := RicherTextLabel.new()
	text.position = pos
	text.fit_content = true
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.size_flags_vertical  = Control.SIZE_SHRINK_CENTER
	text.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(text)
	var n : String = M.pick_random(Global.name_choices).value
	text.set_bbcode("[shake rate=%.2f level=%s][wave]%s" %[rng.randf_range(4,11.0), 7 + rng.randi() % 10, n])
	type.play_one_shot()
	DisplayServer.window_move_to_foreground()
	DisplayServer.window_request_attention()
func start() -> void:
	transition.play()
	Transition.start_sub()
	get_tree().root.transparent = false
	get_tree().root.transparent_bg = false
	scene_loader.try_load()
