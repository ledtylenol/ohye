extends Area3D
class_name SoundMonitor


var children: Array[RayCast3D]:
	get:
		return M.nightmare_getter(self, RayCast3D, &"RayCast3D")
@onready var label_2: Label = $"../../CanvasLayer/Control/Label2"
@export var emitter: FmodEventEmitter3D
var real_acc_dist: = 0.0
