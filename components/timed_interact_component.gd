extends Node
class_name TimedInteractComponent

enum Mode {
	CONTINUOUS,
	ONE_SHOT,
	REPEATED
}

@export var duration_min := 1.0
@export var duration_max := 1.0
@export var interval := 0.2
@export var interact_component: InteractComponent
@export var mode := Mode.ONE_SHOT
@export var reset_on_deactivate := true
@export var call_immediately := false
var time := 0.0
var interval_time := 0.0
var duration: float
var active := false:
	set(value):
		if not call_immediately and time > duration and not value:
			reset_times()
			finished.emit()
		if reset_on_deactivate:
			reset_times()
		active = value
signal finished
signal beep
func _ready() -> void:
	if not interact_component:
		push_warning("no interact component found, this component needs a react component to function")
		queue_free()
		return
	duration = randf_range(duration_min, duration_max)
	interact_component.interact_start.connect(func() -> void: active = true)
	interact_component.interact_end.connect(func() -> void: active = false)
	beep.connect(Global.player.circle_progress.beep)
func _process(delta: float) -> void:
	if not active:
		return
	Global.player.circle_progress.value = (time / duration) * 100
	print(time)
	time += delta
	interval_time += delta
	if interval_time > interval:
		beep.emit()
		interval_time -= interval
	if time > duration and call_immediately:
		finished.emit()
		match mode:
			Mode.ONE_SHOT:
				queue_free()
			Mode.REPEATED:
				time -= duration
				duration = randf_range(duration_min, duration_max)

func reset_times() -> void:
	interval_time = 0.0
	time = 0.0
	Global.player.circle_progress.value = 0
