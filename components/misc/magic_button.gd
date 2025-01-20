extends Button
class_name MagicButton

@export var easing_type: Tween.EaseType
@export var trans_type: Tween.TransitionType
@export var easing_duration := 0.5

@export var down_scale := Vector2(0.9, 0.9)
@export var up_scale := Vector2(1.1, 1.1)
@export var enter_scale := Vector2(1.05, 1.05)
@export var exit_scale := Vector2.ONE
var tween: Tween


func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	button_down.connect(on_button_down)
	button_up.connect(on_button_up)

func _process(_delta: float) -> void:
	pivot_offset = size / 2
func on_mouse_exited() -> void:
	if tween: tween.kill()
	tween = create_tween().set_ease(easing_type).set_trans(trans_type)
	tween.tween_property(self, "scale", exit_scale, easing_duration)
func on_mouse_entered() -> void:
	if tween: tween.kill()
	tween = create_tween().set_ease(easing_type).set_trans(trans_type)
	tween.tween_property(self, "scale", enter_scale, easing_duration)

func on_button_down() -> void:
	if tween: tween.kill()
	tween = create_tween().set_ease(easing_type).set_trans(trans_type)
	tween.tween_property(self, "scale", down_scale, easing_duration)
func on_button_up() -> void:
	if tween: tween.kill()
	tween = create_tween().set_ease(easing_type).set_trans(trans_type)
	tween.tween_property(self, "scale", up_scale, easing_duration)
