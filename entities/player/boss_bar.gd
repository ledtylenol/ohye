extends HealthBar
class_name BossBar

@export var up_pos: Control
@export var down_pos: Control
func _ready() -> void :
	show = false
	Global.boss_started.connect(set_comp)
	if health_component:
		health_component.health_changed.connect(tween_hp)
		value = health_component.uncapped_ratio * 100
func _process(_delta: float) -> void :
	pivot_offset = size / 2
	show = health_component != null
	if not tween or not tween.is_running():
		position = up_pos.position + Vector2.UP * 20 - Vector2.RIGHT * size.x / 2
func set_comp(hp_comp: HealthComponent):
	health_component = hp_comp
	health_component.health_changed.connect(tween_hp)
	value = health_component.uncapped_ratio * 100
	show = true

func tween_show(b: bool) -> void :
	if show_tween: show_tween.kill()
	show_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
	show_tween.tween_property(self, "modulate:a", 1.0 * float(b), 1.0)
	if b:
		show_tween.tween_property(self, "position:y", up_pos.position.y - 20, 1.0)
	else:
		show_tween.tween_property(self, "position:y", up_pos.position.y + 50, 1.0)
