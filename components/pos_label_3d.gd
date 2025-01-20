extends Label3D
class_name PosLabel3D

@onready var initial_pos := position
var tween: Tween
var active := false
signal finished
func delete() -> void:
	if text[0] == ' ':
		finished.emit()
		queue_free()
		return
	if tween:tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "transparency", 1.0, 0.01)
	tween.tween_callback(queue_free)
	await tween.finished
	finished.emit()
func start() -> void:
	if text[0] == ' ':
		finished.emit()
		return
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "transparency", 0.0, 0.1).from(1.0)
	tween.parallel().tween_property(self, "position", initial_pos, 0.1).from(initial_pos + basis.y * 2)
	tween.tween_callback(func() -> void: active = true)
	await tween.finished
	finished.emit()
