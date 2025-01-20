extends Node
class_name SceneLoader
@export var scene_type: Scene
var scene: String
@export var delay := 0.2
@export var load_immediately := true
var next_scene: PackedScene
var status:
	get:
		return ResourceLoader.load_threaded_get_status(scene)
@export var can_change := false
func _ready() -> void:
	scene = scene_type.get_level()
	if not ResourceLoader.exists(scene):
		push_warning("file does not exist at path: %s" % scene)
		queue_free()
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	if load_immediately:
		ResourceLoader.load_threaded_request(scene)

func _process(_delta: float) -> void:
	if status == ResourceLoader.THREAD_LOAD_LOADED and not next_scene:
		print("loaded")
		next_scene = ResourceLoader.load_threaded_get(scene)

func try_load() -> void:
	if not can_change:
		return
	if delay:
		await get_tree().create_timer(delay).timeout
	if not next_scene:
		next_scene = ResourceLoader.load_threaded_get(scene)
	Transition.change_scene(next_scene)
func request_load() -> void:
	ResourceLoader.load_threaded_request(scene)
