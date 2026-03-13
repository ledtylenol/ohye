extends HSlider
class_name MagicSlider
var t := randf_range(-10.0, 10.0)
var time_scale := 1.0
@export var sound: FmodEventEmitter3D
func _ready() -> void:
	value_changed.connect(on_value_changed)
	set_instance_shader_parameter("heat", ratio)
func _process(delta: float) -> void:
	t += delta * time_scale
	time_scale = maxf(ratio, 0.1)
	set_instance_shader_parameter("time", t)
func on_value_changed(_v) -> void:
	set_instance_shader_parameter("heat", ratio)
	FmodServer.play_one_shot_with_params(sound.event_name, {"Heat1": ratio})
