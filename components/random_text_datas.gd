extends Resource
class_name RandomTextDatas

@export var pool: Array[RandomTextData]

func get_text() -> String:
	var cap := 0
	if not pool.is_empty():
		pool.sort_custom(weightasc)
		for thing in pool:
			cap += thing.weight
	var rand := randi() % cap
	for thing: RandomTextData in pool:
		rand -= thing.weight
		if rand < 0:
			return thing.text
	return pool[0].text
func weightasc(a: RandomSpawn, b: RandomSpawn) -> bool:
	return a.weight < b.weight
