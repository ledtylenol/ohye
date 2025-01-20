extends Area3D
class_name InteractComponent
@export var toggle_on_lose_focus := false
@export_multiline var what_text: String:
	set(value):
		if text: text.text = value
		what_text = value
		
@export var mesh: MeshInstance3D
@export var body: PhysicsBody3D
@export var prior := 1
const OUTLINE = preload("res://shaders/outline.tres")
var alpha := 0.0
var tween: Tween
@export var text: Label3D
var player: Node3D
var interacting := false
signal interact
signal interact_start
signal interact_end
@warning_ignore("unused_signal")
signal interact_entered
@warning_ignore("unused_signal")
signal interact_exited
func _ready() -> void:
	if mesh:
		mesh.mesh = mesh.mesh.duplicate(true)
		mesh.mesh.surface_get_material(0).next_pass = preload("res://shaders/outline.tres")
	if body:
		for collider: CollisionShape3D in body.get_children().filter(func(child) -> bool: return child is CollisionShape3D):
			var col = collider.duplicate()
			col.scale *= 1.1
			add_child(col)
	if text:
		text.modulate.a = 0
		text.outline_modulate.a = 0


func _physics_process(_delta: float) -> void:
	do_mesh()
	if not text: return
	if player:
		if body:
			text.global_position = body.global_position * 0.1 + player.global_position * 0.9
		else:
			text.global_position =get_parent().global_position * 0.1 + player.global_position * 0.9
		text.modulate.a = alpha
		text.outline_modulate.a = alpha
	else:
		if body:
			text.global_position = body.global_position
		else:
			text.global_position = get_parent().global_position
		text.modulate.a = 0.0
		text.outline_modulate.a = 0.0
func do_interact() -> void:
	interacting = true
	interact.emit()
	interact_start.emit()
func do_end_interact() -> void:
	interacting = false
	interact_end.emit()
func start_tween_alpha() -> void:

	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "alpha", 1.0, 0.4)
func end_tween_alpha() -> void:
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "alpha", 0.0, 0.4)

func do_mesh() -> void:
	if not mesh:
		return
	var n_p := mesh.mesh.surface_get_material(0).next_pass
	n_p.set_shader_parameter("alpha", alpha)
