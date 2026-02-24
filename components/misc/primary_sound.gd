extends Node
class_name PrimarySound

@export var sound: FmodEventEmitter3D
func _ready() -> void:
	call_deferred("set_sound")


func set_sound() -> void:
	if sound:
		Global.last_sound = sound.event_guid
		print("set sound to %s with guid %s" % [sound.event_name, sound.event_guid])
	else:
		Global.last_sound = ""
