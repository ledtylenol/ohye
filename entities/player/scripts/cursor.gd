extends ColorRect
class_name Cursor

var use_get := false
var alpha := 0.0

@onready var parent_pos: Vector2= get_parent().global_position + get_parent().size / 2.0:
	get: return get_parent().global_position + get_parent().size / 2.0
@onready var initial_pos: Vector2 = position
@onready var dir: Vector2 = (initial_pos - Vector2(18, 18)).normalized()

func _ready() -> void:
	modulate.a = 0.2
var tween: Tween
func _process(delta: float) -> void:
	pivot_offset = size/2
	material.set_shader_parameter("alpha", alpha)
func tween_in() -> void:
	if tween: tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel()
	tween.tween_property(self, "position", initial_pos - dir * 3.0, 0.6)
	tween.tween_property(self, "alpha", 1.0, 1.0)
	tween.tween_property(self, "scale", -abs(dir) * 0.3 + Vector2.ONE, 0.6)
func tween_out() -> void:
	if tween: tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel()
	tween.tween_property(self, "position", initial_pos + dir * 5.0, 0.6)
	tween.tween_property(self, "alpha", 1.0, 1.0)
	tween.tween_property(self, "scale", abs(dir) * 1.5 + Vector2.ONE, 0.6)
func tween_default() -> void:
	if tween: tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel()
	tween.tween_property(self, "position", initial_pos, 1.0)
	tween.tween_property(self, "alpha", 0.3, 1.0)
	tween.tween_property(self, "scale", Vector2.ONE, 1.0)
