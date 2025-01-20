extends Node
class_name AchievementSender

@export var achievement: Achievement
func _ready() -> void:
	get_parent().body_entered.connect(on_body)

func on_body(b: Node3D) -> void:
	if b is Player:
		AchievementManager.push_achievement(achievement)
