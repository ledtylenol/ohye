extends State
class_name InactiveNoiseState

@export var detector: Area3D


func _ready() -> void:
	detector.body_entered.connect(on_body_enter)



func on_body_enter(body: Node3D) -> void:
	var p = body as Player
	if p:
		target.player = p
		transitioned.emit("inactive", "stalk")

func on_exit() -> void:
	detector.body_entered.disconnect(on_body_enter)
