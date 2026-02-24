extends Node3D
@onready var area: Area3D = $ReverbChange
var t := 0.0
var tick := false
var current_phase := 0.0
var tween: Tween
var in_sight := false:
	set(v):
		if v != in_sight:
			if !v:
				start_sound()
			else:
				stop_sound()
		
		in_sight = v
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var directional_light_3d: DirectionalLight3D = $DirectionalLight3D
@onready var crickerts: FmodEventEmitter3D = $ReverbChange/Crickerts
@onready var rigid_body_3d: RigidBody3D = $RigidBody3D
@onready var strawberry: CollectibleStrawberry = $RigidBody3D/Strawberry
@onready var crack: FmodEventEmitter3D = $RigidBody3D/Crack
@export var time_curve: Curve
@onready var ding_1: FmodEventEmitter3D = $Ding1
@onready var ding_2: FmodEventEmitter3D = $Ding2
@onready var ding_3: FmodEventEmitter3D = $Ding3
@onready var area_3d: Area3D = $Area3D
@onready var schizophrenia: Schizophrenia = $Schizophrenia
@onready var glimmer: FmodEventEmitter3D = $Schizophrenia/FmodEventEmitter3D

var had_strawb := false
func _ready() -> void:
	GlobalObserver.unvanish.connect(on_unvanish)
	area.area_entered.connect(on_enter)
	area_3d.area_entered.connect(func(a): if a is SoundMonitor:GlobalObserver.unvanish.emit(2))
	area.area_exited.connect(on_exit)
	if Global.is_event_active(Global.Event.NIGHT):
		current_phase = 1.0
	else:
		var time = Time.get_datetime_dict_from_system()
		var hour = time["hour"]
		var minute = time["minute"]
		current_phase = time_curve.sample(hour + minute / 60.0)
	directional_light_3d.light_energy = 1.0 -  current_phase
	world_environment.environment.adjustment_contrast = lerpf(1.0, 15.0, current_phase)
	world_environment.environment.adjustment_saturation = lerpf(1.0, 0.22, current_phase)

	if Global.game_stats.strawberries.has(strawberry.id):
		rigid_body_3d.queue_free()
		had_strawb = true
func _process(delta: float) -> void:
	in_sight = schizophrenia.in_sight
	if had_strawb and tick:
		current_phase = 0.0
		tick = false
		crickerts.volume = 0.0
		var tween2: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
		tween2.tween_property(world_environment.environment, "adjustment_contrast", 1.0, 2.0)
		tween2.tween_property(world_environment.environment, "adjustment_saturation", 0.05, 2.0)
		tween2.tween_property(directional_light_3d, "light_energy", 0.45, 2.0)
		area.area_entered.disconnect(on_enter)
		GlobalObserver.unvanish.emit(1)
	t += float(tick) * delta
	if current_phase > 0.7:
		crickerts.set_parameter("Heat1", minf(t / 30.0, 1.0))
		if minf(t / 30.0, 1.0) >= 1.0:
			current_phase = 0.0
			tick = false
			crickerts.volume = 0.0
			t = 0.0
			drop_berry()
			area.area_entered.disconnect(on_enter)
func on_enter(_a) -> void:
	if _a is not SoundMonitor or not schizophrenia.in_sight: return
	tick = true
	if current_phase > 0.7:
		crickerts.set_parameter("Charge", 1.0)

func on_exit(_a) -> void:
	if _a is not SoundMonitor or not schizophrenia.in_sight: return

	tick = false
	t = 0.0
	if current_phase > 0.7:
		crickerts.set_parameter("Charge", 0.0)

func drop_berry() -> void:
	print('berry dropped')
	rigid_body_3d.visible = true
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	tween.tween_property(world_environment.environment, "adjustment_contrast", 1.0, 2.0)
	tween.tween_property(world_environment.environment, "adjustment_saturation", 0.05, 2.0)
	tween.tween_property(directional_light_3d, "light_energy", 0.45, 2.0)
	rigid_body_3d.freeze = false
	rigid_body_3d.apply_torque_impulse(180 * Vector3(Global.randf_range(-3, 3), Global.randf_range(-1, 1), Global.randf_range(-1, 1)))
	crack.play()
	GlobalObserver.unvanish.emit(1)

func on_unvanish(id: int) -> void:
	match id:
		1: ding_1.play()
		2: ding_2.play()
		3: ding_3.play()

func start_sound() -> void:
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(glimmer, "volume", 1.0, 1.0)
func stop_sound() -> void:
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(glimmer, "volume", 0.0, 1.0)
	
