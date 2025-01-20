extends CanvasLayer
@export var left_rect: Cursor
@export var right_rect: Cursor
@export var up_rect: Cursor
@export var down_rect: Cursor
@export var interact_ray: InteractRay
@onready var crosshair: Crosshair = $Control / Control
@onready var label: Label = $Control / Label
@onready var fps_label: Label = $Control / FPSLabel

var time: = 0.0
func _ready() -> void :
	await get_tree().physics_frame
	for rect: Cursor in [left_rect, right_rect, up_rect, down_rect]:
		interact_ray.interact_entered.connect(rect.tween_out)
		interact_ray.interact_start.connect(func(_x) -> void : rect.tween_in())
		interact_ray.interact_end.connect(func(_x) -> void : rect.tween_out())
		interact_ray.interact_exited.connect(rect.tween_default)
		Global.enforce_crosshair.connect(rect.change_type)
		Global.enforce_disabled.connect(rect.tween_default)
	interact_ray.interact_entered.connect(crosshair.tween_out)
	interact_ray.interact_start.connect(func(_x) -> void : crosshair.tween_in())
	interact_ray.interact_end.connect(func(_x) -> void : crosshair.tween_out())
	interact_ray.interact_exited.connect(crosshair.tween_default)
	Global.enforce_disabled.connect(crosshair.tween_default)
func _process(delta: float) -> void :
	time += delta
	label.text = M.format_time(time)
	fps_label.text = "%.2f" % Engine.get_frames_per_second()
