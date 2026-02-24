extends Node3D
class_name SoundEmitter3D

@export var event_name: String
@export var attached: bool
var event: FmodEvent
func _ready() -> void:
	#event = FmodServer.create_event_instance(event_name)
	if attached and event:
		event.set_3d_attributes(global_transform)

func _notification(what: int) -> void:
	if what == Object.NOTIFICATION_PREDELETE:
		if event:
			event.stop(FmodServer.FMOD_STUDIO_STOP_IMMEDIATE)
			event.release()
func _physics_process(delta: float) -> void:
	if attached and event and event.is_valid():
		event.transform_3d = global_transform

func play() -> void:
	if event:
		event.start()

func stop() -> void:
	if event:
		event.stop(FmodServer.FMOD_STUDIO_STOP_IMMEDIATE)

func set_parameter(what: String, value: Variant) -> void:
	if event:
		event.set_parameter_by_name(what, value)

func set_parameter_label(what: String, label: String) -> void:
	if event:
		event.set_parameter_by_name_with_label(what, label, false)
func get_parameter(what: String) -> Variant:
	if event:
		return event.get_parameter_by_name(what)
	return null
