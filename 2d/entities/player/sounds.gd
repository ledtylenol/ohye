extends Node2D
@export var hit_event: FmodEventEmitter2D
@export var charge_event: FmodEventEmitter2D
@export var dash_event: FmodEventEmitter2D
@export var player: Player2D
func _ready() -> void:
	player.p_col_started.connect(on_player_collision)
	player.state_changed.connect(dash_collide)
func _physics_process(delta: float) -> void:
	hit_event.set_parameter("State", player.state)
	charge_event.set_parameter("Charge", player.focus)
	charge_event.volume = player.focus ** 2
func on_player_collision(_s, _c):
	hit_event.play()
	print('god')
func dash_collide(_o,state):
	if state != player.DASHING: return
	dash_event.play()
