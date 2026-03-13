extends RaytracedAudioPlayer3D

func _ready() -> void:
	Map.map_node_spawned.connect(play)
