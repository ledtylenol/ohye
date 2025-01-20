extends AudioStreamPlayer3D
class_name Clock

@export var timed_comp: TimedInteractComponent
@export var disable_on_finish := false
var can_play := true

func _ready() -> void:
	if not timed_comp:
		for sibling in get_parent().get_children():
			if sibling is TimedInteractComponent:
				timed_comp = sibling
				break
		if not timed_comp:
			queue_free()
			return
	
	timed_comp.beep.connect(func() -> void: if can_play: play_fmod())
	if disable_on_finish: timed_comp.finished.connect(disable)

func disable() -> void:
	can_play = false

func play_fmod() -> void:
	FmodServer.play_one_shot_attached_with_params("event:/Sfx3D/Light", self, {"Active": 1})
