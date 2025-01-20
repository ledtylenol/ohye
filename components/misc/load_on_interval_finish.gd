extends Node
class_name AllowLoadOnInterval

@export var timed_interact: TimedInteractComponent
var parent: SceneLoader

func _ready() -> void:
	if not get_parent() is SceneLoader or not timed_interact:
		queue_free()
	parent = get_parent() as SceneLoader
	timed_interact.finished.connect(enable_parent, CONNECT_ONE_SHOT)

func enable_parent() -> void:
	parent.can_change = true
