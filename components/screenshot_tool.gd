extends Node
class_name ScreenshotTool
signal save_finished()
signal screenshot_captured()
# keep track of tasks in a property, because we cannot read task_id from the lambda before add_task has finished
var tasks: Array[int] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _init() -> void:
	save_finished.connect(func() -> void:
		# take the oldest finished task
		var task_id: int = tasks.pop_front()
		WorkerThreadPool.wait_for_task_completion(task_id)
	)

func take_screenshot(path: String) -> void:
	if !DirAccess.dir_exists_absolute(path + "screenshots"):
		var dir: DirAccess = DirAccess.open(path); dir.make_dir("screenshots")
	var screenshots_folder: String = path + "screenshots"
	await RenderingServer.frame_post_draw
	var screenshot: Image = get_viewport().get_texture().get_image()
	screenshot_captured.emit.call_deferred()
	var task_id: int = WorkerThreadPool.add_task(func() -> void:
		var datetime: Dictionary = Time.get_datetime_dict_from_system()
		var imgPath: String = screenshots_folder.path_join("Screenshot_%04d-%02d-%02d_%02d-%02d-%02d.webp" % [datetime.year,datetime.month,datetime.day,datetime.hour,datetime.minute,datetime.second])
		screenshot.save_webp(imgPath)
		# notify task completion with call_deferred to clean it up on the main thread
		save_finished.emit.call_deferred()
		print("screen shat")
	)
	tasks.append(task_id)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("screenshot"):
		if Engine.is_editor_hint() || OS.has_feature("editor"):
			take_screenshot("user://")
		else:
			take_screenshot(OS.get_executable_path().get_base_dir() + "/")
