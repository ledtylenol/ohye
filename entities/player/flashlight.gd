extends SpotLight3D

@export var sound: FmodEventEmitter3D
@export var enabled_energy := 1.0
@export var parent: Player
@export var interact: InteractRay
@export var enabled:= false:
	get:
		return is_instance_valid(parent) and enabled and parent.active

@onready var active := enabled:
	set(value):
		print("set active to %s" % value)
		if value:
			light_energy = enabled_energy
			
		else: light_energy = 0.0
		active = value

func _ready() -> void:
	parent.active_set.connect(on_active_set)

func on_active_set(v: bool):
	if enabled:
		active = true
func _unhandled_input(event: InputEvent) -> void:
	if not enabled:
		return 
	if interact.interactable: return
	if sound and event.is_action("interact") and event.is_pressed() and not event.is_echo():
		active = not active
		sound.play()
