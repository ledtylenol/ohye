@tool
extends RandomSpawnBrush
class_name RandomSpawnInteract
@export var off_sound: String
@export var on_sound: String
@export var detach_off := false
@export var detach_on := false
var off: FmodEventEmitter3D
var on: FmodEventEmitter3D
var i_c: InteractComponent
func _func_godot_apply_properties(props: Dictionary) -> void:
	super(props)
	off_sound = props["off_sound"]
	on_sound = props["on_sound"]
	detach_off = props["detach_off"]
	detach_on = props["detach_on"]
func make_area(c: MeshInstance3D):
	var shape = c.mesh.create_trimesh_shape()
	var col_shape := CollisionShape3D.new()
	col_shape.shape = shape
	i_c.add_child(col_shape)
func _ready() -> void:
	super()
	if not Engine.is_editor_hint():
		i_c = InteractComponent.new()
		for child: MeshInstance3D in M.nightmare_getter(self, MeshInstance3D, "MeshInstance3D"):
			make_area( child)
		add_child(i_c)
		if off_sound:
			off = FmodEventEmitter3D.new()
			off.event_name = off_sound
			off.preload_event = false
			i_c.interact_end.connect(play_off)
			off.auto_release = detach_off
			add_child(off)
		if on_sound:
			on = FmodEventEmitter3D.new()
			on.event_name = on_sound
			on.preload_event = false
			i_c.interact_start.connect(play_on)
			on.auto_release = detach_on
			add_child(on)

func play_off() -> void:
	if detach_off:
		off.reparent(get_tree().root)
	off.play()


func play_on() -> void:
	if detach_on:
		on.reparent(get_tree().root)
	on.play()
