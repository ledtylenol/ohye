extends Node
var enforce_cursor := false
var refresh_frame: bool
var tween: Tween
var state := 0
var player_basis: Basis
var pan_basis: Basis
var cam_basis: Basis
var last_sound: String
enum Event {
	NIGHT = 1 << 0,
	CHRISTMAS = 1 << 1,
	HALLOWEEN = 1 << 2,
	WINTER = 1 << 3,
}
var forced_events := 0
var current_menu: Control:
	set(value):
		if value:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		current_menu = value
var player: Player:
	set(value):
		player = value
		if value != null:
			player_set.emit()


var window_size: Vector2i:
	get: return DisplayServer.window_get_size()
var window_pos: Vector2i:
	get: return DisplayServer.window_get_position()
	set(value):
		DisplayServer.window_set_position(value)
var window_size_decors:
	get: return DisplayServer.window_get_size_with_decorations()
@warning_ignore_start("integer_division")
var center: Vector2i:
	get: return window_pos + window_size / 2
	set(value):
		DisplayServer.window_set_position(value + window_size / 2)
var os_size: Vector2i:
	get: return DisplayServer.screen_get_size()
var distort: float = 0.0;

var is_windowed: bool:
	get: return DisplayServer.window_get_mode() == 0

var teleporters: Array[Teleporter] = []
var game_stats: GameStats
var game_settings: Settings
var time_since_saved := 0.0
var closed_menu := false
@export var name_choices: Array[RandomString]
signal player_set
@warning_ignore("unused_signal")
signal enforce_crosshair(mode: int)
@warning_ignore("unused_signal")
signal enforce_disabled()
@warning_ignore("unused_signal")
signal boss_started(health: HealthComponent)
@warning_ignore("unused_signal")
signal teleport_to_id(id: int)
var center_shader := Vector2(0.5, 0.5)
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func randi() -> int:
	print("updated state thru randi")
	var i = rng.randi()
	game_stats.rng_state = rng.state
	return i

func randf_range(minm: float, maxm: float) -> float:
	print("updated state thru randf_range")
	var f = rng.randf_range(minm, maxm)
	if game_stats:
		game_stats.rng_state = rng.state
	return f

func randf() -> float:
	print("updated state thru randf")
	var f = rng.randf()
	game_stats.rng_state = rng.state
	return f
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("no")
		if player and not current_menu and not get_tree().paused:
			player.hurtbox.hit.emit(null, 1)
	if what == NOTIFICATION_WM_POSITION_CHANGED:
		game_settings.screen_pos = get_window().get_position_with_decorations()
		print("new position: %s" % game_settings.screen_pos)
func _ready() -> void:
	print(M.check_app("obs64"))
	get_viewport().size_changed.connect(on_size_change)
	get_tree().auto_accept_quit = false
	var file := FileAccess.get_file_as_string("user://save.goober")
	if not file.is_empty():
		game_stats = GameStats.from_json(JSON.parse_string(file))
	else:
		game_stats = GameStats.new()
	if ResourceLoader.exists("user://settings.tres"):
		game_settings = ResourceLoader.load("user://settings.tres")
	else:
		game_settings = Settings.new()
		game_settings.screen_pos = get_viewport().position
	if game_stats.lucky_number == 0:
		game_stats.lucky_number = randi()
		save()
	rng.seed = game_stats.lucky_number
	rng.state = game_stats.rng_state
	if game_settings.screen_size:
		print(get_viewport().position)
		get_viewport().size = game_settings.screen_size
		get_viewport().position = game_settings.screen_pos
func on_size_change() -> void:
	game_settings.screen_size = get_window().get_size_with_decorations()
	print("new size: %s" % game_settings.screen_size)
	save_settings()
func _exit_tree() -> void:
	save()
	save_settings()
func save() -> void:
	var f := FileAccess.open("user://save.goober", FileAccess.WRITE)
	game_stats.last_played = Time.get_datetime_string_from_system()
	var save_json = game_stats.to_json()
	f.store_string(save_json)
func save_settings() -> void:
	ResourceSaver.save(game_settings, "user://settings.tres")
func _physics_process(delta: float) -> void:
	time_since_saved -= delta
	if time_since_saved <= 0.0:
		time_since_saved = game_stats.autosave_time
		save()
	if player:
		var h_l := (player.velocity\
					.slide(player.normal) * delta).length()
		var v_l := (player.velocity\
					.project(player.normal) * delta).length()
		game_stats.hor_travelled += h_l if not is_nan(h_l) and is_finite(h_l)else 0.0
		game_stats.vert_travelled += v_l if not is_nan(v_l) and is_finite(v_l) else 0.0
	if not get_tree().paused:
		game_stats.playtime += delta
@warning_ignore("shadowed_variable")
func get_label(state: int) -> String:
	var out: String
	match state:
		0: out = "Outdoors"
		1: out =  "SmallInside"
		2: out =  "BigInside"
		3: out =  "Crowded"
		_: out =  "Void"
	print(out)
	return out

func randomize_name() -> void:
	DisplayServer.window_set_title(M.pick_random(name_choices).value)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_R and get_tree().current_scene \
			and (player and player.active or event.ctrl_pressed):
			Transition.reload_scene()
		if event.keycode == KEY_L:
			game_stats.achievements.clear()
			game_stats.strawberries.clear()
			save()
		if event.keycode == KEY_Z:
			print(get_tree().root.title)

func force_event(e: Event):
	forced_events |= e

func is_event_active(e: Event) -> bool:
	return bool(e & forced_events)
