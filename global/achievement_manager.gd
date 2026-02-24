extends CanvasLayer


var ACHIEVEMENT = load("res://special/achievements/achievement.tscn")
@onready var control: Control = $Control

func push_achievement(a: Achievement) -> void:
	if a.name in Global.game_stats.achievements:
		return

	Global.game_stats.achievements[a.name] = Global.game_stats.playtime
	Global.save()
	var acc := ACHIEVEMENT.instantiate() as AchievementHolder
	acc.texture.texture = a.sprite
	acc.description.set_bbcode(a.description)
	acc.title.set_bbcode(a.name)
	acc.playtime.set_bbcode("time of get: " + M.format_time(Global.game_stats.playtime))
	control.add_child(acc)

	acc.sound.play()
