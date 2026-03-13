extends Control
@export var lerp_label: Label
@export var lerp_slider: HSlider

@export var start_text := "this is the start text"
@export var end_text := "end text here I come"

func _ready() -> void:
	lerp_slider.value_changed.connect(change_label_text)


func change_label_text(value: float) -> void:
	lerp_label.text = Tween.interpolate_value(start_text, end_text, value, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
