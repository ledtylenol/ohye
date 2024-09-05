extends Area3D
class_name InteractComponent
@export var show_text := false
@export_multiline var what_text: String
@export var mesh: MeshInstance3D
@export var body: PhysicsBody3D

const OUTLINE = preload("res://shaders/outline.tres")
signal collision_entered
signal collision_exited
signal interact
signal removed
var alpha := 0.0
var tween: Tween
var text: Label3D
var player: Node3D
func _ready() -> void:
	if mesh:
		mesh.mesh.surface_get_material(0).next_pass = OUTLINE.duplicate()
		collision_entered.connect(start_tween_alpha)
		collision_exited.connect(end_tween_alpha)

	if body:
		for collider: CollisionShape3D in body.get_children().filter(func(child) -> bool: return child is CollisionShape3D):
			var col = collider.duplicate()
			add_child(col)
		var pos = body.global_position
		if show_text:
			text = Label3D.new()
			text.no_depth_test = true
			text.text = what_text
			text.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			add_child(text)
			text.global_position = pos
			text.modulate.a = 0
			text.outline_modulate.a = 0
	for sig in [collision_entered, collision_exited, interact]:
		sig.connect(print.bind("AAAA %s" % sig.get_name()))

func _physics_process(delta: float) -> void:
	do_mesh()

	if player and text:
		text.global_position = body.global_position * 0.1 + player.global_position * 0.9
		text.modulate.a = alpha
		text.outline_modulate.a = alpha
	elif text: 
		text.global_position = body.global_position
		text.modulate.a = 0.0
		text.outline_modulate.a = 0.0

func start_tween_alpha(_p) -> void:
	player = _p
	if tween: tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "alpha", 1.0, 0.4)
func end_tween_alpha(_p) -> void:
	player = null
	if tween: tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "alpha", 0.0, 0.4)

func _exit_tree() -> void:
	removed.emit()

func do_mesh() -> void:
	if not mesh:
		return
	var n_p := mesh.mesh.surface_get_material(0).next_pass
	n_p.set_shader_parameter("alpha", alpha)
