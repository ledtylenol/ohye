extends Area3D
class_name SoundMonitor


var children: Array[RayCast3D]:
	get:
		return M.nightmare_getter(self, RayCast3D, &"RayCast3D")
@onready var label_2: Label = $"../../CanvasLayer/Control/Label2"
@export var emitter: FmodEventEmitter3D
var real_acc_dist: = 0.0
func _ready() -> void :
	area_entered.connect(on_area_entered)

func on_area_entered(area: Area3D) -> void :
	if area is ReverbChange:
		print("yes")
		emitter.stop()
		emitter.event_name = "snapshot:/%s" % area.snapshot
		emitter.play()
