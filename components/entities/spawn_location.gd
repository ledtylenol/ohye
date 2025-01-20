extends Marker3D
class_name SpawnLocation

@export var rotation_random := Vector3.ZERO
@export var position_random := Vector3.ZERO

@export var pool: Array[RandomSpawn]
var randoms := [0.0, 0.0, 0.0]
var item: Node3D

func _ready() -> void:
	var cap := 0
	if not pool.is_empty():
		pool.sort_custom(weightasc)
		for thing in pool:
			cap += thing.weight
	var rand := randi() % cap
	for thing in pool:
		rand -= thing.weight
		if rand < 0:
			if thing.thing:
				item = load(thing.thing).instantiate()
			break
	for i in range(3):
		rotation_random[i] = rotation_random[i] * randf()
		position_random[i] = position_random[i] * randf()
	if item:
		add_child(item)
		item.position = position_random
		item.rotation = rotation_random
func weightasc(a: RandomSpawn, b: RandomSpawn) -> bool:
	return a.weight < b.weight
