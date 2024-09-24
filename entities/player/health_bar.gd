extends ProgressBar
class_name HealthBar

@export var health_component: HealthComponent
@export var duration := 1.0
@export var do_heat := true
var heat := 0.0
var tween: Tween
var show_tween: Tween
var time_since_set := 0.0
var show := true:
	set(v):
		if v != show:
			tween_show(v)
		show = v
func _ready() -> void:
	if health_component:
		health_component.health_changed.connect(tween_hp)
		value = health_component.capped_ratio * 100
func tween_hp(how_much: int) -> void:
	time_since_set = 0.0
	var relative := health_component.capped_ratio
	if relative != 1.0:
		show = true
	if tween: tween.stop()
	if not do_heat:
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		tween.tween_property(self, "value", relative * 100, duration)
		return
	if not heat:
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	else:
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "value", relative * 100, duration + (0.5 * heat))
	heat += 1.0
func _process(delta: float) -> void:
	heat = maxf(0.0, heat - delta)
	heat *= 0.95
	time_since_set += delta
	if time_since_set > 1.0 and value == 100:
		show = false


func tween_show(b: bool) -> void:
	if show_tween: show_tween.stop()
	show_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	show_tween.tween_property(self, "modulate:a", 1.0 * float(b), 1.0)
