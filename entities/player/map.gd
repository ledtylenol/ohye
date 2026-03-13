extends Control
var map_node_scene: PackedScene = load("uid://dggq7soli18h0")

var levels: Dictionary[String, MapNode] = {}

@export var dash_curve: Curve
@export var push_over_dist_curve: Curve
@export var head_angle = PI/6
@export var head_length := 10.0
@export var timer: Timer
@export var min_dist := 0.1
var queue: Array[MapNode] = []
var queue_finished := false

signal map_node_spawned


func setup() -> void:
	queue.clear()
	levels.clear()
	for child in get_children():
		if child is not Timer: child.queue_free()
	if not LevelHandler.are_files_loaded:
		print('waiting for file load')
		await LevelHandler.files_loaded
	var had_levels := false
	for i in Global.game_stats.levels:
		print(i)
		var th := randf_range(0, TAU)
		var r := randf_range(30, 120)
		var node: MapNode = map_node_scene.instantiate()
		node.text = i
		node.startpos = size/2.0 + Vector2(cos(th), sin(th)) * r
		th = randf_range(0, TAU)
		r = randf_range(50, 300)
		node.startvel = Vector2(cos(th), sin(th)) * r
		queue.push_back(node)
		levels[node.text] = node
		had_levels = true
	if had_levels:
		timer.timeout.connect(pop_nodes)
		timer.start()
	else:
		timer.stop()

func pop_nodes() -> void:
	var i := 0
	var n = 1
	while i < n and not queue.is_empty():
		var node = queue.pop_back()
		i += 1
		add_child(node)
		map_node_spawned.emit()
	if queue.is_empty():
		timer.stop()
	else:
		timer.start(randf_range(0.01, 0.2) / n)
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_map"):
		if visible:
			visible = false
			if Global.current_menu == self:
				Global.current_menu = null
			timer.stop()
		elif not Global.current_menu:
			visible = true
			setup()
			Global.current_menu = self
			timer.start(randf_range(0.05, 0.8))
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not visible: return
	for node: MapNode in levels.values():
		for other_node: MapNode in levels.values():
			if node == other_node: continue
			if node.position.distance_to(other_node.position) / (size.length() * 0.5) < min_dist:
				var dir := node.position.direction_to(other_node.position)
				node.vel -= dir * 800.0 * delta
		if (node.position.distance_to(get_local_mouse_position())  / (size.length()))< min_dist:
			var dir := node.position.direction_to(get_local_mouse_position())
			node.vel -= dir * 1800.0 * delta
		var center_dir := node.position.direction_to(size / 2.0)
		var center_dist := node.position.distance_to(size * 0.5) / ((size).length() * 0.5)
		
		node.vel += center_dir * push_over_dist_curve.sample(center_dist)
func _draw() -> void:
	for edge_name in Global.game_stats.edges:
		var edge := LevelHandler.edge_dict[edge_name]
		if not levels[edge.from].is_node_ready() or not levels[edge.to].is_node_ready():
			continue
		var map_node1: MapNode = levels[edge.from]
		var map_node2: MapNode = levels[edge.to]
		var radius := map_node1.outer_radius * map_node1.scale.x
		var p1 := map_node1.position
		var p2 := map_node1.position.lerp(map_node2.position, minf(map_node1.ratio,map_node2.ratio))

		var dir := p2.direction_to(p1)
		var head := dir * head_length
		var dir_radius := dir * (radius + map_node1.outer_width)
		if (p1- dir_radius).distance_squared_to(p2 + dir_radius) <= 2 * radius * radius:
			continue
		var points: PackedVector2Array = [
			p2 + dir_radius, 
			p2 + head.rotated(head_angle) + dir_radius, 
			p2 + head.rotated(-head_angle) + dir_radius
		]
		draw_colored_polygon(points, Color.ANTIQUE_WHITE)
		if edge.chance != 1.0:
			var dash := dash_curve.sample(edge.chance)
			draw_dashed_line(p1 - dir_radius, p2 + dir_radius, Color.ANTIQUE_WHITE, 2.0, dash, false)
		else:
			draw_line(p1 - dir_radius, p2 + dir_radius, Color.ANTIQUE_WHITE, 2.0)
