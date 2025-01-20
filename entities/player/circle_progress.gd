extends Control
class_name CircleProg
@onready var texture_p: TextureProgressBar = $TextureProgressBar
@export var pos_control: Control
const CIRCULAR_PROGRESS_BAR = preload("res://components/circle_progress/CircularProgressBar.png")
var interval: = 0.2
var value: = 0.0:
	set(v):
		if not v and value:
			fade_out()
		if v and not value:
			fade_in()
		value = v
var tween: Tween
var fade_tween: Tween
var sign_yes: = 1
var rotate: = false:
	set(value):
		if not value:

			beeps = 0
		elif value:
			randomize_sign()
		rotate = value
var t: = 0.0
var beeps: = 0
var target_value: = 0.0
var target_t: = 0.0
var f0: = 0.0
func _ready() -> void :
	texture_p.scale = Vector2.ZERO

func beep() -> void :
	f0 = randf_range( - PI, PI)
	beeps += 1
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	if beeps % 2 == 0:
		tween.tween_property(texture_p, "scale", Vector2(0.3, 0.3), 0.3)
	else:
		tween.tween_property(texture_p, "scale", Vector2(0.4, 0.4), 0.3)


func _process(delta: float) -> void :
	t += delta if rotate else 0.0
	texture_p.value = target_value
	target_value = M.smooth_nudgef(target_value, value, 10.0, delta)
	position = pos_control.position + Vector2(20, 20)
	pivot_offset = size / 2
	target_t = TAU * sqrt(value) * sign_yes
	texture_p.radial_initial_angle = rad_to_deg(f0 + PI * 2 * (sin(t) ** 2 - 0.5))
	texture_p.material.set_shader_parameter("alpha", texture_p.modulate.a)
func fade_in() -> void :
	rotate = true
	if fade_tween: fade_tween.kill()
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	fade_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	tween.tween_property(texture_p, "scale", Vector2(0.3, 0.3), interval)
	fade_tween.tween_property(texture_p, "modulate:a", 1.0, interval)

func fade_out() -> void :
	rotate = false

	if fade_tween: fade_tween.kill()
	if tween: tween.kill()
	fade_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)

	tween.tween_property(texture_p, "scale", Vector2.ZERO, interval)
	fade_tween.tween_property(texture_p, "modulate:a", 0.0, interval)

func randomize_sign() -> void :
	pass
