extends RayCast3D
class_name InteractRay
var interactable: InteractComponent
@export var shaker_component: ShakerComponent3D
const WEAK_SHAKE = preload("res://shakes/weak_shake.tres")
var engine_tween: Tween
signal interact_entered
signal interact_exited
signal interact_start
signal interact_end
func _ready() -> void:
	interact_entered.connect(tween_time)
	interact_exited.connect(tween_out)
	interact_end.connect(tween_out)
func _physics_process(delta: float) -> void:
	if engine_tween:
		engine_tween.set_speed_scale(1.0/Engine.time_scale)
	if is_colliding() and get_collider() is InteractComponent:
		if not interactable:
			interactable = get_collider()
			interactable.collision_entered.emit(self)
			interactable.interact.connect(spawn_text)
			interactable.removed.connect(func() -> void:
				interact_exited.emit()
				interactable = null)
			#interactable.interact.connect(shake)
			interact_entered.emit()
	else:
		if interactable != null:
			interactable.collision_exited.emit(self)
			interactable.interact.disconnect(spawn_text)
			#interactable.interact.disconnect(shake)
			interact_exited.emit()
			interactable = null
	if interactable != null:
		if Input.is_action_just_pressed("interact"): interactable.interact.emit(); interact_start.emit()
		elif Input.is_action_just_released("interact"):interact_end.emit()
func spawn_text() -> void:
	var text := Label3D.new()
	text.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	text.text = "Interact!"
	text.no_depth_test = true
	text.pixel_size *= 5
	get_tree().root.get_children().back().add_child(text)
	var tween = create_tween().set_parallel(true)
	text.global_position = get_collision_point()
	tween.tween_property(text, "position:y", 15.0, 2.0).as_relative()
	tween.tween_property(text, "modulate:a", 0.0, 1.0).set_delay(1.0)
	tween.tween_property(text, "outline_modulate:a", 0.0, 1.0).set_delay(1.0)
	tween.chain().tween_callback(text.queue_free)
func shake() -> void:
	shaker_component.shake(WEAK_SHAKE, ShakerComponent3D.ShakeAddMode.add, 1.0, 1.0, 10.0)
	Global.boing()

func tween_time() -> void:
	if engine_tween: engine_tween.stop()
	engine_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	engine_tween.set_speed_scale(1.0/Engine.time_scale)
	engine_tween.tween_property(Engine, "time_scale", 0.05, 0.2)
func tween_out() -> void:
	if engine_tween: engine_tween.stop()
	engine_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	engine_tween.set_speed_scale(1.0/Engine.time_scale)
	engine_tween.tween_property(Engine, "time_scale", 1.0, 0.5)
