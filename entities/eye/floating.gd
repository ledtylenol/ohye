extends State
class_name Floating

@export var schizo: EyeSchizo
@export var health_component: HealthComponent
var look_time := 0.0
var active := true
func on_enter() -> void:
	look_time = 1.0
func physics_tick(dt: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		active = false
	if Input.is_action_just_pressed("secondary_attack"):
		active = true
	if active:
		var space := target.get_world_3d().direct_space_state
		var query := PhysicsRayQueryParameters3D\
		.create(Global.player.camera.global_position,\
		 Global.player.camera.global_position - Global.player.camera.global_basis.z * 100, 1)
		var res := space.intersect_ray(query)
		if not res.is_empty():
			target.look_at_pos(res["position"],dt)
		else:
			target.look_at_pos(Global.player.global_position, dt)
		target.target_pos = Global.player.camera.global_position + Vector3.UP * 10
	
	if schizo.player_in_sight:
		transitioned.emit("floating","teleport")
		return
