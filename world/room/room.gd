extends Node3D
@export var area_3d: Area3D
@export var music2: AudioStreamPlayer
@export var music3: AudioStreamPlayer
@export var area_3d2: Area3D
@export var light1: OmniLight3D
@export var light2: OmniLight3D

var transed := false
var min := 1.0
var max := 1.3
var t := 0.0
func _ready() -> void:
	area_3d.body_entered.connect(on_player)
	area_3d2.body_entered.connect(swap)
	$room2/GPUParticles3D.emitting = false
func _process(delta: float) -> void:
	t += delta
	$room2/GPUParticles3D.rotate_y(delta  * PI / 3)
	if t > 4:
		$room2/GPUParticles3D/GPUParticlesAttractorSphere3D.rotate_y(PI * randf())
		t = 0.0
func on_player(body: Node3D) -> void:
	var player := body as Player
	if player and not transed:
		transed = true
		
		$AnimationPlayer.play("woah")
		return
		var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
		tween.tween_property(light1, "light_color", Color.BLACK, 1.0)
		
		tween.chain().tween_callback(func() -> void: light1.light_negative = true)
		tween.tween_property(light1, "light_color", Color.WHITE_SMOKE, 15.0)
		tween.chain().tween_callback(swap_to_midnight)
		tween.chain().tween_callback(enable_emitter.bind(1)).set_delay(16.0)
		tween.tween_property(light1, "omni_range", 150.0, 20.0)
		tween.chain().tween_callback(enable_emitter.bind(2))
		tween.chain().tween_property(self, "min", 1.0, 20.0)
		tween.tween_property(self, "max", 1.3, 20.0)
		#tween.tween_property($OmniLight3D, "omni_attenuation", 0.0, 18.0)

		
		tween.chain().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN).tween_property(light1, "omni_attenuation", -0.3, 20.0)
		tween.chain().tween_callback(enable_emitter.bind(4))
		tween.chain().tween_property(light2, "light_energy", 5.0, 1.0)
		tween.tween_property(light1, "omni_range", 2.0, 1.0)
		#tween.chain().tween_callback($room2/OmniLight3D2/Area3D/CollisionShape3D.set_deferred.bind("disabled", false))
		#tween.tween_callback(music3.play)

func kill_player() ->  void:
	Global.player.hurtbox.hit.emit(null, 1)
	await get_tree().create_timer(1).timeout
	kill_player()
func swap(b: Node3D) -> void:
	if b is Player:
		music3.play()
		music2.stop()
		var r3_pos = $room3.global_position
		$room3.global_position = $room2.global_position
		$room2.global_position = r3_pos
		$CanvasLayer/Label.text = ""
func enable_emitter(i: int) -> void:
	$room2/GPUParticles3D.emitting = i & 1 != 0
	$room2/GPUParticles3D2.emitting = i & 2 != 0
	$room2/GPUParticles3D2.emitting = i & 4 != 0

func swap_to_midnight() -> void:
	music2.get_stream_playback().switch_to_clip_by_name("Midnight")
