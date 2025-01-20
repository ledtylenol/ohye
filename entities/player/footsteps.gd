extends FmodEventEmitter3D
@export var player: Player
var is_ready: = false
func _ready() -> void :
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	is_ready = true
func play_thing() -> void :
	if not is_ready or player.dead: return
	FmodServer.play_one_shot_attached_with_params("event:/Sfx3D/Footsteps", player, {"TerrainType": player.last_ground_type})
