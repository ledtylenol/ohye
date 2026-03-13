extends Area3D
class_name GravityArea

@export var player: Player
@export var water_rect: ColorRect
@export var sound: RaytracedAudioPlayer3D
signal water_entered(water: Water)
signal water_exited(water: Water)
const LOG2: float = log(2.0)
const LOG_MIN_HZ: float = log(1000) / LOG2
var tween: Tween
var time := 0.0
var freq_ratio := 1.0:
	set(ratio):
		var log_t: float = lerpf(LOG_MIN_HZ, RaytracedAudioPlayer3D.LOG_MAX_HZ, ratio)
		lp.cutoff_hz = pow(2, log_t) # Scale back up
		freq_ratio = ratio
var lp: AudioEffectLowPassFilter
func _ready() -> void:
	area_entered.connect(on_area_entered)
	area_exited.connect(on_area_exited)
	# Reverb effect
	var i: int = AudioServer.get_bus_index("Sfx")

	lp = AudioServer.get_bus_effect(i, 0)

func _process(delta: float) -> void:
	time += delta
	water_rect.set_instance_shader_parameter("time", time)
func on_area_entered(area: Area3D) -> void:
	if area is Water:
		if tween: tween.kill()
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
		tween.tween_property(water_rect.material, "shader_parameter/alpha", 1.0, 0.5)
		tween.tween_property(self, "freq_ratio", 0.0, 0.5)
		player.global_gravity_modifier = area.gravity_modifier
		water_entered.emit(area)
		sound.pitch_scale = 1.2
		sound.play()
func on_area_exited(area: Area3D) -> void:
	if area is Water:
		player.global_gravity_modifier = 1.0
		water_exited.emit(area)
		if tween: tween.kill()
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
		tween.tween_property(water_rect.material, "shader_parameter/alpha", 0.0, 1.5)
		tween.tween_property(self, "freq_ratio", 1.0, 1.5)
		sound.pitch_scale = 1.05
		sound.play()
