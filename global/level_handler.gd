@tool
extends Node


@export var levels: Dictionary[String, bool] = {}
@export var edges: Array[Edge] = []
@export var edge_dict: Dictionary[String, Edge] = {}
@export_tool_button("reset") var reset_button = reset_levels
@export_tool_button("reset_edges") var reset_edges_button = reset_edges
@export var queue: Array[String] = []

var are_files_loaded := true
signal files_loaded
func _ready() -> void:
	if not Engine.is_editor_hint(): return
	reset_edges()
	reset_levels()
func reset_edges() -> void:
	var dir := DirAccess.open("res://special/edges")
	if not dir:
		push_error("something went even more horribly wrong")
		return
	edges.clear()
	for file_name in dir.get_files():
		var ext := file_name.get_extension()
		if ext == "tres" or ext == "res":
			var path := "res://special/edges/%s" % file_name
			if not ResourceLoader.exists(path): continue
			ResourceLoader.load_threaded_request(path)
			queue.push_back(path)
			are_files_loaded = false
func _physics_process(delta: float) -> void:
	var remove_queue: PackedStringArray = []
	for file in queue:
		if ResourceLoader.load_threaded_get_status(file) == ResourceLoader.THREAD_LOAD_LOADED:
			var edge = ResourceLoader.load_threaded_get(file)
			print("found edge from %s to %s with change %.2f" % [edge.from, edge.to, edge.chance])
			edges.push_back(edge)
			remove_queue.push_back(file)
			edge_dict[file.get_file().trim_suffix(".tres")] = edge
	for file in remove_queue:
		queue.erase(file)
	if not are_files_loaded and queue.is_empty():
		are_files_loaded = true
		files_loaded.emit()
func reset_levels() -> void:
	print("resetting")
	
	var dir := DirAccess.open("res://world")
	if not dir:
		push_error("something went horribly wrong")
		return
	dir.list_dir_begin()
	levels.clear()
	for file_name in dir.get_directories():
		print("Found directory: " + file_name)
		levels[file_name] = true
	get_string()
func get_string() -> String:
	return ",".join(levels.keys())
func get_edge_string() -> String:
	return ",".join(edge_dict.keys())
