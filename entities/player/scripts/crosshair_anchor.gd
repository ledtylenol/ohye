extends Control
class_name Crosshair
enum MODES {
	Default,
	In,
	Out
}
var mode := MODES.Default
var do_r := 0.0
var t := randf_range(-40.0, 40.0)
var tween: Tween
func _physics_process(delta: float) -> void:
	pivot_offset = size / 2.0
	t += delta if do_r > 0.0 else 0.0
	rotation = (-PI / 4) * do_r + do_r * sin(t) * PI

func tween_out() -> void:
	t = randf_range(-1, 1)
	mode = MODES.Out
	if tween: tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "do_r", 0.5, 1.0)
func tween_in() -> void:
	t = randf_range(-1, 1)

	mode = MODES.In
	if tween: tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "do_r", 1.0, 1.0)
func tween_default() -> void:
	mode = MODES.Default
	if tween: tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "do_r", 0.0, 1.0)
