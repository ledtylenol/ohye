extends PanelContainer
class_name Menu
var tween: Tween
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
@onready var sfx_slider: HSlider = $"VBoxContainer/SFX Container/SFX Slider"
@onready var music_slider: HSlider = $"VBoxContainer/Music Container/Music Slider"
@export var return_button: Button
@export var resume: MagicButton
@onready var sens_label: Label = $"VBoxContainer/Sens Container/Sens Label"
@onready var sens_slider: HSlider = $"VBoxContainer/Sens Container/Sens Slider"

@onready var paused_song: FmodEventEmitter3D = $PausedSong
@export var player: Player
@onready var color_rect: ColorRect = $"../ColorRect"
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

@onready var sfx_bus := AudioServer.get_bus_index("RaytracedReverb")
@onready var ambiance_bus := AudioServer.get_bus_index("RaytracedAmbient")
func _ready() -> void :
	magnitude = 0.0
	quantize_mix = 0.0 
	change_sensitivity(Global.game_settings.sensitivity)
	return_button.button_up.connect(func() -> void :
		get_tree().paused = false
		FmodServer.get_bus("bus:/Music/Pausable").paused = false
		FmodServer.get_bus("bus:/Sfx/Sfx3D/SfxPausable").paused = false
		Transition.return_to_sub())
	sfx_slider.value = Global.game_settings.sfx_volume
	music_slider.value = Global.game_settings.music_volume
	sfx_slider.value_changed.connect(change_sfx)
	music_slider.value_changed.connect(change_music)
	music_slider.drag_ended.connect(Global.save_settings.unbind(1))
	sfx_slider.drag_ended.connect(Global.save_settings.unbind(1))
	sens_slider.drag_ended.connect(Global.save_settings.unbind(1))
	sens_slider.value_changed.connect(change_sensitivity)
	paused_song.play()
	resume.button_up.connect(set.bind("active", false))
	FmodServer.get_bus("bus:/Music").volume = Global.game_settings.music_volume
	FmodServer.get_bus("bus:/Sfx").volume = Global.game_settings.sfx_volume
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("menu") and event.is_pressed():
		active = not active

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
	FmodServer.get_bus("bus:/Music/Pausable").paused = false
	FmodServer.get_bus("bus:/Sfx/Sfx3D/SfxPausable").paused = false
func change_sfx(v: float) -> void :
	FmodServer.get_bus("bus:/Sfx").volume = v
	AudioServer.set_bus_volume_linear(sfx_bus, v)
	AudioServer.set_bus_volume_linear(ambiance_bus, v)
	Global.game_settings.sfx_volume = v

func change_music(v: float) -> void :
	FmodServer.get_bus("bus:/Music").volume = v
	Global.game_settings.music_volume = v

func change_sensitivity(v: float) -> void:
	Global.game_settings.sensitivity = v
	sens_label.text = "Sensitivity: %.2f" % (v / sens_slider.max_value)
func _process(delta: float) -> void:
	if visible:
		time += delta
		sens_slider.custom_minimum_size = music_slider.size
