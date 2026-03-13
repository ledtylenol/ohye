extends Entity
class_name Floater

@onready var schizophrenia: Schizophrenia = $Schizophrenia
@onready var player := Global.player

@onready var interact_component: InteractComponent = $InteractComponent
@onready var health_component: HealthComponent = $HealthComponent

var dragging := false
var drag_dist := 0.0
var target_pos := Vector3.ZERO
var cancellable := true
func _ready() -> void:
	schizophrenia.player_entered.connect(on_enter)
	schizophrenia.player_exited.connect(on_exit)
	interact_component.interact_start.connect(on_interact_start)
	health_component.died.connect(queue_free)
func _physics_process(delta: float) -> void:
	if schizophrenia.in_sight:
		var query := PhysicsRayQueryParameters3D.create(player.global_position, -player.camera.global_basis.z * 770, 1 | 8, [player.get_rid()])
		var space := get_world_3d().direct_space_state
		var res := space.intersect_ray(query)
		if res and res["collider"] == self:
			interact_component.global_position = player.global_position.move_toward(global_position, 2.0)
		else:
			interact_component.global_position = global_position
	if dragging:
		target_pos = player.global_position - player.camera.global_basis.z * max(drag_dist, 4)
		velocity = velocity.move_toward(global_position.direction_to(target_pos) * 300, 40 * delta)
	else:
		velocity = velocity.move_toward(Vector3.ZERO, 20 * delta)
	var col := move_and_collide(velocity * delta)
	if col:
		var dist := velocity.length()
		health_component.current_health -= int(dist / 20)
		print(health_component.current_health)
		velocity = velocity.bounce(col.get_normal())
func on_enter() -> void:
	interact_component.set_deferred("monitorable", true)

func on_exit() -> void:
	interact_component.set_deferred("monitorable", false)
	pass

func on_interact_start() -> void:
	drag_dist = global_position.distance_to(player.global_position)
	dragging = true
	pass

func _unhandled_input(event: InputEvent) -> void:
	if   event.is_released() and event.is_action("interact"):
		dragging = false
		print(dragging)
