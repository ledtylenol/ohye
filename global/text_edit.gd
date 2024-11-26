extends TextEdit
class_name ConsoleEdit
signal text_emitted
var enabled := false
func _input(event: InputEvent) -> void:
	if not has_focus():
		if enabled and event is InputEventKey and event.is_pressed() and event.key_label == KEY_ENTER:
			grab_focus()
			text = text.replace("\n", "").replace("\r", "")
		return
	if event is InputEventKey:
		if event.is_pressed():match event.key_label:
			KEY_ENTER: 
				text_emitted.emit(text.replace("\n", "").replace("\r", ""))
				text = ""
			KEY_ESCAPE:
				release_focus()

func _process(delta: float) -> void:
	if text == "\n":
		text = ""
