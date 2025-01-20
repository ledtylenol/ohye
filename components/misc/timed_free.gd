extends Node
class_name TimedFree

@export var lifetime := 5.0

func _ready() -> void:
	get_tree().create_timer(lifetime).timeout.connect(get_parent().queue_free)
