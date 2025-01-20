extends CanvasLayer


var ACHIEVEMENT = load("res://special/achievements/achievement.tscn")

func push_achievement(a: Achievement) -> void:
	if a in Global.game_stats.achievements:
		return
	Global.game_stats.achievements[a] = Global.game_stats.playtime
	Global.save()
	var acc := ACHIEVEMENT.instantiate() as AchievementHolder
	acc.texture.texture = a.sprite
	acc.description.set_bbcode(a.description)
	acc.title.set_bbcode(a.name)
	acc.playtime.set_bbcode("time of get: " + M.format_time(Global.game_stats.playtime))
	add_child(acc)
