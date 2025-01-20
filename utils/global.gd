extends Node
var enforce_cursor := false
var refresh_frame: bool
var tween: Tween
var state := 0
var player_basis: Basis
var pan_basis: Basis
var cam_basis: Basis
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
var center: Vector2i:
	get: return window_pos + window_size / 2
	set(value):
		DisplayServer.window_set_position(value + window_size / 2)
var os_size: Vector2i:
	get: return DisplayServer.screen_get_size()
var distort: float = 0.0;

var is_windowed: bool:
	get: return DisplayServer.window_get_mode() == 0

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
func _ready() -> void:
	if ResourceLoader.exists("user://data.tres"):
		game_stats = ResourceLoader.load("user://data.tres")
	else:
		game_stats = GameStats.new()
	if ResourceLoader.exists("user://settings.tres"):
		game_settings = ResourceLoader.load("user://settings.tres")
	else:
		game_settings = Settings.new()
	if game_stats.lucky_number == 0:
		game_stats.lucky_number = randi()
		save()
	seed(game_stats.lucky_number)

func _exit_tree() -> void:
	save()
func save() -> void:
	ResourceSaver.save(game_stats, "user://data.tres")
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
	get_tree().root.title = M.pick_random(name_choices).value
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_R and get_tree().current_scene:
		Transition.reload_scene()
