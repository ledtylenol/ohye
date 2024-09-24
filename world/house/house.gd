extends Node3D
@export var music: Node
@export var house_area: Area3D
@export var down_area: Area3D
var in_area := 0
func _ready() -> void:
	music.play(1 << 2)
	if house_area:
		house_area.body_entered.connect(on_house)
		house_area.body_exited.connect(change)
	if down_area:
		down_area.body_entered.connect(on_down)
		down_area.body_exited.connect(change)
	Global.player.camera.environment = preload("res://world/house/house.tres")

func on_house(body: Node3D) -> void:
	in_area += 1
	if body is Player:
		music.change_song_parts(1 << 3)
func on_down(body: Node3D) -> void:
	in_area += 1
	if body is Player:
		music.change_song_parts((1 << 1) | 1)
func change(body: Node3D) -> void:
	in_area -= 1
	print(in_area)
	if not in_area:
		
		if body is Player:
			music.change_song_parts(1 | (1 << 2))
