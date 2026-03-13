extends FmodEventEmitter3D


func change_song(event: FmodEventEmitter3D) -> bool:
	var was_different :=   event_name != event.event_name
	if was_different:
		stop()
		event_name = event.event_name
		play()
	volume = event.volume
	return was_different
