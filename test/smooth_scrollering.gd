extends Control
var tween: Tween
var down := false:
	set(v):
		if v != down:
			if v:
				tween_down()
			else:
				tween_up()
			
		down = v
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton: match event.button_index:
		MOUSE_BUTTON_WHEEL_DOWN: down = true
		MOUSE_BUTTON_WHEEL_UP: down = false 


func tween_down() -> void:
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(get_child(0), "position", Vector2(0, size.y / 2), 1.0)

func tween_up() -> void:
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(get_child(0), "position", Vector2(0, -size.y / 2), 1.0)
