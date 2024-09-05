extends Node
class_name SignalConnector

@export var from: Node
@export var what: String
@export var to: Node
@export var method: String

func _ready() -> void:
	if not (from and what and to and method):
		queue_free()
	var callable := Callable(to, method)
	from.connect(what, callable)
