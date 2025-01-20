extends Node
class_name SignalConnector

@export var from: Node
@export var what: String
@export var to: Node
@export var method: String

@export var unbind_amt := 0
func _ready() -> void:
	if not (from and what and method and to):
		queue_free()
	var callable := Callable(to, method)
	if unbind_amt > 0:
		callable = callable.unbind(unbind_amt)
	from.connect(what, callable)
