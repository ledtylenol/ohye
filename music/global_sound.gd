extends Node
@export var song_parts := 0
var timer := 0.0
var tweens: Array[Tween] = []
var playing := false:
	get: return $AudioStreamPlayer.playing
var stream_count: int:
	get: return $AudioStreamPlayer.stream.stream_count
func _ready() -> void:
	for i in stream_count + 1:
		tweens.push_back(null)
func _process(delta: float) -> void:
	timer += delta / Engine.time_scale
	if timer > 1.0:
		timer -= 1.0
		fix_song_parts()
func play(parts: int, repeat: bool = false) -> void:
	if (parts == song_parts) and not repeat:
		return
	song_parts = parts
	change_song_parts(parts)
	if not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()

func change_song_parts(new_parts: int) -> void:
	song_parts = new_parts
	var x := get_biggest_1_bit(new_parts)
	for i: int in range(0, x):
		
		if (new_parts >> i)& 1:
			fade_in(i)
		else:
			fade_out(i)

func get_biggest_1_bit(number: int) -> int:
	var i := 0
	while number:
		number >>= 1
		i += 1
	if i > 0:
		return i + 1
	return i

func fade_in(i: int) -> void:
	var tween := tweens[i]
	var stream = $AudioStreamPlayer.stream
	if tween:
		tween.stop()
	if stream.get_sync_stream_volume(i) < -1.0:
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tweens[i] = tween
		tween.tween_method(set_stream_volume.bind(i), -60.0, linear_to_db(1), 1.0)
func fade_out(i: int) -> void:
	var tween := tweens[i]
	var stream = $AudioStreamPlayer.stream
	if tween:
		tween.stop()
	if stream.get_sync_stream_volume(i) > -12.0:

		tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tweens[i] = tween
		tween.tween_method(set_stream_volume.bind(i), 0.0 , -60.0, 1.0)
func set_stream_volume(v: float, which: int) -> void:
	var sync_stream :AudioStreamSynchronized= $AudioStreamPlayer.stream as AudioStreamSynchronized
	sync_stream.set_sync_stream_volume(which, v)
func get_stream_volume(which: int) -> float:
	var sync_stream :AudioStreamSynchronized= $AudioStreamPlayer.stream as AudioStreamSynchronized
	return sync_stream.get_sync_stream_volume(which)

func fix_song_parts() -> void:
	var x := get_biggest_1_bit(song_parts)
	for i: int in range(0, x):
		
		if (song_parts >> i)& 1:
			fade_in(i)
		else:
			fade_out(i)
