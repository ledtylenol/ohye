extends Area3D
class_name TransitionArea

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
	set_deferred("monitoring", false)
func _process(delta: float) -> void:
	collision_mask = 1 << 3
	if Global.active_enemy_count == 0 and not monitoring:
		set_deferred("monitoring", true)
	if status >= 1.0 and not next_scene:
		next_scene = ResourceLoader.load_threaded_get(scene)
func on_body_entered(body: Node3D) -> void:
	print("ASDf")
	if body is not Player:
		return
	get_tree().call_deferred("change_scene_to_packed",next_scene)
