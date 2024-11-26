extends Node
class_name GhostSpawner
const GHOST = preload("res://2d/shaders/ghost.tres")
@export var delay := 0.2:
	set(value):
		if timer:
			timer.wait_time = delay
		delay = value
@export var target_node: Node2D
@export var ghost_duration := 1.0
@export var color_randomisation := 1.0
var timer: Timer
@export var active := false:
	set(value):
		if timer.is_stopped() and value:
			timer.start()
		timer.paused = not value
		active = value
func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = delay
	timer.one_shot = false
	if not  target_node:
		target_node = get_parent()
	if not target_node:
		print('cannot work without a target')
		queue_free()
	timer.timeout.connect(spawn_node)
	add_child(timer)

func spawn_node() -> void:
	var new_node :Node2D= target_node.duplicate()
	new_node.add_child(GhostComponent.new(ghost_duration))
	new_node.modulate.r *= randf_range(1.0 - color_randomisation, 1.0)
	new_node.modulate.g *= randf_range(1.0 - color_randomisation, 1.0)
	new_node.modulate.b *= randf_range(1.0 - color_randomisation, 1.0)
	new_node.top_level = true
	new_node.global_transform = target_node.global_transform
	new_node.material = GHOST.duplicate()
	get_parent().add_child(new_node)
