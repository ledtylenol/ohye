extends Node
var saving: = false
func _process(delta: float) -> void :
	if Input.is_action_just_pressed("save") and not saving:
		saving = true
		await get_tree().physics_frame
		await get_tree().physics_frame
		var p = PackedScene.new()
		p.pack(get_tree().current_scene)
		ResourceSaver.save(p, "user://save.res")
		print("loaded")
		saving = false
	if Input.is_action_just_pressed("load"):
		if FileAccess.file_exists("user://save.res"):
			var file = ResourceLoader.load("user://save.res", "", ResourceLoader.CACHE_MODE_REPLACE_DEEP)
			get_tree().change_scene_to_packed.call_deferred(file)
