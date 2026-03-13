extends Control
class_name Menu
var tween: Tween
var timescale_tween: Tween
var active: = false:
	set(value):
		if Global.current_menu and Global.current_menu != self:
			return
		if value and not active:
			Global.current_menu = self
			Global.save()
			tween_visible()
		elif not value and active:
			Global.current_menu = null
			tween_hidden()
		active = value
@export  var sfx_slider: HSlider
@export var sfx_label: Label
@export var music_slider: HSlider
@export var music_label: Label
@export var return_button: Button
@export var resume: MagicButton
@export var sens_label: Label
@export var sens_slider: HSlider

@export var transtime_slider: HSlider
@export var transtime_label: Label

@export var slidersound: FmodEventEmitter3D
@export var paused_song: FmodEventEmitter3D
@export var player: Player
@export var color_rect: ColorRect
var magnitude := 0.0:
	set(value):
		magnitude = value
		color_rect.material.set_shader_parameter("magnitude", value)
var time := 0.0:
	set(value):
		time = value
		color_rect.material.set_shader_parameter("time", value)
var quantize_mix := 0.0:
	set(value):
		quantize_mix = value
		color_rect.material.set_shader_parameter("quantize_mix", value)
var spread := 0.235:
	set(value):
		spread = value
		color_rect.material.set_shader_parameter("spread", value)
var time_scale := 1.0
@onready var sfx_bus := AudioServer.get_bus_index("Sfx")
@export var slider_achievement: Achievement
var times_changed := 0:
	set(v):
		if v >= 1000 and not Global.game_stats.has_achievement(slider_achievement.name):
			AchievementManager.push_achievement(slider_achievement)
		times_changed = v
func _ready() -> void :
	magnitude = 0.0
	quantize_mix = 0.0 
	return_button.button_up.connect(func() -> void :
		get_tree().paused = false
		FmodServer.get_bus("bus:/Music/Pausable").paused = false
		FmodServer.get_bus("bus:/Sfx/Sfx3D/SfxPausable").paused = false
		Transition.return_to_sub())

	sfx_slider.value_changed.connect(change_sfx)
	music_slider.value_changed.connect(change_music)
	music_slider.drag_ended.connect(Global.save_settings.unbind(1))
	sfx_slider.drag_ended.connect(Global.save_settings.unbind(1))
	sens_slider.drag_ended.connect(Global.save_settings.unbind(1))
	sens_slider.value_changed.connect(change_sensitivity)
	transtime_slider.drag_ended.connect(Global.save_settings.unbind(1))
	transtime_slider.value_changed.connect(change_transtime)
	paused_song.play()
	resume.button_up.connect(set.bind("active", false))
	change_music(Global.game_settings.music_volume)
	change_sfx(Global.game_settings.sfx_volume)
	change_transtime(Global.game_settings.transition_secs)
	change_sensitivity(Global.game_settings.sensitivity)
	update_sliders()
	if not visible:
		resume.disabled = true
		return_button.disabled = true
		print("A")
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("menu") and event.is_pressed():
		active = not active

func update_sliders() -> void:
	sfx_slider.value = Global.game_settings.sfx_volume
	music_slider.value = Global.game_settings.music_volume
	sens_slider.value = Global.game_settings.sensitivity
	transtime_slider.value = Global.game_settings.transition_secs
func tween_visible() -> void :
	visible = true
	resume.disabled = false
	return_button.disabled = false
	get_tree().paused = true
	Transition.request_load()
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(paused_song, "volume", 0.5, 0.5)
	tween.parallel().tween_property(self, "magnitude", 0.005, 0.5)
	tween.parallel().tween_property(self, "quantize_mix", 1.0, 2.5)
	tween.parallel().tween_property(self, "spread", 0.0, 5.5)
	if timescale_tween: timescale_tween.kill()
	timescale_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	timescale_tween.tween_property(self, "time_scale", 1.0, 6.0)
	FmodServer.get_bus("bus:/Sfx/Sfx3D/SfxPausable").paused = true
	FmodServer.get_bus("bus:/Music/Pausable").paused = true
func tween_hidden() -> void :
	resume.disabled = true
	return_button.disabled = true
	get_tree().paused = false
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(paused_song, "volume", 0.0, 0.5)
	tween.parallel().tween_property(self, "magnitude", 0.0, 0.5)
	tween.parallel().tween_property(self, "quantize_mix", 0.0, 1.5)
	tween.parallel().tween_property(self, "spread", 0.235, 1.5)
	tween.tween_callback(func(): visible = false)
	if timescale_tween: timescale_tween.kill()
	timescale_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	timescale_tween.tween_property(self, "time_scale", 0.0, 0.5)
	FmodServer.get_bus("bus:/Music/Pausable").paused = false
	FmodServer.get_bus("bus:/Sfx/Sfx3D/SfxPausable").paused = false
func change_sfx(v: float) -> void :
	FmodServer.get_bus("bus:/Sfx").volume = v
	AudioServer.set_bus_volume_linear(sfx_bus, v)
	Global.game_settings.sfx_volume = v
	sfx_label.text = "Sfx: %-2.2f" % sfx_slider.ratio
	times_changed += 1
func change_music(v: float) -> void :
	FmodServer.get_bus("bus:/Music").volume = v
	Global.game_settings.music_volume = v
	music_label.text = "Music: %2.2f" % music_slider.ratio
	times_changed += 1
func change_transtime(v: float) -> void:
	Global.game_settings.transition_secs = v
	transtime_label.text = "Transition Time: %-2.2f" % v
	times_changed += 1
func change_sensitivity(v: float) -> void:
	Global.game_settings.sensitivity = v
	sens_label.text = "Sensitivity: %05.2f" % (sens_slider.value)
	times_changed += 1
func _process(delta: float) -> void:
	if visible:
		time += delta * time_scale
		sens_slider.custom_minimum_size = music_slider.size
