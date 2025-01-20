extends PanelContainer
class_name AchievementHolder

@export var texture: TextureRect
@export var title: RicherTextLabel
@export var description: RicherTextLabel
@export var playtime: RicherTextLabel
@export var sound: FmodEventEmitter3D
func _ready() -> void:
	sound.play()
	tween_pos()

func tween_pos() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position", position, 0.3).from(position + Vector2.DOWN * (size.y * 2 + 1))
	tween.tween_interval(3.0)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)
