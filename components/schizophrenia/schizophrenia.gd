extends VisibleOnScreenNotifier3D
class_name Schizophrenia

@onready var enabled := is_on_screen()

@export var vision_points: Array[Node3D]
@onready var player := Global.player
@export var parent: VisualInstance3D

var children: Array[SchizophreniaComponent]:
	get:
		#return Array(get_children()\
		#.filter(func(c): return c is SchizophreniaComponent),\
		#TYPE_OBJECT,\
		#(SchizophreniaComponent as Script)\
		#.get_instance_base_type(),\
		 #SchizophreniaComponent)
		return M.nightmare_getter(self, SchizophreniaComponent)
var in_sight := false:
	set(value):
		if value and not in_sight:
			for child in children:
				child.on_visible()
			player_entered.emit()
		elif not value and in_sight:
			for child in children:
				child.on_hidden()
			player_exited.emit()
		in_sight = value


signal player_exited
signal player_entered
func _ready() -> void:
	screen_entered.connect(enable)
	screen_exited.connect(disable)
	if vision_points.is_empty():
		vision_points.append(parent)
	aabb = parent.get_aabb()
func _physics_process(_delta: float) -> void:
	if not enabled or not player: in_sight = false;return
	var space := get_world_3d().direct_space_state
	@warning_ignore("shadowed_variable")
	var parent := get_parent()
	var was_in_sight := false
	for point in vision_points:
		var arr = [player.get_rid()] if not parent is CollisionObject3D else [player.get_rid(), parent.get_rid()]
		var query := PhysicsRayQueryParameters3D.create(point.global_position, player.camera.global_position, 1, arr)
		var res := space.intersect_ray(query)
		if res.is_empty():
			in_sight = true
			was_in_sight = true
			break

	if not was_in_sight:
		in_sight = false

func _process(delta: float) -> void:
	if in_sight:
		for child in children:
			child.visible_tick(delta)
	else:
		for child in children:
			child.hidden_tick(delta)
		
func enable() -> void:
	enabled = true

func disable() -> void:
	enabled = false
