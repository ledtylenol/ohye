extends Node

var stats: PlayerStats2d:
	get:
		if player: return player.stats
		return PlayerStats2d.new()
var player: Player2D


func save_save(i: int) -> void:
	if not player:
		return
	ResourceSaver.save(stats, "user://save%s.res" % i)

func load_save(i: int) -> void:
	if not player:
		return
	var new_save: PlayerStats2d = ResourceLoader.load("user://save%s.res" % i)
	if not new_save:
		new_save = PlayerStats2d.new()
	player.stats = new_save
