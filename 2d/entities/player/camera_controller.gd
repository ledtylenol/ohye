extends Area2D
class_name CameraController

@export var player: Player2D
@export var camera: Camera2D
@export var collider: CollisionShape2D
var areas: Array[CameraNode]
var pos:
	get:
		if not areas.is_empty():
			return areas.back().global_position
		return player.global_position
var target_zoom:
	get:
		if not areas.is_empty():
			return areas.back().zoom
		elif player.velocity.length() > 1000.0:
			return sqrt(1000.0 / player.velocity.length())
		else: return 1.0
func _ready() -> void:
	collision_mask = 0b100000000
	if not camera: 
		print("no camera")
		queue_free()
	area_entered.connect(on_area_entered)
	area_exited.connect(on_area_exited)
	var p_col = collider.duplicate()
	add_child(p_col)
func _process(delta: float) -> void:
	var w := 5.0 if not areas.is_empty() else 15.0 if player.state != player.DASHING else 35.0
	camera.global_position = M.smooth_nudge(camera.global_position, pos, w, delta)
	camera.zoom = M.smooth_nudge(camera.zoom, Vector2(target_zoom, target_zoom), 5.0, delta)
func on_area_entered(area: Area2D):
	var cam_n = area as CameraNode
	if cam_n and not areas.has(cam_n):
		areas.append(cam_n)
func on_area_exited(area: Area2D):
	var cam_n = area as CameraNode
	if cam_n and areas.has(cam_n):
		areas.erase(cam_n)
