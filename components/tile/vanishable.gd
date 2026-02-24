@tool
extends SoundTile
class_name Vanishable

@export var id := 0
@export var collidable := false:
	set(value):
		collision_layer = int(value)
		collidable = value
@export var viewable := false:
	set(value):
		visible = value
		viewable = value
func _ready() -> void:
	if  Engine.is_editor_hint():
		return
	GlobalObserver.vanish.connect(on_vanish)
	GlobalObserver.unvanish.connect(on_unvanish)
func _func_godot_apply_properties(props: Dictionary) -> void:
	super(props)
	print(props)
	collidable = props["Collidable"]
	viewable = props["Visible"]
	id = props["id"]
	print(id)

func on_vanish(g_id: int) -> void:
	prints(g_id, id)
	if g_id != id:
		return
	viewable = false
	collidable = false

func on_unvanish(g_id: int) -> void:
	prints(g_id, id)
	if g_id != id:
		return
	viewable = true
	collidable = true
