extends Node

var allow_mosh := true
var datamosh_amount := 0.0
var force_datamosh:float = 0.0
var refresh_frame: bool
var tween: Tween
var v: Vector2 = Vector2.ZERO
var player: Player:
	set(value):
		player = value
		if value != null:
			print("PLYA")
			player_set.emit()
var window_size: Vector2i:
	get: return DisplayServer.window_get_size()
var window_pos: Vector2i:
	get: return DisplayServer.window_get_position()
	set(value):
		DisplayServer.window_set_position(value)
var center: Vector2i:
	get: return window_pos + window_size / 2
	set(value):
		DisplayServer.window_set_position(value + window_size / 2)
var os_size: Vector2i:
	get: return DisplayServer.screen_get_size()

var bounces := 0.0:
	set(value):
		bounces = maxf(value, 0.0)
var is_windowed: bool:
	get: return DisplayServer.window_get_mode() == 0
var former_window_pos = Vector2i.ZERO
var active_enemy_count := 0
signal window_bounced
signal player_set
func _ready() -> void:
	window_bounced.connect(func() -> void: bounces += 1)
func get_datamosh_amount() -> float:
	if not allow_mosh:
		return 0.0
	return minf(1.0, maxf(datamosh_amount, force_datamosh))

func add_mosh(amount: float) -> void:
	datamosh_amount = clampf(datamosh_amount + amount, 0.0, 1)
	print(datamosh_amount)
func _physics_process(delta: float) -> void:
	if not allow_mosh:
		return
	AudioServer.get_bus_effect(1, 0).drive = minf(1.0, bounces / 15.0)
	AudioServer.get_bus_effect(1, 1).mix = minf(1.0, bounces / 15.0)
	bounces -= delta
	bounces *= 0.995
	force_datamosh = minf(1.0, bounces / 3.0)
	handle_window(delta)
	former_window_pos = window_pos

func handle_window(delta: float) -> void:
	if not allow_mosh:
		return
	if not is_windowed or v.length() <= 1.0:
		v.x = M.smooth_nudgef(v.x, 0.0, 2.0, delta)
		v.y = M.smooth_nudgef(v.y, 0.0, 2.0, delta)
		return
	if center.x <= window_size.x / 2.0:
		#window_pos.x = 0
		v.x = abs(v.x)
		if not DisplayServer.mouse_get_button_state() & 1:
			window_bounced.emit()
	if window_pos.x + window_size.x >= os_size.x:
		v.x = abs(v.x) * -1
		if not DisplayServer.mouse_get_button_state() & 1:
			window_bounced.emit()
	if center.y <= window_size.y / 2.0 :
		#window_pos.x = 0
		v.y = abs(v.y)
		if not DisplayServer.mouse_get_button_state() & 1:
			window_bounced.emit()
	if  window_pos.y + window_size.y >= os_size.y:
		v.y = abs(v.y) * -1
		if not DisplayServer.mouse_get_button_state() & 1:
			window_bounced.emit()
	v.x = M.smooth_nudgef(v.x, 0.0, 2.0, delta)
	v.y = M.smooth_nudgef(v.y, 0.0, 2.0, delta)
	window_pos += Vector2i(v)
func boing() -> bool:
	if not allow_mosh:
		return false
	if not is_windowed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	var x = randf_range(-1.0, 1.0)
	var y = randf_range(-1.0, 1.0)

	v += Vector2(x, y).normalized() * randf_range(15, 50)
	return true

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_R:
		get_tree().reload_current_scene()
