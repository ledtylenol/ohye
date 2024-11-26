extends Control
class_name Console

@onready var text_edit: ConsoleEdit = $PanelContainer/VBoxContainer/TextEdit
@onready var label: RichTextLabel = $PanelContainer/VBoxContainer/RichTextLabel
@onready var sod: SecondOrderDynamics = $SecondOrderDynamics

var global_keywords := {
	"print": print_fancy,
	"cast": cast,
	"f": change_f,
	"z": change_z,
	"r": change_r,
}
var user_keywords := {}
var text: Array[String] = []
var tween: Tween
var t_pos := Vector2(0, -200)
var t_a := 0.0
var visibility := false:
	set(value):
		if value:
			tween_show()
		else:
			tween_hide()
		visibility = value
func _ready() -> void:
	text_edit.text_emitted.connect(parse_text)
	position = Vector2(0, -200)
	sod.init2(position, t_a)
func _process(delta: float) -> void:
	label.text = ""
	text.reverse()
	text.resize(30)
	text.reverse()
	for t in text:
		label.text += t + "\n" 
	position = sod.update(position, t_pos, delta)[0]
	modulate.a = sod.update_f(modulate.a, t_a, delta)
func print_fancy(dict = {}):
	var t = "> "
	for x in dict:
		if user_keywords.has(dict[x]):
			t += user_keywords[dict[x]]
		else:
			t += str(dict[x])
	text.push_back(t)

func cast(dict = {}):
	pass

func parse_text(t: String) -> void:
	var words := Array(t.split(" "))
	var ident = words.pop_front()
	var ident_c = global_keywords.get(ident)
	if not ident_c:
		ident_c = user_keywords.get(ident)
	if not words.is_empty() and words[0] == "=":
		user_keywords[ident] = words[1]
	var args = {}
	var i = 0
	for word in words:
		args[i] = word
		i += 1
	if ident_c != null:
		ident_c.call(args)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and event.is_action("console_open"):
		visibility = not visibility

func tween_show() -> void:
	text_edit.grab_click_focus()
	text_edit.grab_focus()
	text_edit.enabled = true

	t_pos = Vector2.ZERO
	t_a = 1.0
func tween_hide() -> void:
	text_edit.release_focus()
	text_edit.enabled = false
	t_pos = Vector2(0, -200)
	t_a = 0.0
	release_focus()

func change_f(args = {}) -> void:
	if not args.has(0):
		return
	var new_val = args[0]
	if new_val and float(new_val):
		sod._f = float(new_val)
func change_z(args = {}) -> void:
	if not args.has(0):
		return
	var new_val = args[0]
	if new_val and float(new_val):
		sod._z = float(new_val)
func change_r(args = {}) -> void:
	if not args.has(0):
		return
	var new_val = args[0]
	if new_val and float(new_val):
		sod._r = float(new_val)
