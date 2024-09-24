extends MeshInstance3D
class_name DrawerDoor


enum STATES {
	CLOSED,
	OPENED
}
@export var state := STATES.CLOSED
@export var interact: InteractComponent
@export var open_audio: AudioStreamPlayer3D
@export var close_audio: AudioStreamPlayer3D

var tween: Tween

func _ready() -> void:
	if interact:
		interact.interact.connect(play_anim)


func play_anim() -> void:
	match state:
		STATES.OPENED: close()
		_: open()


func close() -> void:
	state = STATES.CLOSED
	if tween: tween.stop()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(close_audio.play)
	tween.tween_property(self, "position:z", 0.0, 0.4)
	interact.prior = 2
func open() -> void:
	state = STATES.OPENED
	if tween: tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(open_audio.play)
	tween.tween_property(self, "position:z", 1.5, 0.4)
	interact.prior = 1
