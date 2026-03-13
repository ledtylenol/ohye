extends Button
class_name MagicButton

@export var easing_type: Tween.EaseType
@export var trans_type: Tween.TransitionType
@export var easing_duration := 0.5

@export var down_scale := Vector2(0.9, 0.9)
@export var up_scale := Vector2(1.1, 1.1)
@export var enter_scale := Vector2(1.05, 1.05)
@export var exit_scale := Vector2.ONE

@export_range(0.0, 1.0, 0.01) var mousepos_amount = 0.15

@export var sound_on: FmodEventEmitter3D
@export var sound_off: FmodEventEmitter3D
var tween: Tween

var mouse_on := false
var startpos := Vector2.ZERO

func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	button_down.connect(on_button_down)
	button_up.connect(on_button_up)
	await get_tree().physics_frame
	startpos = position
func _process(_delta: float) -> void:
	if disabled: return
	pivot_offset = size / 2
	var target := Vector2.ZERO
	if mouse_on:
		target = startpos.lerp(get_local_mouse_position() - size / 2, mousepos_amount) 
	else:
		target = startpos 
	position = M.smooth_nudge(position, target, 5.0, _delta)
func on_mouse_exited() -> void:
	if disabled: return
	mouse_on = false
	if tween: tween.kill()
	tween = create_tween().set_ease(easing_type).set_trans(trans_type)
	tween.tween_property(self, "scale", exit_scale, easing_duration)
	if sound_off:
		FmodServer.play_one_shot(sound_off.event_name)
func on_mouse_entered() -> void:
	if disabled: return
	mouse_on = true
	if tween: tween.kill()
	tween = create_tween().set_ease(easing_type).set_trans(trans_type)
	tween.tween_property(self, "scale", enter_scale, easing_duration)

	if sound_on:
		FmodServer.play_one_shot_with_params(sound_on.event_name, {"Heat1": 0.4})

func on_button_down() -> void:
	if disabled: return
	if tween: tween.kill()
	tween = create_tween().set_ease(easing_type).set_trans(trans_type)
	tween.tween_property(self, "scale", down_scale, easing_duration)
func on_button_up() -> void:
	if disabled: return
	if tween: tween.kill()
	tween = create_tween().set_ease(easing_type).set_trans(trans_type)
	tween.tween_property(self, "scale", up_scale, easing_duration)
