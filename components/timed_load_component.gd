extends Node
class_name SceneLoader
@export_file("*.tscn") var scene: String
@export var delay := 0.2
var next_scene: PackedScene
var status:
	get:
		return ResourceLoader.load_threaded_get_status(scene)
@export var can_change := false
func _ready() -> void:
	if scene.is_empty():
		push_warning("scene cannot be empty")
		queue_free()
		return
	if not FileAccess.file_exists(scene):
		push_warning("file does not exist at path: %s" % scene)
		queue_free()
		return
	ResourceLoader.load_threaded_request(scene)

func _process(delta: float) -> void:
	if status == ResourceLoader.THREAD_LOAD_LOADED and not next_scene:
		next_scene = ResourceLoader.load_threaded_get(scene)

func try_load() -> void:
	if not can_change:
		return
	await get_tree().create_timer(delay).timeout
	get_tree().call_deferred("change_scene_to_packed",next_scene)
