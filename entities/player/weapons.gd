extends Node3D

@export var cooldown: = 0.2
@export var player: Player
var real_cooldown: = 0.0
var children: Array[WeaponNode]:
	get:
		return M.nightmare_getter(self, WeaponNode)
func _ready() -> void :
	for c in children:
		player.teleport.connect(c.reset_sods)
func _process(delta: float) -> void :
	if Global.player.dead:
		visible = false
		return
	real_cooldown = maxf(0.0, real_cooldown - delta)
	if Input.is_action_pressed("shoot") and real_cooldown <= 0.0:
		var ch: = children
		ch.shuffle()
		for child in ch:
			if child.heat == 0:
				child.shoot()
				real_cooldown = cooldown
			await get_tree().create_timer(0.5 * cooldown / children.size()).timeout
