extends Node3D
class_name PortalLoader
@export_file("*.tscn") var scene: String
var next_scene: PackedScene
var status:
	get:
		return ResourceLoader.load_threaded_get_status(scene)
var children: Array[Area3D]
@export var active := false:
	set = set_active
func _ready() -> void:
	if scene.is_empty():
		push_warning("scene cannot be empty")
		queue_free()
		return
	if not ResourceLoader.exists(scene):
		push_warning("file does not exist at path: %s" % scene)
		queue_free()
		return
	children = M.nightmare_getter(self, Area3D, &"Area3D")
	for child in children:
		child.body_entered.connect(on_body_entered)
	if active:
		request_load()
func _process(_delta: float) -> void:
	if status == ResourceLoader.THREAD_LOAD_LOADED and not next_scene:
		next_scene = ResourceLoader.load_threaded_get(scene)

func try_load() -> void:
	if not active or not next_scene:
		return
	Transition.change_scene(next_scene)
func request_load() -> void:
	ResourceLoader.load_threaded_request(scene)

func on_body_entered(body: Node3D) -> void:
	if body is Player:
		try_load()

func set_active(v: bool) -> void:
	if not active and v:
		request_load()
	active = v
