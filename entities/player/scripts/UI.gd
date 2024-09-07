extends CanvasLayer
@export var left_rect: Cursor
@export var right_rect: Cursor
@export var up_rect: Cursor
@export var down_rect: Cursor
@export var interact_ray: InteractRay
@onready var crosshair: Crosshair = $Control/Control

func _ready() -> void:
	for rect: Cursor in [left_rect, right_rect, up_rect, down_rect]:
		interact_ray.interact_entered.connect(rect.tween_out)
		interact_ray.interact_start.connect(func(_x)->void: rect.tween_in())
		interact_ray.interact_end.connect(func(_x)->void: rect.tween_out())
		interact_ray.interact_exited.connect(rect.tween_default)
	interact_ray.interact_entered.connect(crosshair.tween_out)
	interact_ray.interact_start.connect(func(_x)->void: crosshair.tween_in)
	interact_ray.interact_end.connect(func(_x)->void: crosshair.tween_out)
	interact_ray.interact_exited.connect(crosshair.tween_default)
func _physics_process(delta: float) -> void:
	pass
