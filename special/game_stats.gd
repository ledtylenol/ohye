extends Resource
class_name GameStats

@export_storage var hor_travelled := 0.0
@export_storage var vert_travelled := 0.0
@export_storage var first_played := Time.get_datetime_string_from_system()
@export_storage var last_played: String
@export var autosave_time := 50.0
@export var completed_subway := false
@export_storage var read_start := false
@export_storage var lucky_number := 0
@export_storage var achievements: Dictionary = {}
@export_storage var playtime := 0.0
@export_storage var strawberries: Dictionary = {}
@export_storage var rng_state := 0

func has_achievement(a: String) -> bool:
	return achievements.has(a)
static func from_json(d: Dictionary) -> GameStats:
	var s := GameStats.new()
	
	s.hor_travelled = d.hor_travelled
	s.vert_travelled = d.vert_travelled
	s.autosave_time = d.autosave_time
	s.completed_subway = d.completed_subway
	s.read_start = d.read_start
	s.lucky_number = d.lucky_number
	s.achievements = d.achievements
	s.playtime = d.playtime
	s.strawberries = d.strawberries
	s.rng_state = d.rng_state
	s.first_played = d.first_played
	s.last_played = d.last_played
	return s

func to_json() -> String:
	var d: Dictionary = {}
	d.hor_travelled = self.hor_travelled
	d.vert_travelled = self.vert_travelled
	d.playtime = self.playtime
	d.first_played = self.first_played
	d.last_played = self.last_played
	d.autosave_time = self.autosave_time
	d.completed_subway = self.completed_subway
	d.read_start = self.read_start
	d.lucky_number = self.lucky_number
	d.rng_state = self.rng_state
	d.achievements = self.achievements
	d.strawberries = self.strawberries
	return JSON.stringify(d, "\t", false)
