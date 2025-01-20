extends Area3D

class_name CollectibleStrawberry

@export var id := 0
@export var sound: FmodEventEmitter3D
@onready var model: Node3D = $StrawberryPurple
func _ready() -> void:
	if Global.game_stats.strawberries.has(id):
		queue_free()
	body_entered.connect(on_body_entered)

func on_body_entered(b: Node3D) -> void:
	if b is Player:
		Global.game_stats.strawberries[id] = Global.game_stats.playtime
		play_disable_anim()
		set_deferred("monitoring", false)

func play_disable_anim() -> void:
	if sound: sound.play()
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(model, "scale", Vector3.ZERO, 1.0)
	tween.tween_callback(queue_free)
