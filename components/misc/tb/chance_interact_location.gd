@tool
extends RandomSpawnInteract
class_name RandomSpawnScene
var sc_l: SceneLoader
@export var scene: String
func _func_godot_apply_properties(props: Dictionary) -> void:
	super(props)
	scene = "res://world/%s.tscn" % props["scene"]

func _ready() -> void:
	super()
	if not Engine.is_editor_hint():
		sc_l = SceneLoader.new()
		sc_l.can_change = true
		sc_l.load_immediately = true
		sc_l.scene_type = SimpleScene.new()
		sc_l.scene_type.scene = scene
		add_child(sc_l)
		i_c.interact_end.connect(sc_l.try_load)
