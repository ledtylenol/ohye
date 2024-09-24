extends Control
class_name CircleProg
@onready var texture_p: TextureProgressBar = $TextureProgressBar
@export var pos_control: Control
const CIRCULAR_PROGRESS_BAR = preload("res://components/circle_progress/CircularProgressBar.png")
var value := 0:
	set(v):
		if not v and value:
			fade_out()
		if v and not value:
			fade_in()
		value = v
var tween: Tween
var fade_tween: Tween
func beep() -> void:
	if tween:tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(texture_p, "scale", Vector2(0.5 - 0.5 * value / 100, 0.5 - 0.5 * value / 100), 0.3)

func _process(delta: float) -> void:
	texture_p.value = value
	position = pos_control.position + Vector2(20, 20)
	pivot_offset = size / 2
func fade_in() -> void:
	texture_p.scale = Vector2(0.3, 0.3)
	if fade_tween: fade_tween.stop()
	fade_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	fade_tween.tween_property(texture_p, "modulate:a", 1.0, 1.0)
func fade_out() -> void:
	if fade_tween: fade_tween.stop()
	fade_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	fade_tween.tween_property(texture_p, "modulate:a", 0.0, 1.0)
	
