extends Node
class_name AchievementSender

@export var achievement: Achievement
@export var sound: Node
func _ready() -> void:
	get_parent().body_entered.connect(on_body)

func on_body(b: Node3D) -> void:
	if b is Player:
		if Global.game_stats.has_achievement(achievement.name): return
		print(sound)
		AchievementManager.push_achievement(achievement)
		sound.play()
