extends Node3D
class_name Toggler
@export var interact: InteractComponent
@export var thing_to_toggle: Node3D
@export var param: String
var value:
	get:
		if thing_to_toggle and param in thing_to_toggle:
			return thing_to_toggle.get(param)
		return null
var v: bool:
	get: return $OmniLight3D.visible
	set(value):
		$OmniLight3D.visible = value
func _ready() -> void:
	if interact:
		interact.interact_start.connect($On.play)
		interact.interact_end.connect($Off.play)
		interact.interact_end.connect(play)



func play() -> void:
	if thing_to_toggle and param in thing_to_toggle:
		thing_to_toggle.set(param, not value)
