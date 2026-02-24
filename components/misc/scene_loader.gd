extends Node
class_name SceneLoader
@export var scene_type: Scene
var scene: String:
	set(value):
		if next_scene and scene != value:
			next_scene = null
		scene = value
@export var delay := 0.2
@export var load_immediately := true
var next_scene: PackedScene
var status:
	get:
		if scene.to_lower() == "nothing":
			return ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
		return ResourceLoader.load_threaded_get_status(scene)
@export var can_change := false
func _ready() -> void:
	if Engine.is_editor_hint():return
	process_mode = Node.PROCESS_MODE_ALWAYS
	if load_immediately:
		request_load()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():return
	if status == ResourceLoader.THREAD_LOAD_LOADED and not next_scene and scene.to_lower() != "nothing":
		next_scene = ResourceLoader.load_threaded_get(scene)
	var p = []
	ResourceLoader.load_threaded_get_status(scene, p)
	if Input.is_action_just_pressed("jump"):
		print(next_scene)
func try_load(do_reset := true) -> void:
	if scene.to_lower() == "nothing":
		request_load()
		return
	if not can_change:
		return
	if delay:
		await get_tree().create_timer(delay).timeout
	if not next_scene:
		next_scene = ResourceLoader.load_threaded_get(scene)
	Transition.change_scene(next_scene, do_reset)
func request_load() -> void:
	scene = scene_type.get_level()
	var pos = "" if not get_parent() or not "global_position" in get_parent() else " at %s" % get_parent().global_position
	print("%s has been requested for loading%s!" % [scene, pos])
	if scene.to_lower() != "nothing":
		ResourceLoader.load_threaded_request(scene)
