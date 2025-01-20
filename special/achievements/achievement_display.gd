extends Node3D

@export var achievement: Achievement
@onready var sprite: Sprite3D = $Sprite
@onready var time_label: Label3D = $"Time label"

func _ready() -> void:
	if not Global.game_stats.achievements.has(achievement):
		return
	visible = true
	sprite.texture = achievement.sprite
	time_label.text = "time: %s" % M.format_time(Global.game_stats.achievements[achievement])
	time_label.position.y += sprite.get_aabb().size.y + 0.5
