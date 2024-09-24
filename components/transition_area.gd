extends Area3D
class_name TransitionArea

@export var active := false:
	set(value):
		active = value
		set_deferred("monitoring", active)

@export_file("*.tscn") var scene: String
var next_scene: PackedScene
var status:
	get:
		var x = []
		ResourceLoader.load_threaded_get_status(scene, x)
		return x[0]

func _ready() -> void:
	ResourceLoader.load_threaded_request(scene)
	body_entered.connect(on_body_entered)
	set_deferred("monitoring", active)
func _process(delta: float) -> void:
	collision_mask = 1 << 3
	if status >= 1.0 and not next_scene:
		next_scene = ResourceLoader.load_threaded_get(scene)
func on_body_entered(body: Node3D) -> void:
	if body is not Player:
		return
	get_tree().call_deferred("change_scene_to_packed",next_scene)
