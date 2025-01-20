extends Control
@onready var rich_text_animation: RichTextAnimation = $RichTextAnimation

@onready var click: FmodEventEmitter3D = $Click
@onready var finishe: FmodEventEmitter3D = $Finishe
@onready var song: FmodEventEmitter3D = $Song
@onready var sfx_slider: HSlider = $GridContainer/HBoxContainer/HSlider
@onready var music_slider: HSlider = $GridContainer/HBoxContainer2/HSlider
@onready var start_button: Button = $GridContainer/StartButton
@onready var knock: FmodEventEmitter3D = $Knock

@export_multiline var texts: Array[String]
var markers = {
	"Pause": func() -> void:
		song.paused = true
}
var active := true
var current := 0:
	set(value):
		current = value
var current_size := 1.0:
	set(value):

		current_size = value
var can_adv := true
var tween: Tween
@onready var initial_size := Global.window_size
signal finished
func get_time_str(x: M.Period) -> String:
	match x:
		M.Period.NOON: return "during such a [rainbow]colorful[] noon"
		M.Period.EVENING: return "now, during this [shake]amazing[] evening"
		M.Period.AFTERNOON: return "now, on this [wave]beautiful[] afternoon"
		M.Period.NIGHT: return "now, at this [sin]soothing[] night time"
		M.Period.MORNING: return "during such an [shake][rainbow]incredible[][] morning"
		_: return "at this forbidden hour"
func start() -> void:
	print("A")
	if Global.game_stats.read_start:
		await get_tree().physics_frame
		finished.emit()
		queue_free()
	else:
		for i in texts.size():
			var text := texts[i]
			texts[i] = text.replace("today", get_time_str(M.get_time()))
		$GridContainer.visible = false
		$GridContainer.mouse_filter = MOUSE_FILTER_IGNORE
		song.play()
		rich_text_animation.on_character.connect(on_char)
		rich_text_animation.anim_finished.connect(finish)
		rich_text_animation.hold_started.connect(enable_adv)
		rich_text_animation.hold_finished.connect(disable_adv)
		rich_text_animation.on_bookmark.connect(on_bookmark)
		rich_text_animation.on_stars_started.connect(on_star)
		rich_text_animation.set_progress(0)
		rich_text_animation.set_bbcode(texts[current])
		song.timeline_marker.connect(on_marker)
func _ready() -> void:
	sfx_slider.value_changed.connect(on_sfx)
	music_slider.value_changed.connect(on_music)
	start_button.pressed.connect(start)
	sfx_slider.value = Global.game_settings.sfx_volume
	music_slider.value = Global.game_settings.music_volume
func on_sfx(v: float) -> void:
	FmodServer.get_bus("bus:/Sfx").volume = v

func on_music(v: float) -> void:
	FmodServer.get_bus("bus:/Music").volume = v
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and can_adv:
		print("ADV")
		rich_text_animation.advance()
func on_char(_i: int) -> void:
	click.play_one_shot()
func _process(_delta: float) -> void:
	if song["fmod_parameters/Active"] == 1:
		song["fmod_parameters/Active"] = 0
func finish() -> void:
	current += 1
	if current >= texts.size():
		active = false
		return
	rich_text_animation.set_bbcode(texts[current])
	finishe.play()
func enable_adv() -> void:
	print('adv start')
	can_adv = true

func disable_adv() -> void:
	print('adv stop')
	can_adv = false
func on_marker(m: Dictionary) -> void:
	if markers.has(m["name"]):
		markers[m["name"]].call()
func on_bookmark(t: String) -> void:
	if t == "resume":
		song["fmod_parameters/Active"] = 1
		song.paused = false 
	if t == "fade":
		tween_finish()
	if t == "mute":
		click.volume = 0.0
		
	if t == "unmute":
		click.volume = 0.7
func tween_finish() -> void:
	Global.game_stats.read_start = true
	Global.save()
	finished.emit()
	if tween: tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "modulate:a", 0.0, 5.0)
	tween.parallel().tween_property(song, "volume", 0.0, 5.0)
	tween.tween_callback(queue_free)
func on_star(s: String) -> void:
	if s == "knock":
		knock.volume = 1
		knock.play_one_shot()
