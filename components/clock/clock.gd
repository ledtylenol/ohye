extends AudioStreamPlayer3D
class_name Clock

@export var timed_comp: TimedInteractComponent
var can_play := true

func _ready() -> void:
	if not timed_comp:
		queue_free()
	
	timed_comp.beep.connect(func() -> void: if can_play: play())
	timed_comp.finished.connect(disable)

func disable() -> void:
	can_play = false
