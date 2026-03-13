@tool
extends Level

@export var wind: AudioStreamPlayer
@export var music: FmodEventEmitter3D
@export var noise: NoiseEntity
@export var achievement: Achievement
@export var player: Player
var eligible := false
func _ready() -> void:
	if Engine.is_editor_hint():return
	#var tween := create_tween()
	#tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	#tween.tween_property(wind, "volume_linear", wind.volume_linear, 5.0).from(0.0)
	Music.change_song(music)
	noise.activated.connect(on_activation)
	noise.hitbox.hit.connect(toggle_on)
	player.just_landed.connect(toggle_off)
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():return
	if player.position.y < 55 and eligible and not Global.game_stats.has_achievement(achievement.name):
		print("PUSHY PUSH")
		AchievementManager.push_achievement(achievement)
		eligible = false
	if Global.player.position.y < 35:

		Transition.reload_scene()


func on_activation() -> void:
	Music.volume = 0.0

func toggle_off() -> void:
	eligible = false
func toggle_on() -> void:
	eligible = true
