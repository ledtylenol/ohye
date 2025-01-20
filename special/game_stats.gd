extends Resource
class_name GameStats

@export_storage var hor_travelled := 0.0
@export_storage var vert_travelled := 0.0
@export var autosave_time := 50.0
@export var completed_subway := false
@export_storage var read_start := false
@export_storage var lucky_number := 0
@export_storage var achievements: Dictionary = {}
@export_storage var playtime := 0.0
@export_storage var strawberries: Dictionary = {}
