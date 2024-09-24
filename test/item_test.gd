extends Node3D
@export var lighter: Toggler

var counter := 0
var do_stuff := false:
	set(value):
		lighter.interact.interact_end.connect(invert_visibility)
func _ready() -> void:
	if lighter:
		lighter.interact.interact_end.connect(play)
		

func play() -> void:
	counter += 1
	if counter == 10:
		do_stuff = true
		$TransitionArea.active = true

func invert_visibility() -> void:
	$CanvasLayer.visible = not $CanvasLayer.visible
	Global.player.winds.volume_db = -80 if $CanvasLayer.visible else 0
