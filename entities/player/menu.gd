extends PanelContainer
class_name Menu
var tween: Tween
var active: = false:
	set(value):
		if value and not active:
			tween_visible()
		elif not value and active:
			tween_hidden()
		active = value
@onready var sfx_slider: HSlider = $"VBoxContainer/SFX Container/SFX Slider"
@onready var music_slider: HSlider = $"VBoxContainer/Music Container/Music Slider"
@onready var return_button: Button = $"VBoxContainer/Return Button"
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
func _ready() -> void :
	return_button.button_up.connect(func() -> void :
		get_tree().paused = false
		Transition.return_to_sub())
	sfx_slider.value = Global.game_settings.sfx_volume
	music_slider.value = Global.game_settings.music_volume
	sfx_slider.value_changed.connect(change_sfx)
	music_slider.value_changed.connect(change_music)
	music_slider.drag_ended.connect(Global.save_settings.unbind(1))
	sfx_slider.drag_ended.connect(Global.save_settings.unbind(1))
	paused_song.play()
	FmodServer.get_bus("bus:/Music").volume = Global.game_settings.music_volume
	FmodServer.get_bus("bus:/Sfx").volume = Global.game_settings.sfx_volume
func _input(event: InputEvent) -> void :
	if event.is_action_pressed("escape") and player.active:
		player.ingame_mode = not player.ingame_mode

func tween_visible() -> void :
	visible = true
	get_tree().paused = true
	Transition.request_load()
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(paused_song, "volume", 0.5, 0.5)
	tween.parallel().tween_property(self, "magnitude", 0.005, 0.5)
func tween_hidden() -> void :
	get_tree().paused = false
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(paused_song, "volume", 0.0, 0.5)
	tween.parallel().tween_property(self, "magnitude", 0.0, 0.5)
	tween.tween_callback(func(): visible = false)
func change_sfx(v: float) -> void :
	FmodServer.get_bus("bus:/Sfx").volume = v
	Global.game_settings.sfx_volume = v

func change_music(v: float) -> void :
	FmodServer.get_bus("bus:/Music").volume = v
	Global.game_settings.music_volume = v

func _process(delta: float) -> void:
	if visible:
		time += delta
