extends Area3D
class_name InteractRay
var interactable: InteractComponent:
	set(value):
		if interactable and value != interactable:
			interactable.end_tween_alpha()
			if interactable.interacting: interactable.do_end_interact(); interact_end.emit(interactable)
			interactable.interact_exited.emit()
			if not value: interact_exited.emit(); interactable = value; return
			value.start_tween_alpha()
			interactable = value
		if not interactable and value:
			interactable = value
			value.start_tween_alpha()
			interact_entered.emit()
			interactable.interact_entered.emit()
var former_size := 0
@export var shaker_component: ShakerComponent3D
@export var center_marker: Control
@export var camera: PlayerCamera
const WEAK_SHAKE = preload("res://shakes/weak_shake.tres")
var interactables: Array[InteractComponent]
var point: Vector3 = Vector3.ZERO

signal interact_entered
signal interact_exited
signal interact_start
signal interact_end

func _physics_process(delta: float) -> void:
	var areas := get_overlapping_areas()
	if not areas.is_empty():
		var nr := 0
		var new_list = []
		var ars := get_overlapping_areas()
		ars = ars.filter(func(a: Area3D) -> bool: return a is InteractComponent)
		new_list = ars
		var highest_prior := -INF
		for col in new_list:
			highest_prior = maxi(col.prior, highest_prior)
		for collider in interactables:
			if not new_list.has(collider):
				interactables.erase(collider)
		for collider in new_list:
			if not interactables.has(collider):
				interactables.push_back(collider)
		interactables.sort_custom(sort_prior)
		var params := PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position - camera.global_basis.z * 4)
		params.collide_with_areas = true
		var exclude = params.exclude
		exclude.push_back(get_rid())
		params.exclude = exclude
		var res := get_world_3d().direct_space_state.intersect_ray(params)
		if res and interactables.size() > 1:
			interactables = interactables.filter(func(i: InteractComponent) -> bool: return i == res["collider"] or i.body and res["collider"] == i.body)
		if not interactables.is_empty():
			interactable = interactables.back()
		else: interactable = null
	if interactable:
		if Input.is_action_just_pressed("interact"): 
			interact_start.emit(interactable)
			interactable.do_interact()
			interactable.interact_entered.emit()
		elif Input.is_action_just_released("interact") and interactable.interacting:
			interact_end.emit(interactable)
			interactable.do_end_interact()
func spawn_text() -> void:
	var text := Label3D.new()
	text.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	text.text = "Interact!"
	text.no_depth_test = true
	text.pixel_size *= 5
	get_tree().root.get_children().back().add_child(text)
	var tween = create_tween().set_parallel(true)
	#text.global_position = get_collision_point(0)
	tween.tween_property(text, "position:y", 15.0, 2.0).as_relative()
	tween.tween_property(text, "modulate:a", 0.0, 1.0).set_delay(1.0)
	tween.tween_property(text, "outline_modulate:a", 0.0, 1.0).set_delay(1.0)
	tween.chain().tween_callback(text.queue_free)
func shake() -> void:
	shaker_component.shake(WEAK_SHAKE, ShakerComponent3D.ShakeAddMode.add, 1.0, 1.0, 10.0)

func distance_from_middle(a: InteractComponent, b: InteractComponent) -> bool:
	var d_a = camera.unproject_position(a.global_position)
	var d_b = camera.unproject_position(b.global_position)
	var dist_a := a.global_position.distance_to(global_position)
	var dist_b := b.global_position.distance_to(global_position)
	return d_a.distance_to(center_marker.position) < d_b.distance_to(center_marker.position) and dist_a < dist_b

func sort_prior(a: Area3D, b: Area3D) -> bool:
	return a.prior > b.prior
