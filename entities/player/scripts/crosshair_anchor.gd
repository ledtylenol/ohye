extends Control
class_name Crosshair
enum MODES{
	Default, 
	In, 
	Out
}
var mode: = MODES.Default
var do_r: = 0.0
var t: = randf_range(-40.0, 40.0)
var tween: Tween
var target_pos: Vector2
var time_since_interact_enter: = 0.0
@export var camera: PlayerCamera
@export var ray: InteractRay
@export var sod: SecondOrderDynamics
@export var center: Control
@export var lerp_enabled: = true
var enforce_cursor: = false:
	get:
		return Global.enforce_cursor
func _ready() -> void :
	sod.init2(position)
func _physics_process(delta: float) -> void :
	pivot_offset = size / 2.0
	t += delta if do_r > 0.0 else 0.0

	if enforce_cursor:
		mode = MODES.In
		do_r = 1.0
		position = center.position
		rotation += do_r * delta * 2 * PI
		return
	else:
		rotation = ( - PI / 4) * do_r + do_r * sin(t) * PI
	if camera and ray and lerp_enabled:
		if ray.interactable:
			target_pos = camera.unproject_position(ray.interactable.global_position) * 0.5 + center.position * 0.5
			time_since_interact_enter = 0.0
		elif center:
			target_pos = center.position
			time_since_interact_enter += delta
	elif center:
		target_pos = center.position
	position = sod.update(position, target_pos, delta)[0]


func tween_out() -> void :
	t = randf_range(-1, 1)
	mode = MODES.Out
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "do_r", 0.5, 1.0)
func tween_in() -> void :
	t = randf_range(-1, 1)

	mode = MODES.In
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "do_r", 1.0, 1.0)
func tween_default() -> void :
	mode = MODES.Default
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "do_r", 0.0, 1.0)
