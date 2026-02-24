extends Window
@onready var richer_text_label: RicherTextLabel = $Control/RicherTextLabel


var t := 1.0
var popo: Vector2 = Vector2.ZERO:
	set(value):
		position = Vector2i(value)
		popo = value
func _ready() -> void:
	print("hello from window")
func _process(delta: float) -> void:
	t -= delta
	richer_text_label.set_bbcode("%.0f" % (t * 8))
