extends CanvasLayer
class_name Ui2D

@export var music_slider: Slider
@export var sfx_slider: Slider
var active := false:
	set(value):
		visible = value
		active = value
func _ready() -> void:
	if music_slider:
		music_slider.value_changed.connect(change_vol.bind("bus:/Music"))
	if sfx_slider:
		sfx_slider.value_changed.connect(change_vol.bind("bus:/Sfx"))
	update_slider_value(music_slider, "bus:/Music")
	update_slider_value(sfx_slider, "bus:/Sfx")
	active = visible
func change_vol(val: float, bus: String) -> void:
	FmodServer.get_bus(bus).volume = val
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")

	# If the file didn't load, ignore it.
	if err != OK and FileAccess.file_exists("user://settings.cfg"):
		return
	config.set_value("audio", bus, val)
	config.save("user://settings.cfg")
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and event.is_action("escape"):
		active = not active

func update_slider_value(sl: Slider, bus: String) -> void:
	var score_data = {}
	var config = ConfigFile.new()

	# Load data from a file.
	var err = config.load("user://settings.cfg")

	# If the file didn't load, ignore it.
	if err != OK and FileAccess.file_exists("user://settings.cfg"):
		return
	
	sl.value = config.get_value("audio", bus, 1.0)
	change_vol(sl.value, bus)
	config.set_value("audio", bus, sl.value)
	config.save("user://settings.cfg")
