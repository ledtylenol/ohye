extends Node2D

func _ready() -> void:
	Global2d.player.player_collided.connect(prints)
	Global2d.player.state_changed.connect(set_param)
func set_param(_o, new):
	$FmodEventEmitter2D.set_parameter("State", float(new))
