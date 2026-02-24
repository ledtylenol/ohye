extends ScrollContainer

var tween: Tween
@export var sod: SecondOrderDynamics
var target_y := 0.0
func _ready() -> void:
	sod.init2(Vector2.ZERO)
func _input(e: InputEvent) -> void:
	if e is InputEventMouseButton:
		match e.button_index:
			MOUSE_BUTTON_WHEEL_DOWN:
				target_y = get_v_scroll_bar().max_value
			MOUSE_BUTTON_WHEEL_UP:
				target_y = 0.0

func _physics_process(delta: float) -> void:
	scroll_vertical = sod.update(Vector2(0, scroll_vertical), Vector2(0, target_y), delta)[0].y
