extends Node

@onready var type: FmodEventEmitter3D = $Type
@onready var timer: Timer = $Timer
@onready var end: FmodEventEmitter3D = $End

var active := false
var key_buffer: Array[String] = []
var current_text: String:
	get:
		if key_buffer:
			var s: String = ""
			return s.join(key_buffer)
		return ""
signal text_changed(text: String)
func _ready() -> void:
	timer.timeout.connect(clear_buffer)
func _input(event: InputEvent) -> void:
	if not event.is_pressed() or not active: return
	var e: InputEventKey = event as InputEventKey
	if not e or e.is_echo(): return
	match e.keycode:
		KEY_BACKSPACE:
			print("delete")
			key_buffer.pop_back()
			text_changed.emit(current_text)
			return
		KEY_SPACE:
			key_buffer.append(" ")
			if key_buffer.size() > 30:
				key_buffer.pop_front()
			type.play_one_shot()
			text_changed.emit(current_text)
			timer.start()
		KEY_SEMICOLON when e.shift_pressed:
			key_buffer.append(":")
			if key_buffer.size() > 30:
				key_buffer.pop_front()
			type.play_one_shot()
			text_changed.emit(current_text)
			timer.start()
		KEY_SEMICOLON:
			key_buffer.append(";")
			if key_buffer.size() > 30:
				key_buffer.pop_front()
			type.play_one_shot()
			text_changed.emit(current_text)
			timer.start()
		var a when a >= KEY_0 and a <= KEY_9 or a >= KEY_A and a <= KEY_Z:
			type.play_one_shot()
			key_buffer.append(e.as_text().to_lower())
			if key_buffer.size() > 30:
				key_buffer.pop_front()
			text_changed.emit(current_text)
			timer.start()
func clear_buffer() -> void:
	key_buffer.clear()
	text_changed.emit(current_text)
	end.play_one_shot()
