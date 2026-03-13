@tool
extends Control
class_name MapNode
@onready var text_label: Label = $CenterContainer/Text
@onready var center_container: CenterContainer = $CenterContainer

var text := "placeholder"

var startpos := Vector2.ZERO
var vel := Vector2.ZERO
var startvel := Vector2.ZERO
var fbmvel := Vector2.ZERO
var time := randf_range(-100, 300)
var ratio := 0.5
@export var outer_radius := 10.0:
	set(v):
		outer_radius = v
		queue_redraw()
		
@export var outer_width := 4.0:
	set(v):
		outer_width = v
		queue_redraw()
@export var inner_radius := 8.0:
	set(v):
		if v > outer_radius:return
		inner_radius = v
		queue_redraw()
@export var noise: FastNoiseLite
var tween: Tween
func _ready() -> void:
	if Engine.is_editor_hint(): return
	text_label.text = text
	vel = startvel
	center_container.position = -size / 2
	position = startpos
	start_tween()
func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	time += delta
	vel = M.smooth_nudge(vel, Vector2.ZERO, 3.0, delta)
	position += vel * delta
func _draw() -> void:
	if Engine.is_editor_hint(): return
	draw_circle(Vector2.ZERO, outer_radius, Color.AQUA, false, outer_width, true)
	draw_circle(Vector2.ZERO, inner_radius, Color.AQUAMARINE, true, -1, true)

func start_tween() -> void:
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	tween.tween_property(self, "scale", Vector2.ONE, 2.0).from(Vector2.ZERO)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).tween_property(self, "ratio", 1.0, 3.5)
